#include "../shared.h"
#include "DICE.hlsl"
#include "./colorcorrect.hlsl"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

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

float inv_tonemap_ReinhardPerComponent(float L, float L_white) {
  const float L2 = L * L;
  const float LW2 = L_white * L_white;
  const float LP1 = (0.5f * ((L * LW2) - LW2));
  // It shouldn't be possible for this to be negative (but if it was, put a max() with 0)
  const float LP2P1 = LW2 * ((L2 * LW2) - (2.0f * L * LW2) + (4.0f * L) + LW2);
  const float LP2 = (0.5f * sqrt(LP2P1));

  // The results can both be negative for some reason (especially on pitch black pixels), so we max against 0.
  const float LA = LP1 + LP2;
  L = max(LA, 0.0f);

  return L;
}

float3 inv_tonemap_ReinhardPerComponent(float3 L, float L_white) {
  const float3 L2 = L * L;
  const float LW2 = L_white * L_white;
  const float3 LP1 = (0.5f * ((L * LW2) - LW2));
  // It shouldn't be possible for this to be negative (but if it was, put a max() with 0)
  const float3 LP2P1 = LW2 * ((L2 * LW2) - (2.0f * L * LW2) + (4.0f * L) + LW2);
  const float3 LP2 = (0.5f * sqrt(LP2P1));

  // The results can both be negative for some reason (especially on pitch black pixels), so we max against 0.
  const float3 LA = LP1 + LP2;
  L = max(LA, 0.0f);

  return L;
}

float3 RestoreHue(float3 targetColor, float3 sourceColor, float amount = 0.5)
{
  float3 oklch = renodx::color::oklch::from::BT709(sourceColor);
  float3 rgb = sourceColor;

  // Invalid or black colors fail oklab conversions or ab blending so early out
  float y = renodx::color::y::from::BT709(targetColor);
  float bloom_y = renodx::color::y::from::BT709(targetColor);

  if (bloom_y < FLT_MIN)
  {
    // Optionally we could blend the target towards the source, or towards black, but there's no need until proven otherwise
    return targetColor;
  }

  const float3 targetOklab = renodx::color::oklab::from::BT709(targetColor);
  const float3 targetOklch = renodx::color::oklch::from::OkLab(targetOklab);
  const float3 sourceOklab = renodx::color::oklab::from::BT709(sourceColor);

  // First correct both hue and chrominance at the same time (oklab a and b determine both, they are the color xy coordinates basically).
  // As long as we don't restore the hue to a 100% (which should be avoided), this will always work perfectly even if the source color is pure white (or black, any "hueless" and "chromaless" color).
  // This method also works on white source colors because the center of the oklab ab diagram is a "white hue", thus we'd simply blend towards white (but never flipping beyond it (e.g. from positive to negative coordinates)),
  // and then restore the original chrominance later (white still conserving the original hue direction, so likely spitting out the same color as the original, or one very close to it).
  float3 correctedTargetOklab = float3(targetOklab.x, lerp(targetOklab.yz, sourceOklab.yz, amount));

  // Then restore chrominance
  float3 correctedTargetOklch = renodx::color::oklch::from::OkLab(correctedTargetOklab);
  correctedTargetOklch.y = targetOklch.y;

  return renodx::color::bt709::from::OkLCh(correctedTargetOklch);
}

float3 saturation(float3 color, float saturation)
{
  float luminance = renodx::color::y::from::BT709(color);
  return lerp(luminance, color, saturation);
}

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
  float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

  float3 ColorExpand = mul(ExpandMat, ColorAP1);
  ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);

  vHDRColor = mul(AP1_2_sRGB, ColorAP1);
  return vHDRColor;
}

float average(float3 vColor)
{
  return dot(vColor, float3(1.f / 3.f, 1.f / 3.f, 1.f / 3.f));
}

bool IsNAN(const float input)
{
  if (isnan(input) || isinf(input))
    return true;
  else
    return false;
}

float fixNAN(const float input)
{
  if (IsNAN(input))
    return 0.f;
  else
    return input;
}

float3 fixNAN(float3 input)
{
  if (IsNAN(input.r))
    input.r = 0.f;
  else if (IsNAN(input.g))
    input.g = 0.f;
  else if (IsNAN(input.b))
    input.b = 0.f;

  return input;
}


float3 PumboInverseTonemap(float3 color) {
  float3 originalColor = color;
  float3 fineTunedColor = color;
  float3 mid_gray = 0.18f;
  // float3 inverse_luminance = color;

  if (INVERSE_TONEMAP_WHITE_LEVEL == 0) {
    return color;
  }
  float PreTonemapLuminance = renodx::color::y::from::BT709(color);

  bool per_channel = RENODX_TONE_MAP_PER_CHANNEL;

  if (per_channel) {
    color = inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL);

    color *= mid_gray / average(inv_tonemap_ReinhardPerComponent(mid_gray, INVERSE_TONEMAP_WHITE_LEVEL));

  } else {
    float PostTonemapLuminance = renodx::color::y::from::BT709(inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL));
    // float PostTonemapLuminance = inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL).r;

    // likely to eliminate NaN.
    float scale = max(1.f, PostTonemapLuminance / PreTonemapLuminance);
    color *= scale;

    color = renodx::color::bt709::clamp::AP1(color);
  }

  if (INVERSE_TONEMAP_COLOR_CONSERVATION != 0.f)
    // Restore part of the original color "saturation" and "hue", but keep the new luminance
    color = RestoreHue(color, fineTunedColor, INVERSE_TONEMAP_COLOR_CONSERVATION);

  // // return color;
  fineTunedColor = color;

  if (INVERSE_TONEMAP_HIGHLIGHT_SATURATION != 1.f)
    {
    const float OklabLightness = renodx::color::oklab::from::BT709(fineTunedColor)[0];
    const float highlightSaturationRatio = max((OklabLightness - (2.f / 3.f)) / (1.f / 3.f), 0.f);
    fineTunedColor = saturation(fineTunedColor, lerp(1.f, INVERSE_TONEMAP_HIGHLIGHT_SATURATION, highlightSaturationRatio));
  }

  float3 displayMappedColor = fineTunedColor;

  // return displayMappedColor;
  displayMappedColor = fixNAN(displayMappedColor);

  float weight;
  if (RENODX_GAMMA_CORRECTION == 0.f)
    weight = saturate(pow(PreTonemapLuminance, 1.f));
  else if (RENODX_GAMMA_CORRECTION == 1.f)
    weight = saturate(pow(PreTonemapLuminance, 2.2));
  else if (RENODX_GAMMA_CORRECTION == 2.f)
    weight = saturate(pow(PreTonemapLuminance, 2.4));

  float3 finalColor = lerp(originalColor, displayMappedColor, weight);

  // // expand gamut
  // if (INVERSE_TONEMAP_EXTRA_HDR_SATURATION > 0.f) {
  //   const float ReferenceWhiteNits_BT2408 = 203.f;
  //   const float sRGB_max_nits = 80.f;
  //   const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

  //   fineTunedColor = finalColor * recommendedBrightnessScale;
  //   fineTunedColor = expandGamut(fineTunedColor, INVERSE_TONEMAP_EXTRA_HDR_SATURATION);
  //   finalColor = fineTunedColor / recommendedBrightnessScale;
  // }
  // // finalColor = fixNAN(finalColor);
  // finalColor = renodx::color::bt709::clamp::AP1(finalColor);
  return finalColor;
}

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




float3 expandColorGamut(float3 finalColor) {
  if (INVERSE_TONEMAP_EXTRA_HDR_SATURATION > 0.f) {
    const float ReferenceWhiteNits_BT2408 = 203.f;
    const float sRGB_max_nits = 80.f;
    const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

    float3 fineTunedColor = finalColor * recommendedBrightnessScale;
    fineTunedColor = expandGamut(fineTunedColor, INVERSE_TONEMAP_EXTRA_HDR_SATURATION);
    finalColor = fineTunedColor / recommendedBrightnessScale;
  
    return finalColor;
  } else {
    return finalColor;
  }
}

float UpgradeToneMapRatio(float color_hdr, float color_sdr) {
  if (color_hdr < color_sdr) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    return 1.f;
  } else {
    float ap1_delta = color_hdr - color_sdr;
    ap1_delta = max(0, ap1_delta);  // Cleans up NaN
    const float ap1_new = color_sdr + ap1_delta;

    const bool ap1_valid = (color_sdr > 0.f && color_hdr > 0.f);  // Cleans up NaN and ignore black
    return ap1_valid ? (ap1_new / color_sdr) : 1.f;
  }
}


float3 scaleByLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  float bloomY = renodx::color::y::from::BT709(bloomColor);
  float Y = renodx::color::y::from::BT709(color);

  float scale = UpgradeToneMapRatio(bloomY, Y);

  scale = clamp(scale, 1.0f, max_scale);
  color = color * scale;

  
  return color;
}

float3 scaleByOKLabLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  float3 bloomColor_oklab = renodx::color::oklab::from::BT709(bloomColor);
  float3 color_oklab = renodx::color::oklab::from::BT709(color);

  // per channel scaling
  float bloomL = bloomColor_oklab.x;
  float L = color_oklab.x;

  float scale = UpgradeToneMapRatio(bloomL, L);
  scale = clamp(scale, 1.0f, max_scale);

  color_oklab = float3(color_oklab.x * scale, color_oklab.y, color_oklab.z);

  color = renodx::color::bt709::from::OkLab(color_oklab);

  return color;
}

float find_scale_for_matching_luminance(float3 rgb_in, float target_I, float max_scale = 4.f, int num_iter = 20) {
  float s_lo = 0.0f, s_hi = max_scale;
  for (int i = 0; i < num_iter; ++i) {  // 20 iterations for high precision
    float s_mid = 0.5f * (s_lo + s_hi);
    float3 rgb_scaled = rgb_in * s_mid;
    float I = renodx::color::ictcp::from::BT709(rgb_scaled).x;
    if (I < target_I)
      s_lo = s_mid;
    else
      s_hi = s_mid;
  }
  return 0.5f * (s_lo + s_hi);
}

// Finds the maximum scale factor for "I" (intensity) in ICtCp space
// such that the RGB result never goes negative.
// For HDR: positive values are allowed, only negatives are forbidden.
//
// Arguments:
//   I        -- original intensity ("I" component) of the color in ICtCp
//   Ct       -- chroma-t ("Ct" component) of the color in ICtCp
//   Cp       -- chroma-p ("Cp" component) of the color in ICtCp
//   ICtCp_to_RGB -- a function that converts ICtCp (float3) to RGB (float3)
//
// Returns:
//   The largest scale factor s >= 1 so that all(RGB(ICtCp(I*s, Ct, Cp)) >= 0)
float max_scale_icp(
    float3 color, float max_scale
)
{
  float s_lo = 1.0;        // Minimum scale (no change)
  float s_hi = max_scale;  // Arbitrary large upper bound (increase if needed)
  float max_nits_normalized = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS; // lets use 10000.f

  // Bisection: find largest s where RGB >= 0
  for (int i = 0; i < 17; ++i)  // 8 steps for decent precision
  {
    float s_mid;
    if (i == 0)
      s_mid = max_scale;
    else
      s_mid = 0.5 * (s_lo + s_hi);
    float3 rgb = renodx::color::bt709::from::ICtCp(float3(color.x * s_mid, color.y, color.z));
    if (all(rgb >= 0.0) && all(rgb <= max_nits_normalized)) {
      s_lo = s_mid;  // Try larger scale
    } else {
      s_hi = s_mid;  // Too large, try smaller
    }

    if (s_hi == s_lo) {
      return s_hi;
    }
  }
  return s_lo;  // Best found scale that is safe
}

float3 scaleByPerceptualLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {


  float3 originalColor = color;
  float3 bloomColor_perceptual = renodx::color::ictcp::from::BT709(bloomColor);
  float3 color_perceptual = renodx::color::ictcp::from::BT709(color);

  // compute Luminance
  float bloomL = bloomColor_perceptual.x;
  float L = color_perceptual.x;

  float bloom_chrominance = (length(bloomColor_perceptual.yz));  // eg: 0.80
  float chrominance = (length(color_perceptual.yz));      // eg: 0.20
  float new_chroma_len = max(chrominance, bloom_chrominance);

  float scale = UpgradeToneMapRatio(bloomL, L);
  float chrominance_scale = UpgradeToneMapRatio(bloom_chrominance, chrominance);

  // scale y and z by chrominance scale causes artifact (exhibited in the bloomColor)
  chrominance_scale = 1.f;
  scale = clamp(scale, 1.0f, max_scale);

  color_perceptual = float3(color_perceptual.x * scale, color_perceptual.y * chrominance_scale, color_perceptual.z * chrominance_scale);

  color = renodx::color::bt709::from::ICtCp(color_perceptual);

  return color;
}

float3 scaleChrominance(float3 color, float3 bloomColor) {
  float3 bloomColor_oklch = renodx::color::oklch::from::BT709(bloomColor);
  float3 color_oklch = renodx::color::oklch::from::BT709(color);

  float scale = UpgradeToneMapRatio(bloomColor_oklch.y, color_oklch.y);

  if (bloomColor_oklch.y > color_oklch.y) 
    color_oklch.y = bloomColor_oklch.y;

  color = renodx::color::bt709::from::OkLCh(color_oklch);

  return color;

}



float3 decodeColor(float3 color, bool srgb = true) {
  if (srgb) {
    return renodx::color::srgb::DecodeSafe(color);
  } else {
    return renodx::color::gamma::DecodeSafe(color, 2.2f);
  }

}

float3 SDRTonemap(float3 color) {
  float tone_map_hue_correction_method = RENODX_TONE_MAP_HUE_CORRECTION_METHOD;
  float3 sdr_color;
  color = max(0.f, color);

  if (tone_map_hue_correction_method == 2.f) {
    sdr_color = renodx::tonemap::dice::BT709(color, 1.f, 0.25f);
  } else if (tone_map_hue_correction_method == 1.f) {
    sdr_color = renodx::tonemap::renodrt::NeutralSDR(color);
  } else if (tone_map_hue_correction_method == 0.f) {
    sdr_color = renodx::tonemap::Reinhard(max(color, 0.f));
  } else if (tone_map_hue_correction_method == 3.f) {
    sdr_color = renodx::tonemap::uncharted2::BT709(max(color, 0.f));
  } else if (tone_map_hue_correction_method == 3.f) {
    sdr_color = renodx::tonemap::ACESFittedAP1(color);
  } else if (tone_map_hue_correction_method == 4.f) {
    sdr_color = color;
  }

  return sdr_color;
}

float3 processColorBuffer(float3 color) {

  color = max(color, 0.f);

  return color;
}

float4 processColorBuffer(float4 color) {

  color.rgb = processColorBuffer(color.rgb);
  color.w = saturate(color.w);

  return color;
}

float3 processBloomBuffer(float3 color) {

  color = max(color, 0.f);


  return color;
}

float4 processBloomBuffer(float4 color) {
  color.rgb = processColorBuffer(color.rgb);
  color.w = saturate(color.w);

  return color;
}

float3 postProcessBloomBuffer(float3 color) {
  
  return color;
}

float3 correctHue(float3 color, float3 correctColor) {
  if (RENODX_TONE_MAP_HUE_CORRECTION <= 0.f) {
    return color;
  }

  float3 sdrColor = SDRTonemap(correctColor);

  // this fixes the math error artifacts 
  color = renodx::color::bt709::clamp::BT709(color);

  // float hue_correction_strength = saturate(renodx::color::y::from::BT709(color));
  float hue_correction_strength = RENODX_TONE_MAP_HUE_CORRECTION;

  color = renodx::color::correct::Hue(color, sdrColor,
                                      hue_correction_strength,
                                      RENODX_TONE_MAP_HUE_PROCESSOR);


  return color;
}

float3 ToneMap(float3 color) {
  

  color = max(color, 0.f);

  float3 originalColor = color;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return saturate(color);
  } else if (shader_injection.tone_map_type == 1.f) {
    if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      color = renodx::color::bt2020::from::BT709(color);
    } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      color = renodx::color::ap1::from::BT709(color);
    }

    color = FrostbiteToneMap(color);

    if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      color = renodx::color::bt709::from::BT2020(color);
    } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      color = renodx::color::bt709::from::AP1(color);
    }
    return color;
  }
  else if (shader_injection.tone_map_type == 2.f) {
    if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      color = renodx::color::bt2020::from::BT709(color);
    } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      color = renodx::color::ap1::from::BT709(color);
    }

    color = DICEToneMap(color);

    if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      color = renodx::color::bt709::from::BT2020(color);
    } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      color = renodx::color::bt709::from::AP1(color);
    }

    return color;
  
  }

  renodx::draw::Config draw_config = renodx::draw::BuildConfig();
  draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;

  renodx::tonemap::Config tone_map_config = renodx::tonemap::config::Create();
  tone_map_config.peak_nits = draw_config.peak_white_nits;
  tone_map_config.game_nits = draw_config.diffuse_white_nits;
  tone_map_config.type = draw_config.tone_map_type;
  tone_map_config.gamma_correction = draw_config.gamma_correction;
  tone_map_config.exposure = draw_config.tone_map_exposure;
  tone_map_config.highlights = draw_config.tone_map_highlights;
  tone_map_config.shadows = draw_config.tone_map_shadows;
  tone_map_config.contrast = draw_config.tone_map_contrast;
  tone_map_config.saturation = draw_config.tone_map_saturation;

  tone_map_config.mid_gray_value = 0.18f;
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

  // removed the code for hue correction
  float3 tonemapped = renodx::tonemap::config::Apply(color, tone_map_config);

  return tonemapped;
}

float3 processAndToneMap(float3 color) {
  color = ToneMap(color);
  color = expandColorGamut(color);
  color = renodx::color::bt709::clamp::BT2020(color);
  color = renodx::draw::RenderIntermediatePass(color);
  return color;
}

float3 scaleColor(float3 color, float3 bloomColor, float max_scale = 4.f) {
  if (BROKEN_BLOOM == 2.f) {
    return color;
  }
  else if (BROKEN_BLOOM == 1.f) {
    return bloomColor;
  }

  float3 unscaledColor = color;
  color = scaleByPerceptualLuminance(unscaledColor, bloomColor, max_scale);
  float3 lum_color = scaleByLuminance(unscaledColor, bloomColor, max_scale);

  float3 scaledColor;
  if (BLOOM_APPROX_METHOD == 0.f) {
    scaledColor = color;
    scaledColor = renodx::color::correct::ChrominanceICtCp(scaledColor, lum_color, 1.0f);
  } else {
    scaledColor = lum_color;
  }
  
  color = correctHue(scaledColor, scaledColor);

  return color;
}