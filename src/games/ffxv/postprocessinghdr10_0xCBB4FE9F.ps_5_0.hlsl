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

float3 SE_Saturation(float4 r0) {
  float4 r1;

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
  r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
  o0.w = r0.w;

  if (RENODX_TONE_MAP_TYPE <= 1.f) {
    r0.xyz = max(float3(0, 0, 0), r0.xyz);

    // srgb decoding
    // r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);

    // gamma scaling
    if (RENODX_TONE_MAP_TYPE == 0.f) {
      // SDR gamma = 1.0, HDR gamma = 1.3
      r0.xyz = renodx::math::SignPow(r0.xyz, gamma);

      // r0.w = 0.587700009 * r0.y;
      // r0.w = r0.x * 1.66050005 + -r0.w;
      // r1.x = -r0.z * 0.072800003 + r0.w;
      // r0.w = 0.100599997 * r0.y;
      // r0.w = r0.x * -0.0182000007 + -r0.w;
      // r1.z = r0.z * 1.11870003 + r0.w;
      // r0.x = dot(r0.xy, float2(-0.124600001, 1.13300002));
      // r1.y = -r0.z * 0.0083999997 + r0.x;
      r1.rgb = SE_Saturation(r0);

      o0.xyz = pqScale * r1.xyz;

      return;
    }
    else {
      // r0.xyz = renodx::math::SignPow(r0.xyz, gamma);
      // gamma should be 1.0 in SDR
      // o0.xyz = saturate(r0.xyz);
      o0.xyz = (r0.xyz);
    }
  }

  else if (FFXV_HDR_GRADING == 1.f) {
    r0.xyz = renodx::math::SignPow(r0.xyz, gamma);
    r1.rgb = SE_Saturation(r0);
    r1.xyz = renodx::math::SignPow(r1.xyz, 1.0f / gamma);
    o0.rgb = r1.rgb;
  } else {
    o0.rgb = r0.rgb;
  }

  // renodx swapchainpass
  float3 color = o0.rgb;

  float swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;

  if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::convert::ColorSpaces(color, swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (RENODX_SWAP_CHAIN_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::convert::ColorSpaces(color, swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  }

  color *= RENODX_GRAPHICS_WHITE_NITS;

  [branch]
  if (RENODX_SWAP_CHAIN_CUSTOM_COLOR_SPACE == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
    color = renodx::color::convert::ColorSpaces(color, swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT709D93(color);
    swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (RENODX_SWAP_CHAIN_CUSTOM_COLOR_SPACE == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
    color = renodx::color::convert::ColorSpaces(color, swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT601NTSCU(color);
    swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (RENODX_SWAP_CHAIN_CUSTOM_COLOR_SPACE == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
    color = renodx::color::convert::ColorSpaces(color, swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::ARIBTRB9(color);
    swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  }

  color = min(color, RENODX_PEAK_WHITE_NITS);

  if (shader_injection.swap_chain_encoding == 4.f) {
    color = renodx::color::bt2020::from::BT709(color);
    color = max(0.f, color);
    color = renodx::color::pq::EncodeSafe(color, 1.f);
  } else {
    color = renodx::color::bt709::clamp::BT2020(color);
    color = color / 80.f;
  }

  o0.rgb = color;


  return;
}