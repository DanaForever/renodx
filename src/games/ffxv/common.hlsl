
#include "./shared.h"
#include "./macleod_boynton.hlsli"


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


float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma=2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ?  y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);

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

  untonemapped_graded = LMS_Vibrancy(untonemapped_graded, shader_injection.tone_map_lms_vibrancy, shader_injection.tone_map_lms_contrast);

  // this dechromas too much
  // untonemapped_graded = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded, RENODX_DIFFUSE_WHITE_NITS, 100.f, 1.f);

  return renodx::draw::ToneMapPass(untonemapped_graded, config);
}

float3 ToneMapPassLMS(float3 untonemapped, float3 graded_sdr_color) {
  return ToneMapPassLMS(untonemapped, graded_sdr_color, renodx::draw::BuildConfig());
}

float3 ToneMapLMS(float3 untonemapped) {
  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 untonemapped_graded = untonemapped;

  untonemapped_graded = LMS_Vibrancy(untonemapped_graded, shader_injection.tone_map_lms_vibrancy, shader_injection.tone_map_lms_contrast);

  // naka rushton
  float3 untonemapped_graded_dechroma = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded, RENODX_DIFFUSE_WHITE_NITS, 100.f, 1.f);

  // untonemapped_graded = lerp(untonemapped_graded, untonemapped_graded_dechroma, shader_injection.color_grade_strength);

  float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

  float3 bt709_tonemapped = renodx::draw::ToneMapPass(untonemapped_graded);

  return bt709_tonemapped;
}

/// Log contrast curve used in case 4 of Nioh LUT builder.
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