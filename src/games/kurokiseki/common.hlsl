
#include "./shared.h"
#include "lms_matrix.hlsl"
#include "macleod_boynton.hlsli"

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

float3 hdrScreenBlend(float3 base, float3 blend, bool encoding = true) {
  if (encoding) {
    base = srgbDecode(base);
    blend = srgbDecode(blend);
  }

  base = max(0.f, base);
  blend = max(0.f, blend);

  blend *= shader_injection.bloom_strength;

  float3 bloom_texture = blend;

  float mid_gray_bloomed = (0.18 + renodx::color::y::from::BT709(bloom_texture)) / 0.18;

  float scene_luminance = renodx::color::y::from::BT709(base) * mid_gray_bloomed;
  float bloom_blend = saturate(smoothstep(0.f, 0.18f, scene_luminance));

  float3 bloom_scaled = lerp(float3(0.f, 0.f, 0.f), bloom_texture, bloom_blend);  // = bloom_blend
  bloom_texture = lerp(bloom_texture, bloom_scaled, 0.5f);

  blend = bloom_texture;

  blend = addBloom(base, blend);

  if (encoding)
    blend = srgbEncode(blend);

  return blend;
}

float3 HueAndChrominanceOKLab(
    float3 incorrect_color,
    float3 hue_reference_color,
    float3 chrominance_reference_color,
    float hue_correct_strength = 1.f,
    float chrominance_correct_strength = 1.f,
    float clamp_chrominance_loss = 0.f) {
  if (hue_correct_strength == 0.f && chrominance_correct_strength == 0.f) {
    return incorrect_color;
  } else if (hue_correct_strength == 0.f) {
    return renodx::color::correct::ChrominanceOKLab(incorrect_color, chrominance_reference_color, chrominance_correct_strength, clamp_chrominance_loss);
  } else if (chrominance_correct_strength == 0.f) {
    return renodx::color::correct::Hue(incorrect_color, hue_reference_color, hue_correct_strength);
  }

  float3 incorrect_lab = renodx::color::oklab::from::BT709(incorrect_color);
  float3 hue_lab = renodx::color::oklab::from::BT709(hue_reference_color);
  float3 chrominance_lab = renodx::color::oklab::from::BT709(chrominance_reference_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 hue_ab = hue_lab.yz;

  // Compute chrominance (magnitude of the a–b vector)
  float incorrect_chrominance = length(incorrect_ab);
  float target_chrominance = length(chrominance_lab.yz);

  // Scale original chrominance vector toward target chrominance
  float desired_chrominance = lerp(incorrect_chrominance, target_chrominance, chrominance_correct_strength);
  float scale = renodx::math::DivideSafe(desired_chrominance, incorrect_chrominance, 1.f);

  float t = 1.0f - step(1.0f, scale);  // t = 1 when scale < 1, 0 when scale >= 1
  scale = lerp(scale, 1.0f, t * clamp_chrominance_loss);

  float adjusted_chrominance = (incorrect_chrominance > 0.f)
                                   ? incorrect_chrominance * scale
                                   : desired_chrominance;

  // Blend hue direction between incorrect and reference colors
  float2 incorrect_dir = renodx::math::DivideSafe(
      incorrect_ab,
      float2(incorrect_chrominance, incorrect_chrominance),
      float2(0.f, 0.f));
  float hue_chrominance = length(hue_ab);
  float2 hue_dir = renodx::math::DivideSafe(
      hue_ab,
      float2(hue_chrominance, hue_chrominance),
      incorrect_dir);
  float2 blended_dir = lerp(incorrect_dir, hue_dir, hue_correct_strength);
  float blended_len = length(blended_dir);
  float2 final_dir = renodx::math::DivideSafe(
      blended_dir,
      float2(blended_len, blended_len),
      hue_dir);

  // Apply final hue direction and chroma magnitude
  float2 final_ab = final_dir * adjusted_chrominance;
  incorrect_lab.yz = final_ab;

  float3 result = renodx::color::bt709::from::OkLab(incorrect_lab);
  return renodx::color::bt709::clamp::AP1(result);
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

float3 FrostbiteToneMap(float3 color) {
  float3 untonemapped = color;

  float frostbitePeak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  color = renodx::tonemap::frostbite::BT709(color, frostbitePeak);

  return color;
}

// Mass Effect Displaymapper
// Linear color in -> Linear color out
// Params in PQ -- Use the helper function to call the displaymapper (MassEffectDisplayMap())
// NormalizedLinearValue = linear color
// SoftShoulderStart2084 = shoulder start in nits (PQ values) -- everything under this is ignored
// MaxBrightnessOfDisplay2084 = peak nits
// MaxBrightnessOfScene2084 = Y of Linear Color (Encoded in PQ) -- Basically whiteclip

float3 MapHDRSceneToDisplayCapabilities(float3 NormalizedLinearValue, float SoftShoulderStart2084, float MaxBrightnessOfDisplay2084, float MaxBrightnessOfScene2084) {
  float3 bt2020_color = renodx::color::bt2020::from::BT709(NormalizedLinearValue);
  // float3 bt2020_color = NormalizedLinearValue;
  float3 ST2084 = renodx::color::pq::EncodeSafe(bt2020_color);

  // Use a simple Bezier curve to create a soft shoulder
  const float P0 = SoftShoulderStart2084;           // First point is: soft shoulder start nits
  const float P1 = MaxBrightnessOfDisplay2084;      // Middle point is: TV max nits
  const float P2 = MaxBrightnessOfDisplay2084;      // Last point is also TV max nits, since values higher than TV max nits are essentially clipped to TV max brightness
  const float SceneMax = MaxBrightnessOfScene2084;  // To determine range, use max brightness of HDR scene

  float3 T = saturate((ST2084 - P0) / (SceneMax - P0));  // Amount to lerp wrt current value
  float3 B0 = (P0 * (1 - T)) + (P1 * T);                 // Lerp between p0 and p1
  float3 B1 = (P1 * (1 - T)) + (P2 * T);                 // Lerp between p1 and p2
  float3 MappedValue = (B0 * (1 - T)) + (B1 * T);        // Final lerp for Bezier

  MappedValue = min(MappedValue, ST2084);  // If HDR scene max luminance is too close to shoulders, then it could end up producing a higher value than the ST.2084 curve,
  // which will saturate colors, i.e. the opposite of what HDR display mapping should do, therefore always take minimum of the two

  // Return a linear color
  return renodx::color::bt709::from::BT2020(renodx::color::pq::DecodeSafe((ST2084 > SoftShoulderStart2084) ? MappedValue : ST2084));
  // return renodx::color::pq::DecodeSafe((ST2084 > SoftShoulderStart2084) ? MappedValue : ST2084);
}

float3 MassEffectDisplayMap(float3 linear_color, float shoulder_start, float peak_nits, float scene_peak) {
  // Helper function for Mass Effect's display mapper to encode params to PQ

  shoulder_start = renodx::color::pq::EncodeSafe(float3(shoulder_start, shoulder_start, shoulder_start)).x;
  peak_nits = renodx::color::pq::EncodeSafe(float3(peak_nits, peak_nits, peak_nits)).x;
  scene_peak = renodx::color::pq::EncodeSafe(float3(scene_peak, scene_peak, scene_peak)).x;

  return MapHDRSceneToDisplayCapabilities(linear_color, shoulder_start, peak_nits, scene_peak);
}

float3 LMS_Processing(float3 color) {
  color = LMS_Vibrancy(color, shader_injection.tone_map_lms_vibrancy, shader_injection.tone_map_lms_contrast);
  color = CastleDechroma_CVVDPStyle_NakaRushton(color, RENODX_DIFFUSE_WHITE_NITS);

  return color;
}

float3 ToneMap(float3 color) {
  float3 originalColor = color;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return color;

  } else if (shader_injection.tone_map_type == 1.f) {
    color = LMS_Processing(color);
                                 
    color = FrostbiteToneMap(color);

    return color;
  } else if (shader_injection.tone_map_type == 2.f) {
    color = LMS_Processing(color);
    color = DICEToneMap(color);

    
    return color;

  }
  else if (shader_injection.tone_map_type == 3.f) {
    color = LMS_Processing(color);

    float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

    color = renodx::color::bt709::clamp::BT2020(color);

    float3 lum_color = renodx::tonemap::HermiteSplineLuminanceRolloff(color, peak);
    // float3 perch_color = renodx::tonemap::HermiteSplinePerChannelRolloff(color, peak);

 
    color = lum_color;

             

    return color;
  } else if (shader_injection.tone_map_type == 4.f) {
    color = LMS_Processing(color);

    // bool pq = (RENODX_TONE_MAP_WORKING_COLOR_SPACE > 0.f);
    bool pq = false;
    float shoulder_start = 0.33333330f;  // borrow from DICE
    float peak_nits = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
    float scene_nits = 4000.f / 203.f;
    color = MassEffectDisplayMap(color, shoulder_start, peak_nits, scene_nits);

    return color;
  } else if (shader_injection.tone_map_type == 5.f) {
    color = LMS_Processing(color);

    float peak_nits = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
    color = renodx::tonemap::neutwo::MaxChannel(color, peak_nits);

    return color;
  }else {
    return color;
  }
}

float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, ch, 1.0f, 0.0f, RENODX_TONE_MAP_HUE_PROCESSOR);
  // float3 result = renodx::color::correct::Chrominance(lum, ch);

  return result;
}



float3 CorrectHueAndPurity(
    float3 target_color_bt709,
    float3 reference_color_bt709,
    float strength = 1.f,
    float2 mb_white_override = float2(-1.f, -1.f),
    float t_min = 1e-6f) {
  float hue_t_ramp_start = 0.5f;
  float hue_t_ramp_end = 1.f;
  return CorrectHueAndPurityMBGated(target_color_bt709, reference_color_bt709, strength, hue_t_ramp_start, hue_t_ramp_end, strength, 1.f, mb_white_override, t_min);
};