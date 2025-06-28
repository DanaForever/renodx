// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 19:17:06 2025
#include "shared.h"
cbuffer Constants : register(b2)
{

  struct
  {
    float4 ThresholdX_OverexposedThreshold_OverexposedSmoothPower;
  } PerDrawCall : packoffset(c0);

}

SamplerState InputTextureSampler_s : register(s0);
Texture2D<float4> InputTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v1.zw, 0).xyz;
  r0.xyz = float3(256,256,256) * r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0).xyz;
  r0.xyz = r1.xyz * float3(256,256,256) + r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v2.xy, 0).xyz;
  r0.xyz = r1.xyz * float3(256,256,256) + r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v2.zw, 0).xyz;
  r0.xyz = r1.xyz * float3(256,256,256) + r0.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.xyz = -PerDrawCall.ThresholdX_OverexposedThreshold_OverexposedSmoothPower.xxx + r0.xyz;
  // r0.xyz = max(float3(0,0,0), r0.xyz);
  // r1.x = log2(abs(r0.w));
  // r1.x = PerDrawCall.ThresholdX_OverexposedThreshold_OverexposedSmoothPower.z * r1.x;
  // r1.x = exp2(r1.x);
  r1.x = renodx::math::SafePow(r0.w, PerDrawCall.ThresholdX_OverexposedThreshold_OverexposedSmoothPower.z);
  r1.y = cmp(PerDrawCall.ThresholdX_OverexposedThreshold_OverexposedSmoothPower.y < r0.w);
  r0.w = r1.y ? r1.x : r0.w;
  r1.x = cmp(r0.w >= PerDrawCall.ThresholdX_OverexposedThreshold_OverexposedSmoothPower.x);
  o0.w = r0.w;
  r0.w = r1.x ? 1.000000 : 0;
  o0.xyz = r0.www * r0.xyz;

  o0 = saturate(o0);

  return;
}