// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 05 22:48:22 2025
#include "./shared.h"
#include "./common.hlsl"

cbuffer _Globals : register(b0)
{
  float4 globalColorMask : packoffset(c0) = {1,1,1,1};
  float4 globalColorMaskN : packoffset(c1) = {0,0,0,0};
  float g_brightPara : packoffset(c2) = {1};
}

SamplerState g_BrightTexState_s : register(s0);
Texture2D<float4> g_BrightTex : register(t0);


// 3Dmigoto declarations
#define cmp -

float3 decode_srgb_wrong(float3 c) {
  return (pow((c + 0.055f) / 1.055f, 2.4f));
}

// float3 decode_srgb_wrong(float3 c) {
//   c.r = decode_srgb_wrong(c.r);
//   c.g = decode_srgb_wrong(c.g);
//   c.b = decode_srgb_wrong(c.b);

//   return c;
// }


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * float2(1,-1) + float2(0,1);
  r0.xyzw = g_BrightTex.Sample(g_BrightTexState_s, r0.xy).xyzw;
  o0.xyz = g_brightPara + r0.xyz;
  o0.xyz = r0.xyz;


  o0.w = r0.w;

  float4 output = o0;
  float3 color = output.rgb;

  renodx::draw::Config config = renodx::draw::BuildConfig();

  color = renodx::draw::DecodeColor(color, RENODX_SWAP_CHAIN_DECODING);

  if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (config.swap_chain_gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  }

  color *= RENODX_GRAPHICS_WHITE_NITS;

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

  color = renodx::draw::EncodeColor(color, RENODX_SWAP_CHAIN_ENCODING);

  output.rgb = color.rgb;

  o0 = output;

  return;
}