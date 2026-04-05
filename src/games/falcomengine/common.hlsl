
#include "./shared.h"
#include "lms_matrix.hlsl"
#include "./macleod_boynton.hlsli"

#include "./psycho_test11.hlsl"
#include "./psycho_test17.hlsl"


float3 sdrToneMap(float3 color) {
  color = renodx::color::srgb::DecodeSafe(color);

  color = renodx::tonemap::neutwo::MaxChannel(color);

  color = renodx::color::srgb::EncodeSafe(color);
  return color;
}

float3 srgbDecode(float3 color) {
  if (RENODX_TONE_MAP_TYPE == 0 || shader_injection.bloom == 0.f) {
    return color;
  }

  return renodx::color::srgb::DecodeSafe(color);
}

float3 srgbEncode(float3 color) {
  if (RENODX_TONE_MAP_TYPE == 0 || shader_injection.bloom == 0.f) {
    return color;
  }

  return renodx::color::srgb::EncodeSafe(color);
}

float calculateLuminanceSRGB(float3 color) {
  return renodx::color::y::from::BT709(renodx::color::srgb::DecodeSafe(color));
  // return renodx::color::y::from::NTCSC1953(renodx::color::srgb::DecodeSafe(color));
  // return renodx::color::y::from::NTSC1953((color));
  // return renodx::color::y::from::BT709((color));
}

float3 compress(float3 color) {
  return saturate(color);

}

float4 compress(float4 color) {
  // color.rgb = compress(color.rgb);
  if (shader_injection.bloom_space == 1) {
    // color.rgb = srgbDecode(color.rgb);
  }
  color.rgb = clamp(color.rgb, -999999999, 1.f);

  color.w = saturate(color.w);

  return color;
}

float3 addBloom(float3 base, float3 blend) {
  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);

  return base + addition;
}

float3 hdrScreenBlend(float3 base, float3 blend, float scale = 0.f) {
  blend = max(0.f, blend);

  // if (shader_injection.bloom != 2.f)
    // blend *= shader_injection.bloom_strength;
  blend *= 4.f;

  float3 bloom_texture = blend;

  float mid_gray_bloomed = (0.18 + renodx::color::y::from::BT709(bloom_texture)) / 0.18;

  float scene_luminance = renodx::color::y::from::BT709(base) * mid_gray_bloomed;
  float bloom_blend = saturate(smoothstep(0.f, 0.18f, scene_luminance));

  float3 bloom_scaled = lerp(float3(0.f, 0.f, 0.f), bloom_texture, bloom_blend);  // = bloom_blend
  bloom_texture = lerp(bloom_texture, bloom_scaled, 0.5f);

  blend = bloom_texture;

  return addBloom(base, blend);
}

float3 hdrScreenBlend2(float3 base, float3 blend, float scale = 0.f) {
  
  
}

float3 LMS_Processing(float3 color) {
  color = LMS_Vibrancy(color, shader_injection.tone_map_lms_vibrancy, shader_injection.tone_map_lms_contrast);
  color = lerp(color, CastleDechroma_CVVDPStyle_NakaRushton(color), shader_injection.tone_map_lms_dechroma);

  color = renodx::color::bt709::clamp::BT2020(color);
  return color;
}

// Samsung research
static const float3x3 XYZ_TO_LMS_PROPOSED_2023 = float3x3(
    0.185083290265044, 0.584080232530060, -0.0240724126371618,
    -0.134432464433222, 0.405751419882862, 0.0358251078084051,
    0.000789395399878065, -0.000912213029667692, 0.0198489810108856);

float3 NeutwoBT709WhiteForEnergy(float3 bt709_linear, float peak = 1.f) {
  float peak_ref = max(peak, 1e-6f);

  // float3x3 xyz_to_lms = renodx::color::XYZ_TO_STOCKMAN_SHARP_LMS_MAT;
  float3x3 xyz_to_lms = XYZ_TO_LMS_PROPOSED_2023;
  float3x3 lms_to_xyz = renodx::math::Invert3x3(xyz_to_lms);
  float3 xyz = renodx::color::xyz::from::BT709(bt709_linear);
  float3 lms = mul(xyz_to_lms, xyz);

  float3 d65_xyz = renodx::color::xyz::from::xyY(float3(renodx::color::WHITE_POINT_D65, 1.f));
  float3 lms_white = mul(xyz_to_lms, d65_xyz);

  float3 lms_norm_input = lms / lms_white;
  float scalar_raw_input = lms_norm_input.x + lms_norm_input.y + lms_norm_input.z;

  const float units = 1.f;  // Use 3.f for broken values
  float scalar_input = scalar_raw_input / units;

  float3 lms_peak = lms_white * peak_ref;
  float3 lms_norm_peak = lms_peak / lms_white;
  float scalar_raw_peak = lms_norm_peak.x + lms_norm_peak.y + lms_norm_peak.z;
  float scalar_peak = scalar_raw_peak / units;

  float scalar_output = renodx::tonemap::Neutwo(scalar_input, scalar_peak);

  float scalar_input_raw = scalar_input * units;
  float scalar_output_raw = scalar_output * units;

  float d65_gray = 0.18f;
  float3 gray_xyz = renodx::color::xyz::from::xyY(float3(renodx::color::WHITE_POINT_D65, d65_gray));
  float3 lms_gray = mul(xyz_to_lms, gray_xyz);
  float3 lms_gray_in = lms_gray * (scalar_input_raw / units);
  float3 lms_gray_out = lms_gray * (scalar_output_raw / units);
  float3 lms_chroma = lms - lms_gray_in;
  float available_white = saturate(renodx::math::DivideSafe(
      scalar_peak - scalar_output,
      scalar_peak,
      0.f));
  float3 lms_out = lms_gray_out + lms_chroma * available_white;

  float3 lms_norm_out = lms_out / lms_white;
  float scalar_out_raw = lms_norm_out.x + lms_norm_out.y + lms_norm_out.z;
  lms_out *= renodx::math::DivideSafe(scalar_output_raw, scalar_out_raw, 0.f);

  float3 xyz_out = mul(lms_to_xyz, lms_out);
  return renodx::color::bt709::from::XYZ(xyz_out);
}



float3 ReinhardBT709WhiteForEnergy(float3 bt709_linear, float peak = 1.f) {
  float peak_ref = max(peak, 1e-6f);

  // float3x3 xyz_to_lms = renodx::color::XYZ_TO_STOCKMAN_SHARP_LMS_MAT;
  float3x3 xyz_to_lms = XYZ_TO_LMS_PROPOSED_2023;
  float3x3 lms_to_xyz = renodx::math::Invert3x3(xyz_to_lms);
  float3 xyz = renodx::color::xyz::from::BT709(bt709_linear);
  float3 lms = mul(xyz_to_lms, xyz);

  float3 d65_xyz = renodx::color::xyz::from::xyY(float3(renodx::color::WHITE_POINT_D65, 1.f));
  float3 lms_white = mul(xyz_to_lms, d65_xyz);

  float3 lms_norm_input = lms / lms_white;
  float scalar_raw_input = lms_norm_input.x + lms_norm_input.y + lms_norm_input.z;

  const float units = 1.f;  // Use 3.f for broken values
  float scalar_input = scalar_raw_input / units;

  float3 lms_peak = lms_white * peak_ref;
  float3 lms_norm_peak = lms_peak / lms_white;
  float scalar_raw_peak = lms_norm_peak.x + lms_norm_peak.y + lms_norm_peak.z;
  float scalar_peak = scalar_raw_peak / units;

  float scalar_output = ReinhardExtended(scalar_input, 100.f, scalar_peak);

  float scalar_input_raw = scalar_input * units;
  float scalar_output_raw = scalar_output * units;

  float d65_gray = 0.18f;
  float3 gray_xyz = renodx::color::xyz::from::xyY(float3(renodx::color::WHITE_POINT_D65, d65_gray));
  float3 lms_gray = mul(xyz_to_lms, gray_xyz);
  float3 lms_gray_in = lms_gray * (scalar_input_raw / units);
  float3 lms_gray_out = lms_gray * (scalar_output_raw / units);
  float3 lms_chroma = lms - lms_gray_in;
  float available_white = saturate(renodx::math::DivideSafe(
      scalar_peak - scalar_output,
      scalar_peak,
      0.f));
  float3 lms_out = lms_gray_out + lms_chroma * available_white;

  float3 lms_norm_out = lms_out / lms_white;
  float scalar_out_raw = lms_norm_out.x + lms_norm_out.y + lms_norm_out.z;
  lms_out *= renodx::math::DivideSafe(scalar_output_raw, scalar_out_raw, 0.f);

  float3 xyz_out = mul(lms_to_xyz, lms_out);
  return renodx::color::bt709::from::XYZ(xyz_out);
}

float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  // float3 result = renodx::color::correct::Chrominance(lum, ch, 1.0f, 0.0f, RENODX_TONE_MAP_HUE_PROCESSOR);
  float3 result = CorrectPurityMBBT709WithBT2020(lum, ch);
  // float3 result = renodx::color::correct::Chrominance(lum, ch);

  return result;
}



float3 ToneMapLMS(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return untonemapped;
  }

  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 untonemapped_graded = untonemapped;

  // untonemapped_graded = LMS_Vibrancy(untonemapped_graded, shader_injection.tone_map_lms_vibrancy, shader_injection.tone_map_lms_contrast);

  // naka rushton
  float3 untonemapped_graded_dechroma = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded);
  untonemapped_graded_dechroma = lerp(untonemapped_graded, untonemapped_graded_dechroma, shader_injection.tone_map_lms_dechroma);

  float3 bt709_tonemapped;
  float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.2f);

  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.4f);
  }

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    float contrast_ratio = min(peak_ratio, 4.f);

  //   bt709_tonemapped = renodx::tonemap::psycho::psychotm_test11(
  //       untonemapped_graded_dechroma,
  //       peak_ratio,  // peak
  //       1.0f,        // exposure
  //       1.0f,        // highlights
  //       1.0f,        // shadows
  //       1.0f,        // contrast
  //       1.0f,        // purity_scale
  //       1.0f,        // bleaching_intensity
  //       100.f,       // clip_point
  //       0.5f,        // hue_restore
  //       1.0f,        // adaptation_contrast
  //       1,           // naka rushton
  //       // 1.0f + 0.025 * (contrast_ratio - 1.0f));  // cone_response_exponent
  //       1.0f);  // cone_response_exponent
  // }

    float contrast = shader_injection.tone_map_lms_contrast / shader_injection.tone_map_lms_vibrancy;

    bt709_tonemapped = renodx::tonemap::psycho::psychotm_test17(
        untonemapped_graded_dechroma,
        peak_ratio,  // peak
        1.0f,        // exposure
        1.0f,        // highlights
        1.0f,        // shadows
        contrast,    // contrast
        1.0f,        // purity_scale
        1.0f,        // bleaching_intensity
        100.f,       // clip_point
        0.5f,        // hue_restore
        1.0f,        // adaptation_contrast
        1,           // naka rushton
        shader_injection.tone_map_lms_vibrancy);  // cone_response_exponent
  }

  return bt709_tonemapped;
}


float3 processAndToneMap(float3 color, bool decoding = true) {
  if (decoding) {
    color = renodx::color::srgb::DecodeSafe(color);
  }

  // float3 sdr_color = SDRTonemap(color);
  // color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);

  color = ToneMapLMS(color);
  // color = correctHue(color, sdr_color);
  color = renodx::color::bt709::clamp::BT2020(color);

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    // color = renodx::color::correct::GammaSafe(color, false, 2.2f);
    color = GammaCorrectHuePreserving(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    // color = renodx::color::correct::GammaSafe(color, false, 2.4f);
    color = GammaCorrectHuePreserving(color, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = GammaCorrectHuePreserving(color, 2.3f); 
    // color = renodx::color::correct::GammaSafe(color, false, 2.3f);
  }

  // This is RenderIntermediatePass, simply brightness scaling and srgb encoding
  color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = renodx::color::correct::GammaSafe(color, true, 2.3f);
  }

  color = renodx::color::srgb::EncodeSafe(color);
  return color;
}

float3 processUI(float3 color, bool decoding = true) {
  if (decoding) {
    color = renodx::color::srgb::DecodeSafe(color);
  }

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.3f);
  }

  // This is RenderIntermediatePass, simply brightness scaling and srgb encoding
  // color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  color *= RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = renodx::color::correct::GammaSafe(color, true, 2.3f);
  }

  color = renodx::color::srgb::EncodeSafe(color);
  return color;
}