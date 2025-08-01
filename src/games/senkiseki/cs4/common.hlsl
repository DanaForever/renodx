#include "../shared.h"
#include "DICE.hlsl"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f


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
  // if (INVERSE_TONEMAP_EXTRA_HDR_SATURATION > 0.f) {
  //   float4 r0, r1;
  //   r0.rgb = finalColor;

  //   r0.w = 0.587700009 * r0.y;
  //   r0.w = r0.x * 1.66050005 + -r0.w;
  //   r1.x = -r0.z * 0.072800003 + r0.w;
  //   r0.w = 0.100599997 * r0.y;
  //   r0.w = r0.x * -0.0182000007 + -r0.w;
  //   r1.z = r0.z * 1.11870003 + r0.w;
  //   r0.x = dot(r0.xy, float2(-0.124600001, 1.13300002));
  //   r1.y = -r0.z * 0.0083999997 + r0.x;

  //   finalColor.rgb = r1.rgb;
  //   return finalColor;
  // } else {
  //   return finalColor;
  // }
  return finalColor;
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
    sdr_color = saturate(color);
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
  color = correctHue(color, color);
  color = expandColorGamut(color);
  

  // color = renodx::draw::RenderIntermediatePass(color);
  color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  color = renodx::color::srgb::EncodeSafe(color);
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
  

  float3 scaledColor;
  if (BLOOM_APPROX_METHOD == 0.f) {
    scaledColor = color;

  } else {
    scaledColor = color;
    // float3 lum_color = scaleByLuminance(unscaledColor, bloomColor, max_scale);
    scaledColor = renodx::color::correct::ChrominanceICtCp(scaledColor, bloomColor, 1.0f);
  }

  color = scaledColor;
  
  return color;
}

float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::ChrominanceICtCp(lum, ch);

  return result;
}
