#version 450

#include "./include/aces.hlsl"
#include "./shared.h"

float3 ChrominanceOKLab(float3 incorrect_color,
                        float3 reference_color,
                        float strength = 1.f,
                        float clamp_chrominance_loss = 0.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_lab = renodx::color::oklab::from::BT709(incorrect_color);
  float3 reference_lab = renodx::color::oklab::from::BT709(reference_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 reference_ab = reference_lab.yz;

  // Compute chrominance (magnitude of the a–b vector)
  float incorrect_chrominance = length(incorrect_ab);
  float correct_chrominance = length(reference_ab);

  // Scale original chrominance vector toward target chrominance
  float chrominance_ratio = renodx::math::DivideSafe(correct_chrominance, incorrect_chrominance, 1.f);
  float scale = lerp(1.f, chrominance_ratio, strength);

  float t = 1.0f - step(1.0f, scale);  // t = 1 when scale < 1, 0 when scale >= 1
  scale = lerp(scale, 1.0f, t * clamp_chrominance_loss);

  incorrect_lab.yz = incorrect_ab * scale;

  float3 result = renodx::color::bt709::from::OkLab(incorrect_lab);
  return result;
}

float3 ChrominanceICtCp(float3 incorrect_color,
                        float3 reference_color,
                        float strength = 1.f,
                        float clamp_chrominance_loss = 0.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_lab = renodx::color::ictcp::from::BT709(incorrect_color);
  float3 reference_lab = renodx::color::ictcp::from::BT709(reference_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 reference_ab = reference_lab.yz;

  // Compute chrominance (magnitude of the Ct-Cp vector)
  float incorrect_chrominance = length(incorrect_ab);
  float correct_chrominance = length(reference_ab);

  // Scale original chrominance vector toward target chrominance
  float chrominance_ratio = renodx::math::DivideSafe(correct_chrominance, incorrect_chrominance, 1.f);
  float scale = lerp(1.f, chrominance_ratio, strength);

  float t = 1.0f - step(1.0f, scale);  // t = 1 when scale < 1, 0 when scale >= 1
  scale = lerp(scale, 1.0f, t * clamp_chrominance_loss);

  incorrect_lab.yz = incorrect_ab * scale;

  float3 result = renodx::color::bt709::from::ICtCp(incorrect_lab);
  return result;
}

float3 ChrominancedtUCS(float3 incorrect_color,
                        float3 correct_color,
                        float strength = 1.f,
                        float clamp_chrominance_loss = 0.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_uvY = renodx::color::dtucs::uvY::from::BT709(incorrect_color);
  float3 correct_uvY = renodx::color::dtucs::uvY::from::BT709(correct_color);

  float2 incorrect_uv = incorrect_uvY.xy;
  float2 correct_uv = correct_uvY.xy;

  float Y_incorrect = incorrect_uvY.z;
  float Y_correct = correct_uvY.z;

  // Compute perceptual lightness (L*) for both colors
  float L_star_hat_i = pow(Y_incorrect, 0.631651345306265f);
  float L_star_i = 2.098883786377f * L_star_hat_i / (L_star_hat_i + 1.12426773749357f);
  float L_star_hat_c = pow(Y_correct, 0.631651345306265f);
  float L_star_c = 2.098883786377f * L_star_hat_c / (L_star_hat_c + 1.12426773749357f);

  // Compute chrominance (C) for both colors
  float M2_incorrect = dot(incorrect_uv, incorrect_uv);
  float M2_correct = dot(correct_uv, correct_uv);
  float C_incorrect = 15.932993652962535f * pow(L_star_i, 0.6523997524738018f) * pow(M2_incorrect, 0.6007557017508491f) / renodx::color::dtucs::L_WHITE;
  float C_correct = 15.932993652962535f * pow(L_star_c, 0.6523997524738018f) * pow(M2_correct, 0.6007557017508491f) / renodx::color::dtucs::L_WHITE;

  // Interpolate chrominance while preserving original hue direction
  float C_lerp = lerp(C_incorrect, C_correct, strength);

  float chroma_scale = renodx::math::DivideSafe(C_lerp, C_incorrect, 1.f);
  float t = 1.0f - step(1.0f, chroma_scale);  // t = 1 when scale < 1, 0 when scale >= 1
  chroma_scale = lerp(chroma_scale, 1.0f, t * clamp_chrominance_loss);
  float C = C_incorrect * chroma_scale;

  float h = atan2(incorrect_uv.y, incorrect_uv.x);

  // Compute original perceptual lightness (J)
  float J = pow(L_star_i / renodx::color::dtucs::L_WHITE, 1.f);

  // Build JCH from original J, clamped/interpolated chrominance, and original hue
  float3 final_jch = float3(J, C, h);

  float3 result = renodx::color::bt709::from::dtucs::JCH(final_jch);
  return result;
}

float3 Chrominance(float3 incorrect_color, float3 correct_color, float strength = 1.f, float clamp_chrominance_loss = 0.f, uint method = 0u) {
  if (method == 1u) return ChrominanceICtCp(incorrect_color, correct_color, strength, clamp_chrominance_loss);
  if (method == 2u) return ChrominancedtUCS(incorrect_color, correct_color, strength, clamp_chrominance_loss);
  return ChrominanceOKLab(incorrect_color, correct_color, strength, clamp_chrominance_loss);
}

float3 HueOKLab(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_lab = renodx::color::oklab::from::BT709(incorrect_color);
  float3 correct_lab = renodx::color::oklab::from::BT709(correct_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 correct_ab = correct_lab.yz;

  // Preserve original chrominance (magnitude of the a–b vector)
  float chrominance_pre_adjust = length(incorrect_ab);

  // Blend chrominance and hue by interpolating (a, b) components
  float2 blended_ab = lerp(incorrect_ab, correct_ab, strength);

  // Rescale to original chrominance to avoid saturation shift
  float chrominance_post_adjust = length(blended_ab);
  blended_ab *= renodx::math::DivideSafe(chrominance_pre_adjust, chrominance_post_adjust, 1.f);

  incorrect_lab.yz = blended_ab;

  float3 result = renodx::color::bt709::from::OkLab(incorrect_lab);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 HueICtCp(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_ictcp = renodx::color::ictcp::from::BT709(incorrect_color);
  float3 correct_ictcp = renodx::color::ictcp::from::BT709(correct_color);

  float2 incorrect_ctcp = incorrect_ictcp.yz;
  float2 correct_ctcp = correct_ictcp.yz;

  // Preserve original chrominance (magnitude of the Ct-Cp vector)
  float chrominance_pre_adjust = length(incorrect_ctcp);

  // Blend chrominance and hue by interpolating (Ct, Cp) components
  float2 blended_ctcp = lerp(incorrect_ctcp, correct_ctcp, strength);

  // Rescale to original chrominance to avoid saturation shift
  float chrominance_post_adjust = length(blended_ctcp);
  blended_ctcp *= renodx::math::DivideSafe(chrominance_pre_adjust, chrominance_post_adjust, 1.f);

  incorrect_ictcp.yz = blended_ctcp;

  float3 result = renodx::color::bt709::from::ICtCp(incorrect_ictcp);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 HuedtUCS(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_uvY = renodx::color::dtucs::uvY::from::BT709(incorrect_color);
  float3 correct_uvY = renodx::color::dtucs::uvY::from::BT709(correct_color);

  float2 incorrect_uv = incorrect_uvY.xy;
  float2 correct_uv = correct_uvY.xy;

  float Y_incorrect = incorrect_uvY.z;
  float Y_correct = correct_uvY.z;

  // Compute perceptual lightness (L*) for both colors
  float L_star_hat_i = pow(Y_incorrect, 0.631651345306265f);
  float L_star_i = 2.098883786377f * L_star_hat_i / (L_star_hat_i + 1.12426773749357f);
  float L_star_hat_c = pow(Y_correct, 0.631651345306265f);
  float L_star_c = 2.098883786377f * L_star_hat_c / (L_star_hat_c + 1.12426773749357f);

  // Compute chrominance (C) for both colors from uv vector magnitude and L*
  float M2_incorrect = dot(incorrect_uv, incorrect_uv);
  float M2_correct = dot(correct_uv, correct_uv);
  float C_incorrect = 15.932993652962535f * pow(L_star_i, 0.6523997524738018f) * pow(M2_incorrect, 0.6007557017508491f) / renodx::color::dtucs::L_WHITE;
  float C_correct = 15.932993652962535f * pow(L_star_c, 0.6523997524738018f) * pow(M2_correct, 0.6007557017508491f) / renodx::color::dtucs::L_WHITE;

  // Build chrominance-direction vectors (C * unit vector of hue angle)
  float2 incorrect_vec = C_incorrect * normalize(incorrect_uv);
  float2 correct_vec = C_correct * normalize(correct_uv);

  // Blend chrominance and hue by interpolating between chrominance-direction vectors
  float2 blended_vec = lerp(incorrect_vec, correct_vec, strength);

  // Rescale to original chrominance to avoid saturation shift
  float blended_chrominance = length(blended_vec);
  blended_vec *= renodx::math::DivideSafe(C_incorrect, blended_chrominance, 1.f);

  // Reconstruct hue from blended vector
  float h = atan2(blended_vec.y, blended_vec.x);

  // Compute original perceptual lightness (J)
  float J = pow(L_star_i / renodx::color::dtucs::L_WHITE, 1.f);

  // Build JCH from original J, original chrominance, and interpolated hue
  float3 final_jch = float3(J, C_incorrect, h);

  float3 result = renodx::color::bt709::from::dtucs::JCH(final_jch);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 Hue(float3 incorrect_color, float3 correct_color, float strength = 1.f, uint method = 0u) {
  if (method == 1u) return HueICtCp(incorrect_color, correct_color, strength);
  if (method == 2u) return HuedtUCS(incorrect_color, correct_color, strength);
  return HueOKLab(incorrect_color, correct_color, strength);
}

/// Applies Exponential Roll-Off tonemapping using the maximum channel.
/// Used to fit the color into a 0–output_max range for SDR LUT compatibility.
float3 ToneMapMaxCLL(float3 color, float rolloff_start = 0.375f, float output_max = 1.f) {
  // color = min(color, 100.f);
  float peak = max(color.r, max(color.g, color.b));
  peak = min(peak, 100.f);
  float log_peak = log2(peak);

  // Apply exponential shoulder in log space
  float log_mapped = renodx::tonemap::ExponentialRollOff(log_peak, log2(rolloff_start), log2(output_max));
  float scale = exp2(log_mapped - log_peak);  // How much to compress all channels

  return min(output_max, color * scale);
}

float3 ToneMapMaxCLLSafe(float3 color_linear) {
  color_linear = min(1.f, ToneMapMaxCLL(max(0.f, color_linear)));

  return color_linear;
}

float3 ExponentialRollOffByLum(float3 color, float output_luminance_max, float highlights_shoulder_start = 1.f) {
  const float source_luminance = renodx::color::y::from::BT709(color);

  [branch]
  if (source_luminance > 0.0f) {
    const float compressed_luminance = renodx::tonemap::ExponentialRollOff(source_luminance, highlights_shoulder_start, output_luminance_max);
    color *= compressed_luminance / source_luminance;
  }

  return color;
}

float3 applyExponentialRollOff(float3 color) {
  const float paperWhite = RENODX_DIFFUSE_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;

  const float peakWhite = RENODX_PEAK_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;

  const float highlightsShoulderStart = 1.f;

  return ExponentialRollOffByLum(color * paperWhite, peakWhite, highlightsShoulderStart) / paperWhite;
}

float3 ApplyExposureContrastFlareHighlightsShadowsByLuminance(float3 untonemapped, float y, renodx::color::grade::Config config, float mid_gray = 0.18f) {
  if (config.exposure == 1.f && config.shadows == 1.f && config.highlights == 1.f && config.contrast == 1.f && config.flare == 0.f) {
    return untonemapped;
  }
  float3 color = untonemapped;

  color *= config.exposure;

  const float y_normalized = y / mid_gray;
  const float highlight_mask = 1.f / mid_gray;
  const float shadow_mask = mid_gray;

  // contrast & flare
  float flare = renodx::math::DivideSafe(y_normalized + config.flare, y_normalized, 1.f);
  float exponent = config.contrast * flare;
  const float y_contrasted = pow(y_normalized, exponent);

  // highlights
  float y_highlighted = pow(y_contrasted, config.highlights);
  y_highlighted = lerp(y_contrasted, y_highlighted, saturate(y_contrasted / highlight_mask));

  // shadows
  float y_shadowed = pow(y_highlighted, -1.f * (config.shadows - 2.f));
  y_shadowed = lerp(y_shadowed, y_highlighted, saturate(y_highlighted / shadow_mask));

  const float y_final = y_shadowed * mid_gray;

  color *= (y > 0 ? (y_final / y) : 0);

  return color;
}

float3 ApplySaturationBlowoutHueCorrectionHighlightSaturation(float3 tonemapped, float3 hue_reference_color, float y, renodx::color::grade::Config config) {
  float3 color = tonemapped;
  if (config.saturation != 1.f || config.dechroma != 0.f || config.hue_correction_strength != 0.f || config.blowout != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(color);

    if (config.hue_correction_strength != 0.f) {
      float3 perceptual_old = renodx::color::oklab::from::BT709(hue_reference_color);

      // Save chrominance to apply black
      float chrominance_pre_adjust = distance(perceptual_new.yz, 0);

      perceptual_new.yz = lerp(perceptual_new.yz, perceptual_old.yz, config.hue_correction_strength);

      float chrominance_post_adjust = distance(perceptual_new.yz, 0);

      // Apply back previous chrominance
      perceptual_new.yz *= renodx::math::DivideSafe(chrominance_pre_adjust, chrominance_post_adjust, 1.f);
    }

    if (config.dechroma != 0.f) {
      perceptual_new.yz *= lerp(1.f, 0.f, saturate(pow(y / (10000.f / 100.f), (1.f - config.dechroma))));
    }

    if (config.blowout != 0.f) {
      float percent_max = saturate(y * 100.f / 10000.f);
      // positive = 1 to 0, negative = 1 to 2
      float blowout_strength = 100.f;
      float blowout_change = pow(1.f - percent_max, blowout_strength * abs(config.blowout));
      if (config.blowout < 0) {
        blowout_change = (2.f - blowout_change);
      }

      perceptual_new.yz *= blowout_change;
    }

    perceptual_new.yz *= config.saturation;

    color = renodx::color::bt709::from::OkLab(perceptual_new);

    color = renodx::color::bt709::clamp::AP1(color);
  }
  return color;
}

float3 ApplyACESByLum(float3 untonemapped_ap1, renodx::color::grade::Config cg_config, bool apply_grading = true) {
  float untonemapped_lum = renodx::color::y::from::AP1(untonemapped_ap1);
  float3 original_bt709 = renodx::color::bt709::from::AP1(untonemapped_ap1);
  untonemapped_ap1 = local::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_ap1));

  const float ACES_MIN = 0.0001f;
  float aces_min = ACES_MIN / RENODX_DIFFUSE_WHITE_NITS;
  float aces_max = (RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS);

  if (RENODX_GAMMA_CORRECTION) {
    aces_max = renodx::color::correct::Gamma(aces_max, true);
    aces_min = renodx::color::correct::Gamma(aces_min, true);
  }

  float3 graded_ap1 = untonemapped_ap1;
  if (apply_grading) {
    graded_ap1 = ApplyExposureContrastFlareHighlightsShadowsByLuminance(untonemapped_ap1, untonemapped_lum, cg_config);
  }

  // tonemap both by channel and luminance
  graded_ap1 = max(0, graded_ap1);
  untonemapped_lum = renodx::color::y::from::AP1(graded_ap1);
  float4 dual_tonemapped_ap1 = local::tonemap::aces::ODT(float4(graded_ap1, untonemapped_lum), aces_min * 48.f, aces_max * 48.f, renodx::color::IDENTITY_MAT) / 48.f;

  float3 channel_tonemapped_ap1 = dual_tonemapped_ap1.rgb;
  float3 luminance_tonemapped_ap1 = graded_ap1 * (dual_tonemapped_ap1.a / untonemapped_lum);

  // correct luminance tonemap saturation
  luminance_tonemapped_ap1 = renodx::color::ap1::from::BT709(
      Chrominance(
          renodx::color::bt709::from::AP1(luminance_tonemapped_ap1),
          renodx::color::bt709::from::AP1(channel_tonemapped_ap1),
          1.f,   // strength
          0.f,   // clamp chrominance loss
          1u));  // hue processor

  // blend luminance and channel
  float lum = renodx::color::y::from::AP1(luminance_tonemapped_ap1);
  float3 tonemapped_ap1 = lerp(luminance_tonemapped_ap1, channel_tonemapped_ap1, saturate(lum / 1.f));
  float3 tonemapped_bt709 = renodx::color::bt709::from::AP1(tonemapped_ap1.rgb);

  if (apply_grading) {
    float3 hue_correction_color;
    hue_correction_color = renodx::tonemap::uncharted2::BT709(original_bt709 * 2);
    tonemapped_bt709 = ApplySaturationBlowoutHueCorrectionHighlightSaturation(tonemapped_bt709, hue_correction_color, untonemapped_lum, cg_config);
    // tonemapped_bt709 = hue_correction_color;
  }

  return tonemapped_bt709;
}

float3 ApplyACES(float3 untonemapped_ap1, renodx::color::grade::Config cg_config) {
  untonemapped_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_ap1));
  float untonemapped_lum = renodx::color::y::from::AP1(untonemapped_ap1);
  cg_config.blowout = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);

  const float ACES_MIN = 0.0001f;
  const float ACES_EXPOSURE = 48.f;
  float aces_min = ACES_MIN / RENODX_DIFFUSE_WHITE_NITS;
  float aces_max = (RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS);

  if (RENODX_GAMMA_CORRECTION != 0.f) {
    aces_max = renodx::color::correct::Gamma(aces_max, true);
    aces_min = renodx::color::correct::Gamma(aces_min, true);
  }

  untonemapped_ap1 = ApplyExposureContrastFlareHighlightsShadowsByLuminance(untonemapped_ap1, untonemapped_lum, cg_config);
  float3 tonemapped_ap1 = renodx::tonemap::aces::ODT(untonemapped_ap1, aces_min * ACES_EXPOSURE, aces_max * ACES_EXPOSURE, renodx::color::IDENTITY_MAT) / 48.f;
  float3 tonemapped_bt709 = renodx::color::bt709::from::AP1(tonemapped_ap1);
  tonemapped_bt709 = ApplySaturationBlowoutHueCorrectionHighlightSaturation(tonemapped_bt709, renodx::color::bt709::from::AP1(untonemapped_ap1), untonemapped_lum, cg_config);

  return tonemapped_bt709;
}

float3 Tonemap(float3 untonemapped_bt709) {
  // float3 untonemapped_graded = renodx::draw::ComputeUntonemappedGraded(RENODX_UE_CONFIG.untonemapped_bt709, RENODX_UE_CONFIG.graded_bt709, config);

  // float3 color = untonemapped_graded;
  float3 color = untonemapped_bt709;

  renodx::color::grade::Config grading_config = renodx::color::grade::config::Create();
  grading_config.exposure = RENODX_TONE_MAP_EXPOSURE;
  grading_config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  grading_config.shadows = RENODX_TONE_MAP_SHADOWS;
  grading_config.contrast = RENODX_TONE_MAP_CONTRAST;
  grading_config.flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
  grading_config.saturation = RENODX_TONE_MAP_SATURATION;
  grading_config.dechroma = RENODX_TONE_MAP_BLOWOUT;
  grading_config.blowout = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
  grading_config.hue_correction_strength = CUSTOM_COLOR_GRADE_HUE_SHIFT;

  float3 untonemapped_ap1 = renodx::color::ap1::from::BT709(color);
  color = ApplyACESByLum(untonemapped_ap1, grading_config);
  color = GammaCorrectHuePreserving(color);
  color = renodx::color::bt2020::from::BT709(color);

  return color;
}

float3 GammaCorrectHuePreserving(float3 incorrect_color) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from per channel gamma correction
  // float3 result = ChrominanceOKLab(lum, ch, 1.f, 1.f);
  float3 result = ChrominanceICtCp(lum, ch, 1.f);

  return result;
}
