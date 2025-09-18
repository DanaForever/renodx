
#include "./shared.h"


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


float3 RestoreHighlightSaturation(float3 untonemapped) {
  float l = renodx::color::y::from::BT709(untonemapped);
  float3 displaymappedColor = untonemapped;

  if (CUSTOM_DISPLAY_MAP_TYPE == 1.f) {
    displaymappedColor = renodx::tonemap::dice::BT709(untonemapped, 1.f, 0.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 2.f) {
    displaymappedColor = renodx::tonemap::frostbite::BT709(untonemapped, 1.f, 0.f, 1.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 3.f) {
    untonemapped = min(100.f, untonemapped);
    displaymappedColor = renodx::tonemap::renodrt::NeutralSDR(untonemapped);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 4.f) {
    displaymappedColor = ToneMapMaxCLL(untonemapped);
  }

  float3 output = lerp(untonemapped, displaymappedColor, saturate(l));

  return output;
}

float3 RestoreHighlightSaturationAP1(float3 untonemapped) {
  float l = renodx::color::y::from::AP1(untonemapped);
  float3 displaymappedColor = untonemapped;

  if (CUSTOM_DISPLAY_MAP_TYPE == 1.f) {
    displaymappedColor = renodx::tonemap::dice::BT709(untonemapped, 1.f, 0.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 2.f) {
    displaymappedColor = renodx::tonemap::frostbite::BT709(untonemapped, 1.f, 0.f, 1.f);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 3.f) {
    untonemapped = min(100.f, untonemapped);
    displaymappedColor = renodx::tonemap::renodrt::NeutralSDR(untonemapped);
  }
    else if (CUSTOM_DISPLAY_MAP_TYPE == 4.f) {
    displaymappedColor = ToneMapMaxCLL(untonemapped);
  }

  float3 output = lerp(untonemapped, displaymappedColor, saturate(l));

  return output;
}

// note: this function returns AP1
float3 displayMap(float3 untonemapped_bt709, float3 untonemapped_ap1) {

  if (RENODX_TONE_MAP_TYPE < 1.f)
    return untonemapped_ap1;

  if (CUSTOM_DISPLAY_MAP_TYPE == 0.f) {
    return untonemapped_ap1;
  } else {
    if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 0.f) {
      return renodx::color::ap1::from::BT709(RestoreHighlightSaturation(untonemapped_bt709));
    } else {
      return RestoreHighlightSaturationAP1(untonemapped_ap1);
    }
  }
}

#define PI    3.141592653589793238462643383279502884197
#define PI_X2 (PI * 2.0)
#define PI_X4 (PI * 4.0)

float3 CorrectHuePolar(float3 incorrectOkLCH, float3 correctOkLCH, float strength) {
  // skip adjustment for achromatic colors
  const float chromaThreshold = 1e-5;
  float iChroma = incorrectOkLCH.y;
  float cChroma = correctOkLCH.y;

  if (iChroma < chromaThreshold || cChroma < chromaThreshold) {
    return incorrectOkLCH;
  }

  // hues in radians
  float iHue = incorrectOkLCH.z;
  float cHue = correctOkLCH.z;

  // calculate shortest angular difference
  float diff = cHue - iHue;
  if (diff > PI) diff -= PI_X2;
  else if (diff < -PI) diff += PI_X2;

  // apply strength-based correction
  float newHue = iHue + strength * diff;

  float3 adjustedOkLCH = float3(
      incorrectOkLCH.x,
      incorrectOkLCH.y,
      newHue
  );

  return adjustedOkLCH;
}

float UpgradeToneMapRatio(float color_hdr, float color_sdr, float post_process_color) {
  if (color_hdr < color_sdr) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    return color_hdr / color_sdr;
  } else {
    float delta = color_hdr - color_sdr;
    delta = max(0, delta);  // Cleans up NaN
    const float new_value = post_process_color + delta;

    const bool valid = (post_process_color > 0);  // Cleans up NaN and ignore black
    return valid ? (new_value / post_process_color) : 0;
  }
}

float3 UpgradeToneMapPerChannel(float3 color_hdr, float3 color_sdr, float3 post_process_color, float post_process_strength) {
  // float ratio = 1.f;

  float3 bt2020_hdr = max(0, renodx::color::bt2020::from::BT709(color_hdr));
  float3 bt2020_sdr = max(0, renodx::color::bt2020::from::BT709(color_sdr));
  float3 bt2020_post_process = max(0, renodx::color::bt2020::from::BT709(post_process_color));

  float3 ratio = float3(
      UpgradeToneMapRatio(bt2020_hdr.r, bt2020_sdr.r, bt2020_post_process.r),
      UpgradeToneMapRatio(bt2020_hdr.g, bt2020_sdr.g, bt2020_post_process.g),
      UpgradeToneMapRatio(bt2020_hdr.b, bt2020_sdr.b, bt2020_post_process.b));

  float3 color_scaled = max(0, bt2020_post_process * ratio);
  color_scaled = renodx::color::bt709::from::BT2020(color_scaled);
  float peak_correction = saturate(1.f - renodx::color::y::from::BT2020(bt2020_post_process));
  color_scaled = renodx::color::correct::Hue(color_scaled, post_process_color, peak_correction, RENODX_TONE_MAP_HUE_PROCESSOR);
  return lerp(color_hdr, color_scaled, post_process_strength);
}

float3 CustomUpgradeToneMapPerChannel(float3 untonemapped, float3 graded) {
  // graded = saturate(graded);
  float hueCorrection = 1.f - CUSTOM_TONEMAP_UPGRADE_HUECORR;
  float satStrength = 1.f - CUSTOM_TONEMAP_UPGRADE_STRENGTH;

  float3 upgradedPerCh = UpgradeToneMapPerChannel(
      untonemapped,
      renodx::tonemap::renodrt::NeutralSDR(untonemapped),
      graded,
      1.f);

  float3 upgradedPerCh_okLCH = renodx::color::oklch::from::BT709(upgradedPerCh);
  float3 graded_okLCH = renodx::color::oklch::from::BT709(graded);

  // heavy hue correction with graded hue
  upgradedPerCh_okLCH = CorrectHuePolar(upgradedPerCh_okLCH, graded_okLCH, saturate(pow(graded_okLCH.y, hueCorrection)));

  // desaturate highlights based on graded chrominance
  upgradedPerCh_okLCH.y = lerp(graded_okLCH.y, upgradedPerCh_okLCH.y, saturate(pow(graded_okLCH.y, satStrength)));

  upgradedPerCh = renodx::color::bt709::from::OkLCh(upgradedPerCh_okLCH);

  // upgradedPerCh = max(-10000000000000000000000000000000000000.f, upgradedPerCh);  // bandaid for NaNs
  upgradedPerCh = renodx::color::bt709::clamp::AP1(upgradedPerCh);

  return upgradedPerCh;
}

//////////////////////////////////////////////////////////////////////////////////////////
///////////// UNREAL ENGINE 4 UTILITIES //////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

// clang-format off
static struct UELutBuilderConfig {
  float3 ungraded_ap1;
  float3 untonemapped_ap1;
  float3 untonemapped_bt709;
  float3 tonemapped_bt709;
  float3 graded_bt709;
} RENODX_UE_CONFIG;
// clang-format on

// First instance of 0.272228718, 0.674081743, 0.0536895171
void SetUngradedAP1(float3 color) {
  RENODX_UE_CONFIG.ungraded_ap1 = color;
}

void SetUntonemappedAP1(inout float3 color) {
  RENODX_UE_CONFIG.untonemapped_ap1 = color;
  RENODX_UE_CONFIG.untonemapped_bt709 = renodx::color::bt709::from::AP1(RENODX_UE_CONFIG.untonemapped_ap1);
  RENODX_UE_CONFIG.tonemapped_bt709 = abs(RENODX_UE_CONFIG.untonemapped_bt709);

  // color has to be AP1
  color = displayMap(RENODX_UE_CONFIG.untonemapped_bt709, RENODX_UE_CONFIG.untonemapped_ap1);
}

// inout = passed by reference
void SetTonemappedBT709(inout float color_red, inout float color_green, inout float color_blue) {
  if (RENODX_TONE_MAP_TYPE == 0.f) return;
  float3 color = float3(color_red, color_green, color_blue);
  RENODX_UE_CONFIG.tonemapped_bt709 = color;

  if (CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION != 0.f
      || CUSTOM_COLOR_GRADE_HUE_CORRECTION != 0.f
      || CUSTOM_COLOR_GRADE_SATURATION_CORRECTION != 0.f
      || CUSTOM_COLOR_GRADE_HUE_SHIFT != 0.f) {
    color = renodx::draw::ApplyPerChannelCorrection(
        RENODX_UE_CONFIG.untonemapped_bt709,
        float3(color_red, color_green, color_blue),
        CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION,
        CUSTOM_COLOR_GRADE_HUE_CORRECTION,
        CUSTOM_COLOR_GRADE_SATURATION_CORRECTION,
        CUSTOM_COLOR_GRADE_HUE_SHIFT);
  }

  color = abs(color);
  color_red = color.r;
  color_green = color.g;
  color_blue = color.b;
}

void SetTonemappedBT709(inout float3 color) {
  SetTonemappedBT709(color.r, color.g, color.b);
}

// Used by LUTs
void SetTonemappedAP1(inout float color_red, inout float color_green, inout float color_blue) {
  if (RENODX_TONE_MAP_TYPE == 0.f) return;
  float3 color = float3(color_red, color_green, color_blue);
  float3 bt709_color = renodx::color::bt709::from::AP1(color);
  SetTonemappedBT709(bt709_color);

  color = renodx::color::ap1::from::BT709(bt709_color);
  color_red = color.r;
  color_green = color.g;
  color_blue = color.b;
}

void SetTonemappedAP1(inout float3 color) {
  SetTonemappedAP1(color.r, color.g, color.b);
}

void SetGradedBT709(inout float3 color) {
  RENODX_UE_CONFIG.graded_bt709 = color;
  RENODX_UE_CONFIG.graded_bt709 *= sign(RENODX_UE_CONFIG.tonemapped_bt709);
}

renodx::draw::Config GetOutputConfig(uint OutputDevice = 0u) {
  renodx::draw::Config config = renodx::draw::BuildConfig();
  bool is_hdr = (OutputDevice >= 3u && OutputDevice <= 6u);
  if (is_hdr) {
    config.intermediate_encoding = renodx::draw::ENCODING_PQ;
    
    config.intermediate_scaling = RENODX_DIFFUSE_WHITE_NITS;
    
    config.intermediate_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
  }
  return config;
}

float4
GenerateOutput(uint OutputDevice = 0u) {
  renodx::draw::Config config = GetOutputConfig(OutputDevice);
  float3 untonemapped_graded;
  float3 graded_bt709 = RENODX_UE_CONFIG.graded_bt709;

  if (CUSTOM_TONEMAP_UPGRADE_TYPE == 0.f) {
    untonemapped_graded = renodx::tonemap::UpgradeToneMap(
        RENODX_UE_CONFIG.untonemapped_bt709,
        renodx::tonemap::renodrt::NeutralSDR(RENODX_UE_CONFIG.untonemapped_bt709),
        graded_bt709,
        config.color_grade_strength,
        config.tone_map_pass_autocorrection);
  } else {
    untonemapped_graded = CustomUpgradeToneMapPerChannel(RENODX_UE_CONFIG.untonemapped_bt709, graded_bt709);
  }
  
  float3 color = untonemapped_graded;
  color *= 1.f / 1.05f;
  return float4(color, 1.f);
}

float4 GenerateOutput(float3 graded_bt709, uint OutputDevice = 0u) {
  SetGradedBT709(graded_bt709);
  return GenerateOutput(OutputDevice);
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