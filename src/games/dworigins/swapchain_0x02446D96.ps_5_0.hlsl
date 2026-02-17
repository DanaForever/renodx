// ---- Created with 3Dmigoto v1.3.16 on Sun Feb 15 17:09:47 2026
#include "common.hlsl"
cbuffer _Globals : register(b0)
{
  float hdrSaturation : packoffset(c0);
  float hdrContrast : packoffset(c0.y);
  float hdrBrightness : packoffset(c0.z);
}

Texture2D<float4> tTex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (int2)v0.xy;
  r0.zw = float2(0,0);
  r0.xyzw = tTex.Load(r0.xyz).xyzw;
  r1.x = cmp(r0.x < r0.y);
  if (r1.x != 0) {
    r1.xyzw = r0.xyzy + -r0.yxxz;
    r2.xyz = cmp(float3(0,0,0) < r1.zyw);
    r3.xyz = float3(60,60,60) * r1.xzz;
    r3.xyz = r3.xyz / r1.zyw;
    r3.xyz = float3(240,120,120) + r3.xyz;
    r4.xy = cmp(r0.yx < r0.zz);
    r2.xyz = r2.xyz ? r3.xyz : 0;
    r2.w = r1.y;
    r3.x = r2.z;
    r3.z = r1.w;
    r3.xz = r4.yy ? r2.yw : r3.xz;
    r1.x = r2.x;
    r1.y = r0.z;
    r3.y = r0.y;
    r1.xyz = r4.xxx ? r1.yzx : r3.yzx;
  } else {
    r2.xyzw = r0.zxyx + -r0.yyzz;
    r3.xyz = cmp(float3(0,0,0) < r2.xyw);
    r4.xyz = float3(60,60,60) * r2.yzz;
    r4.xyz = r4.xyz / r2.xyw;
    r1.w = 240 + r4.x;
    r5.x = r3.x ? r1.w : 0;
    r3.xw = cmp(r0.xy < r0.zz);
    r4.xy = r3.yz ? r4.yz : 0;
    r4.zw = r2.yw;
    r4.xz = r3.ww ? r4.xz : r4.yw;
    r5.y = r0.z;
    r5.z = r2.x;
    r4.y = r0.x;
    r1.xyz = r3.xxx ? r5.yzx : r4.yzx;
  }
  r1.w = cmp(r1.x == 0.000000);
  r1.y = r1.y / r1.x;
  // r1.y = hdrSaturation * r1.y;
  r1.y = r1.y;
  r1.y = r1.w ? 0 : r1.y;
  // r2.x = hdrBrightness * r1.x;
  r2.x = r1.x;
  r1.x = cmp(r1.y == 0.000000);
  if (r1.x != 0) {
    r2.z = r2.x;
    r3.x = r2.x;
  } else {
    r1.x = cmp(r1.z < 0);
    r1.w = cmp(360 < r1.z);
    r3.zw = float2(360,-360) + r1.zz;
    r1.z = r1.w ? r3.w : r1.z;
    r1.x = r1.x ? r3.z : r1.z;
    r1.x = 0.0166666675 * r1.x;
    r1.z = (uint)r1.x;
    r1.z = (uint)r1.z % 6;
    r1.x = frac(r1.x);
    r1.w = 1 + -r1.y;
    r2.z = r2.x * r1.w;
    r1.w = -r1.x * r1.y + 1;
    r3.x = r2.x * r1.w;
    r1.x = 1 + -r1.x;
    r1.x = -r1.x * r1.y + 1;
    r1.x = r2.x * r1.x;
    switch (r1.z) {
      case 0 :      r3.x = r2.z;
      r2.z = r1.x;
      break;
      case 1 :      r1.y = r3.x;
      r1.z = r2.x;
      r3.x = r2.z;
      r2.xz = r1.yz;
      break;
      case 2 :      r1.y = r2.z;
      r2.z = r2.x;
      r3.x = r1.x;
      r2.x = r1.y;
      break;
      case 3 :      r1.y = r2.z;
      r2.z = r3.x;
      r3.x = r2.x;
      r2.x = r1.y;
      break;
      case 4 :      r3.x = r2.x;
      r2.x = r1.x;
      break;
      case 5 :      break;
    }
  }
  r2.yw = float2(1,1);
  // r1.xy = hdrContrast * float2(1,-0.5) + float2(0,0.5);
  r1.xy = float2(1,-0.5) + float2(0,0.5);
  r4.x = dot(r2.xy, r1.xy);
  r4.y = dot(r2.zw, r1.xy);
  r3.y = 1;
  r4.z = dot(r3.xy, r1.xy);

  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 color = r4.rgb;

  color = ToneMapLMS(color, 203.f, 1200.f, 1.0f, 1.0f); 

  color = GammaCorrectHuePreserving(color, 2.4f);

  color = expandGamut(color, 1.0f);

  // Gamut Compression
  color = renodx::color::bt2020::from::BT709(color);
  float grayscale = renodx::color::y::from::BT2020(color);
  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
  float encode_gamma = MID_GRAY_GAMMA;
  float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
  float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
  float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
  color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);
  color = max(0.f, color);

  r0.rgb = color * 203;
  // r0.rgb = color * shader_injection.graphics_white_nits;
  // r0.rgb = color * RENODX_GRAPHICS_WHITE_NITS;
  o0.w = r0.w;
  o0.rgb = renodx::color::pq::Encode(r0.rgb, 1.f);
  

  

  // color = expandGamut(color, shader_injection.inverse_tonemap_extra_hdr_saturation);
  // // color *= 2;

  // color *= 300;

  // [branch]
  // if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT709D93(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT601NTSCU(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::ARIBTRB9(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // }

  // color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos

  // [branch]
  // if (config.swap_chain_clamp_color_space == renodx::color::convert::COLOR_SPACE_UNKNOWN) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
  // } else {
  //   [branch]
  //   if (config.swap_chain_clamp_color_space == config.swap_chain_encoding_color_space) {
  //     color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
  //     color = max(0, color);
  //   } else {
  //     if (config.swap_chain_clamp_color_space != config.swap_chain_decoding_color_space) {
  //       color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_clamp_color_space);
  //     }
  //     color = max(0, color);
  //     color = renodx::color::convert::ColorSpaces(color, config.swap_chain_clamp_color_space, config.swap_chain_encoding_color_space);
  //   }
  // }

  // color = renodx::color::bt2020::from::BT709(color);
  // color = renodx::color::pq::EncodeSafe(color, 1.f);
  // o0.rgb = color;
  // o0.w = r0.w;

  
  
  return;
}