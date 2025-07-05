#include "../shared.h"

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
  // Invalid or black colors fail oklab conversions or ab blending so early out
  if (renodx::color::y::from::BT709(targetColor) <= FLT_MIN)
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

float3 CorrectChrominanceOKLab(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 correct_lab = renodx::color::oklab::from::BT709(correct_color);
  float3 incorrect_lab = renodx::color::oklab::from::BT709(incorrect_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 correct_ab = correct_lab.yz;

  // Compute chrominance (magnitude of the a–b vector)
  float incorrect_chrominance = length(incorrect_ab);
  float correct_chrominance = length(correct_ab);

  // Get tint (hue direction)
  float2 incorrect_direction = (incorrect_ab / incorrect_chrominance) * step(0.f, incorrect_chrominance);

  // Blend chrominance and apply to original tint
  float blended_chroma = lerp(incorrect_chrominance, correct_chrominance, strength);
  incorrect_lab.yz = incorrect_direction * blended_chroma;

  float3 color = renodx::color::bt709::from::OkLab(incorrect_lab);
  color = renodx::color::bt709::clamp::AP1(color);
  return color;
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

float3 BT709(float3 bt709, renodx::tonemap::renodrt::Config current_config) {
  const float n_r = 100.f;
  float n = 1000.f;

  // drt cam
  // n_r = 100
  // g = 1.15
  // c = 0.18
  // c_d = 10.013
  // w_g = 0.14
  // t_1 = 0.04
  // r_hit_min = 128
  // r_hit_max = 896

  float g = 1.1;            // gamma/contrast
  float c = 0.18;           // scene-referred gray
  float c_d = 10.013;       // output gray in nits
  const float w_g = 0.00f;  // gray change
  float t_1 = 0.01;         // shadow toe
  const float r_hit_min = 128;
  const float r_hit_max = 256;

  float white_clip = 100.f;

  g = current_config.contrast;
  c = current_config.mid_gray_value;
  c_d = current_config.mid_gray_nits;
  n = current_config.nits_peak;
  t_1 = current_config.flare;
  white_clip = current_config.white_clip;

  float3 input_color;
  float y_original;

  float current_color_space = current_config.working_color_space;

  if (current_config.working_color_space == 2u) {
    input_color = max(0, renodx::color::ap1::from::BT709(bt709));
    y_original = renodx::color::y::from::AP1(input_color);
  } else if (current_config.working_color_space == 1u) {
    input_color = renodx::color::bt2020::from::BT709(bt709);
    y_original = renodx::color::y::from::BT2020(abs(input_color));
  } else {
    input_color = bt709;
    y_original = renodx::color::y::from::BT709(abs(bt709));
  }

  float y = y_original;

  y *= current_config.exposure;
  y = renodx::tonemap::renodrt::CustomizeLuminance(y, current_config.highlights, current_config.shadows);

  float3 per_channel_color;
  [branch]
  if (current_config.per_channel) {
    per_channel_color = input_color * (y_original > 0 ? (y / y_original) : 0);
  } else {
    per_channel_color = input_color;
  }

  float m_0 = (n / n_r);

  float3 color_output;
  
  // REINHARD 
  white_clip = max(white_clip, m_0);
  white_clip = renodx::tonemap::renodrt::CustomizeLuminance(white_clip, current_config.highlights, current_config.shadows, current_config.contrast);

  [branch]
  if (current_config.per_channel) {
    color_output = per_channel_color;
    color_output /= 0.18f;
    float3 signs = sign(color_output);
    color_output = abs(color_output);

    // No guard for oversized flare
    float3 new_flare = renodx::math::DivideSafe(color_output + current_config.flare, color_output, 1.f);

    float3 exponent = current_config.contrast * new_flare;

    color_output = pow(color_output, exponent);

    color_output *= 0.18f;

    color_output = renodx::tonemap::ReinhardScalableExtended(
        color_output,
        white_clip,
        m_0,
        0,
        0.18f,
        current_config.mid_gray_nits / 100.f);

    color_output *= signs;

  } 

  [branch]
  if (current_config.dechroma != 0.f
      || current_config.saturation != 1.f
      || current_config.hue_correction_strength != 0.f
      || current_config.blowout != 0.f) {
    color_output = renodx::color::convert::ColorSpaces(color_output, current_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    current_color_space = renodx::color::convert::COLOR_SPACE_BT709;

    float3 perceptual_new;

    if (current_config.hue_correction_strength != 0.f) {
      float3 perceptual_old;
      float3 source = (current_config.hue_correction_type == renodx::tonemap::renodrt::config::hue_correction_type::INPUT)
                          ? bt709
                          : current_config.hue_correction_source;

      [branch]
      switch (current_config.hue_correction_method) {
        case renodx::tonemap::renodrt::config::hue_correction_method::OKLAB:
        default:
          perceptual_new = renodx::color::oklab::from::BT709(color_output);
          perceptual_old = renodx::color::oklab::from::BT709(source);
          break;
        case renodx::tonemap::renodrt::config::hue_correction_method::ICTCP:
          perceptual_new = renodx::color::ictcp::from::BT709(color_output);
          perceptual_old = renodx::color::ictcp::from::BT709(source);
          break;
        case renodx::tonemap::renodrt::config::hue_correction_method::DARKTABLE_UCS:
          perceptual_new = renodx::color::dtucs::uvY::from::BT709(color_output).zxy;
          perceptual_old = renodx::color::dtucs::uvY::from::BT709(source).zxy;
          break;
      }

      // Save chrominance to apply back
      float chrominance_pre_adjust = length(perceptual_new.yz);

      perceptual_new.yz = lerp(perceptual_new.yz, perceptual_old.yz, current_config.hue_correction_strength);

      float chrominance_post_adjust = length(perceptual_new.yz);

      // Apply back previous chrominance

      perceptual_new.yz *= renodx::math::DivideSafe(chrominance_pre_adjust, chrominance_post_adjust, 1.f);
    } else {
      [branch]
      switch (current_config.hue_correction_method) {
        default:
        case renodx::tonemap::renodrt::config::hue_correction_method::OKLAB:
          perceptual_new = renodx::color::oklab::from::BT709(color_output);
          break;
        case renodx::tonemap::renodrt::config::hue_correction_method::ICTCP:
          perceptual_new = renodx::color::ictcp::from::BT709(color_output);
          break;
        case renodx::tonemap::renodrt::config::hue_correction_method::DARKTABLE_UCS:
          perceptual_new = renodx::color::dtucs::uvY::from::BT709(color_output).zxy;
          break;
      }
    }

    if (current_config.dechroma != 0.f) {
      perceptual_new.yz *= lerp(1.f, 0.f, saturate(pow(y_original / (10000.f / 100.f), (1.f - current_config.dechroma))));
    }

    if (current_config.blowout != 0.f) {
      float percent_max = saturate(y_original * 100.f / 10000.f);
      // positive = 1 to 0, negative = 1 to 2
      float blowout_strength = 100.f;
      float blowout_change = pow(1.f - percent_max, blowout_strength * abs(current_config.blowout));
      if (current_config.blowout < 0) {
        blowout_change = (2.f - blowout_change);
      }

      perceptual_new.yz *= blowout_change;
    }

    perceptual_new.yz *= current_config.saturation;

    [branch]
    if (current_config.hue_correction_method == renodx::tonemap::renodrt::config::hue_correction_method::OKLAB) {
      color_output = renodx::color::bt709::from::OkLab(perceptual_new);
    } else if (current_config.hue_correction_method == renodx::tonemap::renodrt::config::hue_correction_method::ICTCP) {
      color_output = renodx::color::bt709::from::ICtCp(perceptual_new);
    } else if (current_config.hue_correction_method == renodx::tonemap::renodrt::config::hue_correction_method::DARKTABLE_UCS) {
      color_output = renodx::color::bt709::from::dtucs::uvY(perceptual_new.yzx);
    }

  } else {
    // noop
  }

  [branch]
  if (current_config.clamp_color_space != -1.f) {
    color_output = renodx::color::convert::ColorSpaces(color_output, current_color_space, current_config.clamp_color_space);
    color_output = max(0, color_output);
    current_color_space = current_config.clamp_color_space;
  }

  [branch]
  if (current_config.clamp_peak != -1.f) {
    color_output = renodx::color::convert::ColorSpaces(color_output, current_color_space, current_config.clamp_peak);
    color_output = min(color_output, m_0);
    current_color_space = current_config.clamp_peak;
  }

  color_output = renodx::color::convert::ColorSpaces(color_output, current_color_space, renodx::color::convert::COLOR_SPACE_BT709);

  return color_output;
}

float3 ApplyRenoDRT(float3 color, renodx::tonemap::Config tm_config) {
  float reno_drt_max = (tm_config.peak_nits / tm_config.game_nits);
  [branch]
  if (tm_config.gamma_correction != 0) {
    reno_drt_max = renodx::color::correct::Gamma(
        reno_drt_max,
        tm_config.gamma_correction > 0.f,
        abs(tm_config.gamma_correction) == 1.f ? 2.2f : 2.4f);
  } else {
    // noop
  }

  renodx::tonemap::renodrt::Config reno_drt_config = renodx::tonemap::renodrt::config::Create();
  reno_drt_config.nits_peak = reno_drt_max * 100.f;
  reno_drt_config.mid_gray_value = 0.18f;
  reno_drt_config.mid_gray_nits = tm_config.mid_gray_nits;
  reno_drt_config.exposure = tm_config.exposure;
  reno_drt_config.highlights = tm_config.reno_drt_highlights;
  reno_drt_config.shadows = tm_config.reno_drt_shadows;
  reno_drt_config.contrast = tm_config.reno_drt_contrast;
  reno_drt_config.saturation = tm_config.reno_drt_saturation;
  reno_drt_config.dechroma = tm_config.reno_drt_dechroma;
  reno_drt_config.flare = tm_config.reno_drt_flare;
  reno_drt_config.hue_correction_strength = tm_config.hue_correction_strength;
  reno_drt_config.hue_correction_type = renodx::tonemap::renodrt::config::hue_correction_type::CUSTOM;
  if (tm_config.hue_correction_type == renodx::tonemap::config::hue_correction_type::CUSTOM) {
    reno_drt_config.hue_correction_source = tm_config.hue_correction_color;
  } else if (tm_config.hue_correction_type == renodx::tonemap::config::hue_correction_type::CLAMPED) {
    reno_drt_config.hue_correction_source = tm_config.hue_correction_color;
  } else {
    reno_drt_config.hue_correction_source = color;
  }
  reno_drt_config.hue_correction_method = tm_config.reno_drt_hue_correction_method;
  reno_drt_config.tone_map_method = tm_config.reno_drt_tone_map_method;
  reno_drt_config.working_color_space = tm_config.reno_drt_working_color_space;
  reno_drt_config.per_channel = tm_config.reno_drt_per_channel;
  reno_drt_config.blowout = tm_config.reno_drt_blowout;
  reno_drt_config.clamp_color_space = tm_config.reno_drt_clamp_color_space;
  reno_drt_config.clamp_peak = tm_config.reno_drt_clamp_peak;
  reno_drt_config.white_clip = tm_config.reno_drt_white_clip;

  return renodx::tonemap::renodrt::BT709(color, reno_drt_config);
}

float3 ApplyToneMap(float3 untonemapped, renodx::tonemap::Config tm_config) {
  float3 color = untonemapped;

  tm_config.reno_drt_highlights *= tm_config.highlights;
  tm_config.reno_drt_shadows *= tm_config.shadows;
  tm_config.reno_drt_contrast *= tm_config.contrast;
  tm_config.reno_drt_saturation *= tm_config.saturation;
  color = ApplyRenoDRT(color, tm_config);

  return color;
}

float3 ToneMap(float3 color) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return color;
  }

  // color.x = (isnan(color.x) || isinf(color.x)) ? 0.0f : color.x;
  // color.y = (isnan(color.y) || isinf(color.y)) ? 0.0f : color.y;
  // color.z = (isnan(color.z) || isinf(color.z)) ? 0.0f : color.z;
  // color.w = (isnan(color.w) || isinf(color.w)) ? 0.0f : color.w;

  color = renodx::color::bt709::clamp::AP1(color);
  color = PumboInverseTonemap(color);

  renodx::draw::Config draw_config = renodx::draw::BuildConfig();
  draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
  // draw_config.tone_map_pass_autocorrection = 0.5;

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



float3 expandColorGamut(float3 finalColor) {
  if (INVERSE_TONEMAP_EXTRA_HDR_SATURATION > 0.f) {
    const float ReferenceWhiteNits_BT2408 = 203.f;
    const float sRGB_max_nits = 80.f;
    const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

    float3 fineTunedColor = finalColor * recommendedBrightnessScale;
    fineTunedColor = expandGamut(fineTunedColor, INVERSE_TONEMAP_EXTRA_HDR_SATURATION);
    finalColor = fineTunedColor / recommendedBrightnessScale;
  
    // finalColor = fixNAN(finalColor);
    finalColor = renodx::color::bt709::clamp::AP1(finalColor);
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

float3 ApplyPerChannelCorrection(
    float3 untonemapped,
    float3 per_channel_color,
    float blowout_restoration = 0.5f,
    float hue_correction_strength = 1.f,
    float chrominance_correction_strength = 1.f,
    float hue_shift_strength = 0.5f) {
  const float tonemapped_luminance = renodx::color::y::from::BT709(abs(per_channel_color));

  // const float AUTO_CORRECT_BLACK = 0.02f;
  // // Fix near black
  const float untonemapped_luminance = renodx::color::y::from::BT709(abs(untonemapped));
  float ratio = tonemapped_luminance / untonemapped_luminance;
  // float auto_correct_ratio = lerp(ratio, 1.f, saturate(untonemapped_luminance / AUTO_CORRECT_BLACK));
  // untonemapped *= auto_correct_ratio;

  const float3 tonemapped_perceptual = renodx::color::ictcp::from::BT709(per_channel_color);
  const float3 untonemapped_perceptual = renodx::color::ictcp::from::BT709(untonemapped);

  float2 untonemapped_chromas = untonemapped_perceptual.yz;
  float2 tonemapped_chromas = tonemapped_perceptual.yz;

  float untonemapped_chrominance = length(untonemapped_perceptual.yz);  // eg: 0.80
  float tonemapped_chrominance = length(tonemapped_perceptual.yz);      // eg: 0.20

  // clamp saturation loss

  float chrominance_ratio = min(renodx::math::DivideSafe(tonemapped_chrominance, untonemapped_chrominance, 1.f), 1.f);
  chrominance_ratio = max(chrominance_ratio, blowout_restoration);

  // Untonemapped hue, tonemapped chrominance (with limit)
  float2 reduced_untonemapped_chromas = untonemapped_chromas * chrominance_ratio;

  // pick chroma based on per-channel luminance (supports not oversaturating crushed areas)
  const float2 reduced_hue_shifted = lerp(
      tonemapped_chromas,
      reduced_untonemapped_chromas,
      saturate(tonemapped_luminance / 0.36));

  // Tonemapped hue, restored chrominance (with limit)
  const float2 blowout_restored_chromas = tonemapped_chromas
                                          * renodx::math::DivideSafe(
                                              length(reduced_hue_shifted),
                                              length(tonemapped_chromas), 1.f);

  // const float2 hue_shifted_chromas = lerp(reduced_hue_shifted, blowout_restored_chromas, hue_shift_strength);

  // // Pick untonemapped hues for shadows/midtones
  // const float2 hue_correct_chromas = untonemapped_chromas
  //                                    * renodx::math::DivideSafe(
  //                                        length(hue_shifted_chromas),
  //                                        length(untonemapped_chromas), 1.f);

  // const float2 selectable_hue_correct_range = lerp(
  //     hue_correct_chromas,
  //     hue_shifted_chromas,
  //     saturate(tonemapped_luminance / 0.36f));

  // const float2 hue_corrected_chromas = lerp(hue_shifted_chromas, selectable_hue_correct_range, hue_correction_strength);

  // const float2 chroma_correct_chromas = hue_corrected_chromas
  //                                       * renodx::math::DivideSafe(
  //                                           length(untonemapped_chromas),
  //                                           length(hue_corrected_chromas), 1.f);

  // const float2 selectable_chroma_correct_range = lerp(
  //     chroma_correct_chromas,
  //     hue_corrected_chromas,
  //     saturate(tonemapped_luminance / 0.36f));

  // const float2 chroma_corrected_chromas = lerp(
  //     hue_correct_chromas,
  //     selectable_chroma_correct_range,
  //     chrominance_correction_strength);

  float2 final_chromas = blowout_restored_chromas;

  const float3 final_color = renodx::color::bt709::from::ICtCp(float3(
      tonemapped_perceptual.x,
      final_chromas));

  return final_color;
}

float3 scaleByLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  float bloomY = renodx::color::y::from::BT709(bloomColor);
  float Y = renodx::color::y::from::BT709(color);

  float scale = UpgradeToneMapRatio(bloomY, Y);

  color = color * scale;

  if (RENODX_PER_CHANNEL_BLOWOUT_RESTORATION != 0.f
      || RENODX_PER_CHANNEL_HUE_CORRECTION != 0.f
      || RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION != 0.f) {
    color = ApplyPerChannelCorrection(
        bloomColor,
        color,
        RENODX_PER_CHANNEL_BLOWOUT_RESTORATION,
        RENODX_PER_CHANNEL_HUE_CORRECTION,
        RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION);
  }
  
  return color;
}

float3 scaleByOKLabLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  float3 bloomColor_oklab = renodx::color::oklab::from::BT709(bloomColor);
  float3 color_oklab = renodx::color::oklab::from::BT709(color);

  // per channel scaling
  float bloomL = bloomColor_oklab.x;
  float L = color_oklab.x;

  float scale = UpgradeToneMapRatio(bloomL, L);

  color_oklab = float3(color_oklab.x * scale, color_oklab.y, color_oklab.z);

  color = renodx::color::bt709::from::OkLab(color_oklab);

  if (RENODX_PER_CHANNEL_BLOWOUT_RESTORATION != 0.f
      || RENODX_PER_CHANNEL_HUE_CORRECTION != 0.f
      || RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION != 0.f) {
    color = ApplyPerChannelCorrection(
        bloomColor,
        color,
        RENODX_PER_CHANNEL_BLOWOUT_RESTORATION,
        RENODX_PER_CHANNEL_HUE_CORRECTION,
        RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION);
  }

  return color;
}

float3 scaleByPerceptualLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  // return bloomColor;
  // return color;

  float3 bloomColor_perceptual = renodx::color::ictcp::from::BT709(bloomColor);
  float3 color_perceptual = renodx::color::ictcp::from::BT709(color);
  

  // per channel scaling
  float bloomL = bloomColor_perceptual.x;
  float L = color_perceptual.x;

  float bloom_chrominance = (length(bloomColor_perceptual.yz));  // eg: 0.80
  float chrominance = (length(color_perceptual.yz));      // eg: 0.20

  float new_chroma_len = max(chrominance, bloom_chrominance);

  float scale = UpgradeToneMapRatio(bloomL, L);
  float chrominance_scale = UpgradeToneMapRatio(bloom_chrominance, chrominance);

  // scale y and z by chrominance scale causes artifact (exhibited in the bloomColor)
  chrominance_scale = 1.f;
  // chrominance_scale = lerp(1, scale, saturate(chrominance));

  scale = max(scale, 1.f);
  color_perceptual = float3(color_perceptual.x * scale, color_perceptual.y * chrominance_scale, color_perceptual.z * chrominance_scale);

  color = renodx::color::bt709::from::ICtCp(color_perceptual);
  // color = max(0.f, color);

  return color;
}

float3 scaleColor(float3 color, float3 bloomColor, float max_scale = 4.f) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return bloomColor;
  }

  // return bloomColor;

  // return color;

  if (BROKEN_BLOOM == 0.f) {
    return color;
  }

  float minY = 1e-3;     // Or a bit higher, so you never divide by near-zero

  color = scaleByPerceptualLuminance(color, bloomColor, max_scale);

  // color = lerp(bloomColor, color, renodx::color::y::from);
  // color = scaleByOKLabLuminance(color, bloomColor, max_scale);

  return color;
}