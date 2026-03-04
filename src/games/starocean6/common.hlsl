
#include "./shared.h"
#include "./macleod_boynton.hlsli"
#include "./psycho_test11.hlsl"
#include "so6utils.hlsl"

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

float3 CorrectPurityMBBT709WithBT2020(
    float3 target_color_bt709,
    float3 purity_reference_bt709,
    float strength = 1.f,
    float curve_gamma = 1.f,
    float2 mb_white_override = float2(-1.f, -1.f),
    float t_min = 1e-6f,
    float clamp_purity_loss = 0.f) {
  if (strength <= 0.f) return target_color_bt709;

  float3 target_color_bt2020 = renodx::color::bt2020::from::BT709(target_color_bt709);
  float3 purity_reference_bt2020 = renodx::color::bt2020::from::BT709(purity_reference_bt709);

  float reference_purity01 =
      renodx_custom::color::macleod_boynton::ApplyBT2020(purity_reference_bt2020, 1.f, 1.f,
                                                         mb_white_override, t_min)
          .purityCur01;

  float applied_purity01;
  if (strength == 1.f && clamp_purity_loss <= 0.f) {
    // Fast path: full transfer only needs donor purity.
    applied_purity01 = reference_purity01;
  } else {
    float target_purity01 =
        renodx_custom::color::macleod_boynton::ApplyBT2020(target_color_bt2020, 1.f, 1.f,
                                                           mb_white_override, t_min)
            .purityCur01;

    applied_purity01 = lerp(target_purity01, reference_purity01, strength);

    if (clamp_purity_loss > 0.f) {
      float clamp_strength = saturate(clamp_purity_loss);
      // Only clamp purity reductions: if applied < target, pull back toward target.
      float t = 1.f - step(target_purity01, applied_purity01);
      applied_purity01 = lerp(applied_purity01, target_purity01, t * clamp_strength);
    }
  }

  return renodx::color::bt709::from::BT2020(
      renodx_custom::color::macleod_boynton::ApplyBT2020(
          target_color_bt2020, applied_purity01, curve_gamma, mb_white_override, t_min)
          .rgbOut);
}


float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma=2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ?  y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  // float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);
  float3 result = CorrectPurityMBBT709WithBT2020(lum, incorrect_color);

  return result;
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

float3x3 XYZ_TO_LMS_2006 = float3x3(
    0.185082982238733f, 0.584081279463687f, -0.0240722415044404f,
    -0.134433056469973f, 0.405752392775348f, 0.0358252602217631f,
    0.000789456671966863f, -0.000912281325916184f, 0.0198490812339463f);

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
  // float3x3 XYZ_TO_LMS_2006 = float3x3(
  //     0.185082982238733f, 0.584081279463687f, -0.0240722415044404f,
  //     -0.134433056469973f, 0.405752392775348f, 0.0358252602217631f,
  //     0.000789456671966863f, -0.000912281325916184f, 0.0198490812339463f);

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



// Samsung research
static const float3x3 XYZ_TO_LMS_PROPOSED_2023 = float3x3(
    0.185083290265044, 0.584080232530060, -0.0240724126371618,
    -0.134432464433222, 0.405751419882862, 0.0358251078084051,
    0.000789395399878065, -0.000912213029667692, 0.0198489810108856);

float3 NeutwoBT709WhiteForEnergy(float3 bt709_linear, float peak = 1.f) {
  float peak_ref = max(peak, 1e-6f);

  float3x3 xyz_to_lms = renodx::color::XYZ_TO_STOCKMAN_SHARP_LMS_MAT;
  // float3x3 xyz_to_lms = XYZ_TO_LMS_PROPOSED_2023;
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

float CalculateLuminosity(float3 color) {
  float3 color_xyz = renodx::color::xyz::from::BT709(color);
  float3 color_lms = mul(XYZ_TO_LMS_2006, color_xyz);
  float current_luminosity = 1.55f * color_lms.x + color_lms.y;
  float luminosity = current_luminosity;

  return luminosity;
}

float CalculateLuminance(float3 color) {
  return renodx::color::y::from::BT709(color);
}

 
renodx::lut::Config CreatePQInPQBOutLUTConfig() {
  renodx::lut::Config lut_config = renodx::lut::config::Create();
  lut_config.scaling = CUSTOM_LUT_SCALING;
  lut_config.type_input = renodx::lut::config::type::PQ;
  lut_config.type_output = renodx::lut::config::type::PQ;
  lut_config.recolor = 0.f;
  lut_config.size = 32;
  return lut_config;
}

float3 SampleColor(float3 color, renodx::lut::Config lut_config, Texture3D<float4> lut_texture) {
  float3 sampled_color = renodx::lut::SampleTetrahedral(lut_texture, color, lut_config.size);
  return sampled_color;
}

float3 GammaOutput(float3 color) {
  float3 linear_color = PQtoLinear(color);
  return renodx::color::srgb::Encode(max(0, linear_color));
}

float3 RecolorUnclamped(float3 original_linear, float3 unclamped_linear, float strength = 1.f) {
  const float3 original_perceptual = renodx::color::oklab::from::BT709(original_linear);

  // Hue correction
  float3 retinted_perceptual = renodx::color::oklab::from::BT709(unclamped_linear);
  retinted_perceptual[0] = max(0, retinted_perceptual[0]);
  retinted_perceptual[1] = original_perceptual[1];
  retinted_perceptual[2] = original_perceptual[2];

  // Blend values
  retinted_perceptual = lerp(original_perceptual, retinted_perceptual, strength);

  float3 retinted_linear = renodx::color::bt709::from::OkLab(retinted_perceptual);
  retinted_linear = renodx::color::bt709::clamp::BT2020(retinted_linear);
  return retinted_linear;
}

float3 SampleLUT(Texture3D<float4> lut_texture, renodx::lut::Config lut_config, float3 color_input) {
  float3 lutInputColor = LinearToPQ(color_input);
  float3 lutOutputColor = SampleColor(lutInputColor, lut_config, lut_texture);
  float3 color_output = PQtoLinear(lutOutputColor);

  // return color_output;
  [branch]
  if (lut_config.scaling != 0.f) {
    float3 lutBlack = SampleColor(LinearToPQ(0), lut_config, lut_texture);
    float3 lutMid = SampleColor(LinearToPQ(0.18f), lut_config, lut_texture);
    float3 lutWhite = SampleColor(LinearToPQ(1.f), lut_config, lut_texture);
    float3 unclamped_gamma = renodx::lut::Unclamp(
        GammaOutput(lutOutputColor),
        GammaOutput(lutBlack),
        GammaOutput(lutMid),
        GammaOutput(lutWhite),
        renodx::color::srgb::Encode(max(0, color_input)));
    float3 unclamped_linear = renodx::color::srgb::DecodeSafe(unclamped_gamma);
    float3 recolored = RecolorUnclamped(color_output, unclamped_linear, lut_config.scaling);
    color_output = recolored;
  } else {
  }
  if (lut_config.recolor != 0.f) {
    color_output = renodx::lut::RestoreSaturationLoss(color_input, color_output, lut_config);
  }

  return color_output;
}

float ReinhardExtended(float x, float white_max, float x_max = 1.f, float shoulder = 0.18f) {
  const float x_min = 0.f;
  // float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  // float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  extended = min(extended, x_max);

  return extended;
}

float3 LMS_Vibrancy(float3 color, float vibrancy, float contrast, bool tonemap_to_human_vision = false) {
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

  if (tonemap_to_human_vision) {
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

    lms = new_lms;
  }

  XYZ = mul(LMS_TO_XYZ, lms);

  color = renodx::color::bt709::from::XYZ(XYZ);

  return color;
}

float3 RestoreSaturationLoss(float3 color_input, float3 color_output, float strength = 1.f) {
  
  float3 clamped = renodx::color::bt709::clamp::BT2020(color_output);

  float3 perceptual_in = renodx::color::oklab::from::BT709(color_input);
  float3 perceptual_clamped = renodx::color::oklab::from::BT709(clamped);
  float3 perceptual_out = renodx::color::oklab::from::BT709(color_output);

  float chroma_in = distance(perceptual_in.yz, 0);
  float chroma_clamped = distance(perceptual_clamped.yz, 0);
  float chroma_out = distance(perceptual_out.yz, 0);
  float chroma_loss = renodx::math::DivideSafe(chroma_in, chroma_clamped, 0.f);
  float chroma_new = chroma_out * chroma_loss;

  perceptual_out.yz *= lerp(1.f, renodx::math::DivideSafe(chroma_new, chroma_out, 1.f), strength);

  return renodx::color::bt709::from::OkLab(perceptual_out);
}

float3 LUTSampleAndToneMap(float4 r0, Texture3D<float4> lut, SamplerState lut_sampler) {
  // untonemapped in PQ
  float white = 203.f;

  float3 lut_input_hdr = r0.rgb;
  float3 untonemapped = PQtoLinear(r0.xyz, white, true);

  // we scale it down to SDR range to treat the HDR LUT as SDR LUT, and scale it back up after

  // untonemapped = min(untonemapped, 10000.f / white);
  float scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(untonemapped);
  float3 sdr = untonemapped * scale;

  float3 lut_input = LinearToPQ(sdr, white, true);

  renodx::lut::Config lut_config = CreatePQInPQBOutLUTConfig();

  // float3 lut_output = SampleLUT(lut, lut_config, untonemapped); // in linear
  float3 lut_output = renodx::lut::SampleTetrahedral(lut, lut_input, 32u);
  float3 linear_graded = PQtoLinear(lut_output);
  
  linear_graded /= scale;

  float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

  float3 bt709_tonemapped;
  peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.4f);
  linear_graded = renodx::tonemap::psycho::psychotm_test11(
      linear_graded,
      peak_ratio,                           // peak
      1.0f,                                 // exposure
      1.0f,                                 // highlights
      1.0f,                                 // shadows
      1.0f,                                 // contrast
      1.0f,                                 // purity_scale
      1.0f,                                 // bleaching_intensity
      100.f,                                // clip_point
      0.0f,                                 // hue_restore
      1.0f,                                 // adaptation_contrast
      1,                                    // naka rushton
      1.0f + 0.025 * (peak_ratio - 1.0f));  // cone_response_exponent

  float3 reference_pq = renodx::lut::SampleTetrahedral(lut, lut_input_hdr, 32u);

  // return reference_pq; 
  float3 reference_linear = PQtoLinear(reference_pq, white, true);

  // linear_graded = RestoreSaturationLoss(linear_graded, untonemapped);
  linear_graded = CorrectHueAndPurity(linear_graded, reference_linear, 1.f);
  float3 pq_graded = LinearToPQ(linear_graded, RENODX_DIFFUSE_WHITE_NITS, true);

  return pq_graded;
}