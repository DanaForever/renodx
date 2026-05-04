#include "lms_matrix.hlsl"
#include "./macleod_boynton.hlsli"
#include "./psycho_test17.hlsl"



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

float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  float3 result = CorrectPurityMBBT709WithBT2020(lum, ch);

  return result;
}

float3 ToneMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return untonemapped;
  }

  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 untonemapped_graded = untonemapped;

  // naka rushton
  float3 untonemapped_graded_dechroma = CastleDechroma_CVVDPStyle_NakaRushton(untonemapped_graded);
  untonemapped_graded_dechroma = lerp(untonemapped_graded, untonemapped_graded_dechroma, shader_injection.tone_map_blowout);

  float3 bt709_tonemapped;
  float peak_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.2f);

  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    peak_ratio = renodx::color::correct::Gamma(peak_ratio, true, 2.4f);
  }

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    float contrast_ratio = min(peak_ratio, 4.f);

    float contrast = shader_injection.tone_map_contrast / shader_injection.tone_map_saturation;

    bt709_tonemapped = renodx::tonemap::psycho::psychotm_test17(
        untonemapped_graded_dechroma,
        peak_ratio,                               // peak
        shader_injection.tone_map_exposure,       // exposure
        shader_injection.tone_map_highlights,     // highlights
        shader_injection.tone_map_shadows,        // shadows
        contrast,                                 // contrast
        1.0f,                                     // purity_scale
        1.0f,                                     // bleaching_intensity
        100.f,                                    // clip_point
        0.5f,                                     // hue_restore
        1.0f,                                     // adaptation_contrast
        1,                                        // naka rushton
        shader_injection.tone_map_saturation);  // cone_response_exponent

    return bt709_tonemapped;
  } else {
    return untonemapped;

  }

  
}


float calculateLuminanceSRGB(float3 color) {
  if (RENODX_TONE_MAP_TYPE > 0.f) {
    return renodx::color::y::from::BT709(renodx::color::srgb::DecodeSafe(color));
  } else {
    return renodx::color::y::from::NTSC1953(color);
  }
}

float calculateLuminance(float3 color) {
  return renodx::color::y::from::BT709(color);
}

float3 PostProcessFinal(float3 r0) {
  r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);

  // Swapchain Pass

  renodx::draw::Config config = renodx::draw::BuildConfig();

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.2f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.4f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.3f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.3f);
  }

  float3 o0 = r0;
  float3 color = o0.rgb;

  [branch]
  if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
    color = renodx::color::bt709::from::BT709D93(color);
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
    color = renodx::color::bt709::from::BT601NTSCU(color);
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
    color = renodx::color::bt709::from::ARIBTRB9(color);
  }

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

  if (shader_injection.hdr_format == 0.f) {
    color = renodx::color::bt2020::from::BT709(color);
    color = renodx::color::pq::EncodeSafe(color, shader_injection.graphics_white_nits);
  }
  else {
    color *= shader_injection.graphics_white_nits / 80.f;
  }

  o0.rgb = color;

  return o0.rgb;
}