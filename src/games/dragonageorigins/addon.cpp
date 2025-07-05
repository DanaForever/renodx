/*
 * Copyright (C) 2024 Ersh
 * SPDX-License-Identifier: MIT
 */

#include <include/reshade_api_device.hpp>
#define ImTextureID ImU64

// #define DEBUG_LEVEL_0
// #define DEBUG_LEVEL_1
// #define DEBUG_LEVEL_2

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>
#include "state_block.hpp"

#include <embed/0x0152B6D2.h>
#include <embed/0x30EB4D99.h>
#include <embed/0x412995EB.h>
#include <embed/0x424EA67D.h>
#include <embed/0x880A17D3.h>
#include <embed/0x9269E43A.h>
#include <embed/0x96315369.h>
#include <embed/0xE185D991.h>
#include <embed/0xFFFFFFF9.h>
#include <embed/0xFFFFFFFA.h>
#include <embed/0xFFFFFFFB.h>
#include <embed/0xFFFFFFFC.h>
#include <embed/0xFFFFFFFD.h>
#include <embed/0xFFFFFFFE.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

ShaderInjectData shader_injection;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "toneMapType",
        .binding = &shader_injection.toneMapType,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"Vanilla", "Reinhard"},
        .parse = [](float value) { return std::fmin(std::fmax(value, 0.f), 1.f); },
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapPeakNits",
        .binding = &shader_injection.toneMapPeakNits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapGameNits",
        .binding = &shader_injection.toneMapGameNits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% white in nits",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapUINits",
        .binding = &shader_injection.toneMapUINits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the brightness of UI and HUD elements in nits",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeExposure",
        .binding = &shader_injection.colorGradeExposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 10.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeHighlights",
        .binding = &shader_injection.colorGradeHighlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeShadows",
        .binding = &shader_injection.colorGradeShadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeContrast",
        .binding = &shader_injection.colorGradeContrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeSaturation",
        .binding = &shader_injection.colorGradeSaturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeBlowout",
        .binding = &shader_injection.colorGradeBlowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Controls highlight desaturation due to overexposure.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "hueCorrectionStrength",
        .binding = &shader_injection.hueCorrectionStrength,
        .default_value = 50.f,
        .label = "Hue Correction",
        .section = "Color Grading",
        .tooltip = "Controls the strength of the hue correction.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "gamutExpansion",
        .binding = &shader_injection.gamutExpansion,
        .default_value = 33.f,
        .label = "Gamut Expansion",
        .section = "Color Grading",
        .tooltip = "Generates HDR colors (BT.2020) from bright saturated SDR (BT.709) ones.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType > 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "gameColorGradingStrength",
        .binding = &shader_injection.gameColorGradingStrength,
        .default_value = 100.f,
        .label = "Game Color Grading Strength",
        .section = "Color Grading",
        .tooltip = "Strength of the game's color grading.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "improvedLUT",
        .binding = &shader_injection.improvedLUT,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = true,
        .can_reset = true,
        .label = "Improved LUT",
        .section = "Color Grading",
        .tooltip = "Enables LUT improvements.",
    },
    new renodx::utils::settings::Setting{
        .key = "lutStrength",
        .binding = &shader_injection.lutStrength,
        .default_value = 100.f,
        .label = "Game LUT Strength",
        .section = "Color Grading",
        .tooltip = "Strength of the game's LUT.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "clampBloom",
        .binding = &shader_injection.clampBloom,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Clamp Bloom",
        .section = "Bloom",
        .tooltip = "Clamp bloom to SDR (0-1) range. Unclamped can result in unintentionally bright objects at times.",
        .labels = {"No", "Alpha", "Everything"},
        .is_enabled = []() { return shader_injection.improvedBloom == 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "improvedBloom",
        .binding = &shader_injection.improvedBloom,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = true,
        .can_reset = true,
        .label = "Improved Bloom",
        .section = "Bloom",
        .tooltip = "Enables bloom shader improvements.",
    },
    new renodx::utils::settings::Setting{
        .key = "bloomBlend",
        .binding = &shader_injection.bloomBlend,
        .default_value = 0.f,
        .label = "Bloom Blend",
        .section = "Bloom",
        .tooltip = "Controls the bloom blend.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "bloomStrength",
        .binding = &shader_injection.bloomStrength,
        .default_value = 0.04f,
        .label = "Bloom Strength",
        .section = "Bloom",
        .tooltip = "Controls the bloom strength.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "bloomThreshold",
        .binding = &shader_injection.bloomThreshold,
        .default_value = 0.25f,
        .label = "Bloom Threshold",
        .section = "Bloom",
        .tooltip = "Controls the bloom threshold.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "bloomThresholdKnee",
        .binding = &shader_injection.bloomThresholdKnee,
        .default_value = 0.5f,
        .label = "Bloom Threshold Knee",
        .section = "Bloom",
        .tooltip = "Controls the bloom threshold knee.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "bloomContrast",
        .binding = &shader_injection.bloomContrast,
        .default_value = 2.5f,
        .label = "Bloom Contrast",
        .section = "Bloom",
        .tooltip = "Controls the bloom contrast.",
        .min = 1.f,
        .max = 20.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "bloomRadius",
        .binding = &shader_injection.bloomRadius,
        .default_value = 0.0015f,
        .label = "Bloom Radius",
        .section = "Bloom",
        .tooltip = "Controls the bloom radius.",
        .min = 0.0001f,
        .max = 0.005f,
        .format = "%.4f",
        .is_enabled = []() { return shader_injection.improvedBloom > 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "circleOpacity",
        .binding = &shader_injection.circleOpacity,
        .default_value = 100.f,
        .label = "Circle Opacity",
        .section = "Miscellaneous",
        .tooltip = "Controls the opacity of the circles under actors.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "vignetteStrength",
        .binding = &shader_injection.vignetteStrength,
        .default_value = 100.f,
        .label = "Vignette Strength",
        .section = "Miscellaneous",
        .tooltip = "Controls the vignette strength.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "RenoDX by ShortFuse. Dragon Age: Origins mod by Ersh with help from Pumbo.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "About",
        .group = "button-line-1",
        .tint = 0x5865F2,
        .on_change = []() {
          system("start https://discord.gg/Z7kXxw5VDR");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Ersh's Ko-Fi",
        .section = "About",
        .group = "button-line-1",
        .tint = 0xFF5F5F,
        .on_change = []() {
          system("start https://ko-fi.com/ershin");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Pumbo's Ko-Fi",
        .section = "About",
        .group = "button-line-1",
        .tint = 0xFF5F5F,
        .on_change = []() {
          system("start https://buymeacoffee.com/realfiloppi");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "ShortFuse's Ko-Fi",
        .section = "About",
        .group = "button-line-1",
        .tint = 0xFF5F5F,
        .on_change = []() {
          system("start https://ko-fi.com/shortfuse");
        },
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSetting("toneMapType", 0.f);
  renodx::utils::settings::UpdateSetting("toneMapPeakNits", 203.f);
  renodx::utils::settings::UpdateSetting("toneMapGameNits", 203.f);
  renodx::utils::settings::UpdateSetting("toneMapUINits", 203.f);
  renodx::utils::settings::UpdateSetting("colorGradeExposure", 1.f);
  renodx::utils::settings::UpdateSetting("colorGradeHighlights", 50.f);
  renodx::utils::settings::UpdateSetting("colorGradeShadows", 50.f);
  renodx::utils::settings::UpdateSetting("colorGradeContrast", 50.f);
  renodx::utils::settings::UpdateSetting("colorGradeSaturation", 50.f);
  renodx::utils::settings::UpdateSetting("colorGradeBlowout", 0.f);
  renodx::utils::settings::UpdateSetting("hueCorrectionStrength", 0.f);
  renodx::utils::settings::UpdateSetting("gamutExpansion", 0.f);
  renodx::utils::settings::UpdateSetting("gameColorGradingStrength", 100.f);
  renodx::utils::settings::UpdateSetting("improvedLUT", 0.f);
  renodx::utils::settings::UpdateSetting("lutStrength", 100.f);
  renodx::utils::settings::UpdateSetting("clampBloom", 2.f);
  renodx::utils::settings::UpdateSetting("improvedBloom", 0.f);
  renodx::utils::settings::UpdateSetting("bloomBlend", 0.f);
  renodx::utils::settings::UpdateSetting("bloomStrength", 0.f);
  renodx::utils::settings::UpdateSetting("bloomThreshold", 0.f);
  renodx::utils::settings::UpdateSetting("bloomThresholdKnee", 0.f);
  renodx::utils::settings::UpdateSetting("bloomContrast", 0.f);
  renodx::utils::settings::UpdateSetting("bloomRadius", 0.f);
  renodx::utils::settings::UpdateSetting("circleBrightnessMult", 1.f);
  renodx::utils::settings::UpdateSetting("vignetteStrength", 100.f);
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Dragon Age: Origins";

struct BloomMip {
  float width;
  float height;
  reshade::api::resource texture = {};
  reshade::api::resource_view texture_srv = {};
  reshade::api::resource_view texture_rtv = {};
  reshade::api::sampler texture_sampler = {};
};

constexpr uint8_t MAX_BLOOM_LEVELS = 16;

struct __declspec(uuid("1228220F-364A-46A2-BB29-1CCE591A018A")) DeviceData {
  reshade::api::effect_runtime* runtime;
  float back_buffer_width;
  float back_buffer_height;

  float lut_width = 256;
  float lut_height = 1;

  reshade::api::pipeline lut_pipeline = {};
  reshade::api::pipeline_layout lut_pipeline_layout = {};
  reshade::api::pipeline copy_pipeline = {};
  reshade::api::pipeline_layout copy_pipeline_layout = {};
  reshade::api::pipeline bloom_lightmask_pipeline = {};
  reshade::api::pipeline_layout bloom_lightmask_pipeline_layout = {};
  reshade::api::pipeline downscale_pipeline = {};
  reshade::api::pipeline_layout downscale_pipeline_layout = {};
  reshade::api::pipeline upscale_pipeline = {};
  reshade::api::pipeline_layout upscale_pipeline_layout = {};
  reshade::api::state_block app_state = {};
  std::vector<BloomMip> bloom_mips = {};

  reshade::api::resource bloom_lightmask_texture = {};
  reshade::api::resource_view bloom_lightmask_srv = {};
  reshade::api::resource_view bloom_lightmask_rtv = {};

  reshade::api::resource scene_copy_texture = {};
  reshade::api::resource_view scene_copy_srv = {};
  reshade::api::resource_view scene_copy_rtv = {};
  reshade::api::sampler basic_sampler = {};

  reshade::api::resource lut_texture = {};
  reshade::api::resource_view lut_srv = {};
  reshade::api::resource_view lut_rtv = {};
  reshade::api::sampler lut_sampler = {};

  reshade::api::resource_view current_render_target_view = {};
  reshade::api::pipeline_layout tonemap_pipeline_layout = {};
};

void OnInitEffectRuntime(reshade::api::effect_runtime* runtime) {
  reshade::api::device* device = runtime->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();

  data->runtime = runtime;

  reshade::api::create_state_block(device, &data->app_state);
}

void OnDestroyEffectRuntime(reshade::api::effect_runtime* runtime) {
  reshade::api::device* device = runtime->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();

  data->runtime = nullptr;

  reshade::api::destroy_state_block(device, data->app_state);
  data->app_state = {};
}

reshade::api::pipeline CreatePipeline(reshade::api::device* device, reshade::api::pipeline_layout layout, reshade::api::blend_desc blend_state, std::span<const uint8_t> vs_code, std::span<const uint8_t> ps_code) {
  // create pipeline
  {
    std::vector<reshade::api::pipeline_subobject> subobjects;

    reshade::api::shader_desc vs_desc = {};
    vs_desc.code = vs_code.data();
    vs_desc.code_size = vs_code.size_bytes();
    subobjects.push_back({reshade::api::pipeline_subobject_type::vertex_shader, 1, &vs_desc});

    reshade::api::shader_desc ps_desc = {};
    ps_desc.code = ps_code.data();
    ps_desc.code_size = ps_code.size_bytes();
    subobjects.push_back({reshade::api::pipeline_subobject_type::pixel_shader, 1, &ps_desc});

    reshade::api::format format = reshade::api::format::r16g16b16a16_float;
    subobjects.push_back({reshade::api::pipeline_subobject_type::render_target_formats, 1, &format});

    uint32_t num_vertices = 3;
    subobjects.push_back({reshade::api::pipeline_subobject_type::max_vertex_count, 1, &num_vertices});

    auto topology = reshade::api::primitive_topology::triangle_list;
    subobjects.push_back({reshade::api::pipeline_subobject_type::primitive_topology, 1, &topology});

    subobjects.push_back({reshade::api::pipeline_subobject_type::blend_state, 1, &blend_state});

    reshade::api::rasterizer_desc rasterizer_state = {};
    rasterizer_state.cull_mode = reshade::api::cull_mode::none;
    rasterizer_state.scissor_enable = true;
    subobjects.push_back({reshade::api::pipeline_subobject_type::rasterizer_state, 1, &rasterizer_state});

    reshade::api::depth_stencil_desc depth_stencil_state = {};
    depth_stencil_state.depth_enable = false;
    depth_stencil_state.depth_write_mask = false;
    depth_stencil_state.depth_func = reshade::api::compare_op::always;
    depth_stencil_state.stencil_enable = false;
    depth_stencil_state.front_stencil_read_mask = 0xFF;
    depth_stencil_state.front_stencil_write_mask = 0xFF;
    depth_stencil_state.front_stencil_func = depth_stencil_state.back_stencil_func;
    depth_stencil_state.front_stencil_fail_op = depth_stencil_state.back_stencil_fail_op;
    depth_stencil_state.front_stencil_depth_fail_op = depth_stencil_state.back_stencil_depth_fail_op;
    depth_stencil_state.front_stencil_pass_op = depth_stencil_state.back_stencil_pass_op;
    depth_stencil_state.back_stencil_read_mask = 0xFF;
    depth_stencil_state.back_stencil_write_mask = 0xFF;
    depth_stencil_state.back_stencil_func = reshade::api::compare_op::always;
    depth_stencil_state.back_stencil_fail_op = reshade::api::stencil_op::keep;
    depth_stencil_state.back_stencil_depth_fail_op = reshade::api::stencil_op::keep;
    depth_stencil_state.back_stencil_pass_op = reshade::api::stencil_op::keep;

    subobjects.push_back({reshade::api::pipeline_subobject_type::depth_stencil_state, 1, &depth_stencil_state});

    reshade::api::pipeline out_pipeline;
    device->create_pipeline(layout, static_cast<uint32_t>(subobjects.size()), subobjects.data(), &out_pipeline);

    return out_pipeline;
  }
}

void OnInitDevice(reshade::api::device* device) {
  DeviceData* data = device->create_private_data<DeviceData>();

  // create layouts
  {
    reshade::api::pipeline_layout_param layout_params[3];
    layout_params[0] = reshade::api::descriptor_range{0, 15, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    layout_params[1] = reshade::api::descriptor_range{0, 50, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    layout_params[2] = reshade::api::descriptor_range{0, 13, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::constant_buffer};
    // layout_params[2].type = reshade::api::pipeline_layout_param_type::push_constants;
    // layout_params[2].push_constants.count = 1;
    // layout_params[2].push_constants.dx_register_index = 13;
    // layout_params[2].push_constants.visibility = reshade::api::shader_stage::vertex | reshade::api::shader_stage::pixel;
    
    device->create_pipeline_layout(2, layout_params, &data->copy_pipeline_layout);
    device->create_pipeline_layout(3, layout_params, &data->bloom_lightmask_pipeline_layout);
    device->create_pipeline_layout(3, layout_params, &data->downscale_pipeline_layout);
    device->create_pipeline_layout(3, layout_params, &data->upscale_pipeline_layout);

    reshade::api::pipeline_layout_param lut_layout_params[2];
    layout_params[0] = reshade::api::descriptor_range{0, 1, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    layout_params[1] = reshade::api::descriptor_range{0, 1, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    device->create_pipeline_layout(2, lut_layout_params, &data->lut_pipeline_layout);

    reshade::api::pipeline_layout_param tonemap_layout_params[9];
    tonemap_layout_params[0] = reshade::api::descriptor_range{0, 0, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    tonemap_layout_params[1] = reshade::api::descriptor_range{0, 0, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    tonemap_layout_params[2] = reshade::api::descriptor_range{0, 1, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    tonemap_layout_params[3] = reshade::api::descriptor_range{0, 1, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    tonemap_layout_params[4] = reshade::api::descriptor_range{0, 14, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    tonemap_layout_params[5] = reshade::api::descriptor_range{0, 50, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    tonemap_layout_params[6] = reshade::api::descriptor_range{0, 15, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::sampler};
    tonemap_layout_params[7] = reshade::api::descriptor_range{0, 51, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::shader_resource_view};
    tonemap_layout_params[8] = reshade::api::descriptor_range{0, 13, 0, 1, reshade::api::shader_stage::all, 1, reshade::api::descriptor_type::constant_buffer};
    device->create_pipeline_layout(9, tonemap_layout_params, &data->tonemap_pipeline_layout);
  }

  // create pipelines
  {
    reshade::api::blend_desc default_blend_state = {};

    std::span<const uint8_t> vs_code = __0xFFFFFFFE;
    std::span<const uint8_t> ps_code = __0xFFFFFFF9;
    data->lut_pipeline = CreatePipeline(device, data->lut_pipeline_layout, default_blend_state, vs_code, ps_code);

    vs_code = __0xFFFFFFFE;
    ps_code = __0xFFFFFFFA;
    data->copy_pipeline = CreatePipeline(device, data->bloom_lightmask_pipeline_layout, default_blend_state, vs_code, ps_code);

    vs_code = __0xFFFFFFFE;
    ps_code = __0xFFFFFFFB;
    data->bloom_lightmask_pipeline = CreatePipeline(device, data->bloom_lightmask_pipeline_layout, default_blend_state, vs_code, ps_code);

    vs_code = __0xFFFFFFFE;
    ps_code = __0xFFFFFFFC;
    data->downscale_pipeline = CreatePipeline(device, data->downscale_pipeline_layout, default_blend_state, vs_code, ps_code);

    reshade::api::blend_desc upscale_blend_state = {};
    upscale_blend_state.blend_enable[0] = true;
    upscale_blend_state.source_color_blend_factor[0] = reshade::api::blend_factor::one;
    upscale_blend_state.dest_color_blend_factor[0] = reshade::api::blend_factor::one;
    upscale_blend_state.color_blend_op[0] = reshade::api::blend_op::add;

    vs_code = __0xFFFFFFFE;
    ps_code = __0xFFFFFFFD;
    data->upscale_pipeline = CreatePipeline(device, data->upscale_pipeline_layout, upscale_blend_state, vs_code, ps_code);    
  }
}

void OnDestroyDevice(reshade::api::device* device) {
  DeviceData* data = device->get_private_data<DeviceData>();

  device->destroy_pipeline_layout(data->lut_pipeline_layout);
  device->destroy_pipeline_layout(data->copy_pipeline_layout);
  device->destroy_pipeline_layout(data->bloom_lightmask_pipeline_layout);
  device->destroy_pipeline_layout(data->downscale_pipeline_layout);
  device->destroy_pipeline_layout(data->upscale_pipeline_layout);
  device->destroy_pipeline(data->lut_pipeline);
  device->destroy_pipeline(data->copy_pipeline);
  device->destroy_pipeline(data->bloom_lightmask_pipeline);
  device->destroy_pipeline(data->downscale_pipeline);
  device->destroy_pipeline(data->upscale_pipeline);

  device->destroy_private_data<DeviceData>();
}

void CreateTexture(reshade::api::device* device, uint32_t width, uint32_t height, uint16_t depth, uint16_t levels, reshade::api::format format, reshade::api::resource_usage usage, reshade::api::resource_usage initial_state, reshade::api::resource* out_resource) {
  reshade::api::resource_desc desc = {};
  desc.type = reshade::api::resource_type::texture_2d;
  desc.texture = {
      width,
      height,
      depth,
      levels,
      reshade::api::format_to_typeless(format),
      1,
  };
  desc.heap = reshade::api::memory_heap::gpu_only;
  desc.usage = usage;
  desc.flags = reshade::api::resource_flags::none;
  device->create_resource(desc, nullptr, initial_state, out_resource);
}

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  reshade::api::device* device = swapchain->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();

  // create targets
  {
    auto back_buffer_resource = swapchain->get_back_buffer(0);
    auto back_buffer_desc = device->get_resource_desc(back_buffer_resource);

    data->back_buffer_width = back_buffer_desc.texture.width;
    data->back_buffer_height = back_buffer_desc.texture.height;

    float mipWidth = back_buffer_desc.texture.width;
    float mipHeight = back_buffer_desc.texture.height;

    reshade::api::sampler_desc default_sampler_desc = {};

    CreateTexture(device, back_buffer_desc.texture.width, back_buffer_desc.texture.height, 1, 1, back_buffer_desc.texture.format, reshade::api::resource_usage::render_target | reshade::api::resource_usage::shader_resource | reshade::api::resource_usage::copy_dest, reshade::api::resource_usage::copy_dest, &data->scene_copy_texture);
    device->create_resource_view(data->scene_copy_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &data->scene_copy_srv);
    device->create_resource_view(data->scene_copy_texture, reshade::api::resource_usage::render_target, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &data->scene_copy_rtv);
    device->create_sampler(default_sampler_desc, &data->basic_sampler);

    CreateTexture(device, back_buffer_desc.texture.width, back_buffer_desc.texture.height, 1, 1, back_buffer_desc.texture.format, reshade::api::resource_usage::render_target | reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target, &data->bloom_lightmask_texture);
    device->create_resource_view(data->bloom_lightmask_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &data->bloom_lightmask_srv);
    device->create_resource_view(data->bloom_lightmask_texture, reshade::api::resource_usage::render_target, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &data->bloom_lightmask_rtv);

    CreateTexture(device, data->lut_width, data->lut_height, 1, 1, reshade::api::format::r16g16b16a16_float, reshade::api::resource_usage::render_target | reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::unordered_access, &data->lut_texture);
    device->create_resource_view(data->lut_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_view_desc(reshade::api::format::r16g16b16a16_float), &data->lut_srv);
    device->create_resource_view(data->lut_texture, reshade::api::resource_usage::render_target, reshade::api::resource_view_desc(reshade::api::format::r16g16b16a16_float), &data->lut_rtv);

    reshade::api::sampler_desc lut_sampler_desc;
    lut_sampler_desc.filter = reshade::api::filter_mode::min_mag_mip_linear;
    lut_sampler_desc.address_u = reshade::api::texture_address_mode::clamp;
    lut_sampler_desc.address_v = reshade::api::texture_address_mode::clamp;
    lut_sampler_desc.address_w = reshade::api::texture_address_mode::clamp;
    device->create_sampler(lut_sampler_desc, &data->lut_sampler);

    constexpr uint8_t bloomLevels = 7;

    uint8_t mipCount = min(bloomLevels, MAX_BLOOM_LEVELS);
    for (uint8_t i = 0; i < MAX_BLOOM_LEVELS; ++i) {
      mipWidth *= 0.5f;
      mipHeight *= 0.5f;

      if (mipWidth < 1 || mipHeight < 1) {
        break;
      }

      BloomMip mip;
      mip.width = mipWidth;
      mip.height = mipHeight;

      CreateTexture(device, mipWidth, mipHeight, 1, 1, back_buffer_desc.texture.format, reshade::api::resource_usage::render_target | reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target, &mip.texture);
      device->create_resource_view(mip.texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &mip.texture_srv);
      device->create_resource_view(mip.texture, reshade::api::resource_usage::render_target, reshade::api::resource_view_desc(reshade::api::format_to_default_typed(back_buffer_desc.texture.format)), &mip.texture_rtv);
      reshade::api::sampler_desc mip_sampler_desc;
      mip_sampler_desc.filter = reshade::api::filter_mode::min_mag_mip_linear;
      mip_sampler_desc.address_u = reshade::api::texture_address_mode::clamp;
      mip_sampler_desc.address_v = reshade::api::texture_address_mode::clamp;
      mip_sampler_desc.address_w = reshade::api::texture_address_mode::clamp;
      device->create_sampler(mip_sampler_desc, &mip.texture_sampler);

      data->bloom_mips.emplace_back(mip);
    }
  }

}

void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool resize) {
  reshade::api::device* device = swapchain->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();

  for (auto& mip : data->bloom_mips) {
    device->destroy_sampler(mip.texture_sampler);
    device->destroy_resource_view(mip.texture_rtv);
    device->destroy_resource_view(mip.texture_srv);
    device->destroy_resource(mip.texture);
  }
  data->bloom_mips.clear();

  device->destroy_sampler(data->lut_sampler);
  device->destroy_resource_view(data->lut_rtv);
  device->destroy_resource_view(data->lut_srv);
  device->destroy_resource(data->lut_texture);
  device->destroy_resource_view(data->bloom_lightmask_rtv);
  device->destroy_resource_view(data->bloom_lightmask_srv);
  device->destroy_resource(data->bloom_lightmask_texture);
  device->destroy_resource(data->scene_copy_texture);
  device->destroy_resource_view(data->scene_copy_srv);
  device->destroy_sampler(data->basic_sampler);
}

void OnBindRenderTargetsAndDepthStencil(reshade::api::command_list* cmd_list, uint32_t count,
                                        const reshade::api::resource_view* rtvs, reshade::api::resource_view dsv) {
  // auto device = cmd_list->get_device();
  // auto& data = device->get_private_data<DeviceData>();
  reshade::api::device* device = cmd_list->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();
  if (count > 0) {
    data->current_render_target_view = *rtvs;
  } else {
    data->current_render_target_view = {};
  }
}

void BuildLUT(reshade::api::command_list* cmd_list) {
  // auto device = cmd_list->get_device();
  // auto& data = device->get_private_data<DeviceData>();
  reshade::api::device* device = cmd_list->get_device();
  DeviceData* data = device->get_private_data<DeviceData>();

  capture_state(cmd_list, data->app_state);

  {
    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_graphics, data->lut_pipeline);
    cmd_list->bind_render_targets_and_depth_stencil(1, &data->lut_rtv);

    const reshade::api::viewport viewport = {
        0.0f, 0.0f,
        data->lut_width,
        data->lut_height,
        0.0f, 1.0f};
    cmd_list->bind_viewports(0, 1, &viewport);

    const reshade::api::rect scissor_rect = {0, 0, static_cast<int32_t>(data->lut_width), static_cast<int32_t>(data->lut_height)};
    cmd_list->bind_scissor_rects(0, 1, &scissor_rect);

    cmd_list->draw(4, 1, 0, 0);
  }

  apply_state(cmd_list, data->app_state);
}

// based on https://learnopengl.com/Guest-Articles/2022/Phys.-Based-Bloom
void RunImprovedBloom(reshade::api::command_list* cmd_list) {
  reshade::api::device* device = cmd_list->get_device();
  // auto& data = device->get_private_data<DeviceData>();
  DeviceData* data = device->get_private_data<DeviceData>();


  capture_state(cmd_list, data->app_state);

  // copy pre bloom target WHY DOES THIS BREAK THE GAME
  {
    //auto current_render_target = device->get_resource_from_view(data.current_render_target_view);
    //const reshade::api::resource resources[2] = {current_render_target, data.scene_copy_texture};
    //const reshade::api::resource_usage state_old[2] = {reshade::api::resource_usage::render_target, reshade::api::resource_usage::render_target};
    //const reshade::api::resource_usage state_new[2] = {reshade::api::resource_usage::copy_source, reshade::api::resource_usage::copy_dest};

    //cmd_list->barrier(2, resources, state_old, state_new);
    //cmd_list->copy_texture_region(current_render_target, 0, nullptr, data.scene_copy_texture, 0, nullptr);
    //cmd_list->barrier(2, resources, state_new, state_old);
  }

  // copy pre tonemap target. it's already set, don't touch anything unnecessary or the game shits itself
  {
    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_graphics, data->copy_pipeline);

    //auto current_render_target = device->get_resource_from_view(data.current_render_target_view);
    //cmd_list->barrier(current_render_target, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
    //cmd_list->barrier(data.scene_copy_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target);
    
    //reshade::api::render_pass_render_target_desc render_target = {};
    //render_target.view = data.scene_copy_rtv;
    //cmd_list->begin_render_pass(1, &render_target, nullptr);
    cmd_list->bind_render_targets_and_depth_stencil(1, &data->scene_copy_rtv);

    const reshade::api::viewport viewport = {
        0.0f, 0.0f,
        static_cast<float>(data->back_buffer_width),
        static_cast<float>(data->back_buffer_height),
        0.0f, 1.0f};
    cmd_list->bind_viewports(0, 1, &viewport);

    const reshade::api::rect scissor_rect = {0, 0, static_cast<int32_t>(data->back_buffer_width), static_cast<int32_t>(data->back_buffer_height)};
    cmd_list->bind_scissor_rects(0, 1, &scissor_rect);

    //cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data.copy_pipeline_layout, 0, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &data.basic_sampler});
    //cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data.copy_pipeline_layout, 1, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &data.current_render_target_view});

    cmd_list->draw(4, 1, 0, 0);
    //cmd_list->end_render_pass();
  }

  // generate bloom lightmask
  {
    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_graphics, data->bloom_lightmask_pipeline);

    cmd_list->barrier(data->scene_copy_texture, reshade::api::resource_usage::copy_dest, reshade::api::resource_usage::shader_resource);
    cmd_list->barrier(data->bloom_lightmask_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target);
    
    reshade::api::render_pass_render_target_desc render_target = {};
    render_target.view = data->bloom_lightmask_rtv;
    cmd_list->begin_render_pass(1, &render_target, nullptr);

    const reshade::api::viewport viewport = {
        0.0f, 0.0f,
        static_cast<float>(data->back_buffer_width),
        static_cast<float>(data->back_buffer_height),
        0.0f, 1.0f};
    cmd_list->bind_viewports(0, 1, &viewport);

    const reshade::api::rect scissor_rect = {0, 0, static_cast<int32_t>(data->back_buffer_width), static_cast<int32_t>(data->back_buffer_height)};
    cmd_list->bind_scissor_rects(0, 1, &scissor_rect);

    cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->bloom_lightmask_pipeline_layout, 0, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &data->basic_sampler});
    cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->bloom_lightmask_pipeline_layout, 1, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &data->scene_copy_srv});
    cmd_list->push_constants(reshade::api::shader_stage::all_graphics, data->bloom_lightmask_pipeline_layout, 2, 0, sizeof(shader_injection) / 4, &shader_injection);

    cmd_list->draw(4, 1, 0, 0);
    cmd_list->end_render_pass();
  }

  // downscale
  {
    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_graphics, data->downscale_pipeline);

    cmd_list->barrier(data->bloom_lightmask_texture, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
    cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->downscale_pipeline_layout, 0, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &data->basic_sampler});
    cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->downscale_pipeline_layout, 1, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &data->bloom_lightmask_srv});

    shader_injection.internalBloomSrcTexelSizeX = 1.f / static_cast<float>(data->back_buffer_width);
    shader_injection.internalBloomSrcTexelSizeY = 1.f / static_cast<float>(data->back_buffer_height);

    for (int i = 0; i < data->bloom_mips.size(); ++i) {
      const auto& mip = data->bloom_mips[i];
      cmd_list->barrier(mip.texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target);

      reshade::api::render_pass_render_target_desc render_target = {};
      render_target.view = mip.texture_rtv;
      cmd_list->begin_render_pass(1, &render_target, nullptr);

      const reshade::api::viewport viewport = {
          0.0f, 0.0f,
          mip.width,
          mip.height,
          0.0f, 1.0f};
      cmd_list->bind_viewports(0, 1, &viewport);

      const reshade::api::rect scissor_rect = {0, 0, static_cast<int32_t>(mip.width), static_cast<int32_t>(mip.height)};
      cmd_list->bind_scissor_rects(0, 1, &scissor_rect);

      // push the renodx settings
      cmd_list->push_constants(reshade::api::shader_stage::all_graphics, data->downscale_pipeline_layout, 2, 0, sizeof(shader_injection) / 4, &shader_injection);

      cmd_list->draw(4, 1, 0, 0);
      cmd_list->end_render_pass();

      // set current mip as the input for next iteration
      cmd_list->barrier(mip.texture, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
      cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->downscale_pipeline_layout, 0, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &mip.texture_sampler});
      cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->downscale_pipeline_layout, 1, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &mip.texture_srv});
      shader_injection.internalBloomSrcTexelSizeX = 1.f / mip.width;
      shader_injection.internalBloomSrcTexelSizeY = 1.f / mip.height;
    }
  }

  // upscale
  {
    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_graphics, data->upscale_pipeline);

    float aspect_ratio = data->back_buffer_width / data->back_buffer_height;
    shader_injection.internalBloomFilterRadiusX = shader_injection.bloomRadius;
    shader_injection.internalBloomFilterRadiusY = shader_injection.bloomRadius * aspect_ratio;

    for (int i = data->bloom_mips.size() - 1; i > 0; --i) {
      const auto& mip = data->bloom_mips[i];
      const auto& nextMip = data->bloom_mips[i - 1];

      cmd_list->barrier(mip.texture, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
      cmd_list->barrier(nextMip.texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::render_target);

      reshade::api::render_pass_render_target_desc render_target = {};
      render_target.view = nextMip.texture_rtv;
      cmd_list->begin_render_pass(1, &render_target, nullptr);

      const reshade::api::viewport viewport = {
          0.0f, 0.0f,
          nextMip.width,
          nextMip.height,
          0.0f, 1.0f};
      cmd_list->bind_viewports(0, 1, &viewport);

      const reshade::api::rect scissor_rect = {0, 0, static_cast<int32_t>(nextMip.width), static_cast<int32_t>(nextMip.height)};
      cmd_list->bind_scissor_rects(0, 1, &scissor_rect);

      cmd_list->push_descriptors(reshade::api::shader_stage::pixel, data->upscale_pipeline_layout, 0, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &mip.texture_sampler});
      cmd_list->push_descriptors(reshade::api::shader_stage::pixel, data->upscale_pipeline_layout, 1, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &mip.texture_srv});
      cmd_list->push_constants(reshade::api::shader_stage::pixel, data->upscale_pipeline_layout, 2, 0, sizeof(shader_injection) / 4, &shader_injection);

      cmd_list->draw(4, 1, 0, 0);
      cmd_list->end_render_pass();
    }
  }

  apply_state(cmd_list, data->app_state);
}

void OnBindPipeline(reshade::api::command_list* cmd_list, reshade::api::pipeline_stage type, reshade::api::pipeline pipeline) {
  if (shader_injection.improvedBloom || shader_injection.improvedLUT) {
    renodx::utils::shader::CommandListData* shader_state = cmd_list->get_private_data<renodx::utils::shader::CommandListData>();
    // const uint32_t shader_hash = shader_state->GetCurrentPixelShaderHash();
    const uint32_t shader_hash = renodx::utils::shader::GetCurrentComputeShaderHash(shader_state);

    if (shader_hash == 0x0152B6D2) {
      if (shader_injection.improvedLUT) {
        BuildLUT(cmd_list);
      }
      if (shader_injection.improvedBloom) {
        RunImprovedBloom(cmd_list);
      }
      
      reshade::api::device* device = cmd_list->get_device();
      DeviceData* data = device->get_private_data<DeviceData>();

      if (shader_injection.improvedLUT) {
        // bind the built LUT as a srv to use by the tonemap shader instead of the original one
        cmd_list->barrier(data->lut_texture, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
        cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->tonemap_pipeline_layout, 6, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &data->lut_sampler});
        cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->tonemap_pipeline_layout, 7, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &data->lut_srv});
      }

      if (shader_injection.improvedBloom) {
        // bind the largest bloom mip as a srv to use by the tonemap shader
        auto& firstMip = data->bloom_mips[0];
        cmd_list->barrier(firstMip.texture, reshade::api::resource_usage::render_target, reshade::api::resource_usage::shader_resource);
        cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->tonemap_pipeline_layout, 4, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::sampler, &firstMip.texture_sampler});
        cmd_list->push_descriptors(reshade::api::shader_stage::all_graphics, data->tonemap_pipeline_layout, 5, reshade::api::descriptor_table_update{{}, 0, 0, 1, reshade::api::descriptor_type::texture_shader_resource_view, &firstMip.texture_srv});
      }
    }
  }
}

static reshade::api::fence _queue_sync_fence = {};
static uint64_t _queue_sync_value = 0;

bool OnDrawBloom(reshade::api::command_list* cmd_list) {
  if (shader_injection.improvedBloom) {
    return false;
  }

  return true;
}

bool OnBloomBlurDraw(reshade::api::command_list* cmd_list) {
  // skip with improved bloom
  if (shader_injection.improvedBloom) {
    return false;
  }

  return true;
}

bool OnBloomFinalDraw(reshade::api::command_list* cmd_list) {
  // skip with improved bloom
  if (shader_injection.improvedBloom) {
    return false;
  }

  return true;
}

namespace {
#define CustomShaderEntryCallbackOnDraw(crc32, callback)                                                          \
  {                                                                                                               \
    crc32, { crc32, std::vector<uint8_t>(_##crc32, _##crc32 + sizeof(_##crc32)), -1, nullptr, nullptr, callback } \
  }
#define ShaderEntryOnDraw(__crc32__, callback)             \
  {                                                        \
    __crc32__, { .crc32 = __crc32__, .on_draw = callback } \
  }

renodx::mods::shader::CustomShaders custom_shaders = {

    CustomShaderEntry(0x880A17D3),
    CustomShaderEntry(0x424EA67D),
    CustomShaderEntry(0x96315369),
    CustomShaderEntry(0x9269E43A),

    CustomShaderEntryCallback(0x412995EB, &OnDrawBloom), // lightmask
    CustomShaderEntryCallback(0x30EB4D99, &OnDrawBloom), // blur
    CustomShaderEntryCallback(0xE185D991, &OnDrawBloom), 
    // CustomShaderEntryCallback(0x0152B6D2, &OnDrawBloom), 

    // CustomShaderEntryCallbackOnDraw(0x412995EB, &OnDrawBloom),  // lightmask
    // CustomShaderEntryCallbackOnDraw(0x30EB4D99, &OnDrawBloom),  // blur
    // CustomShaderEntryCallbackOnDraw(0xE185D991, &OnDrawBloom),  // final
    // CustomShaderEntryCallbackOnDraw(0x0152B6D2, &OnTonemapDraw),
    CustomShaderEntry(0x0152B6D2),
};
}  // namespace

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

#ifndef NDEBUG
      while (!IsDebuggerPresent()) {
        Sleep(100);
      }
#endif
      renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
      renodx::mods::swapchain::Use(fdw_reason);
      renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

      renodx::mods::swapchain::prevent_full_screen = true;
      renodx::mods::swapchain::force_borderless = true;

      // renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
      //     .old_format = reshade::api::format::r8g8b8a8_unorm,
      //     .new_format = reshade::api::format::r16g16b16a16_float,
      //     //.ignore_size = true
      //     .aspect_ratio = 16.f / 9.f
      //     //.dimensions = { 3840, 2160 }
      // });

      {
        float screen_width = GetSystemMetrics(SM_CXSCREEN);
        float screen_height = GetSystemMetrics(SM_CYSCREEN);

        // renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
        //     .old_format = reshade::api::format::r8g8b8a8_typeless,
        //     .new_format = reshade::api::format::r16g16b16a16_typeless,
        //     .aspect_ratio = screen_width / screen_height
        //     // .ignore_size=true
        // });

        // renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
        //     .old_format = reshade::api::format::r8g8b8a8_unorm,
        //     .new_format = reshade::api::format::r16g16b16a16_float,
        //     .aspect_ratio = screen_width / screen_height
        //     // .ignore_size=true
        // });
      }

      reshade::register_event<reshade::addon_event::init_effect_runtime>(OnInitEffectRuntime);
      reshade::register_event<reshade::addon_event::destroy_effect_runtime>(OnDestroyEffectRuntime);
      reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
      // reshade::register_event<reshade::addon_event::create_pipeline>(OnCreatePipeline);
      reshade::register_event<reshade::addon_event::bind_render_targets_and_depth_stencil>(OnBindRenderTargetsAndDepthStencil);
      reshade::register_event<reshade::addon_event::bind_pipeline>(OnBindPipeline);

      //// dxvk
      //{
      //    renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
      //        .old_format = reshade::api::format::b8g8r8a8_unorm,
      //        .new_format = reshade::api::format::r16g16b16a16_float,
      //        //.ignore_size = true
      //        .aspect_ratio = 16.f / 9.f
      //        //.dimensions = { 3840, 2160 }
      //    });
      //    renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
      //        .old_format = reshade::api::format::b8g8r8a8_typeless,
      //        .new_format = reshade::api::format::r16g16b16a16_typeless,
      //        //.ignore_size = true
      //        .aspect_ratio = 16.f / 9.f
      //        //.dimensions = {3840, 2160}
      //    });
      //}

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_effect_runtime>(OnInitEffectRuntime);
      reshade::unregister_event<reshade::addon_event::destroy_effect_runtime>(OnDestroyEffectRuntime);
      reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
      // reshade::unregister_event<reshade::addon_event::create_pipeline>(OnCreatePipeline);
      reshade::unregister_event<reshade::addon_event::bind_render_targets_and_depth_stencil>(OnBindRenderTargetsAndDepthStencil);
      reshade::unregister_event<reshade::addon_event::bind_pipeline>(OnBindPipeline);

      reshade::unregister_addon(h_module);
      break;
  }

  return TRUE;
}
