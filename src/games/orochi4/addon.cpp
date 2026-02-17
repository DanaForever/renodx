/*
 * Copyright (C) 2023 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <atomic>

#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

ShaderInjectData shader_injection;

std::atomic_uint64_t g_current_uav0 = 0;

bool OnToneMapDraw(reshade::api::command_list* cmd_list) {
  reshade::api::resource_view current_uav0 = {g_current_uav0};
  auto* resource_view_info = renodx::utils::resource::GetResourceViewInfo(current_uav0);
  if (resource_view_info->resource_info == nullptr) return true;
  if (resource_view_info->resource_info->clone_enabled) return true;
  resource_view_info->resource_info->clone_enabled = true;
  renodx::mods::swapchain::FlushDescriptors(cmd_list);  // Not implemented yet, will fix next draw
  return true;
}

renodx::mods::shader::CustomShaders custom_shaders = {
    
    CustomShaderEntry(0x5D15CFEE),  // output
    CustomShaderEntry(0x987DC89C),  // ui
    CustomShaderEntry(0xA08DCDDC),  // main menu tonemapping
    CustomShaderEntry(0x5A21461F),  // tonemapping 
};

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"SDR", "None", "Hermite Spline", "Neutwo"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% white in nits",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUINits",
        .binding = &shader_injection.graphics_white_nits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the brightness of UI and HUD elements in nits",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Gamma Correction",
        .section = "Tone Mapping",
        .tooltip = "Emulates a 2.2 EOTF (use with HDR or sRGB)",
        .labels = {"Off", "2.2", "BT.1886"}
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapStrategy",
    //     .binding = &shader_injection.custom_tone_map_strategy,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 1.f,
    //     .label = "Tone Map Strategy",
    //     .section = "Tone Mapping",
    //     .tooltip = "Choose strategy how to process untonemapped render with the original output.",
    //     .labels = {"Upgrade", "Extrapolate"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 3.f; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapScaling",
    //     .binding = &shader_injection.tone_map_per_channel,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Scaling",
    //     .section = "Tone Mapping",
    //     .tooltip = "Luminance scales colors consistently while per-channel saturates and blows out sooner",
    //     .labels = {"Luminance", "Per Channel"},
    //     .is_enabled = []() { return shader_injection.tone_map_type == 3.f; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueCorrection",
    //     .binding = &shader_injection.tone_map_hue_correction,
    //     .default_value = 100.f,
    //     .label = "Hue Correction",
    //     .section = "Tone Mapping",
    //     .tooltip = "Emulates hue shifting from the vanilla tonemapper",
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type == 3.f; },
    //     .parse = [](float value) { return value * 0.01f; },
    // },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_lms_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeVibrancy",
        .binding = &shader_injection.tone_map_lms_vibrancy,
        .default_value = 50.f,
        .label = "Vibrancy",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSetting("ToneMapType", 0.f);
  renodx::utils::settings::UpdateSetting("ToneMapPeakNits", 203.f);
  renodx::utils::settings::UpdateSetting("ToneMapGameNits", 203.f);
  renodx::utils::settings::UpdateSetting("ToneMapUINits", 203.f);
  renodx::utils::settings::UpdateSetting("ToneMapScaling", 1.f);
  renodx::utils::settings::UpdateSetting("ToneMapGammaCorrection", 0);
  renodx::utils::settings::UpdateSetting("ToneMapHueCorrection", 0.f);
  renodx::utils::settings::UpdateSetting("colorGradeExposure", 1.f);
  renodx::utils::settings::UpdateSetting("ColorGradeHighlights", 50.f);
  renodx::utils::settings::UpdateSetting("ColorGradeShadows", 50.f);
  renodx::utils::settings::UpdateSetting("ColorGradeContrast", 50.f);
  renodx::utils::settings::UpdateSetting("ColorGradeSaturation", 50.f);
  renodx::utils::settings::UpdateSetting("ColorGradeBlowout", 0.f);
  renodx::utils::settings::UpdateSetting("ColorGradeFlare", 0.f);
  renodx::utils::settings::UpdateSetting("ColorGradeLUTStrength", 100.f);
  renodx::utils::settings::UpdateSetting("ColorGradeLUTScaling", 0.f);
  renodx::utils::settings::UpdateSetting("ColorGradeLUTSampling", 0.f);
  renodx::utils::settings::UpdateSetting("FxBloom", 50.f);
  renodx::utils::settings::UpdateSetting("FxLensFlare", 50.f);
  renodx::utils::settings::UpdateSetting("FxVignette", 50.f);
  renodx::utils::settings::UpdateSetting("FxFilmGrainType", 0.f);
  renodx::utils::settings::UpdateSetting("FxFilmGrain", 50.f);
}

bool fired_on_init_swapchain = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (fired_on_init_swapchain) return;
  fired_on_init_swapchain = true;
  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (peak.has_value()) {
    settings[1]->default_value = peak.value();
    settings[1]->can_reset = true;
  }
}

// inline void OnPushDescriptors(
//     reshade::api::command_list* cmd_list,
//     reshade::api::shader_stage stages,
//     reshade::api::pipeline_layout layout,
//     uint32_t layout_param,
//     const reshade::api::descriptor_table_update& update) {
//   if (update.count == 0u) return;

//   for (uint32_t i = 0; i < update.count; i++) {
//     if (update.type != reshade::api::descriptor_type::texture_unordered_access_view) continue;
//     // Optimized: Use hardcoded Reshade DX11 psuedo-layout values
//     if (layout_param != 3) continue;          // Only UAVs
//     if ((update.binding + i) != 0) continue;  // Only for slot 0
//     g_current_uav0 = static_cast<const reshade::api::resource_view*>(update.descriptors)[i].handle;
//     return;
//   }
// }

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Batman: Arkham Knight";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

    //   shader_injection.custom_has_drawn_menu = 0;
    //   renodx::mods::shader::trace_unmodified_shaders = true;
        renodx::mods::swapchain::force_borderless = false;
        renodx::mods::swapchain::prevent_full_screen = true;
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;
      //  RGBA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r8g8b8a8_typeless,
            .new_format = reshade::api::format::r16g16b16a16_float,
            // .new_format = reshade::api::format::r32g32b32a32_typeless,
            .aspect_ratio = 16.f / 9.f
        });

        //  RGBA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r8g8b8a8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .aspect_ratio = 16.f / 9.f
        });

        //  RGBA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r8g8b8a8_unorm_srgb,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .aspect_ratio = 16.f / 9.f
        });

        //  BGRA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::b8g8r8a8_typeless,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .aspect_ratio = 16.f / 9.f
        });

        //  BGRA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::b8g8r8a8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .aspect_ratio = 16.f / 9.f
        });

        //  BGRA8_typeless
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::b8g8r8a8_unorm_srgb,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .aspect_ratio = 16.f / 9.f
        });

      renodx::mods::swapchain::use_resource_cloning = true;
      renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
      renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    //   reshade::register_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
    //   reshade::unregister_event<reshade::addon_event::push_descriptors>(OnPushDescriptors);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);

  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);

  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
