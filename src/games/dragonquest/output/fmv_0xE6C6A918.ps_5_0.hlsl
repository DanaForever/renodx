#include "output.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sun Jul 20 19:05:55 2025
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t2.Sample(s2_s, v0.xy).x;
  r0.x = -0.5 + r0.x;
  r0.xy = float2(1.59599996,0.813000023) * r0.xx;
  r0.z = t1.Sample(s1_s, v0.xy).x;
  r0.z = -0.5 + r0.z;
  r0.y = r0.z * -0.39199999 + -r0.y;
  r0.z = 2.01699996 * r0.z;
  r0.w = t0.Sample(s0_s, v0.xy).x;
  r0.w = -0.0625 + r0.w;
  r1.y = r0.w * 1.16400003 + r0.y;
  r1.x = r0.w * 1.16400003 + r0.x;
  r1.z = r0.w * 1.16400003 + r0.z;
  r0.xyz = log2(r1.xyz);
  r0.xyz = cb0[0].xxx * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = cmp(cb0[0].x != 1.000000);
  r0.xyz = r0.www ? r0.xyz : r1.xyz;
  r0.xyz = max(float3(6.10351999e-005,6.10351999e-005,6.10351999e-005), r0.xyz);
  r1.xyz = r0.xyz * float3(0.947867274,0.947867274,0.947867274) + float3(0.0521326996,0.0521326996,0.0521326996);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(2.4000001,2.4000001,2.4000001) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = cmp(float3(0.0404499993,0.0404499993,0.0404499993) < r0.xyz);
  r0.xyz = float3(0.0773993805,0.0773993805,0.0773993805) * r0.xyz;
  o0.xyz = r2.xyz ? r1.xyz : r0.xyz;

  // r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);
  // o0.rgb = r0.rgb;
  o0.w = 1;
  return;
}