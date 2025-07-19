// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 01:21:12 2025
#include "./shared.h"
cbuffer CB0 : register(b0)
{
  float4 uColor[2] : packoffset(c0);
}



// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  float3 v2 : POSITION0,
  out float2 o0 : TEXCOORD0,
  out float4 o1 : COLOR0,
  out float4 o2 : COLOR1,
  out float4 o3 : SV_Position0)
{
  o0.xy = v0.xy;
  o1.xyzw = uColor[0].xyzw * v1.xyzw;
  o2.xyzw = uColor[1].xyzw;
  o3.xyz = v2.xyz;
  o3.w = 1;
  return;
}