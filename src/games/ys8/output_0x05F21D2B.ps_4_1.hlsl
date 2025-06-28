// ---- Created with 3Dmigoto v1.3.16 on Sun May 25 18:04:40 2025
#include "./shared.h"
cbuffer CAlTest : register(b0)
{
  float altest : packoffset(c0);
  float mulblend : packoffset(c0.y);
  float noalpha : packoffset(c0.z);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(samp_s, v0.xy).xyzw;
  r1.x = r0.w * v1.w + -altest;
  r1.x = cmp(r1.x < 0);
  if (r1.x != 0) discard;
  r1.x = cmp(v2.w == 100.000000);
  r2.xyzw = -r0.xyzw * v1.xyzw + float4(1,1,1,1);
  r3.xyzw = v1.xyzw * r0.xyzw;
  r0.xyz = r0.xyz * v1.xyz + v2.xyz;
  r1.yzw = v2.xyz * r2.xyz + r3.xyz;
  r0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r1.xyz = r0.xyz * r3.www + r2.www;
  r2.xy = cmp(float2(0,0) != mulblend);
  o0.xyz = r2.xxx ? r1.xyz : r0.xyz;
  o0.w = r2.y ? 1 : r3.w;
  
  o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);

  return;
}