// ---- Created with 3Dmigoto v1.3.16 on Mon Sep 29 00:42:31 2025
#include "../common.hlsl"
cbuffer cb_local : register(b2)
{
  float4 offsetsAndWeights_g[16] : packoffset(c0);
}

SamplerState samLinear_s : register(s0);
Texture2D<float4> colorTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(0,0);
  while (true) {
    r0.z = cmp((int)r0.y >= 9);
    if (r0.z != 0) break;
    r0.zw = offsetsAndWeights_g[r0.y].xy + v1.xy;
    r1.xyz = colorTexture.SampleLevel(samLinear_s, r0.zw, 0).xyz;
    r1.xyz = max(float3(0,0,0), r1.xyz);
    // r0.z = dot(r1.xyz, float3(0.212599993,0.715200007,0.0722000003));
    r0.z = calculateLuminanceSRGB(r1.rgb);
    r0.z = 9.99999975e-005 + r0.z;
    r0.z = log2(r0.z);
    r0.x = r0.z * 0.693147182 + r0.x;
    r0.y = (int)r0.y + 1;
  }
  o0.xyz = float3(0.111111112,0.111111112,0.111111112) * r0.xxx;
  o0.w = 1;
  return;
}