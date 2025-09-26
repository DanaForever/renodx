
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

  float3 lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::XYZ::from::BT709(bt709));
  float3 midgray_lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::XYZ::from::BT709(0.18f));

  // midgray match
  lms = renodx::math::DivideSafe(lms, midgray_lms, 1.f);
  lms = sign(lms) * pow(abs(lms), RENODX_TONE_MAP_CONTRAST);
  lms *= midgray_lms;

  const float human_vision_peak = 4000 / 203.f;
  float3 peak_lms = mul(XYZ_TO_LMS_D65_MAT, renodx::color::XYZ::from::BT709(human_vision_peak));

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




float3 ToneMap(float3 color) {
  
  float3 originalColor = color;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    // return saturate(color);
    return color;
  } else if (shader_injection.tone_map_type == 1.f) {
    color = LMS_ToneMap(color);
    color = FrostbiteToneMap(color);

    return color;
  }
  else if (shader_injection.tone_map_type == 2.f) {

    color = LMS_ToneMap(color);
    color = DICEToneMap(color);

    return color;
  
  }
  else if (shader_injection.tone_map_type == 3.f) {

    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        1.f,                         // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping

    float3 lms_output = LMS_ToneMap(color);
    color = lms_output;

    const float paperWhite = RENODX_DIFFUSE_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;
    const float peakWhite = RENODX_PEAK_WHITE_NITS / renodx::color::srgb::REFERENCE_WHITE;
    float x_max = peakWhite / paperWhite;

    bool per_channel = bool(shader_injection.tone_map_per_channel);
    color = ReinhardPiecewiseExtended(color, 100.f, x_max, 0.18f, per_channel);

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

  else if (shader_injection.tone_map_type >= 4.f) {
  
    color = UserColorGrading(
        color,
        RENODX_TONE_MAP_EXPOSURE,    // exposure
        RENODX_TONE_MAP_HIGHLIGHTS,  // highlights
        RENODX_TONE_MAP_SHADOWS,     // shadows
        1.f,    // contrast
        1.f,                         // saturation, we'll do this post-tonemap
        0.f);                        // dechroma, post tonemapping
                                     // hue correction, Post tonemapping

    float3 lms_output = LMS_ToneMap(color);
    color = lms_output;

    // bool pq = (RENODX_TONE_MAP_WORKING_COLOR_SPACE > 0.f);
    bool pq = false;
    color = ApplyExponentialRollOff(color, pq);

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

  float3 sdr_color = SDRTonemap(color);
  // color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);
  
  color = ToneMap(color);
  color = correctHue(color, sdr_color);
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

  // return renodx::color::y::from::BT709(renodx::color::srgb::DecodeSafe(color));
  return renodx::color::y::from::BT709((color));

}

float3 compress(float3 color) {

  return saturate(color);
  // return ToneMapMaxCLL(color);
  // return renodx::tonemap::dice::BT709(color, 2.0f, 0.25f);
  // return renodx::tonemap::frostbite::BT709(color, 1.0f, 0.25f);
  // return DICEToneMap(color);
  // return max(0.f, color);
  // return renodx::tonemap::renodrt::NeutralSDR(color);
  // return color;
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