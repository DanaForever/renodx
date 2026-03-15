// ---- Created with 3Dmigoto v1.3.16 on Sat Jan 31 14:59:07 2026
#include "shared.h"
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
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(samp_s, v0.xy).xyzw;
  r1.xyzw = v1.wxyz * r0.wxyz;
  r2.x = cmp(altest >= r1.x);
  if (r2.x != 0) discard;
  r2.xy = cmp(float2(0,0) != mulblend);
  r0.xyzw = -r0.wxyz * v1.wxyz + float4(1,1,1,1);
  r0.xyz = r0.xxx * r0.yzw + r1.yzw;
  o0.xyz = r2.xxx ? r0.xyz : r1.yzw;
  o0.w = r2.y ? 1 : r1.x;

  o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
  o0.rgb *= RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  return;
}