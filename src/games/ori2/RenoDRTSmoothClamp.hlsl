#include "./shared.h"

/// Applies a customized version of RenoDRT tonemapper that tonemaps down to 1.0.
/// This function is used to compress HDR color to SDR range for use alongside `UpgradeToneMap`.
///
/// @param lutInputColor The color input that needs to be tonemapped.
/// @return The tonemapped color compressed to the SDR range, ensuring that it can be applied to SDR color grading with `UpgradeToneMap`.
float3 renoDRTSmoothClamp(float3 untonemapped) {
  // renodx::tonemap::renodrt::Config renodrt_config = renodx::tonemap::renodrt::config::Create();
  // renodrt_config.nits_peak = 100.f;
  // renodrt_config.mid_gray_value = 0.18f;
  // renodrt_config.mid_gray_nits = 18.f;
  // renodrt_config.exposure = 1.f;
  // renodrt_config.highlights = 1.f;
  // renodrt_config.shadows = 1.f;
  // renodrt_config.contrast = 1.05f;
  // renodrt_config.saturation = 1.025f;
  // renodrt_config.dechroma = 0.f;
  // renodrt_config.flare = 0.f;
  // renodrt_config.hue_correction_strength = 0.f;
  // // renodrt_config.hue_correction_source = renodx::tonemap::uncharted2::BT709(untonemapped);
  // renodrt_config.hue_correction_method = renodx::tonemap::renodrt::config::hue_correction_method::OKLAB;
  // renodrt_config.tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::DANIELE;
  // renodrt_config.hue_correction_type = renodx::tonemap::renodrt::config::hue_correction_type::INPUT;
  // renodrt_config.working_color_space = 2u;
  // renodrt_config.per_channel = false;

  // float3 renoDRTColor = renodx::tonemap::renodrt::BT709(untonemapped, renodrt_config);

  // float HDRBlendFactor = lerp(1.f, renodrt_config.mid_gray_value, saturate(injectedData.toneMapHDRBlendFactor));
  // renoDRTColor = lerp(min(1.f, untonemapped), renoDRTColor, saturate(untonemapped / HDRBlendFactor));
  untonemapped = renodx::color::gamma::DecodeSafe(untonemapped, 2.2f);
  float3 renoDRTColor = renodx::tonemap::renodrt::NeutralSDR(untonemapped);

  renoDRTColor = renodx::color::gamma::EncodeSafe(renoDRTColor, 2.2f);

  return renoDRTColor;
}

float3 UpgradeToneMap(
    float3 color_untonemapped,
    float3 color_tonemapped,
    float3 color_tonemapped_graded,
    float post_process_strength = 1.f,
    float auto_correction = 0.f) {
  float ratio = 1.f;

  color_untonemapped = renodx::color::gamma::DecodeSafe(color_untonemapped, 2.2f);
  color_tonemapped = renodx::color::gamma::DecodeSafe(color_tonemapped, 2.2f);
  color_tonemapped_graded = renodx::color::gamma::DecodeSafe(color_tonemapped_graded, 2.2f);

  color_untonemapped = renodx::color::bt709::clamp::BT2020(color_untonemapped);
  color_tonemapped = renodx::color::bt709::clamp::BT2020(color_tonemapped);
  color_tonemapped_graded = renodx::color::bt709::clamp::BT2020(color_tonemapped_graded);

  float y_untonemapped = renodx::color::y::from::BT709(color_untonemapped);
  float y_tonemapped = renodx::color::y::from::BT709(color_tonemapped);
  float y_tonemapped_graded = renodx::color::y::from::BT709(color_tonemapped_graded);

  if (y_untonemapped < y_tonemapped) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    ratio = y_untonemapped / y_tonemapped;
  } else {
    float y_delta = y_untonemapped - y_tonemapped;
    y_delta = max(0, y_delta);  // Cleans up NaN
    const float y_new = y_tonemapped_graded + y_delta;

    const bool y_valid = (y_tonemapped_graded > 0);  // Cleans up NaN and ignore black
    ratio = y_valid ? (y_new / y_tonemapped_graded) : 0;
  }
  float auto_correct_ratio = lerp(1.f, ratio, saturate(y_untonemapped));
  ratio = lerp(ratio, auto_correct_ratio, auto_correction);

  float3 color_scaled = color_tonemapped_graded * ratio;
  // Match hue
  color_scaled = renodx::color::correct::Hue(color_scaled, color_tonemapped_graded);
  color_scaled = renodx::color::bt709::clamp::BT2020(color_scaled);
  float3 output = lerp(color_untonemapped, color_scaled, post_process_strength);

  output = renodx::color::gamma::EncodeSafe(output, 2.2f);
  return output;
}