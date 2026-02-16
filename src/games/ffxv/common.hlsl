
#include "./shared.h"
// #include "./macleod_boynton.hlsl"


/// Applies Exponential Roll-Off tonemapping using the maximum channel.
/// Used to fit the color into a 0–output_max range for SDR LUT compatibility.
float3 ToneMapMaxCLL(float3 color, float rolloff_start = 0.375f, float output_max = 1.f) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return color;
  }
  color = min(color, 100.f);
  float peak = max(color.r, max(color.g, color.b));
  peak = min(peak, 100.f);
  float log_peak = log2(peak);

  // Apply exponential shoulder in log space
  float log_mapped = renodx::tonemap::ExponentialRollOff(log_peak, log2(rolloff_start), log2(output_max));
  float scale = exp2(log_mapped - log_peak);  // How much to compress all channels

  return min(output_max, color * scale);
}


float3 PostToneMapScale(float3 color) {
  if (shader_injection.gamma_correction == 2.f) {
    color = renodx::color::srgb::EncodeSafe(color);
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else if (shader_injection.gamma_correction == 1.f) {
    color = renodx::color::srgb::EncodeSafe(color);
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else {
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::srgb::EncodeSafe(color);
  }
  return color;
}

float3 ToneMapPass(float3 untonemapped, 
  float3 graded_sdr, 
  float3 neutral_sdr,
  float mid_gray=0.18f,
  bool regrade=false) {
  renodx::draw::Config draw_config = renodx::draw::BuildConfig();
  draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
  // draw_config.tone_map_pass_autocorrection = 0.5;
  
  draw_config.color_grade_strength = 1;

  float3 color = renodx::tonemap::UpgradeToneMap(
      untonemapped,
      neutral_sdr,
      // renodx::tonemap::renodrt::NeutralSDR(untonemapped),
      graded_sdr,
      draw_config.color_grade_strength,
      draw_config.tone_map_pass_autocorrection);

  renodx::tonemap::Config tone_map_config = renodx::tonemap::config::Create();
  tone_map_config.peak_nits = draw_config.peak_white_nits;
  tone_map_config.game_nits = draw_config.diffuse_white_nits;
  tone_map_config.type = min(draw_config.tone_map_type, 3.f);
  tone_map_config.gamma_correction = draw_config.gamma_correction;
  tone_map_config.exposure = draw_config.tone_map_exposure;
  tone_map_config.highlights = draw_config.tone_map_highlights;
  tone_map_config.shadows = draw_config.tone_map_shadows;
  tone_map_config.contrast = draw_config.tone_map_contrast;
  tone_map_config.saturation = draw_config.tone_map_saturation;

  tone_map_config.mid_gray_value = mid_gray;
  tone_map_config.mid_gray_nits = tone_map_config.mid_gray_value * 100.f;

  tone_map_config.reno_drt_highlights = 1.0f;
  tone_map_config.reno_drt_shadows = 1.0f;
  tone_map_config.reno_drt_contrast = 1.0f;
  tone_map_config.reno_drt_saturation = 1.0f;
  tone_map_config.reno_drt_blowout = -1.f * (draw_config.tone_map_highlight_saturation - 1.f);
  tone_map_config.reno_drt_dechroma = draw_config.tone_map_blowout;
  tone_map_config.reno_drt_flare = 0.10f * pow(draw_config.tone_map_flare, 10.f);
  tone_map_config.reno_drt_working_color_space = (uint)draw_config.tone_map_working_color_space;
  tone_map_config.reno_drt_per_channel = draw_config.tone_map_per_channel == 1.f;
  tone_map_config.reno_drt_hue_correction_method = (uint)draw_config.tone_map_hue_processor;
  tone_map_config.reno_drt_clamp_color_space = draw_config.tone_map_clamp_color_space;
  tone_map_config.reno_drt_clamp_peak = draw_config.tone_map_clamp_peak;
  tone_map_config.reno_drt_tone_map_method = (uint)draw_config.reno_drt_tone_map_method;
  tone_map_config.reno_drt_white_clip = draw_config.reno_drt_white_clip;

  tone_map_config.hue_correction_strength = draw_config.tone_map_hue_correction;
  draw_config.tone_map_hue_shift = 0.f;

  if (draw_config.tone_map_hue_shift != 0.f) {
    tone_map_config.hue_correction_type = renodx::tonemap::config::hue_correction_type::CUSTOM;

    float3 hue_shifted_color;
    if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_CLIP) {
      hue_shifted_color = saturate(color);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_SDR_MODIFIED) {
      renodx::tonemap::renodrt::Config renodrt_config = renodx::tonemap::renodrt::config::Create();
      renodrt_config.nits_peak = 100.f;
      renodrt_config.mid_gray_value = 0.18f;
      renodrt_config.mid_gray_nits = 18.f;
      renodrt_config.exposure = 1.f;
      renodrt_config.highlights = 1.f;
      renodrt_config.shadows = 1.f;
      renodrt_config.contrast = 1.0f;
      renodrt_config.saturation = draw_config.tone_map_hue_shift_modifier;
      renodrt_config.dechroma = 0.f;
      renodrt_config.flare = 0.f;
      renodrt_config.per_channel = false;
      renodrt_config.tone_map_method = 1u;
      renodrt_config.white_clip = 1.f;
      renodrt_config.hue_correction_strength = 0.f;
      renodrt_config.working_color_space = 0u;
      renodrt_config.clamp_color_space = 0u;
      hue_shifted_color = renodx::tonemap::renodrt::BT709(color, renodrt_config);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_AP1_ROLL_OFF) {
      float3 incorrect_hue_ap1 = renodx::color::ap1::from::BT709(color * tone_map_config.mid_gray_value / 0.18f);
      hue_shifted_color = renodx::color::bt709::from::AP1(renodx::tonemap::ExponentialRollOff(incorrect_hue_ap1, tone_map_config.mid_gray_value, 2.f));
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_ACES_FITTED_BT709) {
      hue_shifted_color = renodx::tonemap::ACESFittedBT709(color);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_ACES_FITTED_AP1) {
      hue_shifted_color = renodx::tonemap::ACESFittedAP1(color);
    }
    tone_map_config.hue_correction_color = lerp(
        color,
        hue_shifted_color,
        draw_config.tone_map_hue_shift);
  }

  float3 tonemapped = renodx::tonemap::config::Apply(color, tone_map_config);

  return tonemapped;
}

///////////////////////////////////////////////////////////////////////////
////////// CUSTOM TONEMAPPASS//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

float3 PostToneMapProcess(float3 output) {
  
  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    output = renodx::color::correct::GammaSafe(output, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    output = renodx::color::correct::GammaSafe(output, false, 2.4f);
  }

  output *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    output = renodx::color::correct::GammaSafe(output, true, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    output = renodx::color::correct::GammaSafe(output, true, 2.4f);
  }

  output = renodx::color::srgb::EncodeSafe(output);
  // output = renodx::draw::RenderIntermediatePass(output);

  return output;

}


float3 PostToneMapProcessFMV(float3 output) {
  if (RENODX_TONE_MAP_TYPE > 1.f) {
    [branch]
    if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
      output = renodx::color::correct::GammaSafe(output, false, 2.2f);
    } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
      output = renodx::color::correct::GammaSafe(output, false, 2.4f);
    }

    output *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

    [branch]
    if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
      output = renodx::color::correct::GammaSafe(output, true, 2.2f);
    } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
      output = renodx::color::correct::GammaSafe(output, true, 2.4f);
    }
  }

  output = renodx::color::srgb::EncodeSafe(output);
  // output = renodx::draw::RenderIntermediatePass(output);

  return output;
}

///////////////////////////////////////////////////////////////////////////
////////// CUSTOM TONEMAPPASS//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f

static const float3x3 Wide_2_XYZ_MAT = float3x3(
    0.5441691, 0.2395926, 0.1666943,
    0.2394656, 0.7021530, 0.0583814,
    -0.0023439, 0.0361834, 1.0552183);

static const float3 AP1_RGB2Y = float3(
    0.2722287168,  // AP1_2_XYZ_MAT[0][1],
    0.6740817658,  // AP1_2_XYZ_MAT[1][1],
    0.0536895174   // AP1_2_XYZ_MAT[2][1]
);

float3 hdrExtraSaturation(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
{
  // const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
  // const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
  // const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
  // const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  const float3x3 sRGB_2_AP1 = renodx::color::BT709_TO_AP1_MAT;
  const float3x3 AP1_2_sRGB = renodx::color::AP1_TO_BT709_MAT;
  const float3x3 Wide_2_AP1 = mul(renodx::color::XYZ_TO_AP1_MAT, Wide_2_XYZ_MAT);
  const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  // float3 ColorAP1 = mul(sRGB_2_AP1, vHDRColor);
  float3 ColorAP1 = renodx::color::ap1::from::BT709(vHDRColor);
  float LumaAP1 = renodx::color::y::from::AP1(ColorAP1);

  // float LumaAP1 = dot(ColorAP1, AP1_RGB2Y);
  if (LumaAP1 <= 0.f)
    {
    return vHDRColor;
  }
  float3 ChromaAP1 = ColorAP1 / LumaAP1;

  float ChromaDistSqr = dot(ChromaAP1 - 1, ChromaAP1 - 1);
  // float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));
  float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

  float3 ColorExpand = mul(ExpandMat, ColorAP1);

  // ColorAP1 = lerp(ColorAP1, ColorExpand, fExpandGamut);
  ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);
  // ColorAP1 = ColorExpand;

  // vHDRColor = mul(AP1_2_sRGB, ColorAP1);
  vHDRColor = renodx::color::bt709::from::AP1(ColorAP1);
  return vHDRColor;
}

float3 expandGamut(float3 color, float fExpandGamut /*= 1.0f*/) {

  if (fExpandGamut > 0.f) {
    // Do this with a paper white of 203 nits, so it's balanced (the formula seems to be made for that),
    // and gives consistent results independently of the user paper white
    static const float sRGB_max_nits = 80.f;
    static const float ReferenceWhiteNits_BT2408 = 203.f;
    const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

    float3 vHDRColor = color * recommendedBrightnessScale;

    vHDRColor = hdrExtraSaturation(vHDRColor, fExpandGamut);

    color = vHDRColor / recommendedBrightnessScale;


  }

  return color;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
float ComputeReinhardSmoothClampScale(float3 untonemapped, float rolloff_start = 0.18f, float output_max = 1.f, float white_clip = 100.f) {
  float peak = renodx::math::Max(untonemapped.r, untonemapped.g, untonemapped.b);
  float mapped_peak = renodx::tonemap::ReinhardPiecewiseExtended(peak, white_clip, output_max, rolloff_start);
  float scale = renodx::math::DivideSafe(mapped_peak, peak, 1.f);

  return scale;
}

float3 ToneMapForGrading(float3 untonemapped, float scale) {
  float3 output = renodx::color::bt2020::from::BT709(untonemapped);
  output = max(0, output);

  scale = ComputeReinhardSmoothClampScale(output);
  output *= scale;

  output = renodx::color::bt709::from::BT2020(output);
  return output;
}



#define PI    3.141592653589793238462643383279502884197
#define PI_X2 (PI * 2.0)
#define PI_X4 (PI * 4.0)

float3 CorrectHuePolar(float3 incorrectOkLCH, float3 correctOkLCH, float strength) {
  // skip adjustment for achromatic colors
  const float chromaThreshold = 1e-5;
  float iChroma = incorrectOkLCH.y;
  float cChroma = correctOkLCH.y;

  if (iChroma < chromaThreshold || cChroma < chromaThreshold) {
    return incorrectOkLCH;
  }

  // hues in radians
  float iHue = incorrectOkLCH.z;
  float cHue = correctOkLCH.z;

  // calculate shortest angular difference
  float diff = cHue - iHue;
  if (diff > PI) diff -= PI_X2;
  else if (diff < -PI) diff += PI_X2;

  // apply strength-based correction
  float newHue = iHue + strength * diff;

  float3 adjustedOkLCH = float3(
      incorrectOkLCH.x,
      incorrectOkLCH.y,
      newHue
  );

  return adjustedOkLCH;
}

float UpgradeToneMapRatio(float color_hdr, float color_sdr, float post_process_color) {
  if (color_hdr < color_sdr) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    return color_hdr / color_sdr;
  } else {
    float delta = color_hdr - color_sdr;
    delta = max(0, delta);  // Cleans up NaN
    const float new_value = post_process_color + delta;

    const bool valid = (post_process_color > 0);  // Cleans up NaN and ignore black
    return valid ? (new_value / post_process_color) : 0;
  }
}

float3 UpgradeToneMapPerChannel(float3 color_hdr, float3 color_sdr, float3 post_process_color, float post_process_strength) {
  // float ratio = 1.f;

  float3 bt2020_hdr = max(0, renodx::color::bt2020::from::BT709(color_hdr));
  float3 bt2020_sdr = max(0, renodx::color::bt2020::from::BT709(color_sdr));
  float3 bt2020_post_process = max(0, renodx::color::bt2020::from::BT709(post_process_color));

  float3 ratio = float3(
      UpgradeToneMapRatio(bt2020_hdr.r, bt2020_sdr.r, bt2020_post_process.r),
      UpgradeToneMapRatio(bt2020_hdr.g, bt2020_sdr.g, bt2020_post_process.g),
      UpgradeToneMapRatio(bt2020_hdr.b, bt2020_sdr.b, bt2020_post_process.b));

  float3 color_scaled = max(0, bt2020_post_process * ratio);
  color_scaled = renodx::color::bt709::from::BT2020(color_scaled);
  float peak_correction = saturate(1.f - renodx::color::y::from::BT2020(bt2020_post_process));
  color_scaled = renodx::color::correct::Hue(color_scaled, post_process_color, peak_correction);
  return lerp(color_hdr, color_scaled, post_process_strength);
}

float3 CustomUpgradeToneMapPerChannel(float3 untonemapped, float3 graded) {
  float hueCorrection = 1.f - 0.5f;
  float satStrength = 1.f - 0.5f;

  float3 upgradedPerCh = UpgradeToneMapPerChannel(
      untonemapped,
      renodx::tonemap::renodrt::NeutralSDR(untonemapped),
      graded,
      1.f);

  float3 upgradedPerCh_okLCH = renodx::color::oklch::from::BT709(upgradedPerCh);
  float3 graded_okLCH = renodx::color::oklch::from::BT709(graded);

  // heavy hue correction with graded hue
  upgradedPerCh_okLCH = CorrectHuePolar(upgradedPerCh_okLCH, graded_okLCH, saturate(pow(graded_okLCH.y, hueCorrection)));

  // desaturate highlights based on graded chrominance
  upgradedPerCh_okLCH.y = lerp(graded_okLCH.y, upgradedPerCh_okLCH.y, saturate(pow(graded_okLCH.y, satStrength)));

  upgradedPerCh = renodx::color::bt709::from::OkLCh(upgradedPerCh_okLCH);

  upgradedPerCh = max(-10000000000000000000000000000000000000.f, upgradedPerCh);  // bandaid for NaNs

  return upgradedPerCh;
}

// static const float3x3 Bt709ToBt2020 =
//     float3x3
//       (
//         0.627403914f, 0.329283028f, 0.0433130674f,
//         0.0690972879f, 0.919540405f, 0.0113623151f,
//         0.0163914393f, 0.0880133062f, 0.895595252f
//       );

// static const float3x3 Bt2020ToBt709 =
//     float3x3
//       (
//         1.66049098f, -0.587641119f, -0.0728498622f,
//         -0.124550476f, 1.13289988f, -0.00834942236f,
//         -0.0181507635f, -0.100578896f, 1.11872971f
//       );

// float3 clampBT2020(float3 color) {
//   float3 color_bt2020 = mul(Bt709ToBt2020, color);
//   color_bt2020 = max(color_bt2020, 0.f);
//   return mul(Bt2020ToBt709, color_bt2020);
//   // return renodx::color::bt709::from::BT2020(bt2020);
// }




float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma=2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ?  y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);

  return result;
}





// For LMS

float ReinhardExtended(float x, float white_max, float x_max = 1.f, float shoulder = 0.18f) {
  const float x_min = 0.f;
  // float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  // float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  extended = min(extended, x_max);

  return extended;
}

float3x3 NormalizeXYZToLMS_D65(float3x3 M) {
  static const float3 XYZ_D65 = float3(0.95047f, 1.00000f, 1.08883f);

  float3 LMS_D65 = mul(M, XYZ_D65);
  return float3x3(
      M[0] / LMS_D65.x,
      M[1] / LMS_D65.y,
      M[2] / LMS_D65.z);
}

float3 DKLFromLMS(float3 lms) {
  float3 dkl;
  dkl.x = lms.x + lms.y;                                                 // Luminance (L + M)
  dkl.y = renodx::math::DivideSafe(lms.x - lms.y, dkl.x, 0.f);           // L–M normalized by luminance
  dkl.z = renodx::math::DivideSafe(lms.z - 0.5f * dkl.x, dkl.x, lms.z);  // S–(L+M) normalized
  return dkl;
}

float3 LMSFromDKL(float3 dkl) {
  float3 lms;
  lms.x = 0.5f * dkl.x * (1.0f + dkl.y);         // L = ½ × luminance × (1 + L–M)
  lms.y = 0.5f * dkl.x * (1.0f - dkl.y);         // M = ½ × luminance × (1 - L–M)
  lms.z = 0.5f * dkl.x * (1.0f + 2.0f * dkl.z);  // S = ½ × luminance × (1 + 2×S–(L+M))
  return lms;
}

float3 LMS_ToneMap_Stockman(float3 color, float vibrancy, float contrast) {
  float3 XYZ = renodx::color::xyz::from::BT709(color);
  float original_y = XYZ.y;

  // Not used
  float3x3 XYZ_TO_XYZf = float3x3(
      0.2498f, 0.7865f, 0.0363f,
      0.4429f, 1.3324f, 0.1105f,
      0.0000f, 0.0000f, 1.0000f);

  float3x3 XYZ_TO_XYZf10 = float3x3(
      +0.2080f, 0.8280f, -0.0361f,
      -0.5119f, 1.4009f, 0.1109f,
      +0.0000f, 0.0000f, 1.0000f);

  // Stockman & Sharpe 2 degree
  float3x3 LMS_TO_XYZf = float3x3(
      1.94735469f, -1.41445123f, 0.36476327f,
      0.68990272f, +0.34832189f, 0.00000000f,
      0.00000000f, +0.00000000f, 1.93485343f);

  // float3x3 XYZ_TO_LMS_EE = renodx::color::xyz_TO_HUNT_POINTER_ESTEVEZ_LMS_MAT;

  // Normalize each row of the matrix by its LMS_D65 component
  float3x3 XYZ_TO_LMS = NormalizeXYZToLMS_D65(renodx::math::Invert3x3(LMS_TO_XYZf));
  float3x3 LMS_TO_XYZ = renodx::math::Invert3x3(XYZ_TO_LMS);

  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f

  float3 LMS_WHITE = mul(XYZ_TO_LMS, renodx::color::xyz::from::BT709(1.f));
  float3 LMS_GRAY = mul(XYZ_TO_LMS, renodx::color::xyz::from::BT709(MID_GRAY_LINEAR));
  float3 LMS = mul(XYZ_TO_LMS, XYZ);

  float LMS_sum = LMS.x + LMS.y + LMS.z;
  float3 lms_sensitivies = LMS / (LMS_sum);

  float3 peak_xyz = renodx::color::xyz::from::BT709(1.f);
  float3 peak_lms = mul(XYZ_TO_LMS, peak_xyz);
  float3 peak_lms_sum = peak_lms.x + peak_lms.y + peak_lms.z;
  float3 peak_lms_sensitivities = peak_lms / (peak_lms_sum);

  lms_sensitivies = lms_sensitivies / ((lms_sensitivies) / (peak_lms_sensitivities) + 1.f);

  float3x3 LMS_TO_IPT = renodx::color::PLMS_TO_IPT_MAT;

  float optical_gamma = MID_GRAY_GAMMA;

  float3 lms_vibrancy = renodx::math::SignPow(LMS, 1.f / optical_gamma);
  float3 ipt = mul(LMS_TO_IPT, lms_vibrancy);
  ipt.yz *= vibrancy;
  lms_vibrancy = mul(renodx::math::Invert3x3(LMS_TO_IPT), ipt);
  lms_vibrancy = renodx::math::SignPow(lms_vibrancy, optical_gamma);

  float3 LMS_rel = LMS;
  float3 DKL_original = DKLFromLMS(LMS);
  float3 DKL_gray = DKLFromLMS(LMS_GRAY);

  float3 vibrant_dkl = DKL_original * float3(1.f, vibrancy, vibrancy);

  float3 lms_contrast = LMS_GRAY * renodx::math::SignPow(LMS / LMS_GRAY, contrast);

  bool use_dkl_luminance = true;

  // if (use_dkl_luminance) {
  //   vibrant_dkl.x = DKL_gray.x * renodx::math::SignPow(vibrant_dkl.x / DKL_gray.x, contrast);
  // }

  if (use_dkl_luminance) {
    float r = vibrant_dkl.x / DKL_gray.x;
    float s = sign(r);

    float p = pow(abs(r), contrast) * s;

    vibrant_dkl.x = DKL_gray.x * p;
  }

  lms_vibrancy = LMSFromDKL(vibrant_dkl);

  float3 lms = lms_vibrancy;

  const float human_vision_peak = (4000.f / 203.f);
  float3 peak_human_lms = mul(XYZ_TO_LMS, renodx::color::xyz::from::BT709(float3(human_vision_peak, human_vision_peak, human_vision_peak)));
  float3 midgray_lms = LMS_GRAY;
  // --- Physiological sigma values in your unit scale (1.0 = 100 nits)
  float3 sigma = float3(4.0f, 3.0f, 1.5f);  // L, M, S cones: 400, 300, 150 nits

  // Naka Rushton per cone
  float3 new_lms = float3(
      sign(lms.x) * ReinhardExtended(abs(lms.x), 100.f, peak_human_lms.x, abs(midgray_lms.x)),
      sign(lms.y) * ReinhardExtended(abs(lms.y), 100.f, peak_human_lms.y, abs(midgray_lms.y)),
      sign(lms.z) * ReinhardExtended(abs(lms.z), 100.f, peak_human_lms.z, abs(midgray_lms.z)));

  XYZ = mul(LMS_TO_XYZ, new_lms);

  color = renodx::color::bt709::from::XYZ(XYZ);

  return color;
}

float3 UserColorGrading(
    float3 bt709,
    float exposure,
    float highlights,
    float shadows,
    float contrast,
    float saturation,
    float dechroma) {
  if (exposure == 1.f
      && saturation == 1.f
      && dechroma == 0.f
      && shadows == 1.f
      && highlights == 1.f
      && contrast == 1.f) {
    return bt709;
  }

  float3 color = bt709;

  color *= exposure;

  float y = renodx::color::y::from::BT709(abs(color));
  const float y_contrasted = renodx::color::grade::Contrast(y, contrast);
  float y_highlighted = renodx::color::grade::Highlights(y_contrasted, highlights);
  float y_shadowed = renodx::color::grade::Shadows(y_highlighted, shadows);
  const float y_final = y_shadowed;

  color = renodx::color::correct::Luminance(color, y, y_final);

  if (saturation != 1.f || dechroma != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(color);

    if (dechroma != 0.f) {
      perceptual_new.yz *= lerp(1.f, 0.f, saturate(pow(y / (10000.f / 100.f), (1.f - dechroma))));
    }

    perceptual_new.yz *= saturation;

    color = renodx::color::bt709::from::OkLab(perceptual_new);

    color = renodx::color::bt709::clamp::AP1(color);
  }

  return color;
}



float3 RestoreHighlightSaturation(float3 untonemapped) {
  float l;
  l = renodx::color::y::from::BT709(untonemapped);
  

  float3 displaymappedColor = untonemapped;

  if (CUSTOM_DISPLAY_MAP_TYPE == 1.f) {
    displaymappedColor = renodx::tonemap::dice::BT709(untonemapped, 1.f, 0.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 2.f) {
    displaymappedColor = renodx::tonemap::frostbite::BT709(untonemapped, 1.f, 0.f, 1.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 3.f) {
    untonemapped = min(100.f, untonemapped);
    displaymappedColor = renodx::tonemap::renodrt::NeutralSDR(untonemapped);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 4.f) {
    displaymappedColor = ToneMapMaxCLL(untonemapped);
  }

  float3 output = lerp(untonemapped, displaymappedColor, saturate(l));

  return output;
}

float3 displayMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE <= 1.f)
    return untonemapped;

  // // all options are bad ;)
  // if (shader_injection.custom_display_map_type >= 1) {
  //   untonemapped = RestoreHighlightSaturation(untonemapped);
  // }

  return untonemapped;
}

float NR(float x, float sigma, float n) {
  float ax = abs(x);
  float xn = pow(max(ax, 0.0f), n);
  float sn = pow(max(sigma, 1e-6f), n);
  float r = xn / (xn + sn);
  return (x < 0.0f) ? -r : r;
}

float NR_inv(float r, float sigma, float n) {
  float ar = abs(r);
  float rc = min(ar, 1.0f - 1e-6f);
  float denom = max(1.0f - rc, 1e-6f);
  float x = sigma * pow(rc / denom, 1.0f / n);
  return (r < 0.0f) ? -x : x;
}

// CVVDP-style chroma plateau, but with a cone-domain Naka-Rushton stage.
// The NR semi-saturation is anchored to CastleCSF achromatic sensitivity
// at the adapting background (heuristic tie between detectability and cone gain).
float3 CastleDechroma_CVVDPStyle_NakaRushton(
    float3 rgb_lin,
    float Lbkg_nits = 100.f,
    float diffuse_white = 100.f,
    float nr_n = 1.00f,
    float nr_response_at_thr = 0.18f) {
  // --------------------------------------------------------------------------
  // 1) Convert stimulus + background to LMS and apply cone-domain NR
  // --------------------------------------------------------------------------
  float3x3 XYZ_TO_LMS_2006 = float3x3(
      0.185082982238733f, 0.584081279463687f, -0.0240722415044404f,
      -0.134433056469973f, 0.405752392775348f, 0.0358252602217631f,
      0.000789456671966863f, -0.000912281325916184f, 0.0198490812339463f);

  float3x3 XYZ_TO_LMS_PROPOSED_2023 = float3x3(
      0.185083290265044, 0.584080232530060, -0.0240724126371618,
      -0.134432464433222, 0.405751419882862, 0.0358251078084051,
      0.000789395399878065, -0.000912213029667692, 0.0198489810108856);

  XYZ_TO_LMS_2006 = XYZ_TO_LMS_PROPOSED_2023;

  const float3x3 LMS_TO_XYZ_2006 = renodx::math::Invert3x3(XYZ_TO_LMS_2006);
  const float3x3 BT709_TO_XYZ = renodx::color::BT709_TO_XYZ_MAT;
  const float3x3 XYZ_TO_BT709 = renodx::color::XYZ_TO_BT709_MAT;
  float3x3 BT709_TO_LMS = mul(XYZ_TO_LMS_2006, BT709_TO_XYZ);

  float3 stim_nits = rgb_lin * diffuse_white;
  float3 lms_stim = mul(BT709_TO_LMS, stim_nits);

  float3 lms_bg = mul(BT709_TO_LMS, float3(1, 1, 1) * Lbkg_nits);

  // CastleCSF sensitivity at background (achromatic) -> contrast threshold proxy.
  const float rho = 1.0f;
  const float omega = 0.0f;
  const float ecc = 0.0f;
  const float vis_field = 0.0f;
  const float area = 3.14159265358979323846f;
  float S_ach = renodx::color::castlecsf::Eq27_29_MechSens(rho, omega, ecc, vis_field, area, Lbkg_nits).x;
  float c_thr = 1.0f / max(S_ach, 1e-6f);

  float r_target = clamp(nr_response_at_thr, 1e-3f, 0.999f);
  float sigma_scale = pow((1.0f - r_target) / r_target, 1.0f / max(nr_n, 1e-3f));
  float x_ref = 1.0f + c_thr;

  // Contrast-domain NR: normalize by background LMS so neutral stays neutral.
  float sigma_rel = max(x_ref * sigma_scale, 1e-6f);
  float3 lms_rel = lms_stim / max(abs(lms_bg), float3(1e-6f, 1e-6f, 1e-6f));

  float3 lms_rel_nr = float3(
      NR(lms_rel.x, sigma_rel, nr_n),
      NR(lms_rel.y, sigma_rel, nr_n),
      NR(lms_rel.z, sigma_rel, nr_n));
  float bg_rel_nr = NR(1.0f, sigma_rel, nr_n);

  float3 lms_stim_nr = lms_rel_nr * lms_bg;
  float3 lms_bg_nr = bg_rel_nr.xxx * lms_bg;

  // Test output
  float luminance_in = renodx::color::y::from::BT709(rgb_lin);
  float3 testout = mul(XYZ_TO_BT709, mul(LMS_TO_XYZ_2006, lms_stim_nr)) / diffuse_white;
  float luminance_out = renodx::color::y::from::BT709(testout);
  return testout * luminance_in / luminance_out;
}

float3 LMS_Vibrancy(float3 color, float vibrancy, float contrast) {
  float3 XYZ = renodx::color::xyz::from::BT709(color);
  float original_y = XYZ.y;

  // Not used
  float3x3 XYZ_TO_XYZf = float3x3(
      0.2498f, 0.7865f, 0.0363f,
      0.4429f, 1.3324f, 0.1105f,
      0.0000f, 0.0000f, 1.0000f);

  float3x3 XYZ_TO_XYZf10 = float3x3(
      +0.2080f, 0.8280f, -0.0361f,
      -0.5119f, 1.4009f, 0.1109f,
      +0.0000f, 0.0000f, 1.0000f);

  // Stockman & Sharpe 2 degree
  float3x3 LMS_TO_XYZf = float3x3(
      1.94735469f, -1.41445123f, 0.36476327f,
      0.68990272f, +0.34832189f, 0.00000000f,
      0.00000000f, +0.00000000f, 1.93485343f);

  // float3x3 XYZ_TO_LMS_EE = renodx::color::xyz_TO_HUNT_POINTER_ESTEVEZ_LMS_MAT;

  // Normalize each row of the matrix by its LMS_D65 component
  float3x3 XYZ_TO_LMS = NormalizeXYZToLMS_D65(renodx::math::Invert3x3(LMS_TO_XYZf));
  float3x3 LMS_TO_XYZ = renodx::math::Invert3x3(XYZ_TO_LMS);

  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f

  float3 LMS_WHITE = mul(XYZ_TO_LMS, renodx::color::xyz::from::BT709(1.f));
  float3 LMS_GRAY = mul(XYZ_TO_LMS, renodx::color::xyz::from::BT709(MID_GRAY_LINEAR));
  float3 LMS = mul(XYZ_TO_LMS, XYZ);

  float LMS_sum = LMS.x + LMS.y + LMS.z;
  float3 lms_sensitivies = LMS / (LMS_sum);

  float3 peak_xyz = renodx::color::xyz::from::BT709(1.f);
  float3 peak_lms = mul(XYZ_TO_LMS, peak_xyz);
  float3 peak_lms_sum = peak_lms.x + peak_lms.y + peak_lms.z;
  float3 peak_lms_sensitivities = peak_lms / (peak_lms_sum);

  lms_sensitivies = lms_sensitivies / ((lms_sensitivies) / (peak_lms_sensitivities) + 1.f);

  float3x3 LMS_TO_IPT = renodx::color::PLMS_TO_IPT_MAT;

  float optical_gamma = MID_GRAY_GAMMA;

  float3 lms_vibrancy = renodx::math::SignPow(LMS, 1.f / optical_gamma);
  float3 ipt = mul(LMS_TO_IPT, lms_vibrancy);
  ipt.yz *= vibrancy;
  lms_vibrancy = mul(renodx::math::Invert3x3(LMS_TO_IPT), ipt);
  lms_vibrancy = renodx::math::SignPow(lms_vibrancy, optical_gamma);

  float3 LMS_rel = LMS;
  float3 DKL_original = DKLFromLMS(LMS);
  float3 DKL_gray = DKLFromLMS(LMS_GRAY);

  float3 vibrant_dkl = DKL_original * float3(1.f, vibrancy, vibrancy);

  float3 lms_contrast = LMS_GRAY * renodx::math::SignPow(LMS / LMS_GRAY, contrast);

  bool use_dkl_luminance = true;

  // if (use_dkl_luminance) {
  //   vibrant_dkl.x = DKL_gray.x * renodx::math::SignPow(vibrant_dkl.x / DKL_gray.x, contrast);
  // }

  if (use_dkl_luminance) {
    float r = vibrant_dkl.x / DKL_gray.x;
    float s = sign(r);

    float p = pow(abs(r), contrast) * s;

    vibrant_dkl.x = DKL_gray.x * p;
  }

  lms_vibrancy = LMSFromDKL(vibrant_dkl);

  float3 lms = lms_vibrancy;
  XYZ = mul(LMS_TO_XYZ, lms);

  color = renodx::color::bt709::from::XYZ(XYZ);

  return color;
}

float3 ToneMapPassLMS(float3 untonemapped, float3 graded_sdr_color, renodx::draw::Config config) {
  float3 neutral_sdr = renodx::tonemap::renodrt::NeutralSDR(untonemapped);

  float3 untonemapped_graded = renodx::draw::UpgradeToneMapByLuminance(untonemapped, neutral_sdr, graded_sdr_color, 1.f);

  untonemapped_graded = LMS_ToneMap_Stockman(untonemapped_graded, 1.0f, 1.0f);

  // this dechromas too much
  // untonemapped_graded = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded, 50.f);

  return renodx::draw::ToneMapPass(untonemapped_graded, config);
}

float3 ToneMapPassLMS(float3 untonemapped, float3 graded_sdr_color) {
  return ToneMapPassLMS(untonemapped, graded_sdr_color, renodx::draw::BuildConfig());
}

float3 ToneMapLMS(float3 untonemapped) {
  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 untonemapped_graded = untonemapped;

  untonemapped_graded = LMS_Vibrancy(untonemapped_graded, 1.0f, 1.0f);

  // naka rushton
  untonemapped_graded = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded, 50.f);

  return renodx::draw::ToneMapPass(untonemapped_graded, config);
}

/// Rational curve used in case 4 of Nioh LUT builder.
#define FFXV_GENERATOR(T)                                                                           \
  T ApplyFFXVCurve(T x, float a, float b, float inv, float p, float Tmul, float n46, float n49) {   \
    T tmp = a * x + b;                                                                              \
    tmp = log2(tmp);                                                                                \
    tmp = inv * tmp;                                                                                \
    tmp = tmp * 0.693147182; /* ln2 */                                                              \
    tmp = pow(tmp, p);                                                                              \
    tmp = Tmul * tmp + 1;                                                                           \
    tmp = log2(tmp);                                                                                \
    tmp = n46 * tmp;                                                                                \
    tmp = tmp * 0.693147182; /* ln2 */                                                              \
    tmp = tmp - n49;                                                                                \
    return tmp;                                                                                     \
  }                                                                                                 \
  T ApplyFFXVCurveLn(T x, float a, float b, float inv, float p, float Tmul, float n46, float n49) { \
    T u = inv * log(a * x + b); /* natural log */                                                   \
    u = pow(u, p);                                                                                  \
    T y = n46 * log(1 + Tmul * u) - n49;                                                            \
    return y;                                                                               \
  } \

FFXV_GENERATOR(float)
FFXV_GENERATOR(float3)
#undef FFXV_GENERATOR

float Derivative_FFXVCurveLn(
    float x,
    float a,
    float b,
    float inv,
    float p,
    float Tmul,
    float n46)
{
  float axb = a * x + b;
  float g = log(axb);  // ln(a*x + b)
  float u = inv * g;   // inner log domain

  float up = pow(u, p);            // u^p
  float dup = p * pow(u, p - 1.0)  // derivative of u^p
              * inv * a / axb;

  return n46 * (Tmul * dup) / (1.0 + Tmul * up);
}

float FFXV_ypp(
    float x, float a, float b, float inv, float p, float Tmul, float n46)
{
  float axb = max(a * x + b, 1e-6);
  float g = log(axb);
  // If g can go <= 0 in your domain, clamp it to avoid pow issues:
  float gSafe = max(g, 1e-6);

  float u = inv * gSafe;

  float up = pow(u, p);  // u^p

  // (u^p)' = p*u^(p-1) * inv*a/(ax+b)
  float up_p = p * pow(u, p - 1.0) * (inv * a / axb);

  // (u^p)'' = p*inv*a^2/(ax+b)^2 * u^(p-2) * ((p-1) - g)
  float up_pp = p * inv * (a * a) / (axb * axb) * pow(u, p - 2.0) * ((p - 1.0) - gSafe);

  float denom = 1.0 + Tmul * up;

  return n46 * ((Tmul * up_pp) / denom - (Tmul * Tmul * up_p * up_p) / (denom * denom));
}

float FindInflection_FFXV(
    float xmin, float xmax,
    int scanSteps, int bisectIters,
    float a, float b, float inv, float p, float Tmul, float n46)
{
  float logMin = log(xmin + 1e-6);
  float logMax = log(xmax);

  float xPrev = exp(logMin);
  float fPrev = FFXV_ypp(xPrev, a, b, inv, p, Tmul, n46);

  float xl = xPrev, fl = fPrev;
  float xr = xPrev, fr = fPrev;
  bool found = false;

  // 1) scan for sign change
  [loop]
  for (int i = 1; i <= scanSteps; i++)
    {
    float x = exp(lerp(logMin, logMax, (float)i / (float)scanSteps));
    float f = FFXV_ypp(x, a, b, inv, p, Tmul, n46);

    if ((fPrev <= 0 && f >= 0) || (fPrev >= 0 && f <= 0))
        {
      xl = xPrev; fl = fPrev;
      xr = x; fr = f;
      found = true;
      break;
    }

    xPrev = x;
    fPrev = f;
  }

  if (!found) return -1.0;  // no inflection in the range

  // 2) bisection (midpoint in log space)
  [loop]
  for (int it = 0; it < bisectIters; it++)
    {
    float xm = sqrt(xl * xr);
    float fm = FFXV_ypp(xm, a, b, inv, p, Tmul, n46);

    if ((fl <= 0 && fm >= 0) || (fl >= 0 && fm <= 0))
        {
      xr = xm; fr = fm;
    }
        else
        {
      xl = xm; fl = fm;
    }
  }

  return sqrt(xl * xr);
}

#define APPLYFFXVEXTENDED_GENERATOR(T)                                                                 \
  T ApplyFFXVExtended(                                                                                 \
      T x, T base, float a, float b, float inv, float p, float Tmul, float n46, float n49, float inflection) { \
    float pivot_x = inflection;                                                                        \
                                                                                                       \
    float pivot_y = ApplyFFXVCurveLn(pivot_x, a, b, inv, p, Tmul, n46, n49);              \
                                                                         \
    float slope = Derivative_FFXVCurveLn(pivot_x, a, b, inv, p, Tmul, n46);                \
                                                                         \
    /* Line passing through (pivot_x, pivot_y) with matching slope */    \
    T offset = pivot_y - slope * pivot_x;                                \
    T extended = slope * x + offset;                                     \
                                                                         \
    return lerp(base, extended, step(pivot_x, x));                       \
  }

APPLYFFXVEXTENDED_GENERATOR(float)
APPLYFFXVEXTENDED_GENERATOR(float3)
#undef APPLYFFXVEXTENDED_GENERATOR

float3 CorrectHueAndPurityMB(
    float3 target_color_bt709,
    float3 reference_color_bt709,
    float curve_gamma = 1.f,
    float2 mb_white_override = float2(-1.f, -1.f),
    float t_min = 1e-6f) {
  float3 target_color_bt2020 = renodx::color::bt2020::from::BT709(target_color_bt709);
  float3 reference_color_bt2020 = renodx::color::bt2020::from::BT709(reference_color_bt709);

  float reference_purity01 =
      renodx_custom::color::macleod_boynton::ApplyBT2020(reference_color_bt2020, 1.f, 1.f,
                                                         mb_white_override, t_min)
          .purityCur01;

  float3 target_lms = mul(renodx_custom::color::macleod_boynton::XYZ_TO_LMS_2006,
                          mul(renodx::color::BT2020_TO_XYZ_MAT, target_color_bt2020));
  float target_t = target_lms.x + target_lms.y;
  if (target_t <= t_min) {
    return target_color_bt709;
  }

  float3 reference_lms = mul(renodx_custom::color::macleod_boynton::XYZ_TO_LMS_2006,
                             mul(renodx::color::BT2020_TO_XYZ_MAT, reference_color_bt2020));

  float2 white = (mb_white_override.x >= 0.f && mb_white_override.y >= 0.f)
                     ? mb_white_override
                     : renodx_custom::color::macleod_boynton::MB_White_D65();

  float2 target_direction = renodx_custom::color::macleod_boynton::MB_From_LMS(target_lms) - white;
  float2 reference_direction = renodx_custom::color::macleod_boynton::MB_From_LMS(reference_lms) - white;
  float reference_len_sq = dot(reference_direction, reference_direction);

  // If donor hue is undefined (near white), fallback to purity-only transfer.
  if (reference_len_sq < renodx_custom::color::macleod_boynton::MB_NEAR_WHITE_EPSILON) {
    return renodx::color::bt709::from::BT2020(
        renodx_custom::color::macleod_boynton::ApplyBT2020(
            target_color_bt2020, reference_purity01, curve_gamma, mb_white_override, t_min)
            .rgbOut);
  }

  float2 mb_seed = white + reference_direction * rsqrt(reference_len_sq) * length(target_direction);

  float3 lms_seed = renodx_custom::color::macleod_boynton::LMS_From_MB_T(mb_seed, target_t);
  float3 xyz_seed = mul(renodx_custom::color::macleod_boynton::LMS_TO_XYZ_2006, lms_seed);
  float3 seed_bt2020 = mul(renodx::color::XYZ_TO_BT2020_MAT, xyz_seed);

  return renodx::color::bt709::from::BT2020(
      renodx_custom::color::macleod_boynton::ApplyBT2020(
          seed_bt2020, reference_purity01, curve_gamma, mb_white_override, t_min)
          .rgbOut);
}