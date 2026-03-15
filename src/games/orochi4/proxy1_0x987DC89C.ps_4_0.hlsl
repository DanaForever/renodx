// ---- Created with 3Dmigoto v1.3.16 on Wed May 14 22:04:14 2025
#include "./common.hlsl"
#include "./shared.h"


cbuffer _Globals : register(b0)
{
  float vATest : packoffset(c0);
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
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(smp_s, v2.xy).xyzw;
  
  r1.x = r0.w * v1.w + -vATest;
  r0.xyzw = v1.xyzw * r0.xyzw;
  o0.xyzw = r0.xyzw;
 
  r0.x = cmp(r1.x < 0);
  if (r0.x != 0) discard;
  return;
}