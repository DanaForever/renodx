/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/date.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    
    CustomShaderEntry(0x5D15CFEE),  // output
    CustomShaderEntry(0x987DC89C),  // ui
    CustomShaderEntry(0xA08DCDDC),  // main menu tonemapping
    CustomShaderEntry(0x5A21461F),  // tonemapping 
};
ShaderInjectData shader_injection;

float current_settings_mode = 0;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &current_settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .labels = {"Simple", "Intermediate", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .can_reset = true,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"Vanilla", "None", "ACES", "RenoDRT"},
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
    },
    new renodx::utils::settings::Setting{
        .key = "GammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Gamma Correction",
        .section = "Tone Mapping",
        .tooltip = "Emulates a display EOTF.",
        .labels = {"Off", "2.2", "BT.1886"},
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapScaling",
        .binding = &shader_injection.tone_map_per_channel,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Scaling",
        .section = "Tone Mapping",
        .tooltip = "Luminance scales colors consistently while per-channel saturates and blows out sooner",
        .labels = {"Luminance", "Per Channel"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapWorkingColorSpace",
        .binding = &shader_injection.tone_map_working_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Working Color Space",
        .section = "Tone Mapping",
        .labels = {"BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueProcessor",
        .binding = &shader_injection.tone_map_hue_processor,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Hue Processor",
        .section = "Tone Mapping",
        .tooltip = "Selects hue processor",
        .labels = {"OKLab", "ICtCp", "darkTable UCS"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueCorrection",
        .binding = &shader_injection.tone_map_hue_correction,
        .default_value = 100.f,
        .label = "Hue Correction",
        .section = "Tone Mapping",
        .tooltip = "Hue retention strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 50.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Hue-shift emulation strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapClampColorSpace",
        .binding = &shader_injection.tone_map_clamp_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Clamp Color Space",
        .section = "Tone Mapping",
        .tooltip = "Hue-shift emulation strength.",
        .labels = {"None", "BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapClampPeak",
        .binding = &shader_injection.tone_map_clamp_peak,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Clamp Peak",
        .section = "Tone Mapping",
        .tooltip = "Hue-shift emulation strength.",
        .labels = {"None", "BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUpradeType",
        .binding = &shader_injection.custom_tonemap_upgrade_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Grading Application",
        .section = "Highlight Saturation Restoration",
        .tooltip = "How the graded image gets upgraded",
        .labels = {"Luminance", "Per Channel+"},
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUpradeStrength",
        .binding = &shader_injection.custom_tonemap_upgrade_strength,
        .default_value = 50.f,
        .label = "Saturation Strength",
        .section = "Highlight Saturation Restoration",
        .is_enabled = []() { return shader_injection.custom_tonemap_upgrade_type == 1.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUpradeHueCorr",
        .binding = &shader_injection.custom_tonemap_upgrade_huecorr,
        .default_value = 100.f,
        .label = "Hue Correction",
        .section = "Highlight Saturation Restoration",
        .is_enabled = []() { return shader_injection.custom_tonemap_upgrade_type == 1.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "DisplayMapType",
        .binding = &shader_injection.custom_display_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Display Map Type",
        .section = "Highlight Saturation Restoration",
        .tooltip = "Sets the display mapper used",
        .labels = {"None", "DICE", "Frostbite", "RenoDRT NeutralSDR", "ToneMapMaxCLL"},
        .is_visible = []() { return settings[0]->GetValue() >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowoutRestoration",
        .binding = &shader_injection.color_grade_per_channel_blowout_restoration,
        .default_value = 0.f,
        .label = "Per Channel Blowout Restoration",
        .section = "Per channel scene-grading",
        .tooltip = "Restores color from blowout from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1 && shader_injection.custom_tonemap_upgrade_type == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeChrominanceCorrection",
        .binding = &shader_injection.color_grade_per_channel_chrominance_correction,
        .default_value = 0.f,
        .label = "Per Channel Chrominance Correction",
        .section = "Per channel scene-grading",
        .tooltip = "Corrects unbalanced chrominance (?) from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
       .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1 && shader_injection.custom_tonemap_upgrade_type == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHueCorrection",
        .binding = &shader_injection.color_grade_per_channel_hue_correction,
        .default_value = 0.f,
        .label = "Per Channel Hue Correction",
        .section = "Per channel scene-grading",
        .tooltip = "Corrects per-channel hue shifts from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1 && shader_injection.custom_tonemap_upgrade_type == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },

    
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .tooltip = "Adds or removes highlight color.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Controls highlight desaturation due to overexposure.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .tooltip = "Flare/Glare Compensation",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 3; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeScene",
        .binding = &shader_injection.color_grade_strength,
        .default_value = 100.f,
        .label = "Scene Grading",
        .section = "Color Grading",
        .tooltip = "Scene grading as applied by the game",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "SwapChainCustomColorSpace",
        .binding = &shader_injection.swap_chain_custom_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Custom Color Space",
        .section = "Display Output",
        .tooltip = "Selects output color space"
                   "\nUS Modern for BT.709 D65."
                   "\nJPN Modern for BT.709 D93."
                   "\nUS CRT for BT.601 (NTSC-U)."
                   "\nJPN CRT for BT.601 ARIB-TR-B9 D93 (NTSC-J)."
                   "\nDefault: US CRT",
        .labels = {
            "US Modern",
            "JPN Modern",
            "US CRT",
            "JPN CRT",
        },
        .is_visible = []() { return settings[0]->GetValue() >= 1; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "IntermediateDecoding",
    //     .binding = &shader_injection.intermediate_encoding,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Intermediate Encoding",
    //     .section = "Display Output",
    //     .labels = {"Auto", "None", "SRGB", "2.2", "2.4"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) {
    //         if (value == 0) return shader_injection.gamma_correction + 1.f;
    //         return value - 1.f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "SwapChainDecoding",
    //     .binding = &shader_injection.swap_chain_decoding,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Swapchain Decoding",
    //     .section = "Display Output",
    //     .labels = {"Auto", "None", "SRGB", "2.2", "2.4"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) {
    //         if (value == 0) return shader_injection.intermediate_encoding;
    //         return value - 1.f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "SwapChainGammaCorrection",
    //     .binding = &shader_injection.swap_chain_gamma_correction,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Gamma Correction",
    //     .section = "Display Output",
    //     .labels = {"None", "2.2", "2.4"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "SwapChainClampColorSpace",
    //     .binding = &shader_injection.swap_chain_clamp_color_space,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 2.f,
    //     .label = "Clamp Color Space",
    //     .section = "Display Output",
    //     .labels = {"None", "BT709", "BT2020", "AP1"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value - 1.f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },

    new renodx::utils::settings::Setting{
        .key = "fxSharpening",
        .binding = &shader_injection.rcas,
        .default_value = 0.f,
        .label = "Sharpening",
        .section = "Effects",
        .max = 100.f,
        .parse = [](float value) { return value == 0 ? 0.f : exp2(-(1.f - (value * 0.01f))); },
        .is_visible = []() { return settings[0]->GetValue() >= 1; },
    },

    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Discord",
    //     .section = "Links",
    //     .group = "button-line-2",
    //     .tint = 0x5865F2,
    //     .on_change = []() {
    //       renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP");
    //     },
    // },
    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "More Mods",
    //     .section = "Links",
    //     .group = "button-line-2",
    //     .tint = 0x2B3137,
    //     .on_change = []() {
    //       renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx/wiki/Mods");
    //     },
    // },
    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Github",
    //     .section = "Links",
    //     .group = "button-line-2",
    //     .tint = 0x2B3137,
    //     .on_change = []() {
    //       renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx");
    //     },
    // },
    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Musa's Ko-Fi",
    //     .section = "Links",
    //     .group = "button-line-3",
    //     .tint = 0xFF5A16,
    //     .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/musaqh"); },
    // },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
};


void OnPresetOff() {
  //   renodx::utils::settings::UpdateSetting("toneMapType", 0.f);
  //   renodx::utils::settings::UpdateSetting("toneMapPeakNits", 203.f);
  //   renodx::utils::settings::UpdateSetting("toneMapGameNits", 203.f);
  //   renodx::utils::settings::UpdateSetting("toneMapUINits", 203.f);
  //   renodx::utils::settings::UpdateSetting("toneMapGammaCorrection", 0);
  //   renodx::utils::settings::UpdateSetting("colorGradeExposure", 1.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeHighlights", 50.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeShadows", 50.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeContrast", 50.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeSaturation", 50.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeLUTStrength", 100.f);
  //   renodx::utils::settings::UpdateSetting("colorGradeLUTScaling", 0.f);
}

const auto UPGRADE_TYPE_NONE = 0.f;
const auto UPGRADE_TYPE_OUTPUT_SIZE = 1.f;
const auto UPGRADE_TYPE_OUTPUT_RATIO = 2.f;
const auto UPGRADE_TYPE_ANY = 3.f;

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX Warriors Orochi 4";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

    //   if (!initialized) {
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::swapchain::force_borderless = true;     // needed for stability
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::swapchain_proxy_compatibility_mode = true;
        renodx::mods::swapchain::swap_chain_proxy_shaders = {
            {
                reshade::api::device_api::d3d11,
                {
                    .vertex_shader = __swap_chain_proxy_vertex_shader_dx11,
                    .pixel_shader = __swap_chain_proxy_pixel_shader_dx11,
                },
            },
            {
                reshade::api::device_api::d3d12,
                {
                    .vertex_shader = __swap_chain_proxy_vertex_shader_dx12,
                    .pixel_shader = __swap_chain_proxy_pixel_shader_dx12,
                },
            },
        };

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

        // {
        //   auto* setting = new renodx::utils::settings::Setting{
        //       .key = "SwapChainForceBorderless",
        //       .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //       .default_value = 0.f,
        //       .label = "Force Borderless",
        //       .section = "Display Output",
        //       .tooltip = "Forces fullscreen to be borderless for proper HDR",
        //       .labels = {
        //           "Disabled",
        //           "Enabled",
        //       },
        //       .on_change_value = [](float previous, float current) { renodx::mods::swapchain::force_borderless = (current == 1.f); },
        //       .is_global = true,
        //       .is_visible = []() { return current_settings_mode >= 2; },
        //   };
        //   renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, setting);
        //   renodx::mods::swapchain::force_borderless = (setting->GetValue() == 1.f);
        //   settings.push_back(setting);
        // }

        // {
        //   auto* setting = new renodx::utils::settings::Setting{
        //       .key = "SwapChainPreventFullscreen",
        //       .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //       .default_value = 0.f,
        //       .label = "Prevent Fullscreen",
        //       .section = "Display Output",
        //       .tooltip = "Prevent exclusive fullscreen for proper HDR",
        //       .labels = {
        //           "Disabled",
        //           "Enabled",
        //       },
        //       .on_change_value = [](float previous, float current) { renodx::mods::swapchain::prevent_full_screen = (current == 1.f); },
        //       .is_global = true,
        //       .is_visible = []() { return current_settings_mode >= 2; },
        //   };
        //   renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, setting);
        //   renodx::mods::swapchain::prevent_full_screen = (setting->GetValue() == 1.f);
        //   settings.push_back(setting);
        // }

        {
            bool is_hdr10 = false;
            renodx::mods::swapchain::SetUseHDR10(is_hdr10);
            renodx::mods::swapchain::use_resize_buffer = false;
        }


    //     initialized = true;
    //   }

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
