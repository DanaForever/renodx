// ---- Created with 3Dmigoto v1.3.16 on Wed May 21 16:53:47 2025
#include "./shared.h"
cbuffer _Globals : register(b0)
{
  float gamma : packoffset(c0);
}

SamplerState smp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(smp_s, v2.xy).xyzw;
  // r0.xyz = log2(r0.xyz);
  
  // r0.xyz = gamma * r0.xyz;
  // o0.xyz = exp2(r0.xyz);

  o0.xyz = renodx::math::SignPow(r0.xyz, gamma);
  o0.w = r0.w;

  // o0.r = isnan(o0.r) ? 0.0 : o0.r;
  // o0.g = isnan(o0.g) ? 0.0 : o0.g;
  // o0.b = isnan(o0.b) ? 0.0 : o0.b;
  return;
}