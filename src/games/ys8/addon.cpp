/*
 * Copyright (C) 2023 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

// #define DEBUG_LEVEL_0

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
        .labels = {"Vanilla", "Frostbite", "DICE", "RenoDRT"},
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
    new renodx::utils::settings::Setting{
        .key = "InverseToneMapExtraHDRSaturation",
        .binding = &shader_injection.inverse_tonemap_extra_hdr_saturation,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Gamut Expansion",
        .section = "Tone Mapping",
        .tooltip = "Generates HDR colors (BT.2020) from bright saturated SDR (BT.709) ones. Neutral at 0.",
        .min = 0.f,
        .max = 500.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueCorrectionMethod",
        .binding = &shader_injection.tone_map_hue_correction_method,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Hue Correction Method",
        .section = "Hue Correction",
        .tooltip = "Selects tonemapping method for hue correction",
        .labels = {"Reinhard", "NeutralSDR", "DICE", "Uncharted2", "ACES", "Clipping"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
        // .is_visible = []() { return shader_injection.tone_map_type >= 1 && current_settings_mode >= 2.f; },
        // .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueProcessor",
        .binding = &shader_injection.tone_map_hue_processor,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Hue Processor",
        .section = "Hue Correction",
        .tooltip = "Selects hue processor",
        .labels = {"OKLab", "ICtCp", "darkTable UCS"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 50.f,
        .label = "Hue Shift",
        .section = "Hue Correction",
        .tooltip = "Hue-shift emulation strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    

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
        .key = "ToneMapHueCorrection",
        .binding = &shader_injection.tone_map_hue_correction,
        .default_value = 100.f,
        .label = "Hue Correction",
        .section = "Hue Correction",
        .tooltip = "Hue retention strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapWorkingColorSpace",
        .binding = &shader_injection.tone_map_working_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Working Color Space",
        .section = "Color Space",
        .labels = {"BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 1; },
        // .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapClampColorSpace",
        .binding = &shader_injection.tone_map_clamp_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Clamp Color Space",
        .section = "Color Space",
        .tooltip = "Hue-shift emulation strength.",
        .labels = {"None", "BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "DICEToneMapType",
        .binding = &shader_injection.dice_tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .can_reset = true,
        .label = "DICE ToneMap Type",
        .section = "DICE Configuration",
        .tooltip = "Sets the DICE tone mapper type",
        .labels = {"Luminance RGB", "Luminance PQ", "Luminance PQ w/ Channel Correction", "Channel PQ"},
        .is_visible = []() { return current_settings_mode >= 2 && shader_injection.tone_map_type == 2.f ; },
    },
    new renodx::utils::settings::Setting{
        .key = "DICEShoulderStart",
        .binding = &shader_injection.dice_shoulder_start,
        .default_value = 33.f,
        .label = "DICE Shoulder Start",
        .section = "DICE Configuration",
        .tooltip = "Sets the DICE shoulder start.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2 && shader_injection.tone_map_type == 2.f ; },
    },
    new renodx::utils::settings::Setting{
        .key = "DICEDesaturation",
        .binding = &shader_injection.dice_desaturation,
        .default_value = 33.f,
        .label = "DICE Desaturation",
        .section = "DICE Configuration",
        .tooltip = "Sets the DICE desaturation.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2 && shader_injection.tone_map_type == 2.f ; },
    },
    new renodx::utils::settings::Setting{
        .key = "DICEDarkening",
        .binding = &shader_injection.dice_darkening,
        .default_value = 33.f,
        .label = "DICE Darkening",
        .section = "DICE Configuration",
        .tooltip = "Sets the DICE darkening.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 2 && shader_injection.tone_map_type == 2.f ; },
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
        .is_enabled = []() { return shader_injection.tone_map_type >= 1 && shader_injection.tone_map_type == 3.f; },
        .is_visible = []() { return shader_injection.tone_map_type >= 1 && shader_injection.tone_map_type == 3.f; },
    },
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
        .tooltip = "Adds highlight desaturation due to overexposure.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return (value * 0.01f); },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .tooltip = "Flare/Glare Compensation",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeStrength",
        .binding = &shader_injection.color_grade_strength,
        .value_type = renodx::utils::settings::SettingValueType::FLOAT,
        .default_value = 100.f,
        .label = "Grading Strength",
        .section = "Color Grading",
        .tooltip = "Chooses strength of original color grading.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return settings[0]->GetValue() >= 1; },
        .is_visible = []() { return false; },
    },
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
    //     .is_visible = []() {
    //       return settings[0]->GetValue() >= 1;
    //     },
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
    //     .is_visible = []() {
    //       return settings[0]->GetValue() >= 1;
    //     },
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
    //     .is_visible = []() {
    //       return settings[0]->GetValue() >= 1;
    //     },
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
    //     .is_visible = []() {
    //       return settings[0]->GetValue() >= 1;
    //     },
    // },


    // Display map end

    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::TEXT,
    //     .label = " - THIS IS A BETA! The game has per-zone shaders, and I might've not added them all to the mod! - Please report bugs! \r\n \r\n - Join the HDR Den discord for help!",
    //     .section = "Instructions",
    // },

    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "HDR Den Discord",
    //     .section = "About",
    //     .group = "button-line-1",
    //     .tint = 0x5865F2,
    //     .on_change = []() {
    //       static const std::string obfuscated_link = std::string("start https://discord.gg/5WZX") + std::string("DpmbpP");
    //       system(obfuscated_link.c_str());
    //     },
    // },

    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Get more RenoDX mods!",
    //     .section = "About",
    //     .group = "button-line-1",
    //     .tint = 0x5865F2,
    //     .on_change = []() {
    //       system("start https://github.com/clshortfuse/renodx/wiki/Mods");
    //     },
    // },

    // new renodx::utils::settings::Setting{
    //     .key = "midGray",
    //     .binding = &shader_injection.midGray,
    //     .default_value = 0.18f,
    //     .label = "Midgray",
    //     .section = "DEBUG",
    //     .max = 2.f,
    //     .format = "%.2f",
    //     .is_enabled = []() { return shader_injection.toneMapType == 3; },
    //     .is_visible = []() { return settings[0]->GetValue() >= 1; },
    // },

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
    //   renodx::mods::swapchain::swapchain_proxy_compatibility_mode = true;
    //   renodx::mods::swapchain::swapchain_proxy_revert_state = true;
    //   renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
    //   renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;
      

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8g8b8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
        //   .ignore_size = true,
          .use_resource_view_cloning = use_resource_view_cloning,
          .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
      });


      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::b8g8r8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
          .ignore_size = true,
          .use_resource_view_cloning = use_resource_view_cloning,
      });
      
    
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