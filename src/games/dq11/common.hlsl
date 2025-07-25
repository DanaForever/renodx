
#include "./shared.h"

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
  color_scaled = renodx::color::correct::Hue(color_scaled, post_process_color, peak_correction);
  return lerp(color_hdr, color_scaled, post_process_strength);
}

float3 CustomUpgradeToneMapPerChannel(float3 untonemapped, float3 graded) {
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

  upgradedPerCh = max(-10000000000000000000000000000000000000.f, upgradedPerCh);  // bandaid for NaNs

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

  // if (CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION != 0.f
  //     || CUSTOM_COLOR_GRADE_HUE_CORRECTION != 0.f
  //     || CUSTOM_COLOR_GRADE_SATURATION_CORRECTION != 0.f
  //     || CUSTOM_COLOR_GRADE_HUE_SHIFT != 0.f) {
  //   color = renodx::draw::ApplyPerChannelCorrection(
  //       RENODX_UE_CONFIG.untonemapped_bt709,
  //       float3(color_red, color_green, color_blue),
  //       CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION,
  //       CUSTOM_COLOR_GRADE_HUE_CORRECTION,
  //       CUSTOM_COLOR_GRADE_SATURATION_CORRECTION,
  //       CUSTOM_COLOR_GRADE_HUE_SHIFT);
  // }

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
  // renodx::draw::Config config = renodx::draw::BuildConfig();
  renodx::draw::Config config = GetOutputConfig(OutputDevice);
  float3 untonemapped_graded;
  // float3 untonemapped_graded = renodx::draw::ComputeUntonemappedGraded(
  //   RENODX_UE_CONFIG.untonemapped_bt709,
  //   RENODX_UE_CONFIG.graded_bt709,
  //   config);
  float3 graded_bt709 = RENODX_UE_CONFIG.graded_bt709;
  float3 neutral_sdr_color = renodx::tonemap::renodrt::NeutralSDR(RENODX_UE_CONFIG.untonemapped_bt709);
  if (CUSTOM_TONEMAP_UPGRADE_TYPE == 0.f) {
    if (CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION != 0.f
        || CUSTOM_COLOR_GRADE_HUE_CORRECTION != 0.f
        || CUSTOM_COLOR_GRADE_SATURATION_CORRECTION != 0.f
        || CUSTOM_COLOR_GRADE_HUE_SHIFT != 0.f) {
      graded_bt709 = renodx::draw::ApplyPerChannelCorrection(
          RENODX_UE_CONFIG.untonemapped_bt709,
          graded_bt709,
          CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION,
          CUSTOM_COLOR_GRADE_HUE_CORRECTION,
          CUSTOM_COLOR_GRADE_SATURATION_CORRECTION,
          CUSTOM_COLOR_GRADE_HUE_SHIFT);
    }

    untonemapped_graded = renodx::tonemap::UpgradeToneMap(
        RENODX_UE_CONFIG.untonemapped_bt709,
        neutral_sdr_color,
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