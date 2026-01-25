
#include "./shared.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f

static const float3x3 XYZ_2_sRGB_MAT = float3x3(
	3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363, 1.8759675015, 0.0415550574,
	0.0556300797, -0.2039769589, 1.0569715142);
static const float3x3 sRGB_2_XYZ_MAT = float3x3(
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041);
static const float3x3 XYZ_2_AP1_MAT = float3x3(
	1.6410233797, -0.3248032942, -0.2364246952,
	-0.6636628587, 1.6153315917, 0.0167563477,
	0.0117218943, -0.0082844420, 0.9883948585);
static const float3x3 D65_2_D60_CAT = float3x3(
	1.01303, 0.00610531, -0.014971,
	0.00769823, 0.998165, -0.00503203,
	-0.00284131, 0.00468516, 0.924507);
static const float3x3 D60_2_D65_CAT = float3x3(
	0.987224, -0.00611327, 0.0159533,
	-0.00759836, 1.00186, 0.00533002,
	0.00307257, -0.00509595, 1.08168);
static const float3x3 AP1_2_XYZ_MAT = float3x3(
	0.6624541811, 0.1340042065, 0.1561876870,
	0.2722287168, 0.6740817658, 0.0536895174,
	-0.0055746495, 0.0040607335, 1.0103391003);
static const float3 AP1_RGB2Y = float3(
	0.2722287168, //AP1_2_XYZ_MAT[0][1],
	0.6740817658, //AP1_2_XYZ_MAT[1][1],
	0.0536895174 //AP1_2_XYZ_MAT[2][1]
);
// Bizarre matrix but this expands sRGB to between P3 and AP1
// CIE 1931 chromaticities:	x		y
//				Red:		0.6965	0.3065
//				Green:		0.245	0.718
//				Blue:		0.1302	0.0456
//				White:		0.31271	0.32902
static const float3x3 Wide_2_XYZ_MAT = float3x3(
    0.5441691, 0.2395926, 0.1666943,
    0.2394656, 0.7021530, 0.0583814,
    -0.0023439, 0.0361834, 1.0552183);

static const float M1 = 2610.f / 16384.f;           // 0.1593017578125f;
static const float M2 = 128.f * (2523.f / 4096.f);  // 78.84375f;
static const float C1 = 3424.f / 4096.f;            // 0.8359375f;
static const float C2 = 32.f * (2413.f / 4096.f);   // 18.8515625f;
static const float C3 = 32.f * (2392.f / 4096.f);   // 18.6875f;


float3 hdrExtraSaturation(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
{
    const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
    const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
    const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
    const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

    float3 ColorAP1 = mul(sRGB_2_AP1, vHDRColor);

    float LumaAP1 = dot(ColorAP1, AP1_RGB2Y);
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

float3 expandGamut(float3 color, float fExpandGamut /*= 1.0f*/) {

    if (RENODX_TONE_MAP_TYPE == 0.f)  {
      return color;
    }

    if (fExpandGamut > 0.f) {

      // Do this with a paper white of 203 nits, so it's balanced (the formula seems to be made for that),
      // and gives consistent results independently of the user paper white
      static const float sRGB_max_nits = 80.f;
      static const float ReferenceWhiteNits_BT2408 = 203.f;
      const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

      float3 vHDRColor = color * recommendedBrightnessScale;

      vHDRColor = hdrExtraSaturation(vHDRColor, fExpandGamut);

      color = vHDRColor /  recommendedBrightnessScale;

    }

    return color;

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




float3 GamutCompress(float3 color, float grayscale) {
  // Desaturate (move towards grayscale) until no channel is below 0
  float lowest_negative_channel = min(0.f, min(color.r, min(color.g, color.b)));
  float distance = grayscale - lowest_negative_channel;

  float ratio = renodx::math::DivideSafe(-lowest_negative_channel, distance, 0.f);

  // if grayscale is 0, ratio is 0 via DivideSafe, so no change
  // if minchannel is 0, ratio is 0, so no change
  color = lerp(grayscale, color, 1.f - ratio);

  return color;
}

float3 GamutCompress(float3 color) {
  color = renodx::color::bt2020::from::BT709(color);
  float y = renodx::color::y::from::BT2020(color);
  color = GamutCompress(color, y);
  color = renodx::color::bt709::from::BT2020(color);
  return color;
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


// --- Saturation curve for cone response ---
float NakaRushton(float x, float sigma) {
  return x / (x + sigma);
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




float3 LMS_ToneMap_Stockman(float3 color, float vibrancy, float contrast) {
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

  XYZ = mul(LMS_TO_XYZ, new_lms);

  color = renodx::color::bt709::from::XYZ(XYZ);

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

float3 UserColorGradeSRGB(float3 color) {
  color = renodx::color::srgb::DecodeSafe(color);

  color = color = UserColorGrading(
      color,
      injectedData.colorGradeExposure,    // exposure
      injectedData.colorGradeHighlights,  // highlights
      injectedData.colorGradeShadows,     // shadows
      injectedData.colorGradeContrast,    // contrast
      1.f,                                // saturation, we'll do this post-tonemap
      0.f);                               // dechroma, post tonemapping
                                          // hue correction, Post tonemapping

  color = renodx::color::srgb::EncodeSafe(color);

  return color;
}


float3 ToneMap(float3 color, float peak, float paperwhite) {
  
  float3 originalColor = color;

  color = LMS_ToneMap_Stockman(color, 1.f,
                               1.f);


  // color = renodx::draw::ToneMapPass(color, config);
  float rpeak = peak / paperwhite;

  float3 lum_color = renodx::tonemap::HermiteSplineLuminanceRolloff(color, rpeak);
  // float3 perch_color = renodx::tonemap::HermiteSplinePerChannelRolloff(color, peak);

  // color = renodx::color::correct::Chrominance(lum_color, perch_color, RENODX_TONE_MAP_HUE_CORRECTION);
  color = lum_color;

  color = renodx::color::grade::UserColorGrading(
      color,
      1.f,                         // exposure
      1.f,                         // highlights
      1.f,                         // shadows
      1.f,                         // contrast
      injectedData.colorGradeSaturation,  // saturation
      0.f,     // dechroma, we don't need it
      0.f,                         // Hue Correction Strength
      color);                      // Hue Correction Type

  return color;
}




float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, ch, 1.0f, 0.0f);
  // float3 result = renodx::color::correct::Chrominance(lum, ch);

  return result;
}

float3 SDRTonemap(float3 untonemapped) {
  float maxChannel = renodx::math::Max(untonemapped);

  if (maxChannel == 0.f)
    return 0.f;
  else {
      float3 output = 1 - (untonemapped / maxChannel);

      return output;
  }
}