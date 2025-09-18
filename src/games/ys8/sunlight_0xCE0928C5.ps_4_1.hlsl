// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 03:17:22 2025
#include "common.hlsl"
#include "shared.h"
cbuffer CB0 : register(b0)
{
  float4 tatecolor : packoffset(c0);
  float4 encolor : packoffset(c1);
  float4 sunpos : packoffset(c2);
}



// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = -sunpos.xyz + v0.xyy;
  r0.x = dot(r0.xy, r0.xy);
  r1.x = abs(r0.z) / tatecolor.w;
  r0.x = sqrt(r0.x);
  r1.y = r0.x / encolor.w;
  r0.xy = float2(1,1) + -r1.xy;
  r0.xy = max(float2(0,0), r0.xy);
  r1.xyz = sunpos.www * encolor.xyz;
  // r0.yzw = -r1.xyz * r0.yyy + float3(1,1,1);
  // r1.xyz = -tatecolor.xyz * r0.xxx + float3(1,1,1);
  // o0.xyz = -r1.xyz * r0.yzw + float3(1,1,1);
  o0.rgb = r1.rgb * r0.y + tatecolor.xyz * r0.x;
  o0.w = 1;

  // o0.rgb *=
  return;
}