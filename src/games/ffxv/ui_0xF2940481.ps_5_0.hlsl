// ---- Created with 3Dmigoto v1.3.16 on Fri May 30 00:38:52 2025
#include "shared.h"
cbuffer MenuHDRParam : register(b0)
{
  float HDRSaturation : packoffset(c0);
  float HDRLuminance : packoffset(c0.y);
}

SamplerState g_samp0_s : register(s0);
Texture2D<float4> g_samp0Texture : register(t0);
Texture2D<float4> g_samp1Mask : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = g_samp1Mask.Sample(g_samp0_s, v2.zw).x;
  r1.xyzw = g_samp0Texture.Sample(g_samp0_s, v2.xy).xyzw;
  r1.w = r1.w * r0.x;
  r0.xyzw = v1.xyzw * r1.xyzw;
  // r0.xyzw = saturate(r0.xyzw * float4(2, 2, 2, 2) + v3.xyzw);
  r0.xyzw = (r0.xyzw * float4(2, 2, 2, 2) + v3.xyzw);
  // r1.xyz = float3(0.0549999997, 0.0549999997, 0.0549999997) + r0.xyz;
  // r1.xyz = float3(0.947867334, 0.947867334, 0.947867334) * r1.xyz;
  // r1.xyz = log2(r1.xyz);
  // r1.xyz = float3(2.4000001, 2.4000001, 2.4000001) * r1.xyz;
  // r1.xyz = exp2(r1.xyz);
  // r2.xyz = cmp(float3(0.0392800011, 0.0392800011, 0.0392800011) >= r0.xyz);
  // r0.xyz = float3(0.0773993805, 0.0773993805, 0.0773993805) * r0.xyz;
  o0.w = r0.w;
  r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
  // r0.xyz = r2.xyz ? r0.xyz : r1.xyz;

  r1.xy = float2(0.627399981, 0.329299986) * r0.xy;
  r0.w = r1.x + r1.y;
  r1.x = r0.z * 0.0432999991 + r0.w;
  r2.xyz = float3(0.919499993, 0.0164000001, 0.0879999995) * r0.yxy;
  r0.w = r0.x * 0.0691 + r2.x;
  r1.w = r2.y + r2.z;
  r1.z = r0.z * 0.895600021 + r1.w;
  r1.y = r0.z * 0.0114000002 + r0.w;
  r0.xyz = -r1.xyz + r0.xyz;
  r0.xyz = HDRSaturation * r0.xyz + r1.xyz;
  r0.xyz = HDRLuminance * r0.xyz;
  // r1.xyz = log2(r0.xyz);
  // r1.xyz = float3(0.416666657, 0.416666657, 0.416666657) * r1.xyz;
  // r1.xyz = exp2(r1.xyz);
  // r1.xyz = r1.xyz * float3(1.05499995, 1.05499995, 1.05499995) + float3(-0.0549999997, -0.0549999997, -0.0549999997);
  // r2.xyz = cmp(float3(0.00313080009, 0.00313080009, 0.00313080009) >= r0.xyz);
  // r0.xyz = float3(12.9200001, 12.9200001, 12.9200001) * r0.xyz;
  // o0.xyz = r2.xyz ? r0.xyz : r1.xyz;
  r0.xyz = renodx::color::srgb::EncodeSafe(r0.xyz);
  o0.rgb = r0.rgb;

  return;
}