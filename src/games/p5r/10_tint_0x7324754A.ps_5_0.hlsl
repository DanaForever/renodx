#include "./shared.h"

cbuffer GFD_PSCONST_CORRECT : register(b12)
{
  float3 colorBalance : packoffset(c0);
  float _reserve00 : packoffset(c0.w);
  float3 colorBlend : packoffset(c1);
}

SamplerState sampler0_s : register(s0);
Texture2D<float4> texture0 : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = texture0.Sample(sampler0_s, v1.xy).xyz;
  r0.xyz = r0.xyz;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -r0.w;
  r1.x = 1 + r1.x;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;
  r1.yzw = -r1.xxx;
  r0.xyz = r1.yzw + r0.xyz;
  r0.xyz = r0.xyz / r0.www;
  r0.xyz = colorBalance.xyz + r0.xyz;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = r0.xyz + r1.xxx;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;
  r0.xyz = r0.xyz / colorBlend.xxx;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;
  r0.xyz = r0.xyz / colorBlend.yyy;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;
  r0.w = colorBlend.z;
  r0.xyz = r0.xyz;
  r0.w = r0.w;
  o0.xyzw = r0.xyzw;

  o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);

  return;
}