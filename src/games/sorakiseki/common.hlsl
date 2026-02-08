#include "./shared.h"
#include "lms_matrix.hlsl"
#include "DICE.hlsl"

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

float pqEncode(float color, float scaling = 10000.f) {
  color *= (scaling / 10000.f);
  float y_m1 = pow(color, M1);
  return pow((C1 + C2 * y_m1) / (1.f + C3 * y_m1), M2);
}

float pqDecode(float color, float scaling = 10000.f) {
  float e_m12 = pow(color, 1.f / M2);
  float out_color = pow(max(0, e_m12 - C1) / (C2 - C3 * e_m12), 1.f / M1);
  return out_color * (10000.f / scaling);
}

float pqEncodeSafe(float color, float scaling = 10000.f) {
  return pqEncode(max(0, color), scaling);
}

float pqDecodeSafe(float color, float scaling = 10000.f) {
  return pqDecode(max(0, color), scaling);
}

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


float3 ExponentialRollOffByLum(float3 color, float output_luminance_max, float highlights_shoulder_start = 0.f, bool pq = false) {
  const float y = renodx::color::y::from::BT709(color);

  [branch]
  if (y > 0.0f) {
    if (pq) {
      highlights_shoulder_start = 0.33 * output_luminance_max;
      float compressed_luminance = exp2(renodx::tonemap::ExponentialRollOff(log2(y), log2(highlights_shoulder_start), log2(output_luminance_max)));
      color *= compressed_luminance / y;
    }
    else {
      const float compressed_luminance = renodx::tonemap::ExponentialRollOff(y, highlights_shoulder_start, output_luminance_max);
      color *= compressed_luminance / y;
    }
  }

  return color;
}


float3 ApplyExponentialRollOff(float3 color, bool pq = false) {
  const float paperWhite = RENODX_DIFFUSE_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;

  const float peakWhite = RENODX_PEAK_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;

  // const float highlightsShoulderStart = paperWhite;
  float highlightsShoulderStart = 1.0f;

  [branch]
  if (RENODX_TONE_MAP_PER_CHANNEL == 1.f) {
    // float3 color_lum = ExponentialRollOffByLum(color * paperWhite, peakWhite, highlightsShoulderStart, false) / paperWhite;

    color = color * paperWhite;
    float3 signs = sign(color);
    color = abs(color);
    color = renodx::tonemap::ExponentialRollOff(color, highlightsShoulderStart, peakWhite) / paperWhite;
    color = signs * color;

    // float y = renodx::color::y::from::BT709(color);
    // color = renodx::color::correct::ChrominanceICtCp(color, color_lum, 0.5f);
  } else {
    float3 color_lum = ExponentialRollOffByLum(color * paperWhite, peakWhite, highlightsShoulderStart, false) / paperWhite;

    color = color * paperWhite;
    float3 signs = sign(color);
    color = abs(color);
    color = renodx::tonemap::ExponentialRollOff(color, highlightsShoulderStart, peakWhite) / paperWhite;
    color = signs * color;

    // float y = renodx::color::y::from::BT709(color);
    color = renodx::color::correct::Chrominance(color_lum, color, 1.f, 0.f, RENODX_TONE_MAP_HUE_PROCESSOR);
    // color = color_lum;
  }

  return color;
}

// float3 GamutCompress(float3 color) {
//   color = renodx::color::bt2020::from::BT709(color);
//   float grayscale = renodx::color::y::from::BT2020(color);
//   // Desaturate (move towards grayscale) until no channel is below 0
//   float max_negative_channel = min(color.r, min(color.g, color.b));
//   if (max_negative_channel < 0.f) {
//     float desat_amount = renodx::math::DivideSafe(-max_negative_channel, (grayscale - max_negative_channel), 1.f);
//     color = lerp(grayscale, color, 1.f - desat_amount);
//   }
//   color = renodx::color::bt709::from::BT2020(color);
//   return color;
// }

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
  if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2.f) {
    color = renodx::color::ap1::from::BT709(color);
    float y = renodx::color::y::from::AP1(color);
    color = GamutCompress(color, y);
    color = renodx::color::bt709::from::AP1(color);
    return color;
  }
  else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1.f) {
    color = renodx::color::bt2020::from::BT709(color);
    float y = renodx::color::y::from::BT2020(color);
    color = GamutCompress(color, y);
    color = renodx::color::bt709::from::BT2020(color);
    return color;
  } else {
    return GamutCompress(color, renodx::color::y::from::BT709(color));
  }
}



float3 LMS_ToneMap(float3 bt709) {

  float3x3 XYZ_TO_LMS_D65_MAT;

  if (shader_injection.lms_matrix == 0.f) {
    return bt709;
  }

  switch (int(shader_injection.lms_matrix)) {
      case 1: 
        XYZ_TO_LMS_D65_MAT = CAT_VON_KRIES;
        break;
      case 2:
        XYZ_TO_LMS_D65_MAT = CAT_BRADFORD;
        break;
      case 3:
        XYZ_TO_LMS_D65_MAT = CAT_FAIRCHILD;
        break;
      default:
        XYZ_TO_LMS_D65_MAT = CAT_FAIRCHILD;
        break;
  }

  float3 lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::xyz::from::BT709(bt709));
  float3 midgray_lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::xyz::from::BT709(0.18f));

  // midgray match
  lms = renodx::math::DivideSafe(lms, midgray_lms, 1.f);
  lms = sign(lms) * pow(abs(lms), RENODX_TONE_MAP_CONTRAST);
  lms *= midgray_lms;

  const float human_vision_peak = 4000 / 203.f;
  float3 peak_lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::xyz::from::BT709(human_vision_peak));

  // Naka Rushton per cone
  float3 new_lms = float3(
      sign(lms.x) * renodx::tonemap::ReinhardScalableExtended(abs(lms.x), 100.f, peak_lms.x, 0.f, abs(midgray_lms.x), abs(midgray_lms.x)),
      sign(lms.y) * renodx::tonemap::ReinhardScalableExtended(abs(lms.y), 100.f, peak_lms.y, 0.f, abs(midgray_lms.y), abs(midgray_lms.y)),
      sign(lms.z) * renodx::tonemap::ReinhardScalableExtended(abs(lms.z), 100.f, peak_lms.z, 0.f, abs(midgray_lms.z), abs(midgray_lms.z)));

  float3 new_xyz = mul(renodx::math::Invert3x3(XYZ_TO_LMS_D65_MAT), new_lms);
  float3 input_color = renodx::color::bt709::from::XYZ(new_xyz);
  input_color = GamutCompress(input_color);
  return input_color;
  
}

float ReinhardPiecewiseExtended(float x, float white_max, float x_max = 1.f, float shoulder = 0.18f) {
  const float x_min = 0.f;
  float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  extended = min(extended, x_max);

  return lerp(x, extended, step(shoulder, x));
}

float3 ReinhardPiecewiseExtended(float3 x, float white_max, float x_max = 1.f, float shoulder = 0.18f, bool per_channel = true) {
  if (per_channel) {
    float y = renodx::color::y::from::BT709(x);
    float new_y = ReinhardPiecewiseExtended(y, 100.f, x_max);
    float3 lum = x * (y > 0 ? (new_y / y) : 0);

    float3 signs = sign(x);
    x = abs(x);
    const float x_min = 0.f;
    float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
    float3 extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
    extended = min(extended, x_max);

    x = lerp(x, extended, step(shoulder, x));
    x *= signs;

    // x = renodx::color::correct::ChrominanceICtCp(x, lum);

  } else {
    float3 perch = x;
    float3 signs = sign(perch);
    perch = abs(perch);
    const float x_min = 0.f;
    float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
    float3 extended = renodx::tonemap::ReinhardExtended(perch * exposure, white_max * exposure, x_max);
    extended = min(extended, x_max);

    perch = lerp(x, extended, step(shoulder, perch));
    perch *= signs;

    float y = renodx::color::y::from::BT709(x);

    float new_y = ReinhardPiecewiseExtended(y, 100.f, x_max);

    x = x * (y > 0 ? (new_y / y) : 0);
    
    // Luminance seems over-saturated, so chrominance correction seems to get the middle ground between perch and luminance.
    // x = renodx::color::correct::ChrominanceICtCp(x, perch, 0.5f);
  }

  return x;
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

float3 DICEToneMap(float3 color) {
  float3 untonemapped = color;

  color = UserColorGrading(
      color,
      RENODX_TONE_MAP_EXPOSURE,    // exposure
      RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
      RENODX_TONE_MAP_SHADOWS,     // shadows
      RENODX_TONE_MAP_CONTRAST,    // contrast
      1.f,                         // saturation, we'll do this post-tonemap
      0.f);                        // dechroma, post tonemapping
                                   // hue correction, Post tonemapping

  DICESettings DICEconfig = DefaultDICESettings();
  DICEconfig.Type = (int)shader_injection.dice_tone_map_type;
  DICEconfig.ShoulderStart = shader_injection.dice_shoulder_start;  // Start shoulder
  DICEconfig.DesaturationAmount = shader_injection.dice_desaturation;
  DICEconfig.DarkeningAmount = shader_injection.dice_darkening;

  float dicePaperWhite = RENODX_DIFFUSE_WHITE_NITS / 80.f;
  float dicePeakWhite = RENODX_PEAK_WHITE_NITS / 80.f;

  color = ApplyDICE(color * dicePaperWhite, dicePeakWhite, DICEconfig) / dicePaperWhite;

  color = renodx::color::grade::UserColorGrading(
      color,
      1.f,                         // exposure
      1.f,                         // highlights
      1.f,                         // shadows
      1.f,                         // contrast
      RENODX_TONE_MAP_SATURATION,  // saturation
      0.f,                         // dechroma, we don't need it
      0.f,                         // Hue Correction Strength
      color);                      // Hue Correction Type

  return color;
}

float3 FrostbiteToneMap(float3 color) {
  float3 untonemapped = color;

  color = renodx::color::grade::UserColorGrading(
      color,
      RENODX_TONE_MAP_EXPOSURE,    // exposure
      RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
      RENODX_TONE_MAP_SHADOWS,     // shadows
      RENODX_TONE_MAP_CONTRAST,    // contrast
      1.f,                         // saturation, we'll do this post-tonemap
      0.f,                         // dechroma, post tonemapping
      0.f);                        // hue correction, Post tonemapping

  float frostbitePeak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  color = renodx::tonemap::frostbite::BT709(color, frostbitePeak);

  color = renodx::color::grade::UserColorGrading(
      color,
      1.f,                         // exposure
      1.f,                         // highlights
      1.f,                         // shadows
      1.f,                         // contrast
      RENODX_TONE_MAP_SATURATION,  // saturation
      0.f,                         // dechroma, we don't need it
      0.f,                         // Hue Correction Strength
      color);                      // Hue Correction Type

  return color;
}



float3 ToneMap(float3 color) {
  
  float3 originalColor = color;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    // return saturate(color);
    return color;
  } else if (shader_injection.tone_map_type == 1.f) {
    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        RENODX_TONE_MAP_CONTRAST,    // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping
    color = LMS_ToneMap_Stockman(color, 1.f,
                                 1.f);
    color = FrostbiteToneMap(color);

    color = UserColorGrading(
        color,
        1.f,                         // exposure
        1.f,                         // highlights
        1.f,                         // shadows
        1.f,                         // contrast
        RENODX_TONE_MAP_SATURATION,  // saturation
        RENODX_TONE_MAP_BLOWOUT     // dechroma, we don't need it
    );

    return color;
  }
  else if (shader_injection.tone_map_type == 2.f) {
    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        RENODX_TONE_MAP_CONTRAST,    // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping
    color = LMS_ToneMap_Stockman(color, 1.f,
                                 1.f);
    color = DICEToneMap(color);

    color = UserColorGrading(
        color,
        1.f,                         // exposure
        1.f,                         // highlights
        1.f,                         // shadows
        1.f,                         // contrast
        RENODX_TONE_MAP_SATURATION,  // saturation
        RENODX_TONE_MAP_BLOWOUT     // dechroma, we don't need it
    );

    return color;
  
  }
  else if (shader_injection.tone_map_type == 3.f) {
    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        RENODX_TONE_MAP_CONTRAST,    // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping

    color = LMS_ToneMap_Stockman(color, 1.f,
                                 1.f);

    float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

    color = renodx::color::bt709::clamp::BT2020(color);

    float3 lum_color = renodx::tonemap::HermiteSplineLuminanceRolloff(color, peak);

    color = lum_color;

    color = UserColorGrading(
        color,
        1.f,                         // exposure
        1.f,                         // highlights
        1.f,                         // shadows
        1.f,                         // contrast
        RENODX_TONE_MAP_SATURATION,  // saturation
        RENODX_TONE_MAP_BLOWOUT     // dechroma, we don't need it
    );

    return color;
  }

  else if (shader_injection.tone_map_type >= 4.f) {
    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        RENODX_TONE_MAP_CONTRAST,    // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping

    color = LMS_ToneMap_Stockman(color, 1.f,
                                 1.f);

    float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

    color = renodx::color::bt709::clamp::BT2020(color);

    float3 lum_color = renodx::tonemap::neutwo::MaxChannel(color, peak);

    color = lum_color;

    color = UserColorGrading(
        color,
        1.f,                         // exposure
        1.f,                         // highlights
        1.f,                         // shadows
        1.f,                         // contrast
        RENODX_TONE_MAP_SATURATION,  // saturation
        RENODX_TONE_MAP_BLOWOUT      // dechroma, we don't need it
    );

    return color;
  }

  // default: no tonemapping
  return color;
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

  if (RENODX_TONE_MAP_TYPE == 0.f)  {
      return color;
    }

  if (RENODX_TONE_MAP_HUE_CORRECTION <= 0.f) {
    return color;
  }
  
  // float hue_correction_strength = saturate(renodx::color::y::from::BT709(color));
  // float hue_correction_strength = RENODX_TONE_MAP_HUE_CORRECTION;
  float hue_correction_strength = RENODX_TONE_MAP_HUE_CORRECTION;

  if (hue_correction_strength > 0.f)

    color = renodx::color::correct::Hue(color, correctColor,
                                        hue_correction_strength,
                                        RENODX_TONE_MAP_HUE_PROCESSOR);


  return color;
}


float3 processAndToneMap(float3 color, bool decoding = true) {

  if (decoding) {
    color = renodx::color::srgb::DecodeSafe(color);
  }

  // float3 sdr_color = SDRTonemap(color);
  // color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);
  
  color = ToneMap(color);
  // color = correctHue(color, sdr_color);
  color = renodx::color::bt709::clamp::BT2020(color);

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.3f);
  } 
  
  // This is RenderIntermediatePass, simply brightness scaling and srgb encoding
  color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    color = renodx::color::correct::GammaSafe(color, true, 2.3f);
  }

  color = renodx::color::srgb::EncodeSafe(color);
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

  // if (shader_injection.bloom_processing_space == 0.f) {
  //   return renodx::color::y::from::BT709(renodx::color::srgb::DecodeSafe(color));
  // }
  // else  {
  //   return renodx::color::y::from::BT709(color);
  // }
}



float3 addBloom(float3 base, float3 blend)  {

  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);
    
  return base + addition;
}




float3 hdrScreenBlend(float3 base, float3 blend, float scale = 0.f) {


  blend = max(0.f, blend);

   if (shader_injection.bloom != 2.f) 
    blend *= shader_injection.bloom_strength;

  float3 bloom_texture = blend;
  
  float mid_gray_bloomed = (0.18 + renodx::color::y::from::BT709(bloom_texture)) / 0.18;
  
  float scene_luminance = renodx::color::y::from::BT709(base) * mid_gray_bloomed;
  float bloom_blend = saturate(smoothstep(0.f, 0.18f, scene_luminance));

  float3 bloom_scaled = lerp(float3(0.f, 0.f, 0.f), bloom_texture, bloom_blend); // = bloom_blend 
  bloom_texture = lerp(bloom_texture, bloom_scaled, 0.5f);

  blend = bloom_texture;

  return addBloom(base, blend);
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