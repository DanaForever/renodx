// ---- Created with 3Dmigoto v1.3.16 on Tue Jul 15 22:55:41 2025
#include "shared.h"
cbuffer CParam : register(b0)
{
  float4 param0 : packoffset(c0);
  float4 param1 : packoffset(c1);
}

SamplerState srcsamp_s : register(s0);
SamplerState lumisamp_s : register(s3);
SamplerState dofsamp_s : register(s4);
Texture2D<float4> srctex : register(t0);
Texture2D<float4> lumitex : register(t3);
Texture2D<float4> doftex : register(t4);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = srctex.Sample(srcsamp_s, v0.xy).xyz;
  r0.xyz = r0.xyz;
  r1.xyz = lumitex.Sample(lumisamp_s, v0.xy).xyz;
  r1.xyz = r1.xyz;
  r2.xyz = doftex.Sample(dofsamp_s, w0.xy).xyz;
  r2.xyz = r2.xyz;
  // r2.xyz = log2(r2.xyz);
  // r2.xyz = param0.xxx * r2.xyz;
  // r2.xyz = exp2(r2.xyz);
  r2.xyz =  renodx::math::SafePow(r2.xyz, param0.x);
  // r0.xyz = log2(r0.xyz);
  // r0.xyz = param0.xxx * r0.xyz;
  // r0.xyz = exp2(r0.xyz);
  r0.xyz = renodx::math::SafePow(r0.xyz, param0.x);
  r1.xyz = param0.yyy * r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyz = param0.zzz * r2.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  o0.w = 1;
  o0.xyz = r0.xyz;
  return;
}