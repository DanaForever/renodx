// ---- Created with 3Dmigoto v1.3.16 on Wed Jul 23 17:14:39 2025
#include "common.hlsl"
#include "shared.h"
cbuffer _Globals : register(b0)
{
  float gamma : packoffset(c0);
  float pqScale : packoffset(c0.y);
}

SamplerState samplerSrc0_s : register(s0);
Texture2D<float4> samplerSrc0Texture : register(t0);

static const float3x3 saturationMat =
    float3x3
      (
        1.66050005f, -0.587700009f, -0.072800003,
        -0.124600001f, 1.13300002f, 0.0083999997f,
        -0.0182000007f, 0.100599997f, 1.11870003f
      );

float3 SE_Saturation(float3 color) {
  float4 r1;
  float4 r0;

  r0.rgb = color;

  r0.w = 0.587700009 * r0.y;
  r0.w = r0.x * 1.66050005 + -r0.w;
  r1.x = -r0.z * 0.072800003 + r0.w;
  r0.w = 0.100599997 * r0.y;
  r0.w = r0.x * -0.0182000007 + -r0.w;
  r1.z = r0.z * 1.11870003 + r0.w;
  r0.x = dot(r0.xy, float2(-0.124600001, 1.13300002));
  r1.y = -r0.z * 0.0083999997 + r0.x;

  return r1.rgb;
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = samplerSrc0Texture.Sample(samplerSrc0_s, v1.xy).xyzw;

  // srgb decoding
  
  r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);
  o0.w = r0.w;

  if (RENODX_TONE_MAP_TYPE <= 1.f) {
    
    r0.xyz = max(float3(0, 0, 0), r0.xyz);

    // srgb decoding

    // gamma scaling
    if (RENODX_TONE_MAP_TYPE == 0.f) {
      // SDR gamma = 1.0, HDR gamma = 1.3
      // this can be considered as a poor attempt to correct gamma
      r0.xyz = renodx::math::SignPow(r0.xyz, gamma);

      // r0.w = 0.587700009 * r0.y;
      // r0.w = r0.x * 1.66050005 + -r0.w;
      // r1.x = -r0.z * 0.072800003 + r0.w;
      // r0.w = 0.100599997 * r0.y;
      // r0.w = r0.x * -0.0182000007 + -r0.w;
      // r1.z = r0.z * 1.11870003 + r0.w;
      // r0.x = dot(r0.xy, float2(-0.124600001, 1.13300002));
      // r1.y = -r0.z * 0.0083999997 + r0.x;
      r1.rgb = SE_Saturation(r0.rgb);

      o0.xyz = pqScale * r1.xyz;

      return;
    }
    else {
      // r0.xyz = renodx::math::SignPow(r0.xyz, gamma);
      // gamma should be 1.0 in SDR
      // o0.xyz = saturate(r0.xyz);
      float3 color = r0.rgb;
      renodx::draw::Config config = renodx::draw::BuildConfig();

      [branch]
      if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
        color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
        config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
        // color = renodx::color::correct::GammaSafe(color, false, 2.2f);
        color = GammaCorrectHuePreserving(color, 2.2f);

      } else if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
        color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
        config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
        // color = renodx::color::correct::GammaSafe(color, false, 2.4f);
        color = GammaCorrectHuePreserving(color, 2.4f);
      }

      color *= config.swap_chain_scaling_nits;
      color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos

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

      color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos

      [branch]
      if (config.swap_chain_clamp_color_space == renodx::color::convert::COLOR_SPACE_UNKNOWN) {
        color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
      } else {
        [branch]
        if (config.swap_chain_clamp_color_space == config.swap_chain_encoding_color_space) {
          color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
          color = max(0, color);
        } else {
          if (config.swap_chain_clamp_color_space != config.swap_chain_decoding_color_space) {
            color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_clamp_color_space);
          }
          color = max(0, color);
          color = renodx::color::convert::ColorSpaces(color, config.swap_chain_clamp_color_space, config.swap_chain_encoding_color_space);
        }
      }
      
      o0.xyz = color;

      // o0.xyz *= RENODX_GRAPHICS_WHITE_NITS;
      o0.xyz = o0.xyz / 80.f;
      return;
    }
  }


  // o0.rgb = renodx::draw::SwapChainPass(r0.rgb);
  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 color = r0.rgb;

  [branch]
  if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    // color = renodx::color::correct::GammaSafe(color, false, 2.2f);
    color = GammaCorrectHuePreserving(color, 2.2f);

  } else if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    // color = renodx::color::correct::GammaSafe(color, false, 2.4f);
    color = GammaCorrectHuePreserving(color, 2.4f);
  }

  if (FFXV_HDR_GRADING) {
    color = SE_Saturation(color);
  }

  color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);
  // color *= 2;

  

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

  color *= config.swap_chain_scaling_nits;
  color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos

  // scrgb output
  color = color / 80.f;
  o0.rgb = color;


  return;
}