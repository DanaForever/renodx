
#include "./shared.h"
#include "./macleod_boynton.hlsli"

///////////////////////////////////////////////////////////////////////////
////////// CUSTOM TONEMAPPASS//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

float3 PostToneMapProcess(float3 output) {

  [branch]
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    output = renodx::color::correct::GammaSafe(output, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    output = renodx::color::correct::GammaSafe(output, false, 2.4f);
  }

  output *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

  [branch]
  if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    output = renodx::color::correct::GammaSafe(output, true, 2.2f);
  } else if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    output = renodx::color::correct::GammaSafe(output, true, 2.4f);
  }

  return output;

}

///////////////////////////////////////////////////////////////////////////
////////// CUSTOM TONEMAPPASS//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f

static const float3x3 Wide_2_XYZ_MAT = float3x3(
    0.5441691, 0.2395926, 0.1666943,
    0.2394656, 0.7021530, 0.0583814,
    -0.0023439, 0.0361834, 1.0552183);

static const float3 AP1_RGB2Y = float3(
    0.2722287168,  // AP1_2_XYZ_MAT[0][1],
    0.6740817658,  // AP1_2_XYZ_MAT[1][1],
    0.0536895174   // AP1_2_XYZ_MAT[2][1]
);

float3 hdrExtraSaturation(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
{
  // const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
  // const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
  // const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
  // const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  const float3x3 sRGB_2_AP1 = renodx::color::BT709_TO_AP1_MAT;
  const float3x3 AP1_2_sRGB = renodx::color::AP1_TO_BT709_MAT;
  const float3x3 Wide_2_AP1 = mul(renodx::color::XYZ_TO_AP1_MAT, Wide_2_XYZ_MAT);
  const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  // float3 ColorAP1 = mul(sRGB_2_AP1, vHDRColor);
  float3 ColorAP1 = renodx::color::ap1::from::BT709(vHDRColor);
  float LumaAP1 = renodx::color::y::from::AP1(ColorAP1);

  // float LumaAP1 = dot(ColorAP1, AP1_RGB2Y);
  if (LumaAP1 <= 0.f)
    {
    return vHDRColor;
  }
  float3 ChromaAP1 = ColorAP1 / LumaAP1;

  float ChromaDistSqr = dot(ChromaAP1 - 1, ChromaAP1 - 1);
  // float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));
  float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

  float3 ColorExpand = mul(ExpandMat, ColorAP1);

  // ColorAP1 = lerp(ColorAP1, ColorExpand, fExpandGamut);
  ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);
  // ColorAP1 = ColorExpand;

  // vHDRColor = mul(AP1_2_sRGB, ColorAP1);
  vHDRColor = renodx::color::bt709::from::AP1(ColorAP1);
  return vHDRColor;
}

float3 expandGamut(float3 color, float fExpandGamut /*= 1.0f*/) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
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

    color = vHDRColor / recommendedBrightnessScale;
  }

  return color;
}



float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = renodx::color::correct::Chrominance(lum, incorrect_color);

  return result;
}

float3 CustomRenderIntermediatePass(float3 color) {
  // return RenderIntermediatePass(color, BuildConfig());

  renodx::draw::Config config = renodx::draw::BuildConfig();

  [branch]
  if (config.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    // color = renodx::color::correct::GammaSafe(color, false, 2.2f);
    color = GammaCorrectHuePreserving(color, 2.2f);
  } else if (config.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    // color = renodx::color::correct::GammaSafe(color, false, 2.4f);
    color = GammaCorrectHuePreserving(color, 2.4f);
  }

  color *= config.intermediate_scaling;

  [branch]
  if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  }

  color = renodx::color::convert::ColorSpaces(
      color,
      renodx::color::convert::COLOR_SPACE_BT709,
      config.intermediate_color_space);

  color = renodx::draw::EncodeColor(color, config.intermediate_encoding);

  return color;

}




float4 CustomSwapChainPass(float4 input_color) {
  // return float4(SwapChainPass(color.rgb, 0, BuildConfig()).rgb, 1.f);

  float3 color = input_color.rgb;
  renodx::draw::Config config = renodx::draw::BuildConfig();
  float2 position = 0;

  color = renodx::draw::DecodeColor(color, config.swap_chain_decoding);

  if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = GammaCorrectHuePreserving(color, 2.2f);
  } else if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = GammaCorrectHuePreserving(color, 2.4f);
  }

  color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);

  [branch]
  if (config.swap_chain_output_preset == renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_SDR) {
    config.swap_chain_clamp_color_space = renodx::color::convert::COLOR_SPACE_NONE;
    config.swap_chain_compress_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    config.swap_chain_encoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    config.swap_chain_encoding = renodx::draw::ENCODING_SRGB;
    config.swap_chain_scaling_nits = 1.f;
    config.swap_chain_clamp_nits = 1.f;
  } else if (config.swap_chain_output_preset == renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10) {
    config.swap_chain_clamp_color_space = renodx::color::convert::COLOR_SPACE_NONE;
    config.swap_chain_compress_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
    config.swap_chain_encoding_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
    config.swap_chain_encoding = renodx::draw::ENCODING_PQ;
  } else if (config.swap_chain_output_preset == renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_SCRGB) {
    config.swap_chain_clamp_color_space = renodx::color::convert::COLOR_SPACE_NONE;
    config.swap_chain_compress_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
    config.swap_chain_encoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    config.swap_chain_encoding = renodx::draw::ENCODING_SCRGB;
  }

  [branch]
  if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT709D93(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT601NTSCU(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::ARIBTRB9(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  }

  [branch]
  if (config.swap_chain_clamp_color_space != renodx::color::convert::COLOR_SPACE_NONE) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_clamp_color_space);
    color = max(0, color);
    if (config.swap_chain_clamp_color_space != config.swap_chain_encoding_color_space) {
      color = renodx::color::convert::ColorSpaces(color, config.swap_chain_clamp_color_space, config.swap_chain_encoding_color_space);
    }
  } else {
    [branch]
    if (config.swap_chain_compress_color_space != renodx::color::convert::COLOR_SPACE_NONE) {
      color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_compress_color_space);
      float grayscale = renodx::color::convert::Luminance(color, config.swap_chain_compress_color_space);
      const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
      const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
      const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
      float encode_gamma = MID_GRAY_GAMMA;
      float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
      float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
      float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
      color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);

      if (config.swap_chain_compress_color_space != config.swap_chain_encoding_color_space) {
        color = renodx::color::convert::ColorSpaces(color, config.swap_chain_compress_color_space, config.swap_chain_encoding_color_space);
      }
    } else {
      color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
    }
  }

  color *= config.swap_chain_scaling_nits;
  float max_channel = max(max(max(color.r, color.g), color.b), config.swap_chain_clamp_nits);
  color *= config.swap_chain_clamp_nits / max_channel;  // Clamp UI or Videos

  color = renodx::draw::EncodeColor(color, config.swap_chain_encoding);

  if (config.swap_chain_output_dither_bits > 0.f && config.swap_chain_output_dither_amplitude != 0.f) {
    float maxValue = exp2(config.swap_chain_output_dither_bits) - 1.0;
    float dither_strength = exp2(config.swap_chain_output_dither_amplitude) - 1.0;
    // ie: 12bit amplitude for 10bit quantization

    float random_number = renodx::random::Generate(position + config.swap_chain_output_dither_seed);

    float3 noise = (random_number - 0.5) * (1.f / maxValue);

    float3 dithered = color.rgb * maxValue + noise * dither_strength;

    float3 rounded = round(max(0, dithered)) / maxValue;

    color = rounded;
  }

  return float4(color, 1.0f);
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