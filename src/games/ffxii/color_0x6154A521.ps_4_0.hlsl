// ---- Created with 3Dmigoto v1.3.16 on Sat May 31 20:51:58 2025
#include "./shared.h"
cbuffer _Globals : register(b0)
{
  float4 offsets : packoffset(c0);
  float2 usmresolution : packoffset(c1);
  float percent : packoffset(c1.z);
  float colorR : packoffset(c1.w);
  float colorG : packoffset(c2);
  float colorB : packoffset(c2.y);
  float gamma : packoffset(c2.z);
  float intensity : packoffset(c2.w);
  float threshhold : packoffset(c3);
}

SamplerState ColorBufferSampler_s : register(s0);
Texture2D<float4> apply_MainTex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * float2(1,-1) + float2(0,1);
  r0.xyzw = apply_MainTex.Sample(ColorBufferSampler_s, r0.xy).xyzw;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    r0.xyzw = max(float4(0,0,0,0), r0.xyzw);
    r0.xyzw = min(float4(2,2,2,2), r0.xyzw);
  }
  r0.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r0.xyzw;
  r1.x = 1 + percent;
  r2.x = r0.x * r1.x + colorR;
  r2.yz = r0.yz * r1.xx + colorG;
  r2.w = r0.w * r1.x + 0.5;
  r0.xyzw = float4(0.5,0.5,0.5,0) + r2.xyzw;

  // r0.xyzw = log2(r0.xyzw);
  // r1.x = 1 / gamma;
  // r0.xyzw = r1.xxxx * r0.xyzw;
  // o0.xyzw = exp2(r0.xyzw);
  o0.xyz = renodx::math::SafePow(r0.xyz, 1 / gamma);

  // oh looks like it does gamma conversion here
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    r0.xyzw = max(float4(0, 0, 0, 0), r0.xyzw);
    r0.xyzw = min(float4(100, 100, 100, 100), r0.xyzw);
  }
  else {
    o0.xyz = r0.xyz;
    o0.rgb = renodx::color::bt709::clamp::AP1(o0.rgb);  // clamp to bt2020 to eliminate invalid colors
  }

  o0.w = r0.w;

  o0.rgb = renodx::draw::RenderIntermediatePass(o0.rgb);
  
  return;
}