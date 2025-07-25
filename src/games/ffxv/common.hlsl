
#include "./shared.h"

static const float M1 = 2610.f / 16384.f;           // 0.1593017578125f;
static const float M2 = 128.f * (2523.f / 4096.f);  // 78.84375f;
static const float C1 = 3424.f / 4096.f;            // 0.8359375f;
static const float C2 = 32.f * (2413.f / 4096.f);   // 18.8515625f;
static const float C3 = 32.f * (2392.f / 4096.f);   // 18.6875f;

float PQEncode(float color, float scaling = 10000.f) {
  color *= (scaling / 10000.f);
  float3 y_m1 = pow(color, M1);
  return pow((C1 + C2 * y_m1) / (1.f + C3 * y_m1), M2);
}

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
  if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    output = renodx::color::correct::GammaSafe(output, true, 2.2f);
  } else if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    output = renodx::color::correct::GammaSafe(output, true, 2.4f);
  }

  output = renodx::color::srgb::EncodeSafe(output);

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

float3 expandGamut(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
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

//////////////////////////////////////////////////////////////////////////////////////////////////

float3 RestoreHighlightSaturation(float3 untonemapped) {
  float l;
  if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1.f) {
    untonemapped = renodx::color::bt2020::from::BT709(untonemapped);
    l = renodx::color::y::from::BT2020(untonemapped);
  } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2.f) {
    untonemapped = renodx::color::ap1::from::BT709(untonemapped);
    l = renodx::color::y::from::AP1(untonemapped);
  }

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

  if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1.f) {
    output = renodx::color::bt709::from::BT2020(output);
  } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2.f) {
    output = renodx::color::bt709::from::AP1(output);
  }

  return output;
}

float3 displayMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE <= 1.f)
    return untonemapped;

  if (CUSTOM_DISPLAY_MAP_TYPE == 0.f) {
    return untonemapped;
  } else {
    return RestoreHighlightSaturation(untonemapped);
  }
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
  float hueCorrection = 1.f - CUSTOM_TONEMAP_UPGRADE_HUECORR;
  float satStrength = 1.f - CUSTOM_TONEMAP_UPGRADE_STRENGTH;

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