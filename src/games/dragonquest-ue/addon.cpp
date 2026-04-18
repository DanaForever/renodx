/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <include/reshade_api_format.hpp>
#include <include/reshade_api_resource.hpp>

#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/path.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/shader.hpp"
#include "../../utils/shader_dump.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"

namespace {

std::unordered_set<std::uint32_t> drawn_shaders;

renodx::mods::shader::CustomShaders custom_shaders = {__ALL_CUSTOM_SHADERS};

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
        .section = "Settings",
        .labels = {"Simple", "Intermediate", "Advanced"},
        .is_global = true,
    },

    

    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .can_reset = false,
        .label = "Tone Curve",
        .section = "Unreal Engine Settings",
        .tooltip = "Sets the tone mapper type",
        .labels = {"UE Legacy (Vanilla SDR)", "UE Filmic (SDR)", "UE Legacy Extended (HDR)", "UE Filmic Extended (HDR)", "UE ACES RRT-ODT (HDR)"},
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapBase",
        .binding = &shader_injection.filmic_curve,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Filmic Tonemapping Curve",
        .section = "Unreal Engine Settings",
        .tooltip = "Sets the tone mapper type for filmic",
        .labels = {"Default", "Uncharted", "High Precision", "Legacy", "ACES"},
        .is_enabled = []() { return shader_injection.tone_map_type == 1.f || shader_injection.tone_map_type == 3.f; },
        .is_visible = []() { return (shader_injection.tone_map_type == 1.f || shader_injection.tone_map_type == 3.f) && settings[0]->GetValue() >= 1; },
    },

    new renodx::utils::settings::Setting{
        .key = "UnrealExpandGamut",
        .binding = &shader_injection.unreal_expand_gamut,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Gamut Expansion",
        .section = "Unreal Engine Settings",
        .tooltip = "Expand bright saturated colors outside the BT709 gamut to fake wide gamut rendering.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "UnrealBlueCorrection",
        .binding = &shader_injection.unreal_blue_correction,
        .default_value = 100.f,
        .can_reset = false,
        .label = "Blue Correction",
        .section = "Unreal Engine Settings",
        .tooltip = "Blue Correction.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 1.f || shader_injection.tone_map_type == 3.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return (shader_injection.tone_map_type == 1.f || shader_injection.tone_map_type == 3.f)  && settings[0]->GetValue() >= 1; },
    },

    new renodx::utils::settings::Setting{
        .key = "UnrealOverrideBlackClip",
        .binding = &shader_injection.override_black_clip,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Override Black Clip",
        .section = "Unreal Engine Settings",
        .tooltip = "Disables black clip in the tonemapper. Prevents crushing when the black clip parameter is used",
        .is_enabled = []() { return shader_injection.tone_map_type == 3.f && settings[0]->GetValue() >= 1; },
    },

    new renodx::utils::settings::Setting{
        .key = "UnrealLUTGammaCorrection",
        .binding = &shader_injection.unreal_lut_gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "LUT Gamma Correction",
        .section = "Unreal Engine Settings",
        .tooltip = "The game encodes gamma instead of srgb by default in the LUT. Removing this behaviour deviates from SDR.",
        .labels = {"Off", "On"},
        // .is_visible = []() { return settings[0]->GetValue() >= 1; },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "UnrealLUTScaling",
        .binding = &shader_injection.custom_lut_scaling,
        .default_value = 100.f,
        .label = "LUT Scaling",
        .section = "Unreal Engine Settings",
        .tooltip = "Scales the color grade LUT to full range when size is clamped.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 1.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return shader_injection.tone_map_type > 1.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "DisplayMapType",
        .binding = &shader_injection.display_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Display Map Type",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type for filmic",
        .labels = {"Neutwo (Max Channel)", "PsychoV"},
        .is_enabled = []() { return shader_injection.tone_map_type > 1.f; },
        .is_visible = []() { return shader_injection.tone_map_type > 1.f; },
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
        .is_enabled = []() { return shader_injection.tone_map_type > 1.f; },
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
        // .is_visible = []() { return shader_injection.processing_path == 1.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapGammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "SDR EOTF Emulation",
        .section = "Tone Mapping",
        .tooltip = "Emulates a 2.2 EOTF",
        .labels = {"Off", "2.2", "BT.1886 (2.4)", "DQ11 S (1.5)"},
    },

    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueShiftSource",
    //     .binding = &shader_injection.tone_map_hue_shift_source,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Filmic Hue Shift source",
    //     .section = "Tone Mapping",
    //     .tooltip = "Hue-shifting source",
    //     .labels = {"Filmic SDR", "Legacy HDR"},
    //     .is_enabled = []() { return shader_injection.tone_map_type == 3.f; },
    //     .is_visible = []() { return shader_injection.tone_map_type == 3.f; },
    // },

    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 50.f,
        .label = "Filmic Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Hue-shift emulation strength (from SDR to HDR).",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 3.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return shader_injection.tone_map_type == 3.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "PsychoVAdaptationContrast",
        .binding = &shader_injection.psychov_adaptation_contrast,
        .default_value = 100.f,
        .label = "Adaptation Contrast",
        .section = "PsychoV Settings",
        .tooltip = "Controls highlight desaturation with CastleCSF.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.display_map_type == 1; },
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "PsychoVBleach",
        .binding = &shader_injection.psychov_bleach,
        .default_value = 50.f,
        .label = "Bleach",
        .section = "PsychoV Settings",
        .tooltip = "Controls highlight desaturation with CastleCSF.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.display_map_type == 1; },
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Custom Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Custom Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Custom Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Custom Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Custom Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Dechroma",
        .section = "Custom Color Grading",
        .tooltip = "Controls highlight desaturation with CastleCSF.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Custom Color Grading",
        .tooltip = "Adds or removes highlight color.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return false; },
    },

    

    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Custom Color Grading",
        .tooltip = "Flare/Glare Compensation",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return false; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeLUTStrength",
        .binding = &shader_injection.custom_lut_strength,
        .default_value = 100.f,
        .label = "LUT Strength",
        .section = "Color Grading LUTs",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeLUTGamutRestoration",
        .binding = &shader_injection.custom_lut_gamut_restoration,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "LUT Gamut Restoration",
        .section = "Color Grading LUTs",
        .tooltip = "Restores wide gamut colors clipped by the LUT",
        .is_enabled = []() { return shader_injection.tone_map_type != 0; },
        .is_visible = []() { return false; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "FixPostProcess",
    //     .binding = &shader_injection.fix_post_process,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 2.f,
    //     .label = "Fix Post Process",
    //     .section = "Color Grading",
    //     .tooltip = "Changes the color space post processing shaders are run in",
    //     .labels = {"Off (BT.2020 PQ)", "BT.709 sRGB Piecewise (most accurate)", "BT.2020 sRGB Piecewise (retains WCG)"},
    //     .is_enabled = []() { return shader_injection.tone_map_type != 0; },
    // },
    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::TEXT,
    //     .label = std::string("\nSliders in this section do not work with FSR Frame Generation enabled.\n\n"),
    //     .section = "Effects",
    // },

    // new renodx::utils::settings::Setting{
    //     .key = "FxGrainType",
    //     .binding = &shader_injection.custom_grain_type,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Grain Type",
    //     .section = "Effects",
    //     .tooltip = "Replaces vanilla film grain with perceptual",
    //     .labels = {"Vanilla", "Perceptual"},
    //     .is_enabled = []() { return shader_injection.tone_map_type != 0; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "FxGrainStrength",
    //     .binding = &shader_injection.custom_grain_strength,
    //     .default_value = 50.f,
    //     .label = "Film Grain",
    //     .section = "Effects",
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type != 0 && shader_injection.custom_grain_type != 0; },
    //     .parse = [](float value) { return value * 0.02f; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "FxSharpening",
    //     .binding = &shader_injection.custom_sharpness,
    //     .default_value = 0.f,
    //     .label = "Lilium RCAS Sharpening",
    //     .section = "Effects",
    //     .tooltip = "Adds RCAS, as implemented by Lilium for HDR.",
    //     .is_enabled = []() { return shader_injection.tone_map_type != 0; },
    //     .parse = [](float value) { return value == 0 ? 0.f : exp2(-(1.f - (value * 0.01f))); },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "UIGammaCorrection",
    //     .binding = &shader_injection.gamma_correction_ui,
    //     .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
    //     .default_value = 1.f,
    //     .label = "UI SDR EOTF Emulation",
    //     .section = "Other",
    //     .tooltip = "Emulates a 2.2 EOTF for the UI",
    //     .labels = {"Off", "2.2"},
    //     .is_enabled = []() { return shader_injection.tone_map_type != 0; },
    // },

    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Reset All",
    //     .section = "Options",
    //     .group = "button-line-1",
    //     .on_change = []() {
    //       for (auto* setting : settings) {
    //         if (setting->key.empty()) continue;
    //         if (!setting->can_reset) continue;
    //         renodx::utils::settings::UpdateSetting(setting->key, setting->default_value);
    //       }
    //     },
    // },
    // new renodx::utils::settings::Setting{
    //     .value_type = renodx::utils::settings::SettingValueType::BUTTON,
    //     .label = "Match SDR",
    //     .section = "Options",
    //     .group = "button-line-1",
    //     .on_change = []() {
    //       renodx::utils::settings::ResetSettings();
    //       renodx::utils::settings::UpdateSettings({
    //           {"ToneMapGammaCorrection", 1.f},
    //           {"ToneMapHueCorrection", 0.f},
    //           {"OverrideBlackClip", 0.f},
    //           {"ColorGradeLUTScaling", 0.f},
    //           {"ColorGradeLUTGamutRestoration", 0.f},
    //       });
    //     },
    // },

    // new renodx::utils::settings::Setting{
    //     .key = "ColorGradeColorSpace",
    //     .binding = &shader_injection.color_grade_color_space,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Color Space",
    //     .section = "Custom Color Grading",
    //     .tooltip = "Selects output color space"
    //                "\nUS Modern for BT.709 D65."
    //                "\nJPN Modern for BT.709 D93."
    //                "\nUS CRT for BT.601 (NTSC-U)."
    //                "\nJPN CRT for BT.601 ARIB-TR-B9 D93 (NTSC-J)."
    //                "\nDefault: US CRT",
    //     .labels = {
    //         "US Modern",
    //         "JPN Modern",
    //         "US CRT",
    //         "JPN CRT",
    //     },
    //     .is_visible = []() { return settings[0]->GetValue() >= 1; },
    // },

};


const std::unordered_map<std::string, reshade::api::format> UPGRADE_TARGETS = {
    {"R8G8B8A8_TYPELESS", reshade::api::format::r8g8b8a8_typeless},
    {"B8G8R8A8_TYPELESS", reshade::api::format::b8g8r8a8_typeless},
    {"R8G8B8A8_UNORM", reshade::api::format::r8g8b8a8_unorm},
    {"B8G8R8A8_UNORM", reshade::api::format::b8g8r8a8_unorm},
    {"R8G8B8A8_SNORM", reshade::api::format::r8g8b8a8_snorm},
    {"R8G8B8A8_UNORM_SRGB", reshade::api::format::r8g8b8a8_unorm_srgb},
    {"B8G8R8A8_UNORM_SRGB", reshade::api::format::b8g8r8a8_unorm_srgb},
    {"R10G10B10A2_TYPELESS", reshade::api::format::r10g10b10a2_typeless},
    {"R10G10B10A2_UNORM", reshade::api::format::r10g10b10a2_unorm},
    {"B10G10R10A2_UNORM", reshade::api::format::b10g10r10a2_unorm},
    {"R11G11B10_FLOAT", reshade::api::format::r11g11b10_float},
    {"R16G16B16A16_TYPELESS", reshade::api::format::r16g16b16a16_typeless},
};

// renodx::utils::settings::Settings info_settings = {
//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::BUTTON,
//         .label = "Reset All",
//         .section = "Options",
//         .group = "button-line-1",
//         .on_change = []() { renodx::utils::settings::ResetSettings(); },
//     },

//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::BUTTON,
//         .label = "Discord",
//         .section = "Links",
//         .group = "button-line-2",
//         .tint = 0x5865F2,
//         .on_change = []() {
//           renodx::utils::platform::LaunchURL("https://discord.gg/", "F6AUTeWJHM");
//         },
//     },
//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::BUTTON,
//         .label = "More Mods",
//         .section = "Links",
//         .group = "button-line-2",
//         .tint = 0x2B3137,
//         .on_change = []() {
//           renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx/wiki/Mods");
//         },
//     },
//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::BUTTON,
//         .label = "Github",
//         .section = "Links",
//         .group = "button-line-2",
//         .tint = 0x2B3137,
//         .on_change = []() {
//           renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx");
//         },
//     },
//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::BUTTON,
//         .label = "ShortFuse's Ko-Fi",
//         .section = "Links",
//         .group = "button-line-2",
//         .tint = 0xFF5A16,
//         .on_change = []() {
//           renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse");
//         },
//     },
//     new renodx::utils::settings::Setting{
//         .value_type = renodx::utils::settings::SettingValueType::TEXT,
//         .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
//         .section = "About",
//     },
// };

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 203.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"ToneMapGammaCorrection", 0.f},
      // {"FxGrainType", 0.f},
      // {"FxGrainStrength", 50.f},
  });
}

bool fired_on_init_swapchain = false;




void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {

  int n_unreal_settings = 5;
  auto process_path = renodx::utils::platform::GetCurrentProcessPath();
  auto filename = process_path.filename().string();
  auto product_name = renodx::utils::platform::GetProductName(process_path);
  if (fired_on_init_swapchain) return;
  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (peak.has_value()) {
    settings[1 + n_unreal_settings + 3]->default_value = peak.value();
    settings[1 + n_unreal_settings + 3]->can_reset = true;
    fired_on_init_swapchain = true;
  }

  // lut gamma correction
  if (filename == "DRAGON QUEST XI S.exe")  {
    settings[1 + n_unreal_settings]->default_value = 1;
    shader_injection.unreal_lut_gamma_correction = 1.f;

    settings[1 + n_unreal_settings + 6]->default_value = 3.f; // 1.5
    settings[1 + n_unreal_settings + 6]->can_reset = true;
  } else {
    settings[1 + n_unreal_settings]->default_value = 0;
    settings[1 + n_unreal_settings]->is_visible = []() { return false; };
    shader_injection.unreal_lut_gamma_correction = 0.f;

    settings[1 + n_unreal_settings + 6]->default_value = 1.f; // 2.2
    settings[1 + n_unreal_settings + 6]->can_reset = true;
  } 

  // gamut expansion and blue correction (only for DQ)
//   if (filename == "DRAGON QUEST XI S.exe" || filename == "DRAGON QUEST XI.exe" || product_name == "Stellar Blade")  {
    
//   } else {
//     settings[1 + n_unreal_settings-3]->is_visible = []() { return false; };
//     settings[1 + n_unreal_settings-2]->is_visible = []() { return false; };
//   }

//   // Blue Correction
//   if (filename == "DRAGON QUEST XI S.exe" || filename == "DRAGON QUEST XI.exe")  {
    
//   } else {
//     settings[1 + n_unreal_settings-4]->is_visible = []() { return false; };
//   }


  // Hue shift?
  if (filename == "DQ7R-Win64-Shipping.exe")  {
    settings[3]->default_value = 3.f; 
    settings[1 + n_unreal_settings + 3 + 4]->default_value = 50.f;
    
  } else {
    
  }

}


void OnInitDevice(reshade::api::device* device) {
  int vendor_id;
  auto retrieved = device->get_property(reshade::api::device_properties::vendor_id, &vendor_id);
  if (retrieved && vendor_id == 0x10de) {  // Nvidia vendor ID
    // Bugs out AMD GPUs
    renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
      .old_format = reshade::api::format::r11g11b10_float,
      .new_format = reshade::api::format::r16g16b16a16_float,
      .use_resource_view_cloning = true,
      .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
    });
  }
}




bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Dragon Quest XI: Echoes of an Elusive Age";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {

  auto process_path = renodx::utils::platform::GetCurrentProcessPath();
  auto filename = process_path.filename().string();
  auto product_name = renodx::utils::platform::GetProductName(process_path);

  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);

      renodx::mods::shader::on_create_pipeline_layout = [](auto, auto params) {
        return (params.size() < 20);
      };

      if (!initialized) {

        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::allow_multiple_push_constants = true;
        renodx::mods::shader::force_pipeline_cloning = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::use_resource_cloning = true;

        shader_injection.tone_map_hue_shift_source = 0.f;

        // new renodx::utils::settings::Setting{
        //     .key = "ToneMapUnrealIni",
        //     .binding = &shader_injection.processing_path,
        //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //     .default_value = 1.f,
        //     .can_reset = false,
        //     .label = "Processing Path",
        //     .section = "Unreal Engine Settings",
        //     .tooltip = "Use Unreal Engine HDR path or Upgrade SDR path.",
        //     .labels = {"Engine HDR", "Upgrade SDR"},
        // },

        {
          auto* upgrade_setting = new renodx::utils::settings::Setting{
            .key = "ToneMapUnrealIni",
            .binding = &shader_injection.processing_path,
            .value_type = renodx::utils::settings::SettingValueType::INTEGER,
            .default_value = 1.f,
            .can_reset = false,
            .label = "Processing Path",
            .section = "Display Output",
            .tooltip = "Use Unreal Engine HDR path or Upgrade SDR path.",
            .labels = {"Engine HDR", "Upgrade SDR"},
            .is_global = true,
         };

          renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, upgrade_setting);
          bool is_upgrading_sdr = upgrade_setting->GetValue() > 0;
          settings.push_back(upgrade_setting);
        // only use proxy for sdr path

          if (is_upgrading_sdr) {
                renodx::mods::swapchain::swapchain_proxy_compatibility_mode = true;
                renodx::mods::swapchain::swapchain_proxy_revert_state = true;
                
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
                reshade::log::message(reshade::log::level::info, std::format("[DEBUGGING] Applying Swapchain Proxy ...").c_str());
            } else {
                reshade::log::message(reshade::log::level::info, std::format("[DEBUGGING] NOT Applying Swapchain Proxy ...").c_str());
            }
        }
        
        if (filename == "DQ7R-Win64-Shipping.exe")  {
           renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::b8g8r8a8_typeless,
              .new_format = reshade::api::format::r16g16b16a16_typeless,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          }); 
          
          // Upgrade for character screen 
          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::b8g8r8a8_typeless,
              .new_format = reshade::api::format::r16g16b16a16_typeless,
              .use_resource_view_cloning = true,
              .dimensions = {.width = 1700, .height = 1700},
          });

          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::b8g8r8a8_unorm,
              .new_format = reshade::api::format::r16g16b16a16_float,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          });
  
        } else { // This is Dragon Quest XIS and Sword & Fairy 7. 
          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r8g8b8a8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .use_resource_view_cloning = true
          });

          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::r8g8b8a8_typeless,
              .new_format = reshade::api::format::r16g16b16a16_typeless,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          });

          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::b8g8r8a8_unorm,
              .new_format = reshade::api::format::r16g16b16a16_float,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          });

          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::b8g8r8a8_typeless,
              .new_format = reshade::api::format::r16g16b16a16_typeless,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          });

          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::r10g10b10a2_unorm,
              .new_format = reshade::api::format::r16g16b16a16_float,
              .use_resource_view_cloning = true,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          });

          
        }

        // General Upgrades 

        // fp11 upgrades only for nvidia
        reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);

        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r10g10b10a2_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .use_resource_view_cloning = true,
            .dimensions = {.width = 32, .height = 32, .depth = 32},
        });

        
        {
          auto* setting = new renodx::utils::settings::Setting{
              .key = "SwapChainEncoding",
              .binding = &shader_injection.hdr_format,
              .value_type = renodx::utils::settings::SettingValueType::INTEGER,
              .default_value = 1.f,
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
          renodx::mods::swapchain::SetUseHDR10(is_hdr10);
          renodx::mods::swapchain::use_resize_buffer = false;
          shader_injection.swap_chain_encoding = (is_hdr10 ? 4.f : 5.f);
          shader_injection.swap_chain_encoding_color_space = is_hdr10 ? 1.f : 0.f;
          settings.push_back(setting);

          if (is_hdr10)   {
              renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::r10g10b10a2_typeless,
              .new_format = reshade::api::format::r16g16b16a16_typeless,
              .use_resource_view_cloning = true,
              });
          }
        }
          
        initialized = true;
      }
    //   renodx::utils::random::binds.push_back(&shader_injection.custom_random);  // film grain

      break;
    case DLL_PROCESS_DETACH:
    //   renodx::utils::shader::Use(fdw_reason);
    //   renodx::utils::swapchain::Use(fdw_reason);
    //   renodx::utils::resource::Use(fdw_reason);
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);

      reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
//   renodx::utils::random::Use(fdw_reason);  // film grain

  return TRUE;
}