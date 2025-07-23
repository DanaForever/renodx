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
    CustomShaderEntry(0x16C5613F), // artifact
    CustomShaderEntry(0xE9CCCC87), // artifact
    CustomShaderEntry(0xE011F8E0), // artifact
    CustomShaderEntry(0xAC986310), // artifact
    CustomShaderEntry(0xF4F7DF67), // artifact
    CustomShaderEntry(0x00D25A6E), // artifact
    CustomShaderEntry(0x2CA64FEA), // artifact
    CustomShaderEntry(0x4EFC489C), // artifact
    CustomShaderEntry(0xD76CAD22), // artifact
    CustomShaderEntry(0x27C49A90), // artifact
    CustomShaderEntry(0xEB8EAAE7), // artifact
    CustomShaderEntry(0x2140995A), // artifact
    CustomShaderEntry(0xBA8780BB), // artifact
    CustomShaderEntry(0xC757392B), // artifact
    CustomShaderEntry(0xFBEC108C), // artifact
    CustomShaderEntry(0xB6F58E83), // artifact
    CustomShaderEntry(0x83970024), // artifact
    CustomShaderEntry(0x9971D43C), // artifact
    CustomShaderEntry(0x40AAA6CF), // artifact
    CustomShaderEntry(0x0CE1250D), // artifact
    CustomShaderEntry(0x2F9ED134), // artifact
    CustomShaderEntry(0x4EFC489C), // artifact
    CustomShaderEntry(0x374F364D), // artifact
    CustomShaderEntry(0xF299DBA1), // artifact
    CustomShaderEntry(0x4A5044D3), // artifact
    CustomShaderEntry(0x85AF2462), // artifact
    CustomShaderEntry(0x96E2605E), // artifact
    CustomShaderEntry(0x4C191089), // artifact
    CustomShaderEntry(0xA15E5BC7), // artifact
    CustomShaderEntry(0x19B22350), // artifact
    CustomShaderEntry(0xA750A152), // artifact
    CustomShaderEntry(0x9FCDD407), // artifact
    CustomShaderEntry(0x92449B53), // artifact
    CustomShaderEntry(0x63655D7C), // artifact
    CustomShaderEntry(0x2286C934), // artifact
    CustomShaderEntry(0xC41CBE29), // artifact
    CustomShaderEntry(0xBDFDE2B7), // artifact
    CustomShaderEntry(0x4CB2EE15), // artifact
    CustomShaderEntry(0x1E7B91F3), // artifact
    
};

renodx::mods::shader::CustomShaders custom_shaders = {
    CustomShaderEntry(0x256687A6), // sun
    CustomShaderEntry(0x2403F73F), // ui
    CustomShaderEntry(0xD6241E03), // ui
    CustomShaderEntry(0x631BC5B3), // ui
    CustomShaderEntry(0x0844C159), // ui
    CustomShaderEntry(0xB55FDE0D), // ui
    CustomShaderEntry(0x131CC98E),
    CustomShaderEntry(0x46A727D9), // final4
    CustomShaderEntry(0xC2D07E63), // final-Scraft
    CustomShaderEntry(0x9DB02646), // swapchain unclamp
    CustomShaderEntry(0xF0FA2768), // artifact
    CustomShaderEntry(0x386909EF), // bloom artifact
    CustomShaderEntry(0xE8C7EBA2), // bloom artifact
    CustomShaderEntry(0x96BB8CFF), // MSAA
    CustomShaderEntry(0xC5F739B8), // Tone
    CustomShaderEntry(0x312CE29D), // PreBloom
    CustomShaderEntry(0x640BFEB8), // Bloom
    CustomShaderEntry(0xC1EA843D), // Bloom 2
    CustomShaderEntry(0xD63B1562), // Bloom 4
    CustomShaderEntry(0x96FE091D), // Bloom 1
    CustomShaderEntry(0xFB26B904), // Bloom godray 3
    CustomShaderEntry(0xA3F66EB7), // Artifact
    CustomShaderEntry(0xA77E6454), // Artifact 
    CustomShaderEntry(0x3EB64A30), // Artifact 
    CustomShaderEntry(0x085FEFA2), // Artifact 
    CustomShaderEntry(0x466B2B3A), // Artifact 
    CustomShaderEntry(0xA8FAC241), // Artifact 
    CustomShaderEntry(0x0EC06FAC), // Lantern
    CustomShaderEntry(0x4D7BB28D), // Helicopter
    CustomShaderEntry(0xACB821F7), // effect
    CustomShaderEntry(0x7DF4072B), // effect
    CustomShaderEntry(0x90904C40), // effect
    CustomShaderEntry(0xD2EE0840), // effect
    CustomShaderEntry(0x1275C3E6), // environment
    CustomShaderEntry(0x605593B6), // environment
    CustomShaderEntry(0x6907BF88), // lantern
    CustomShaderEntry(0xCF69F81A), // effect
    
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
    CustomShaderEntry(0xB9AF63CD), // rean eff
    CustomShaderEntry(0xAF5B4CE1), // lantern
    CustomShaderEntry(0xE3E9C74F), // lantern
    CustomShaderEntry(0x51EB2788), // lantern
    CustomShaderEntry(0x01906E4B), // lantern
    CustomShaderEntry(0x4C831242), // lantern 
    CustomShaderEntry(0xCD0D39E7), // light
    

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
    CustomShaderEntry(0x63462E18), // smoke
    
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
        .default_value = 0.f,
        .can_reset = false,
        .label = "Game Bloom",
        .labels = {"Enabled (Approximated)", "Enabled", "Disabled"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "SettingsBloom",
        .binding = &shader_injection.bloom_approx_method,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Bloom Approximation",
        .labels = {"Perception", "Luminance"},
        .is_global = true,
        .is_visible = []() { return shader_injection.bloom == 0.f && current_settings_mode >= 1; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "SettingsBloomRescale",
    //     .binding = &shader_injection.bloom_rescale,
    //     .default_value = 0.f,
    //     .can_reset = false,
    //     .label = "Game Bloom Rescaling Factor",
    //     .tooltip = "Game Bloom.",
    //     .min = 0.f,
    //     .max = 500.f,
    //     .parse = [](float value) { return value * 0.01f; },
    // },
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
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .can_reset = true,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"Vanilla", "Frostbite", "DICE", "RenoDRT"},
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
    // new renodx::utils::settings::Setting{
    //     .key = "InverseToneMapExtraHDRSaturation",
    //     .binding = &shader_injection.inverse_tonemap_extra_hdr_saturation,
    //     .default_value = 0.f,
    //     .can_reset = false,
    //     .label = "Gamut Expansion",
    //     .section = "Tone Mapping",
    //     .tooltip = "Generates HDR colors (BT.2020) from bright saturated SDR (BT.709) ones. Neutral at 0.",
    //     .min = 0.f,
    //     .max = 500.f,
    //     .parse = [](float value) { return value * 0.01f; },
    // },
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
        .section = "RenoDRT Configuration",
        .tooltip = "Luminance scales colors consistently while per-channel saturates and blows out sooner",
        .labels = {"Luminance", "Per Channel"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2 && shader_injection.tone_map_type == 3.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapWhiteClip",
        .binding = &shader_injection.tone_map_white_clip,
        .default_value = 100.f,
        .label = "White Clip",
        .section = "RenoDRT Configuration",
        .tooltip = "White clip values.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 1.f; },
        .is_visible = []() { return current_settings_mode >= 1 && shader_injection.tone_map_type == 3.f; },
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
        .is_visible = []() { return current_settings_mode >= 2; },
        // .is_visible = []() { return shader_injection.tone_map_type >= 1 && current_settings_mode >= 2.f; },
        // .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueCorrection",
        .binding = &shader_injection.tone_map_hue_correction,
        .default_value = 100.f,
        .label = "Hue Correction Strength",
        .section = "Hue Correction",
        .tooltip = "Hue retention strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return false; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 0.f,
        .label = "Hue Shift",
        .section = "Hue Correction",
        .tooltip = "Hue-shift emulation strength.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .parse = [](float value) { return value * 0.01f; },
        // .is_visible = []() { return current_settings_mode >= 1; },
        .is_visible = []() { return false; },
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
        .default_value = 1.f,
        .label = "Clamp Color Space",
        .section = "Color Space",
        .tooltip = "Hue-shift emulation strength.",
        .labels = {"BT709", "BT2020"},
        .is_enabled = []() { return shader_injection.tone_map_type >= 1; },
        .is_visible = []() { return current_settings_mode >= 2; },
    },
    // new renodx::utils::settings::Setting{
    //     .key = "ToneMapClampPeak",
    //     .binding = &shader_injection.tone_map_clamp_peak,
    //     .value_type = renodx::utils::settings::SettingValueType::INTEGER,
    //     .default_value = 0.f,
    //     .label = "Clamp Peak",
    //     .section = "Color Space",
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
        .is_visible = []() { return false; },
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
        .is_visible = []() { return false; },
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
        .is_visible = []() { return false; },
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
        .is_enabled = []() { return shader_injection.tone_map_type == 3; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return current_settings_mode >= 1; },
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
        // renodx::mods::swapchain::force_borderless = false;
        // renodx::mods::swapchain::swapchain_proxy_compatibility_mode = false;
        // renodx::mods::swapchain::prevent_full_screen = false;
        // renodx::mods::swapchain::swap_chain_proxy_shaders = {
        //     {
        //         reshade::api::device_api::d3d11,
        //         {
        //             .vertex_shader = __swap_chain_proxy_vertex_shader_dx11,
        //             .pixel_shader = __swap_chain_proxy_pixel_shader_dx11,
        //         },
        //     },
        //     {
        //         reshade::api::device_api::d3d12,
        //         {
        //             .vertex_shader = __swap_chain_proxy_vertex_shader_dx12,
        //             .pixel_shader = __swap_chain_proxy_pixel_shader_dx12,
        //         },
        //     },
        // };


        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r8g8b8a8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            //   .use_resource_view_cloning = true,
            .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
            .usage_include = reshade::api::resource_usage::render_target
        });


        bool is_hdr10 = true;
        renodx::mods::swapchain::SetUseHDR10(is_hdr10);
        renodx::mods::swapchain::use_resize_buffer = false;
        

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
