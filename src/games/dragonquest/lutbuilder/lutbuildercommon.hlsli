// #include "../common.hlsli"
#include "./macleod_boynton.hlsli"

#ifndef INCLUDE_LUTBUILDER_COMMON
#define INCLUDE_LUTBUILDER_COMMON

float3 HueAndChrominanceOKLab(
    float3 incorrect_color, float3 reference_color,
    float hue_correct_strength = 0.f,
    float chrominance_correct_strength = 0.f,
    float saturation = 1.f) {
  if (hue_correct_strength != 0.0 || chrominance_correct_strength != 0.0 || saturation != 0.0) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(incorrect_color);
    const float3 reference_oklab = renodx::color::oklab::from::BT709(reference_color);

    float chrominance_current = length(perceptual_new.yz);
    float chrominance_ratio = 1.0;

    if (hue_correct_strength != 0.0) {
      const float chrominance_pre = chrominance_current;
      perceptual_new.yz = lerp(perceptual_new.yz, reference_oklab.yz, hue_correct_strength);
      const float chrominancePost = length(perceptual_new.yz);
      chrominance_ratio = renodx::math::SafeDivision(chrominance_pre, chrominancePost, 1);
      chrominance_current = chrominancePost;
    }

    if (chrominance_correct_strength != 0.0) {
      const float reference_chrominance = length(reference_oklab.yz);
      float target_chrominance_ratio = renodx::math::SafeDivision(reference_chrominance, chrominance_current, 1);
      chrominance_ratio = lerp(chrominance_ratio, target_chrominance_ratio, chrominance_correct_strength);
    }
    perceptual_new.yz *= chrominance_ratio;
    perceptual_new.yz *= saturation;

    incorrect_color = renodx::color::bt709::from::OkLab(perceptual_new);
    incorrect_color = renodx::color::bt709::clamp::AP1(incorrect_color);
  }
  return incorrect_color;
}

float3 CorrectHueAndChrominanceOKLab(
    float3 incorrect_color_bt709,
    float3 reference_color_bt709,
    float hue_emulation_strength = 0.f,
    float chrominance_emulation_strength = 0.f,
    float hue_emulation_ramp_start = 0.18f,
    float hue_emulation_ramp_end = 1.f) {
  if (hue_emulation_strength == 0.0 && chrominance_emulation_strength == 0.0) {
    return incorrect_color_bt709;
  }

  float3 perceptual_new = renodx::color::oklab::from::BT709(incorrect_color_bt709);
  float3 perceptual_reference = renodx::color::oklab::from::BT709(reference_color_bt709);

  float chrominance_current = length(perceptual_new.yz);
  float chrominance_ratio = 1.0;

  if (hue_emulation_strength != 0.0) {
    float ramp_denom = hue_emulation_ramp_end - hue_emulation_ramp_start;
    float ramp_t = clamp(renodx::math::DivideSafe(perceptual_new.x - hue_emulation_ramp_start, ramp_denom, 0.0), 0.0, 1.0);
    hue_emulation_strength *= ramp_t;

    float chrominance_pre = chrominance_current;
    perceptual_new.yz = lerp(perceptual_new.yz, perceptual_reference.yz, hue_emulation_strength);
    float chrominance_post = length(perceptual_new.yz);
    chrominance_ratio = renodx::math::DivideSafe(chrominance_pre, chrominance_post, 1.0);
    chrominance_current = chrominance_post;
  }

  if (chrominance_emulation_strength != 0.0) {
    float reference_chrominance = length(perceptual_reference.yz);
    float target_chrominance_ratio = renodx::math::DivideSafe(reference_chrominance, chrominance_current, 1.0);
    chrominance_ratio = lerp(chrominance_ratio, target_chrominance_ratio, chrominance_emulation_strength);
  }

  perceptual_new.yz *= chrominance_ratio;

  float3 corrected_color_bt709 = renodx::color::bt709::from::OkLab(perceptual_new);
  return corrected_color_bt709;
}


float Highlights(float x, float highlights, float mid_gray) {
  if (highlights == 1.f) return x;

  if (highlights > 1.f) {
    // value = max(x, lerp(x, mid_gray * pow(x / mid_gray, highlights), x));
    return max(x,
               lerp(x, mid_gray * pow(x / mid_gray, highlights),
                    renodx::tonemap::ExponentialRollOff(x, 1.f, 1.1f)));
  } else {  // highlights < 1.f
    x /= mid_gray;
    return lerp(x, pow(x, highlights), step(1.f, x)) * mid_gray;
  }
}

float Shadows(float x, float shadows, float mid_gray) {
  if (shadows == 1.f) return x;

  const float ratio = max(renodx::math::DivideSafe(x, mid_gray, 0.f), 0.f);
  const float base_term = x * mid_gray;
  const float base_scale = renodx::math::DivideSafe(base_term, ratio, 0.f);

  if (shadows > 1.f) {
    float raised = x * (1.f + renodx::math::DivideSafe(base_term, pow(ratio, shadows), 0.f));
    float reference = x * (1.f + base_scale);
    return max(x, x + (raised - reference));
  } else {  // shadows < 1.f
    float lowered = x * (1.f - renodx::math::DivideSafe(base_term, pow(ratio, 2.f - shadows), 0.f));
    float reference = x * (1.f - base_scale);
    return clamp(x + (lowered - reference), 0.f, x);
  }
}

float3 ApplyExposureContrastFlareHighlightsShadowsByLuminance(float3 untonemapped, float y, renodx::color::grade::Config config, float mid_gray = 0.18f) {
  if (config.exposure == 1.f && config.shadows == 1.f && config.highlights == 1.f && config.contrast == 1.f && config.flare == 0.f) {
    return untonemapped;
  }
  float3 color = untonemapped;

  color *= config.exposure;

  // contrast & flare
  const float y_normalized = y / mid_gray;
  float flare = renodx::math::DivideSafe(y_normalized + config.flare, y_normalized, 1.f);
  float exponent = config.contrast * flare;
  const float y_contrasted = pow(y_normalized, exponent) * mid_gray;

// highlights
#if 0
  // const float highlights = 1 + (sign(config.highlights - 1) * pow(abs(config.highlights - 1), 10.f));
  // float y_highlighted = renodx::color::grade::Highlights(y_contrasted, config.highlights, mid_gray);
#else
  float y_highlighted = Highlights(y_contrasted, config.highlights, mid_gray);
#endif
  // shadows
  float y_shadowed = Shadows(y_highlighted, config.shadows, mid_gray);

  const float y_final = y_shadowed;

  color = renodx::color::correct::Luminance(color, y, y_final);

  return color;
}

float3 ApplySaturationBlowoutHighlightSaturationAP1(float3 tonemapped, renodx::color::grade::Config config) {
  float3 color = tonemapped;
  float y = renodx::color::y::from::AP1(color);

  if (config.saturation != 1.f || config.dechroma != 0.f || config.blowout != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(renodx::color::bt709::from::AP1(color));

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

    color = renodx::color::ap1::from::BT709(color);
    color = max(0, color);
  }
  return color;
}

renodx::color::grade::Config CreateColorGradingConfig() {
  renodx::color::grade::Config cg_config = renodx::color::grade::config::Create();
  cg_config.exposure = RENODX_TONE_MAP_EXPOSURE;
  cg_config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  cg_config.shadows = RENODX_TONE_MAP_SHADOWS;
  cg_config.contrast = RENODX_TONE_MAP_CONTRAST;
  cg_config.flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
  cg_config.saturation = RENODX_TONE_MAP_SATURATION;
  cg_config.dechroma = RENODX_TONE_MAP_BLOWOUT;
  // cg_config.hue_correction_strength = 0.f;
  cg_config.blowout = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);

  return cg_config;
}

float3 ApplyGammaCorrection(float3 incorrect_color) {
  float3 corrected_color;

  if (RENODX_GAMMA_CORRECTION == 1.f) {
    corrected_color = renodx::color::correct::GammaSafe(incorrect_color);
  } else {
    corrected_color = incorrect_color;
  }

  return corrected_color;
}

float3 ScaleScene(float3 color) {
  if (RENODX_DIFFUSE_WHITE_NITS != RENODX_GRAPHICS_WHITE_NITS) {
    color = renodx::color::gamma::DecodeSafe(color);
    color *= (RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS);
    color = renodx::color::gamma::EncodeSafe(color);
  }
  return color;
}

float4 GenerateOutput(float r, float g, float b, inout float4 SV_Target, uint device) {
  // if (RENODX_TONE_MAP_TYPE == 0 || device == 8u) return false;

  // final_color is in BT709
  // We displaymap + run Saturation/Dechroma/HighlightsSaturation so SDR Luts dont get griefed
  // And then go back to BT709 for SDR/HDR path branching
  float3 final_color = (float3(r, g, b));

  // Dont displaymapp SDR
  // [branch]
  // if (RENODX_TONE_MAP_TYPE != 0.f) {
  //   // Displaymap to User Peak in BT2020
  //   float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  //   // if (RENODX_GAMMA_CORRECTION) peak_ratio = renodx::color::correct::Gamma(peak_ratio, true);

  //   // Doing stuff in bt2020 is almost always better than BT709
  //   // float3 bt2020_final_color = renodx::color::bt2020::from::BT709(final_color);                                             // displaymap in bt2020
  //   // float3 bt2020_displaymapped_color = renodx::tonemap::neutwo::MaxChannel(max(0, bt2020_final_color), peak_ratio, 100.f);  // Display map to peak
  //   // // float3 bt2020_displaymapped_color = renodx::tonemap::neutwo::PerChannel(max(0, bt2020_final_color), peak_ratio, 100.f);  // Display map to peak
  //   // float3 bt709_displaymapped_color = renodx::color::bt709::from::BT2020(bt2020_displaymapped_color);  // Back to BT709

  //   // Colorgrade in AP1, and back to BT709
  //   renodx::color::grade::Config cg_config = CreateColorGradingConfig();
  //   // float3 bt709_colorgraded_color = renodx::color::bt709::from::AP1(ApplySaturationBlowoutHighlightSaturationAP1(renodx::color::ap1::from::BT709(bt709_displaymapped_color), cg_config));

  //   final_color = bt709_colorgraded_color;
  // }

  // Saturate if SDR TM is selected
  // if (RENODX_TONE_MAP_TYPE == 0.f) final_color = saturate(final_color);

  // Intermediate Encoding
  // float3 encoded_color;

  // encoded_color = renodx::color::pq::EncodeSafe(final_color);
  float3 encoded_color = final_color;
  encoded_color = renodx::color::pq::EncodeSafe(final_color);

  return SV_Target = float4(encoded_color / 1.05f, 0.f);
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



float3 expandGamut(float3 color, float fExpandGamut /*= 1.0f*/) {

    static const float sRGB_max_nits = 80.f;
    static const float ReferenceWhiteNits_BT2408 = 203.f;
    const float recommendedBrightnessScale = ReferenceWhiteNits_BT2408 / sRGB_max_nits;

    if (fExpandGamut > 0.f) {
      
      float3 ColorAP1 = color * recommendedBrightnessScale;

      const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
      const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
      const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
      const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

      float LumaAP1 = renodx::color::y::from::AP1(ColorAP1);
      if (LumaAP1 <= 0.f)
      {
          return ColorAP1;
      }
      float3 ChromaAP1 = ColorAP1 / LumaAP1;

      float ChromaDistSqr = dot(ChromaAP1 - 1, ChromaAP1 - 1);
      float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

      float3 ColorExpand = mul(ExpandMat, ColorAP1);
      ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);

      color = ColorAP1 / recommendedBrightnessScale;
    }

    return color;

}

float3 CorrectGammaHuePreservingSRGB(float3 incorrect_color, float gamma=2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, true, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, true, gamma));

  float3 lum = incorrect_color * (y_in > 0 ?  y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);

  return result;
}



#endif  // INCLUDE_LUTBUILDER_COMMON