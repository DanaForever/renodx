#include "./shared.h"


float ReinhardExtended(float x, float white_max, float x_max = 1.f, float shoulder = 0.18f) {
  const float x_min = 0.f;
  // float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  // float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  extended = min(extended, x_max);

  return extended;
}



float3 CorrectGammaHuePreserving(float3 incorrect_color, float gamma=2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ?  y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);

  return result;
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

  if (tonemap_to_human_vision)  {

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







float3 CustomSwapchainPass(float3 color)  {
  renodx::draw::Config config = renodx::draw::BuildConfig();

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = CorrectGammaHuePreserving(color, 2.2f);

  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = CorrectGammaHuePreserving(color, 2.4f);
  }

  // color = expandGamut(color, 1000.f);

  // [branch]
  // if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT709D93(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT601NTSCU(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::ARIBTRB9(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // }

  // Gamut Compression
  color = renodx::color::bt2020::from::BT709(color);
  float grayscale = renodx::color::convert::Luminance(color, renodx::color::convert::COLOR_SPACE_BT2020);
  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
  float encode_gamma = MID_GRAY_GAMMA;
  float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
  float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
  float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
  color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);
  color = max(0.f, color);
  color = renodx::color::bt709::from::BT2020(color);

  float swap_chain_scale_nits = RENODX_DIFFUSE_WHITE_NITS;

  if (shader_injection.processing_path == 0.f)  {
    swap_chain_scale_nits = RENODX_DIFFUSE_WHITE_NITS;
  } else {
    // SDR path - maybe use GRAPHICS_WHITE_NITS
    swap_chain_scale_nits = RENODX_GRAPHICS_WHITE_NITS;
  }

  color *= swap_chain_scale_nits;
  float max_channel = max(max(max(color.r, color.g), color.b), config.swap_chain_clamp_nits);
  color *= config.swap_chain_clamp_nits / max_channel;  // Clamp UI or Videos

  color /= 80.f;

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


float3 psychotm_test4(
    float3 bt709_linear_input,
    float peak_value = 1000.f / 203.f,
    float exposure = 1.f,
    float highlights = 1.f,
    float shadows = 1.f,
    float contrast = 1.f,
    float purity_scale = 1.f,
    float bleaching_intensity = 0.f,
    float hue_restore = 1.f,
    float adaptation_contrast = 1.f,
    float cone_response_exponent = 1.f) {
  const float kEps = 1e-6f;
  float3 bt2020 = renodx::color::bt2020::from::BT709(bt709_linear_input * exposure);

  float3x3 XYZ_TO_LMS_PROPOSED_2023 = float3x3(
      0.185083290265044, 0.584080232530060, -0.0240724126371618,
      -0.134432464433222, 0.405751419882862, 0.0358251078084051,
      0.000789395399878065, -0.000912213029667692, 0.0198489810108856);

  float3x3 XYZ_TO_LMS_2006 = XYZ_TO_LMS_PROPOSED_2023;

  // Match BT709WithBT2020 slider behavior for brightness-domain controls.
  float3 midgray_xyz = renodx::color::xyz::from::BT2020(0.18f.xxx);
  float3 midgray_lms = mul(XYZ_TO_LMS_2006, midgray_xyz);
  float mid_gray_luminosity = 1.55f * midgray_lms.x + midgray_lms.y;

  float3 color_xyz = renodx::color::xyz::from::BT2020(bt2020);
  float3 color_lms = mul(XYZ_TO_LMS_2006, color_xyz);
  float current_luminosity = 1.55f * color_lms.x + color_lms.y;
  float luminosity = current_luminosity;

  if (highlights != 1.f) {
    luminosity = renodx::color::grade::Highlights(luminosity, highlights, mid_gray_luminosity);
  }
  if (shadows != 1.f) {
    luminosity = renodx::color::grade::Shadows(luminosity, shadows, mid_gray_luminosity);
  }
  if (contrast != 1.f) {
    luminosity = renodx::color::grade::ContrastSafe(luminosity, contrast, mid_gray_luminosity);
  }

  float luminosity_scale = renodx::math::DivideSafe(luminosity, current_luminosity, 1.f);
  bt2020 *= luminosity_scale;

  // Fixed white basis: D65.
  float3 lms_raw = mul(XYZ_TO_LMS_2006, renodx::color::xyz::from::BT2020(bt2020));
  float3 lms_white = mul(XYZ_TO_LMS_2006, renodx::color::xyz::from::BT2020(1.f.xxx));
  float vstar_white = 1.55f * lms_white.x + lms_white.y;
  float3 midgray_lms_anchor = lms_white * 0.18f;

  // Saturation in ACC chroma plane (.yz) around same-V* white anchor.
  if (purity_scale != 1.f) {
    float vstar_input_sat = 1.55f * lms_raw.x + lms_raw.y;
    float3 lms_white_sat = lms_white * renodx::math::DivideSafe(vstar_input_sat, vstar_white, 0.f);

    float3 base_sat = max(lms_white_sat, kEps.xxx);
    float3 cone_contrast = (lms_raw - base_sat) / base_sat;

    float3 white_safe = max(lms_white, kEps.xxx);
    float mc1 = white_safe.x / white_safe.y;
    float mc2 = (white_safe.x + white_safe.y) / white_safe.z;
    float3x3 lms_to_acc = float3x3(
        1.f, 1.f, 0.f,
        1.f, -mc1, 0.f,
        -1.f, -1.f, mc2);
    float3x3 acc_to_lms = renodx::math::Invert3x3(lms_to_acc);

    float3 acc = mul(lms_to_acc, cone_contrast);
    acc.yz *= purity_scale;
    float3 cone_contrast_scaled = mul(acc_to_lms, acc);
    lms_raw = lms_white_sat * (1.f.xxx + cone_contrast_scaled);
  }

  float3 lms_raw_source = lms_raw;

  // Adaptation-level contrast in LMS (inline Naka-Rushton around sigma).
  if (adaptation_contrast != 1.f) {
    float3 lms_sigma = max(midgray_lms_anchor, kEps.xxx);
    float exponent = max(adaptation_contrast, kEps);
    float3 ax = abs(lms_raw);
    float3 ax_n = pow(ax, exponent);
    float3 s_n = pow(lms_sigma, exponent);
    float3 response_target = ax_n / max(ax_n + s_n, kEps.xxx);
    float3 response_baseline = ax / max(ax + lms_sigma, kEps.xxx);
    float3 gain = response_target / max(response_baseline, kEps.xxx);
    float3 sign_raw = float3(
        lms_raw.x < 0.f ? -1.f : 1.f,
        lms_raw.y < 0.f ? -1.f : 1.f,
        lms_raw.z < 0.f ? -1.f : 1.f);
    lms_raw = sign_raw * (ax * gain);

    // Inline hue-preserve at matched V* anchors.
    if (hue_restore > 0.f) {
      float vstar_source = 1.55f * lms_raw_source.x + lms_raw_source.y;
      float vstar_target = 1.55f * lms_raw.x + lms_raw.y;
      float3 lms_white_source = lms_white * renodx::math::DivideSafe(vstar_source, vstar_white, 0.f);
      float3 lms_white_target = lms_white * renodx::math::DivideSafe(vstar_target, vstar_white, 0.f);
      float3 dir_source = lms_raw_source - lms_white_source;
      float3 dir_target = lms_raw - lms_white_target;
      float len_source = length(dir_source);
      float len_target = length(dir_target);
      if (len_source > 0.f && len_target > 0.f) {
        float chroma_scale = renodx::math::DivideSafe(len_target, len_source, 0.f);
        float3 lms_hue_preserved = lms_white_target + dir_source * chroma_scale;
        lms_raw = lerp(lms_raw, lms_hue_preserved, hue_restore);
      }
    }
  }

  float3 lms = lms_raw;

  // D65 bleaching path inline (no white-basis branching).
  if (bleaching_intensity != 0.f) {
    float blend = bleaching_intensity;
    float diffuse_white_nits = 100.f;
    float pupil_area_mm2 = 4.f;
    float half_bleach_trolands = 20000.f;

    // Adapted white proxy (same as previous path): neutral at adapted V*.
    float adapted_vstar = max(1.55f * max(lms.x, 0.f) + max(lms.y, 0.f), 0.18f);
    float3 adapted_lms = lms_white * adapted_vstar;

    // Compute per-cone availability from adapted LMS:
    // p(I) = 1 / (1 + I / I0)
    float3 stimulus_nits = max(adapted_lms, 0.f) * max(diffuse_white_nits, 0.f);
    float3 stimulus_trolands = stimulus_nits * max(pupil_area_mm2, 0.f);
    float half_bleach_safe = max(half_bleach_trolands, kEps);
    float3 availability_raw = 1.f.xxx / (1.f.xxx + stimulus_trolands / half_bleach_safe);
    float3 availability = lerp(1.f.xxx, availability_raw, blend);

    // White-relative per-cone attenuation in LMS.
    float y_lm = lms.x + lms.y;
    float white_y_lm = lms_white.x + lms_white.y;
    if (y_lm > kEps && white_y_lm > kEps) {
      float3 white_at_y = lms_white * (y_lm / white_y_lm);
      float3 delta = lms - white_at_y;
      delta *= max(availability, 0.f.xxx);
      lms = white_at_y + delta;
    }
  }

  // Fixed white curve: Naka-Rushton to peak, per LMS channel (inline equation).
  float3 lms_peak = lms_white * peak_value;
  float exponent_tone = max(cone_response_exponent, kEps);
  float3 p = max(lms_peak, kEps.xxx);
  float3 g = clamp(midgray_lms_anchor, kEps.xxx, p - kEps.xxx);
  float3 n = exponent_tone * p / max(p - g, kEps.xxx);
  float3 sign_lms = float3(
      lms.x < 0.f ? -1.f : 1.f,
      lms.y < 0.f ? -1.f : 1.f,
      lms.z < 0.f ? -1.f : 1.f);
  float3 ax_lms = abs(lms);
  float3 sigma_n = pow(g, n - 1.f.xxx) * (p - g);
  float3 x_n = pow(ax_lms, n);
  float3 y = p * (x_n / max(x_n + sigma_n, kEps.xxx));
  float3 lms_toned = sign_lms * y;

  // Inline hue-preserve after tonemap.
  if (hue_restore > 0.f) {
    float vstar_source = 1.55f * lms.x + lms.y;
    float vstar_target = 1.55f * lms_toned.x + lms_toned.y;
    float3 lms_white_source = lms_white * renodx::math::DivideSafe(vstar_source, vstar_white, 0.f);
    float3 lms_white_target = lms_white * renodx::math::DivideSafe(vstar_target, vstar_white, 0.f);
    float3 dir_source = lms - lms_white_source;
    float3 dir_target = lms_toned - lms_white_target;
    float len_source = length(dir_source);
    float len_target = length(dir_target);
    if (len_source > 0.f && len_target > 0.f) {
      float chroma_scale = renodx::math::DivideSafe(len_target, len_source, 0.f);
      float3 lms_hue_preserved = lms_white_target + dir_source * chroma_scale;
      lms_toned = lerp(lms_toned, lms_hue_preserved, hue_restore);
    }
  }

  float3x3 XYZ_FROM_LMS_2006 = renodx::math::Invert3x3(XYZ_TO_LMS_2006);

  float3 bt2020_toned = renodx::color::bt2020::from::XYZ(mul(XYZ_FROM_LMS_2006, lms_toned));
  // bt2020_toned = BT2020MapAnyToBoundsLMS(bt2020_toned, 0.f);
  return renodx::color::bt709::from::BT2020(bt2020_toned);
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

  float scalar_output = renodx::tonemap::ReinhardPiecewiseExtended(scalar_input, 100.f, scalar_peak, 0.000001);

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



float3 DisplayMap(float3 color) {
  // Tonemapping
  if (RENODX_TONE_MAP_TYPE > 1.f) {
    color = LMS_Vibrancy(color, shader_injection.tone_map_saturation, shader_injection.tone_map_contrast, true);
    // color = LMS_Vibrancy(color, shader_injection.tone_map_saturation, shader_injection.tone_map_contrast, false);
    float3 dechroma = CastleDechroma_CVVDPStyle_NakaRushton(color);

    color = lerp(color, dechroma, shader_injection.tone_map_blowout);

    float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
    
    if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
      peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.2f);

    } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
      peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.4f);
    }

    color = renodx::color::bt2020::from::BT709(color);               // displaymap in bt2020
    color = renodx::tonemap::neutwo::MaxChannel(color, peak_ratio, 100.f);  // Display map to peak]
    color = renodx::color::bt709::from::BT2020(color);  // Back to BT709

    // color = ReinhardBT709WhiteForEnergy(color, peak_ratio);
    // color = renodx::draw::ToneMapPass(color);

  } else {

  }
  
  if (shader_injection.processing_path == 0.f)  {
    return CustomSwapchainPass(color);
    
  } else {
    // SDR path, process later
    // maybe PostToneMapScale?
    return PostToneMapProcess(color);
  }
}
