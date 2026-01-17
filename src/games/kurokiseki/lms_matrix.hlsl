#include "shared.h"


static const float3x3 CAT_VON_KRIES = float3x3(
      0.4002400f, 0.7076000f, -0.0808100f,
      -0.2263000f, 1.1653200f, 0.0457000f,
      0.0000000f, 0.0000000f, 0.9182200f);

static const float3x3 CAT_BRADFORD = float3x3(
    0.8951f, 0.2664f, -0.1614f,
    -0.7502f, 1.7135f, 0.0367f,
    0.0389f, -0.0685f, 1.0296f);

static const float3x3 CAT_FAIRCHILD = float3x3(
    0.8562f, 0.3372f, -0.1934f,
    -0.8360f, 1.8327f, 0.0033f,
    0.0357f, -0.0469f, 1.0112f);

static const float3x3 CAT_SHARP = float3x3(
    1.2694, -0.0988, -0.1706,
    -0.8364, 1.8006, 0.0357,
    0.0297, -0.0315, 1.0018);

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

float ReinhardExtended(float x, float white_max, float x_max = 1.f, float shoulder = 0.18f) {
  const float x_min = 0.f;
  // float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  // float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  float exposure = renodx::tonemap::ComputeReinhardExtendableScale(white_max, x_max, x_min, shoulder, shoulder);
  float extended = renodx::tonemap::ReinhardExtended(x * exposure, white_max * exposure, x_max);
  extended = min(extended, x_max);

  return extended;
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

  if (use_dkl_luminance) {
    float r = vibrant_dkl.x / DKL_gray.x;
    float s = sign(r);

    float p = pow(abs(r), contrast) * s;

    vibrant_dkl.x = DKL_gray.x * p;
  }

  lms_vibrancy = LMSFromDKL(vibrant_dkl);

  float3 lms = lms_vibrancy;
  // float3 lms = vibrant_dkl;

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
  // float3 new_lms = lms;

  XYZ = mul(LMS_TO_XYZ, new_lms);

  color = renodx::color::bt709::from::XYZ(XYZ);

  return color;
}

float max3(float a, float b, float c) {
  return max(a, max(b, c));
}

float max3(float3 v) {
  return max3(v.x, v.y, v.z);
}

static const float PQ_constant_M1 = 0.1593017578125f;
static const float PQ_constant_M2 = 78.84375f;
static const float PQ_constant_C1 = 0.8359375f;
static const float PQ_constant_C2 = 18.8515625f;
static const float PQ_constant_C3 = 18.6875f;

// PQ (Perceptual Quantizer - ST.2084) encode/decode used for HDR10 BT.2100.
// Clamp type:
// 0 None
// 1 Remove negative numbers
// 2 Remove numbers beyond 0-1
// 3 Mirror negative numbers
float3 Linear_to_PQ(float3 LinearColor, int clampType = 3) {
  float3 LinearColorSign = sign(LinearColor);
  if (clampType == 1) {
    LinearColor = max(LinearColor, 0.f);
  } else if (clampType == 2) {
    LinearColor = saturate(LinearColor);
  } else if (clampType == 3) {
    LinearColor = abs(LinearColor);
  }
  float3 colorPow = pow(LinearColor, PQ_constant_M1);
  float3 numerator = PQ_constant_C1 + PQ_constant_C2 * colorPow;
  float3 denominator = 1.f + PQ_constant_C3 * colorPow;
  float3 pq = pow(numerator / denominator, PQ_constant_M2);
  if (clampType == 3) {
    return pq * LinearColorSign;
  }
  return pq;
}

float3 PQ_to_Linear(float3 ST2084Color, int clampType = 3) {
  float3 ST2084ColorSign = sign(ST2084Color);
  if (clampType == 1) {
    ST2084Color = max(ST2084Color, 0.f);
  } else if (clampType == 2) {
    ST2084Color = saturate(ST2084Color);
  } else if (clampType == 3) {
    ST2084Color = abs(ST2084Color);
  }
  float3 colorPow = pow(ST2084Color, 1.f / PQ_constant_M2);
  float3 numerator = max(colorPow - PQ_constant_C1, 0.f);
  float3 denominator = PQ_constant_C2 - (PQ_constant_C3 * colorPow);
  float3 linearColor = pow(numerator / denominator, 1.f / PQ_constant_M1);
  if (clampType == 3) {
    return linearColor * ST2084ColorSign;
  }
  return linearColor;
}

// Aplies exponential ("Photographic") luminance/luma compression.
// The pow can modulate the curve without changing the values around the edges.
// The max is the max possible range to compress from, to not lose any output range if the input range was limited.
float rangeCompress(float X, float Max = asfloat(0x7F7FFFFF)) {
  // Branches are for static parameters optimizations
  if (Max == renodx::math::FLT_MAX) {
    // This does e^X. We expect X to be between 0 and 1.
    return 1.f - exp(-X);
  }
  const float lostRange = exp(-Max);
  const float restoreRangeScale = 1.f / (1.f - lostRange);
  return (1.f - exp(-X)) * restoreRangeScale;
}

// Refurbished DICE HDR tonemapper (per channel or luminance).
// Expects "InValue" to be >= "ShoulderStart" and "OutMaxValue" to be > "ShoulderStart".
float luminanceCompress(
    float InValue,
    float OutMaxValue,
    float ShoulderStart = 0.f,
    bool considerMaxValue = false,
    float InMaxValue = asfloat(0x7F7FFFFF)) {
  const float compressableValue = InValue - ShoulderStart;
  const float compressableRange = InMaxValue - ShoulderStart;
  const float compressedRange = OutMaxValue - ShoulderStart;
  const float possibleOutValue = ShoulderStart + compressedRange * rangeCompress(compressableValue / compressedRange, considerMaxValue ? (compressableRange / compressedRange) : renodx::math::FLT_MAX);
#if 1
  return possibleOutValue;
#else  // Enable this branch if "InValue" can be smaller than "ShoulderStart"
  return (InValue <= ShoulderStart) ? InValue : possibleOutValue;
#endif
}

#define DICE_TYPE_BY_LUMINANCE_RGB 0
// Doing the DICE compression in PQ (either on luminance or each color channel) produces a curve that is closer to our "perception" and leaves more detail highlights without overly compressing them
#define DICE_TYPE_BY_LUMINANCE_PQ 1
// Modern HDR displays clip individual rgb channels beyond their "white" peak brightness,
// like, if the peak brightness is 700 nits, any r g b color beyond a value of 700/80 will be clipped (not acknowledged, it won't make a difference).
// Tonemapping by luminance, is generally more perception accurate but can then generate rgb colors "out of range". This setting fixes them up,
// though it's optional as it's working based on assumptions on how current displays work, which might not be true anymore in the future.
// Note that this can create some steep (rough, quickly changing) gradients on very bright colors.
#define DICE_TYPE_BY_LUMINANCE_PQ_CORRECT_CHANNELS_BEYOND_PEAK_WHITE 2
// This might look more like classic SDR tonemappers and is closer to how modern TVs and Monitors play back colors (usually they clip each individual channel to the peak brightness value, though in their native panel color space, or current SDR/HDR mode color space).
// Overall, this seems to handle bright gradients more smoothly, even if it shifts hues more (and generally desaturating).
#define DICE_TYPE_BY_CHANNEL_PQ 3

struct DICESettings {
  uint Type;
  // Determines where the highlights curve (shoulder) starts.
  // Values between 0.25 and 0.5 are good with DICE by PQ (any type).
  // With linear/rgb DICE this barely makes a difference, zero is a good default but (e.g.) 0.5 would also work.
  // This should always be between 0 and 1.
  float ShoulderStart;

  // For "Type == DICE_TYPE_BY_LUMINANCE_PQ_CORRECT_CHANNELS_BEYOND_PEAK_WHITE" only:
  // The sum of these needs to be <= 1, both within 0 and 1.
  // The closer the sum is to 1, the more each color channel will be containted within its peak range.
  float DesaturationAmount;
  float DarkeningAmount;
};

DICESettings DefaultDICESettings() {
  DICESettings Settings;
  Settings.Type = DICE_TYPE_BY_CHANNEL_PQ;
  Settings.ShoulderStart = (Settings.Type >= DICE_TYPE_BY_LUMINANCE_RGB) ? (1.f / 4.f) : 0.f;
  Settings.DesaturationAmount = 1.0 / 3.0;
  Settings.DarkeningAmount = 1.0 / 3.0;
  return Settings;
}

// Tonemapper inspired from DICE. Can work by luminance to maintain hue.
// Takes scRGB colors with a white level (the value of 1 1 1) of 80 nits (sRGB) (to not be confused with paper white).
// Paper white is expected to have already been multiplied in.
float3 ApplyDICE(
    float3 Color,
    float PeakWhite,
    const DICESettings Settings) {
  const float sourceLuminance = renodx::color::y::from::BT709(Color);

  if (Settings.Type != DICE_TYPE_BY_LUMINANCE_RGB) {
    static const float HDR10_MaxWhite = 10000.f / 80.f;

    const float shoulderStartPQ = Linear_to_PQ((Settings.ShoulderStart * PeakWhite) / HDR10_MaxWhite).x;
    if (Settings.Type == DICE_TYPE_BY_LUMINANCE_PQ || Settings.Type == DICE_TYPE_BY_LUMINANCE_PQ_CORRECT_CHANNELS_BEYOND_PEAK_WHITE) {
      const float sourceLuminanceNormalized = sourceLuminance / HDR10_MaxWhite;
      const float sourceLuminancePQ = Linear_to_PQ(sourceLuminanceNormalized, 1).x;

      if (sourceLuminancePQ > shoulderStartPQ)  // Luminance below the shoulder (or below zero) don't need to be adjusted
      {
        const float peakWhitePQ = Linear_to_PQ(PeakWhite / HDR10_MaxWhite).x;

        const float compressedLuminancePQ = luminanceCompress(sourceLuminancePQ, peakWhitePQ, shoulderStartPQ);
        const float compressedLuminanceNormalized = PQ_to_Linear(compressedLuminancePQ).x;
        Color *= compressedLuminanceNormalized / sourceLuminanceNormalized;

        if (Settings.Type == DICE_TYPE_BY_LUMINANCE_PQ_CORRECT_CHANNELS_BEYOND_PEAK_WHITE) {
          float3 Color_BT2020 = renodx::color::bt2020::from::BT709(Color);
          if (any(Color_BT2020 > PeakWhite))  // Optional "optimization" branch
          {
            float colorLuminance = renodx::color::y::from::BT2020(Color_BT2020);
            float colorLuminanceInExcess = colorLuminance - PeakWhite;
            float maxColorInExcess = max3(Color_BT2020) - PeakWhite;                                                                       // This is guaranteed to be >= "colorLuminanceInExcess"
            float brightnessReduction = saturate(renodx::math::SafeDivision(PeakWhite, max3(Color_BT2020), 1));                            // Fall back to one in case of division by zero
            float desaturateAlpha = saturate(renodx::math::SafeDivision(maxColorInExcess, maxColorInExcess - colorLuminanceInExcess, 0));  // Fall back to zero in case of division by zero
            Color_BT2020 = lerp(Color_BT2020, colorLuminance, desaturateAlpha * Settings.DesaturationAmount);
            Color_BT2020 = lerp(Color_BT2020, Color_BT2020 * brightnessReduction, Settings.DarkeningAmount);  // Also reduce the brightness to partially maintain the hue, at the cost of brightness
            Color = renodx::color::bt709::from::BT2020(Color_BT2020);
          }
        }
      }
    } else  // DICE_TYPE_BY_CHANNEL_PQ
    {
      const float peakWhitePQ = Linear_to_PQ(PeakWhite / HDR10_MaxWhite).x;

      // Tonemap in BT.2020 to more closely match the primaries of modern displays
      const float3 sourceColorNormalized = renodx::color::bt2020::from::BT709(Color) / HDR10_MaxWhite;
      const float3 sourceColorPQ = Linear_to_PQ(sourceColorNormalized, 1);

      for (uint i = 0; i < 3; i++)  // TODO LUMA: optimize? will the shader compile already convert this to float3? Or should we already make a version with no branches that works in float3?
      {
        if (sourceColorPQ[i] > shoulderStartPQ)  // Colors below the shoulder (or below zero) don't need to be adjusted
        {
          const float compressedColorPQ = luminanceCompress(sourceColorPQ[i], peakWhitePQ, shoulderStartPQ);
          const float compressedColorNormalized = PQ_to_Linear(compressedColorPQ).x;
          Color[i] = renodx::color::bt709::from::BT2020(Color[i] * (compressedColorNormalized / sourceColorNormalized[i])).x;
        }
      }
    }
  } else  // DICE_TYPE_BY_LUMINANCE_RGB
  {
    if (sourceLuminance > Settings.ShoulderStart)  // Luminance below the shoulder (or below zero) don't need to be adjusted
    {
      const float compressedLuminance = luminanceCompress(sourceLuminance, PeakWhite, PeakWhite * Settings.ShoulderStart);
      Color *= compressedLuminance / sourceLuminance;
    }
  }

  return Color;
}


float3 DICEToneMap(float3 color) {
  DICESettings DICEconfig = DefaultDICESettings();
  DICEconfig.Type = (int)shader_injection.dice_tone_map_type;
  DICEconfig.ShoulderStart = shader_injection.dice_shoulder_start;  // Start shoulder
  DICEconfig.DesaturationAmount = shader_injection.dice_desaturation;
  DICEconfig.DarkeningAmount = shader_injection.dice_darkening;

  float dicePaperWhite = RENODX_DIFFUSE_WHITE_NITS / 80.f;
  float dicePeakWhite = RENODX_PEAK_WHITE_NITS / 80.f;

  color = ApplyDICE(color * dicePaperWhite, dicePeakWhite, DICEconfig) / dicePaperWhite;

  return color;
}