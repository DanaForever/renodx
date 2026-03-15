// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 17:32:25 2025
#include "common.hlsl"
#include "shared.h"
cbuffer CAlTest : register(b0)
{
  float altest : packoffset(c0);
  float mulblend : packoffset(c0.y);
  float noalpha : packoffset(c0.z);
}

SamplerState tex_samp_s : register(s0);
Texture2D<float4> tex_tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float3 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD8,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).xyzw;
  r0.w = v1.w * r0.w;
  r1.x = cmp(0 != noalpha);
  r1.y = ~(int)r1.x;
  r1.z = cmp(r0.w < altest);
  r1.y = r1.z ? r1.y : 0;
  if (r1.y != 0) discard;
  r0.xyz = r0.xyz * v1.xyz + v2.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r1.y = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.z = dot(v3.xyz, float3(0.298999995,0.587000012,0.114));
  r1.y = -r1.z * 0.5 + r1.y;
  r1.y = max(0, r1.y);
  r1.z = 1 + -v3.w;
  r1.z = v0.z * r1.z;
  r1.y = r1.y * r1.z;
  r2.xyz = r0.xyz * v3.www + v3.xyz;
  r3.xyz = r1.yyy * r0.xyz;
  r0.xyz = r0.xyz * r1.yyy + r2.xyz;
  r0.xyz = -r2.xyz * r3.xyz + r0.xyz;
  r1.y = cmp(0 != mulblend);
  r1.z = -r0.w * v3.w + 1;
  r2.xyz = float3(1,1,1) + -r0.xyz;
  r2.xyz = r1.zzz * r2.xyz + r0.xyz;
  o0.xyz = r1.yyy ? r2.xyz : r0.xyz;
  o0.w = r1.x ? 1 : r0.w;

  return;
}