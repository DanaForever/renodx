/*
 * Copyright (C) 2023 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#include <include/reshade_api_format.hpp>
#define ImTextureID ImU64

// #define DEBUG_LEVEL_0
#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <embed/shaders.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"



namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    // Uber_Post
    CustomShaderEntry(0xEFA663EF),  // color
    CustomShaderEntry(0x488CE77A),  // color
    CustomShaderEntry(0x5957375C),  // color
    CustomShaderEntry(0xA7CEF703),  // light2
    CustomShaderEntry(0x2E081582),  // ui
    CustomShaderEntry(0x05F21D2B),  // ui2
    CustomShaderEntry(0x3934D0EB),  // ui
    
   
};

ShaderInjectData shader_injection;
const std::string build_date = __DATE__;
const std::string build_time = __TIME__;

float current_settings_mode = 0;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &current_settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Settings Mode",
        .labels = {"Simple", "Intermediate", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"Vanilla", "PsychoV"},
        .parse = [](float value) { return value ; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits",
        .min = 48.f,
        .max = 4000.f,
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
        // .is_visible = []() { return false; },
    },
    
    new renodx::utils::settings::Setting{
        .key = "ToneMapGammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Gamma Correction",
        .section = "Tone Mapping",
        .tooltip = "Emulates a display EOTF.",
        .labels = {"Off", "2.2", "BT.1886"},
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueCorrectionMethod",
    //     .binding = &shader_injection.tone_map_hue_correction_method,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Hue Correction Method",
    //     .section = "Hue Correction",
    //     .tooltip = "Selects tonemapping method for hue correction",
    //     .labels = {"Reinhard", "NeutralSDR", "DICE", "Uncharted2", "ACES", "Clipping"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    //     // .is_visible = []() { return shader_injection.tone_map_type >= 1 && current_settings_mode >= 2.f; },
    //     // .is_visible = []() { return false; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueProcessor",
    //     .binding = &shader_injection.tone_map_hue_processor,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 1.f,
    //     .label = "Hue Processor",
    //     .section = "Hue Correction",
    //     .tooltip = "Selects hue processor",
    //     .labels = {"OKLab", "ICtCp", "darkTable UCS"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .is_visible = []() { return current_settings_mode >= 1; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueShift",
    //     .binding = &shader_injection.tone_map_hue_shift,
    //     .default_value = 50.f,
    //     .label = "Hue Shift",
    //     .section = "Hue Correction",
    //     .tooltip = "Hue-shift emulation strength.",
    //     .min = 0.f,
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value * 0.01f; },
    //     .is_visible = []() { return current_settings_mode >= 1; },
    // },
    

    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueShiftMethod",
    //     .binding = &shader_injection.tone_map_hue_correction_method,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Hue Shift Method",
    //     .section = "Tone Mapping",
    //     .tooltip = "Hue Shift Method",
    //     .labels = {
    //         "HUE_SHIFT_METHOD_CLIP",
    //         "HUE_SHIFT_METHOD_SDR_MODIFIED",
    //         "HUE_SHIFT_METHOD_AP1_ROLL_OFF",
    //         "HUE_SHIFT_METHOD_ACES_FITTED_BT709",
    //         "HUE_SHIFT_METHOD_ACES_FITTED_AP1",
    //     },
    //     .is_visible = []() {
    //       return settings[0]->GetValue() >= 1;
    //     },
    // },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 0; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ColorGradeHighlightSaturation",
    //     .binding = &shader_injection.tone_map_highlight_saturation,
    //     .default_value = 50.f,
    //     .label = "Highlight Saturation",
    //     .section = "Color Grading",
    //     .tooltip = "Adds or removes highlight color.",
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value * 0.02f; },
    //     .is_visible = []() { return current_settings_mode >= 1; },
    // },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Adds highlight desaturation due to overexposure.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return (value * 0.01f); },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ColorGradeFlare",
    //     .binding = &shader_injection.tone_map_flare,
    //     .default_value = 0.f,
    //     .label = "Flare",
    //     .section = "Color Grading",
    //     .tooltip = "Flare/Glare Compensation",
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value * 0.01f; },
    //     .is_visible = []() { return current_settings_mode >= 1; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ColorGradeStrength",
    //     .binding = &shader_injection.color_grade_strength,
    //     .value_type = renodx::utils::settings::SettingValueType::FLOAT,
    //     .default_value = 100.f,
    //     .label = "Grading Strength",
    //     .section = "Color Grading",
    //     .tooltip = "Chooses strength of original color grading.",
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value * 0.01f; },
    //     .is_visible = []() { return settings[0]->GetValue() >= 1; },
    //     // .is_visible = []() { return false; },
    // },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeColorSpace",
        .binding = &shader_injection.swap_chain_custom_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Color Space",
        .section = "Color Grading",
        .tooltip = "Selects output color space"
                   "\nUS Modern for BT.709 D65."
                   "\nJPN Modern for BT.709 D93.",
        .labels = {
            "US Modern",
            "JPN Modern",
        },
        .is_visible = []() {
          return settings[0]->GetValue() >= 1;
        },
    },
};

void OnPresetOff() {
//   renodx::utils::settings::UpdateSetting("ToneMapType", 0.f);
//   renodx::utils::settings::UpdateSetting("ToneMapPeakNits", 203.f);
//   renodx::utils::settings::UpdateSetting("ToneMapGameNits", 203.f);
//   renodx::utils::settings::UpdateSetting("ToneMapUINits", 203.f);
//   renodx::utils::settings::UpdateSetting("ToneMapGammaCorrection", 0.f);
//   renodx::utils::settings::UpdateSetting("ToneMapHueCorrection", 0.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeExposure", 1.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeHighlights", 50.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeShadows", 50.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeContrast", 50.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeSaturation", 50.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeBlowout", 0.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeLUTStrength", 100.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeLUTScaling", 0.f);
//   renodx::utils::settings::UpdateSetting("ColorGradeColorSpace", 0.f);
//   renodx::utils::settings::UpdateSetting("ToneMapHueShiftMethod", 0.f);
//   renodx::utils::settings::UpdateSetting("DisplayMapType", 0.f);
}

// bool fired_on_init_swapchain = false;

// void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
//   if (fired_on_init_swapchain) return;
//   fired_on_init_swapchain = true;
//   auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
//   if (peak.has_value()) {
//     settings[1]->default_value = peak.value();
//     settings[1]->can_reset = true;
//   }
// }

}  // namespace

// NOLINTBEGIN(readability-identifier-naming)


extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX YS8";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for YS8";
bool use_resource_view_cloning = true;

// NOLINTEND(readability-identifier-naming)
float screen_width = GetSystemMetrics(SM_CXSCREEN);
float screen_height = GetSystemMetrics(SM_CYSCREEN);

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
    
  switch (fdw_reason) {
    
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;
      
      renodx::mods::shader::force_pipeline_cloning = true;
      renodx::mods::swapchain::force_borderless = false;
      renodx::mods::swapchain::prevent_full_screen = false;
      renodx::mods::shader::allow_multiple_push_constants = true;
      renodx::mods::swapchain::use_resource_cloning = true;
      renodx::mods::swapchain::swapchain_proxy_compatibility_mode = true;
      renodx::mods::swapchain::swapchain_proxy_revert_state = true;
      renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
      renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;
      

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8g8b8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
        //   .ignore_size = true,
          .use_resource_view_cloning = use_resource_view_cloning,
          .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          .usage_include = reshade::api::resource_usage::render_target,

      });


      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::b8g8r8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
          //   .ignore_size = true,
          .use_resource_view_cloning = use_resource_view_cloning,
          .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          .usage_include = reshade::api::resource_usage::render_target,
      });

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::b8g8r8x8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
        //   .ignore_size = true,
          .use_resource_view_cloning = use_resource_view_cloning,
          .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          .usage_include = reshade::api::resource_usage::render_target,
      });


    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::r10g10b10a2_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //       .ignore_size = true,
    //     //   .use_resource_view_cloning = use_resource_view_cloning,
    //     //   .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
    //     //   .usage_include = reshade::api::resource_usage::render_target,
    //   });
      
    
      // special condition?
    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::b8g8r8x8_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //     //   .ignore_size = true,
    //       .use_resource_view_cloning = use_resource_view_cloning,
    //       .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
    //   });

      /// r16_unorm
    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::r16_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //       .ignore_size = true,
    //       .use_resource_view_cloning = use_resource_view_cloning,
    //   });

    {
            auto* setting = new renodx::utils::settings::Setting{
                .key = "SwapChainEncoding",
                .binding = &shader_injection.hdr_format,
                .value_type = renodx::utils::settings::SettingValueType::INTEGER,
                .default_value = 0.f,
                .label = "HDR Format",
                .section = "Display Output",
                .tooltip = "Sets the HDR format (HDR10 is compatible with Smooth Motion)",
                .labels = {"HDR10", "scRGB (default)"},
                .is_enabled = []() { return true; },
                .is_global = true,
                .is_visible = []() { return current_settings_mode >= 2; },
            };

            renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, setting);
            bool is_hdr10 = setting->GetValue() == 0;
            is_hdr10 = false; // force scRGB for now, since HDR10 seems to cause issues with swap chain resizing in this game
            renodx::mods::swapchain::SetUseHDR10(is_hdr10);
            renodx::mods::swapchain::use_resize_buffer = false;
            shader_injection.swap_chain_encoding = (is_hdr10 ? 4.f : 5.f);
            shader_injection.swap_chain_encoding_color_space = is_hdr10 ? 1.f : 0.f;
            settings.push_back(setting);
        }
      
      break;
      
    case DLL_PROCESS_DETACH:
      reshade::unregister_addon(h_module);
      break;
  }
  
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}