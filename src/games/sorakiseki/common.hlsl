
#include "./shared.h"
#include "DICE.hlsl"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f

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


float3 SDRTonemap(float3 color) {
  float tone_map_hue_correction_method = RENODX_TONE_MAP_HUE_CORRECTION_METHOD;
  float3 sdr_color;
  color = max(0.f, color);

  if (tone_map_hue_correction_method == 2.f) {
    sdr_color = renodx::tonemap::dice::BT709(color, 1.f, 0.f);
  } else if (tone_map_hue_correction_method == 1.f) {
    sdr_color = renodx::tonemap::renodrt::NeutralSDR(color);
  } else if (tone_map_hue_correction_method == 0.f) {
    sdr_color = renodx::tonemap::Reinhard(max(color, 0.f));
  } else if (tone_map_hue_correction_method == 3.f) {
    sdr_color = renodx::tonemap::uncharted2::BT709(max(color, 0.f));
  } else if (tone_map_hue_correction_method == 3.f) {
    sdr_color = renodx::tonemap::ACESFittedAP1(color);
  } else if (tone_map_hue_correction_method == 4.f) {
    sdr_color = saturate(color);
  }

  return sdr_color;
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


float3 processAndToneMap(float3 color) {

  if (shader_injection.gamma == 0.f)  {
    color = renodx::color::srgb::DecodeSafe(color);
  } else {
    color = renodx::color::gamma::DecodeSafe(color, 2.3f);
  }

  color = ToneMap(color);
  color = correctHue(color, color);
  color = renodx::color::bt709::clamp::BT2020(color);
  
  // This is RenderIntermediatePass, simply brightness scaling and srgb encoding
  color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  // color = renodx::color::srgb::EncodeSafe(color);
  // color = renodx::color::gamma::EncodeSafe(color, 2.3f);

  if (shader_injection.gamma == 0.f)  {
    color = renodx::color::srgb::EncodeSafe(color);
  } else {
    color = renodx::color::gamma::EncodeSafe(color, 2.3f);
  }
  return color;
}


float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  // return ch;
  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  // float3 result = renodx::color::correct::ChrominanceICtCp(lum, ch);
  float3 result = renodx::color::correct::Chrominance(lum, ch);

  return result;
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

  // return renodx::color::bt709::from::OkLCh(correctedTargetOklch);
  float3 output = renodx::color::bt709::from::OkLCh(correctedTargetOklch);

  output = renodx::color::bt709::clamp::BT2020(output);

  return output;
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
  // chrominance_scale = 1.f;
  scale = clamp(scale, 1.0f, max_scale);

  color_perceptual = float3(color_perceptual.x * scale, color_perceptual.y * chrominance_scale, color_perceptual.z * chrominance_scale);

  color = renodx::color::bt709::from::ICtCp(color_perceptual);
  color = renodx::color::bt709::clamp::BT2020(color);

  return color;
}

float3 scaleByLuminance(float3 color, float3 bloomColor, float max_scale = 4.f) {
  float bloomY = renodx::color::y::from::BT709(bloomColor);
  float Y = renodx::color::y::from::BT709(color);

  float scale = UpgradeToneMapRatio(bloomY, Y);

  scale = clamp(scale, 1.0f, max_scale);
  color = color * scale;

  
  return color;
}
