/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#include <iostream>
#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/settings.hpp"
#include <filesystem>
#include <regex>
#include "./shared.h"
// #include "artifact_shaders.h"

namespace fs = std::filesystem;

namespace {

#define UpgradeRTVReplaceShader(value)         \
  {                                            \
    value,                                     \
        {                                      \
            .crc32 = value,                    \
            .code = __##value,                 \
            .on_draw = [](auto* cmd_list) {                                                             \
            auto rtvs = renodx::utils::swapchain::GetRenderTargets(cmd_list);                         \
            bool changed = false;                                                                     \
            for (auto rtv : rtvs) {                                                                   \
              changed = renodx::mods::swapchain::ActivateCloneHotSwap(cmd_list->get_device(), rtv);   \
            }                                                                                         \
            if (changed) {                                                                            \
              renodx::mods::swapchain::FlushDescriptors(cmd_list);                                    \
              renodx::mods::swapchain::RewriteRenderTargets(cmd_list, rtvs.size(), rtvs.data(), {0}); \
            }                                                                                         \
            return true; }, \
        },                                     \
  }

#define UpgradeRTVShader(value)                \
  {                                            \
    value,                                     \
        {                                      \
            .crc32 = value,                    \
            .on_draw = [](auto* cmd_list) {                                                           \
            auto rtvs = renodx::utils::swapchain::GetRenderTargets(cmd_list);                       \
            bool changed = false;                                                                   \
            for (auto rtv : rtvs) {                                                                 \
              changed = renodx::mods::swapchain::ActivateCloneHotSwap(cmd_list->get_device(), rtv); \
            }                                                                                       \
            if (changed) {                                                                          \
              renodx::mods::swapchain::FlushDescriptors(cmd_list);                                  \
              renodx::mods::swapchain::RewriteRenderTargets(cmd_list, rtvs.size(), rtvs.data(), {0});      \
            }                                                                                       \
            return true; }, \
        },                                     \
  }

renodx::mods::shader::CustomShaders artifact_shaders = {

    CustomShaderEntry(0x0A800445), // Artifact 
    CustomShaderEntry(0x24E3F2E9), // Artifact
    CustomShaderEntry(0x51A0872B), // Artifact
    CustomShaderEntry(0xC24A5C78),
    CustomShaderEntry(0xC7178B80), // Artifact
    CustomShaderEntry(0xD9D77A15), // Artifact
    CustomShaderEntry(0xF5F14005), // Artifact
    CustomShaderEntry(0x1A8F8A60), // Artifact
    CustomShaderEntry(0x010A2698), // Artifact
    CustomShaderEntry(0x1FEBC77F), // Artifact
    CustomShaderEntry(0xFB81CC22), // Artifact
    CustomShaderEntry(0x53F9EA61), // Helix
    CustomShaderEntry(0x8377693A), // Helix
    CustomShaderEntry(0xF52ED722), // Helix
    CustomShaderEntry(0x7C713EA2), // artifact
    CustomShaderEntry(0x899A5037), // artifact
    CustomShaderEntry(0x92AF88E8), // artifact
    CustomShaderEntry(0x693BB6AD), // artifact
    CustomShaderEntry(0x0617F17E), // artifact
    CustomShaderEntry(0x864D0B94), // artifact
    CustomShaderEntry(0x28A12202), // artifact
    CustomShaderEntry(0x03A9635B), // artifact
    CustomShaderEntry(0xD4CC30DD), // artifact
    CustomShaderEntry(0x5904850F), // artifact
    CustomShaderEntry(0xAEFC72F9), // artifact
    CustomShaderEntry(0x5A14FF14), // artifact
    CustomShaderEntry(0x97B6686A), // artifact
    CustomShaderEntry(0xB6F58E83), // artifact
    
};

renodx::mods::shader::CustomShaders custom_shaders = {
    CustomShaderEntry(0x2403F73F), // ui
    CustomShaderEntry(0xD6241E03), // ui
    CustomShaderEntry(0x131CC98E),
    CustomShaderEntry(0x46A727D9), // final4
    CustomShaderEntry(0xC2D07E63), // final-Scraft
    CustomShaderEntry(0x9DB02646), // swapchain unclamp
    CustomShaderEntry(0xF0FA2768), // artifact
    CustomShaderEntry(0x386909EF), // bloom artifact
    CustomShaderEntry(0xE8C7EBA2), // bloom artifact
    CustomShaderEntry(0x96BB8CFF), // MSAA
    CustomShaderEntry(0xC5F739B8), // Tone
    CustomShaderEntry(0x640BFEB8), // Bloom
    CustomShaderEntry(0xD63B1562), // Bloom 2
    CustomShaderEntry(0x96FE091D), // Bloom 4
    CustomShaderEntry(0xFB26B904), // Bloom 5
    CustomShaderEntry(0xA3F66EB7), // Artifact
    CustomShaderEntry(0xA77E6454), // Artifact 
    CustomShaderEntry(0x3EB64A30), // Artifact 
    CustomShaderEntry(0x085FEFA2), // Artifact 
    CustomShaderEntry(0x466B2B3A), // Artifact 
    CustomShaderEntry(0xA8FAC241), // Artifact 
    CustomShaderEntry(0x0EC06FAC), // Lantern
    CustomShaderEntry(0x4D7BB28D), // Helicopter
    // CustomShaderEntry(0x6C72EE93), // Bloom Generator
    // CS4
    CustomShaderEntry(0x2BF0C94B), // Final 3
    CustomShaderEntry(0x3E08A3A6), // Final 2
    CustomShaderEntry(0x2A8422DE), // Final 1
    CustomShaderEntry(0x49107B8F), // Final 6
    CustomShaderEntry(0x1C7DCC30), // Final 7
    CustomShaderEntry(0x3541804A), // Final 8
    CustomShaderEntry(0xFD245ECC), // Final 9
    CustomShaderEntry(0x93DEF816), // Final 10
    CustomShaderEntry(0xE92523E6), // Light 
    CustomShaderEntry(0x2CE1FDAD), // Moon
    CustomShaderEntry(0x7CC40E3A), // Artifact 
    CustomShaderEntry(0xDCCD09BC), // Artifact 
    CustomShaderEntry(0xC36D80C8), // Artifact 
    CustomShaderEntry(0x825031AD), // Artifact 
    CustomShaderEntry(0x2EB3D75C), // Artifact 
    CustomShaderEntry(0x311ECA34), // Artifact 
    CustomShaderEntry(0x5DFE166C), // Artifact 
    CustomShaderEntry(0xE291FC5C), // Artifact 
    CustomShaderEntry(0xE291FC5C), // Artifact 
    CustomShaderEntry(0x2A1ED860), // Artifact 
    CustomShaderEntry(0x3F916BC5), // Sky Artifact 
    CustomShaderEntry(0x40E73DDB), // mirror light
    CustomShaderEntry(0x39657C8A), // light
    CustomShaderEntry(0xBB9756CF), // light
    CustomShaderEntry(0x24FB4CC2), // light
    CustomShaderEntry(0x36E4465F), // light
    CustomShaderEntry(0x50ED90FA), // light
    CustomShaderEntry(0xD15C5D7D), // light
    CustomShaderEntry(0xE7F4B7AF), // lantern
    CustomShaderEntry(0x2BBCADD8), // lantern
    CustomShaderEntry(0xF5F14005), // lantern
    CustomShaderEntry(0x8E631192), // waterfall
    CustomShaderEntry(0x6E7F5CBB), // waterfall2
    CustomShaderEntry(0xB64DF407), // sky
    CustomShaderEntry(0x8C099E7B), // lantern
    CustomShaderEntry(0xB9AF63CD), // lantern

    // CS3
    CustomShaderEntry(0xDB20052A), // CS3 swapchain
    CustomShaderEntry(0xFAD1BDE8), // CS3 bloom
    CustomShaderEntry(0x8E0121CE), // CS3 bloom
    CustomShaderEntry(0x36ED28F7), // CS3 bloom
    CustomShaderEntry(0x6B574B6E), // CS3 final 
    CustomShaderEntry(0xABF4E009), // CS3 final 2
    CustomShaderEntry(0xB4406452), // CS3 final 3
    CustomShaderEntry(0x95F02C1D), // CS3 final 4
    CustomShaderEntry(0x26217A30), // CS3 final 5
    CustomShaderEntry(0x46DC6C58), // CS3 final 6
    CustomShaderEntry(0x70EAAEFC), // lighthouse
    CustomShaderEntry(0xD4F2A488), // ortis light
    CustomShaderEntry(0xA7E488FF), // aion
    CustomShaderEntry(0x9243FD49), // valimar
    CustomShaderEntry(0xFF76CAFD), // valimar2
    CustomShaderEntry(0x1355F463), // house light
    // CustomSwapchainShader(0x00000000),
    // BypassShaderEntry(0x00000000)
};


renodx::mods::shader::CustomShaders generate_artifact_shaders(const std::string& folder_path) {
    renodx::mods::shader::CustomShaders shaders;
    std::regex filename_pattern(R"(0x([0-9A-Fa-f]+)\.ps_\d+_\d+\.hlsl)");

    for (const auto& file : fs::directory_iterator(folder_path)) {
        if (!file.is_regular_file())
            continue;

        const std::string filename = file.path().filename().string();
        std::smatch match;

        if (std::regex_match(filename, match, filename_pattern)) {
            uint32_t hash = static_cast<uint32_t>(std::stoul(match[1].str(), nullptr, 16));
            // shaders.insert(CustomShaderEntry(hash));
            shaders.emplace(hash, renodx::mods::shader::CustomShader{hash});
        }
    }

    return shaders;
}


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
        .key = "SettingsBloom",
        .binding = &shader_injection.bloom,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Game Bloom.",
        .labels = {"Disabled", "Enabled"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "SettingsAA",
        .binding = &shader_injection.fxaa,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Game FXAA.",
        .labels = {"Disabled", "Enabled"},
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
        .default_value = 2.f,
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
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapWorkingColorSpace",
    //     .binding = &shader_injection.tone_map_working_color_space,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 2.f,
    //     .label = "Working Color Space",
    //     .section = "Tone Mapping",
    //     .labels = {"BT709", "BT2020", "AP1"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     // .is_visible = []() { return current_settings_mode >= 2; },
    //     .is_visible = []() { return false; },
    // },
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
        // .is_visible = []() { return current_settings_mode >= 2; },
        .is_visible = []() { return false; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapHueCorrection",
    //     .binding = &shader_injection.tone_map_hue_correction,
    //     .default_value = 100.f,
    //     .label = "Hue Correction",
    //     .section = "Tone Mapping",
    //     .tooltip = "Hue retention strength.",
    //     .min = 0.f,
    //     .max = 100.f,
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value * 0.01f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
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
        // .is_visible = []() { return current_settings_mode >= 1; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapWhiteClip",
        .binding = &shader_injection.tone_map_white_clip,
        .default_value = 100.f,
        .label = "White Clip",
        .section = "Tone Mapping",
        .tooltip = "White clip values.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 1.f; },
        .is_visible = []() { return current_settings_mode >= 1; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapClampColorSpace",
    //     .binding = &shader_injection.tone_map_clamp_color_space,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Clamp Color Space",
    //     .section = "Tone Mapping",
    //     .tooltip = "Hue-shift emulation strength.",
    //     .labels = {"None", "BT709", "BT2020", "AP1"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value - 1.f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapClampPeak",
    //     .binding = &shader_injection.tone_map_clamp_peak,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Clamp Peak",
    //     .section = "Tone Mapping",
    //     .tooltip = "Hue-shift emulation strength.",
    //     .labels = {"None", "BT709", "BT2020", "AP1"},
    //     .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
    //     .parse = [](float value) { return value - 1.f; },
    //     .is_visible = []() { return current_settings_mode >= 2; },
    // },
    ///////////////////////////////////////////

    
    new renodx::utils::settings::Setting{
        .key = "InverseToneMapperWhiteLevel",
        .binding = &shader_injection.inverse_tonemap_white_level,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Tonemapper white level (in units)",
        .section = "Inverse Tone Mapping",
        .tooltip = "Used as parameter by some (inverse) tonemappers. Increases saturation. Has no effect at 1.",
        .min = 0.f,
        .max = 4.f,
    },
    new renodx::utils::settings::Setting{
        .key = "InverseToneMapColorConservation",
        .binding = &shader_injection.inverse_tonemap_color_conservation,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Inverse tonemapper color conservation",
        .section = "Inverse Tone Mapping",
        .tooltip = "This makes the inverse tonemapped color gradually restore the SDR source image color (hue and saturation/chroma), while retaining its increased perceived brightness.\nAvoid setting this too close to one as it could cause problems in some scenes.",
        .min = 1.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "InverseToneMapHighlightSaturation",
        .binding = &shader_injection.inverse_tonemap_highlight_saturation,
        .default_value = 100.f,
        .can_reset = false,
        .label = "Inverse tonemapper Highlight saturation",
        .section = "Inverse Tone Mapping",
        .tooltip = "Allows tuning of highlights saturation (vibrancy). Relative to the input white level. Neutral at 100.f.",
        .min = 0.f,
        .max = 200.f,
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "InverseToneMapExtraHDRSaturation",
        .binding = &shader_injection.inverse_tonemap_extra_hdr_saturation,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Extra HDR saturation",
        .section = "Inverse Tone Mapping",
        .tooltip = "Generates HDR colors (BT.2020) from bright saturated SDR (BT.709) ones. Neutral at 0.",
        .min = 0.f,
        .max = 200.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    

    /////////////////////////////////////////////////////////////
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
        .is_visible = []() { return false; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowoutRestoration",
        .binding = &shader_injection.color_grade_per_channel_blowout_restoration,
        .default_value = 0.f,
        .label = "Per Channel Blowout Restoration",
        .section = "Color Grading",
        .tooltip = "Restores color from blowout from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return current_settings_mode >= 1; },
        .is_visible = []() { return false >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeChrominanceCorrection",
        .binding = &shader_injection.color_grade_per_channel_chrominance_correction,
        .default_value = 0.f,
        .label = "Per Channel Chrominance Correction",
        .section = "Color Grading",
        .tooltip = "Corrects unbalanced chrominance (?) from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return current_settings_mode >= 1; },
        .is_visible = []() { return false >= 1; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHueCorrection",
        .binding = &shader_injection.color_grade_per_channel_hue_correction,
        .default_value = 0.f,
        .label = "Per Channel Hue Correction",
        .section = "Color Grading",
        .tooltip = "Corrects per-channel hue shifts from per-channel grading.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return current_settings_mode >= 1; },
        .is_visible = []() { return false >= 1; },
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
    },
    new renodx::utils::settings::Setting{
        .key = "IntermediateDecoding",
        .binding = &shader_injection.intermediate_encoding,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Intermediate Encoding",
        .section = "Display Output",
        .labels = {"Auto", "None", "SRGB", "2.2", "2.4"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) {
            if (value == 0) return shader_injection.gamma_correction + 1.f;
            return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "SwapChainDecoding",
        .binding = &shader_injection.swap_chain_decoding,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Swapchain Decoding",
        .section = "Display Output",
        .labels = {"Auto", "None", "SRGB", "2.2", "2.4"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) {
            if (value == 0) return shader_injection.intermediate_encoding;
            return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "SwapChainGammaCorrection",
        .binding = &shader_injection.swap_chain_gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .label = "Gamma Correction",
        .section = "Display Output",
        .labels = {"None", "2.2", "2.4"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "SwapChainClampColorSpace",
        .binding = &shader_injection.swap_chain_clamp_color_space,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .label = "Clamp Color Space",
        .section = "Display Output",
        .labels = {"None", "BT709", "BT2020", "AP1"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value - 1.f; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
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

extern "C" __declspec(dllexport) constexpr const char* NAME = "Sen no Kiseki - RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Trails of Cold Steel games";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::force_borderless = true;
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

        // Always upgrade first of format
    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::r8g8b8a8_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //       .use_resource_view_cloning = true,
    //       .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
    //       .usage_include = reshade::api::resource_usage::render_target,
    //   });

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8g8b8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_unorm,
          .shader_hash = 0x2403F73F
      });

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8g8b8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_unorm,
          .shader_hash = 0xD6241E03
      });

      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8g8b8a8_unorm,
          .new_format = reshade::api::format::r16g16b16a16_float,
        //   .new_format = reshade::api::format::r32g32b32a32_float,
        //   .use_resource_view_cloning = true,
        //   .use_resource_view_hot_swap = true,
          .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
          .usage_include = reshade::api::resource_usage::render_target,
      });

    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::bc1_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //       .ignore_size = true
          
    //     });
    //   renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
    //       .old_format = reshade::api::format::r8g8b8a8_unorm,
    //       .new_format = reshade::api::format::r16g16b16a16_float,
    //       .use_resource_view_cloning = true,
    //       .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
    //   });

      bool is_hdr10 = false;
      renodx::mods::swapchain::SetUseHDR10(is_hdr10);
      renodx::mods::swapchain::use_resize_buffer = false;
        
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

        // {
        //   auto* setting = new renodx::utils::settings::Setting{
        //       .key = "SwapChainEncoding",
        //       .binding = &shader_injection.swap_chain_encoding,
        //       .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //       .default_value = 5.f,
        //       .label = "Encoding",
        //       .section = "Display Output",
        //       .labels = {"None", "SRGB", "2.2", "2.4", "HDR10", "scRGB"},
        //       .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        //       .on_change_value = [](float previous, float current) {
        //         bool is_hdr10 = current == 4;
        //         shader_injection.swap_chain_encoding_color_space = (is_hdr10 ? 1.f : 0.f);
        //         // return void
        //       },
        //       .is_global = true,
        //       .is_visible = []() { return current_settings_mode >= 2; },
        //   };
        //   renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, setting);
        //   bool is_hdr10 = setting->GetValue() == 4;
        //   renodx::mods::swapchain::SetUseHDR10(is_hdr10);
        //   renodx::mods::swapchain::use_resize_buffer = setting->GetValue() < 4;
        //   shader_injection.swap_chain_encoding_color_space = is_hdr10 ? 1.f : 0.f;
        //   settings.push_back(setting);
        // }

        // for (const auto& [key, format] : UPGRADE_TARGETS) {
        //   auto* setting = new renodx::utils::settings::Setting{
        //       .key = "Upgrade_" + key,
        //       .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        //       .default_value = 0.f,
        //       .label = key,
        //       .section = "Resource Upgrades",
        //       .labels = {
        //           "Off",
        //           "Output size",
        //           "Output ratio",
        //           "Any size",
        //       },
        //       .is_global = true,
        //       .is_visible = []() { return settings[0]->GetValue() >= 2; },
        //   };
        //   renodx::utils::settings::LoadSetting(renodx::utils::settings::global_name, setting);
        //   settings.push_back(setting);

        //   auto value = setting->GetValue();
        //   if (value > 0) {
        //     renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
        //         .old_format = format,
        //         .new_format = reshade::api::format::r16g16b16a16_float,
        //         .ignore_size = (value == UPGRADE_TYPE_ANY),
        //         .use_resource_view_cloning = true,
        //         .aspect_ratio = static_cast<float>((value == UPGRADE_TYPE_OUTPUT_RATIO)
        //                                                ? renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER
        //                                                : renodx::mods::swapchain::SwapChainUpgradeTarget::ANY),
        //         .usage_include = reshade::api::resource_usage::render_target,
        //     });
        //     std::stringstream s;
        //     s << "Applying user resource upgrade for ";
        //     s << format << ": " << value;
        //     reshade::log::message(reshade::log::level::info, s.str().c_str());
        //   }
        // }

        initialized = true;
      }

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);

//   auto artifact_shaders = generate_artifact_shaders("artifacts");
  custom_shaders.insert(artifact_shaders.begin(), artifact_shaders.end());
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
