// ---- Created with 3Dmigoto v1.3.16 on Wed May 28 20:54:02 2025
#include "./common.hlsl"
#include "./shared.h"

cbuffer _Globals : register(b0)
{
  float4 vLightShaftPower : packoffset(c0) = {0.200000003,0.119999997,0.119999997,37};
  float fParamA : packoffset(c1) = {0.219999999};
  float fParamCB : packoffset(c1.y) = {0.0299999993};
  float fParamDE : packoffset(c1.z) = {0.00200000009};
  float fParamB : packoffset(c1.w) = {0.300000012};
  float fParamDF : packoffset(c2) = {0.0599999987};
  float fParamEperF : packoffset(c2.y) = {0.0333000012};
  float fWhiteTone : packoffset(c2.z) = {1.35598528};
  float4 vUVOffset : packoffset(c3) = {0,0,1,1};
  float fBloomWeight : packoffset(c4) = {1};
  float3 vColorScale : packoffset(c4.y) = {1,1,1};
  float3 vSaturationScale : packoffset(c5) = {1,1,1};
  float fGamma : packoffset(c5.w) = {1};
}

SamplerState smplBlurFront_s : register(s0);
SamplerState smplBlurBack_s : register(s1);
SamplerState smplLightShaft_s : register(s2);
SamplerState smplFlare_s : register(s3);
SamplerState smplScene_s : register(s4);
SamplerState smplBloom_s : register(s5);
Texture2D<float4> smplBlurFront_Tex : register(t0);
Texture2D<float4> smplBlurBack_Tex : register(t1);
Texture2D<float4> smplLightShaft_Tex : register(t2);
Texture2D<float4> smplFlare_Tex : register(t3);
Texture2D<float4> smplScene_Tex : register(t4);
Texture2D<float4> smplBloom_Tex : register(t5);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * vUVOffset.zw + vUVOffset.xy;
  r0.xyzw = smplScene_Tex.Sample(smplScene_s, r0.xy).xyzw;
  r1.x = -0.5 + r0.w;
  r1.x = abs(r1.x) * -2 + 1;
  r1.x = max(0, r1.x);
  r1.x = 9.99999975e-006 + r1.x;
  r1.y = 1 / r1.x;
  r1.y = -1 + r1.y;
  r1.y = saturate(0.25 * r1.y);
  r1.y = r1.y + -r1.x;
  r1.y = max(0, r1.y);
  r2.xyzw = smplBlurBack_Tex.Sample(smplBlurBack_s, v1.xy).xyzw;
  r2.xyzw = r2.xyzw * r1.yyyy;
  r1.y = r1.x * r1.x + r1.y;
  r1.x = r1.x * r1.x;
  r0.xyzw = r0.xyzw * r1.xxxx + r2.xyzw;
  r0.xyzw = r0.xyzw / r1.yyyy;
  r1.xyzw = smplBlurFront_Tex.Sample(smplBlurFront_s, v1.xy).xyzw;
  r2.xyzw = r1.xyzw + -r0.xyzw;
  r1.x = 0.5 + -r1.w;
  r1.x = saturate(r1.x + r1.x);
  r0.xyzw = r1.xxxx * r2.xyzw + r0.xyzw;
  r1.xyz = smplLightShaft_Tex.Sample(smplLightShaft_s, v1.xy).xyz;
  r1.xyz = r1.xyz * vLightShaftPower.xyz + r0.xyz;
  r2.xyz = smplFlare_Tex.Sample(smplFlare_s, v1.xy).xyz;
  r0.xyz = r2.xyz + r1.xyz;
  r1.xyzw = smplBloom_Tex.Sample(smplBloom_s, v1.xy).xyzw;
  r0.xyzw = r1.xyzw * fBloomWeight + r0.xyzw;

  float3 untonemapped = r0.xyz;
  r0.xyz = RestoreHighlightSaturation(untonemapped);
  // Uncharted 3 tonemapper
  r1.xyz = fParamA * r0.xyz + fParamCB;
  r1.xyz = r0.xyz * r1.xyz + fParamDE;
  r2.xyz = fParamA * r0.xyz + fParamB;
  r0.xyz = r0.xyz * r2.xyz + fParamDF;
  o0.w = r0.w;
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = -fParamEperF + r0.xyz;

  r0.xyz = fWhiteTone * r0.xyz;
  r1.xyz = vColorScale.xyz * r0.xyz;
  r0.w = dot(r1.xyz, float3(0.298909992,0.586610019,0.114480004));
  r0.xyz = r0.xyz * vColorScale.xyz + -r0.www;
  r0.xyz = vSaturationScale.xyz * r0.xyz + r0.www;

  float3 graded = r0.xyz;

  // second tonemapper to estimate mid_gray
  r0.xyz = float3(0.18f, 0.18f, 0.18f);
  r1.xyz = fParamA * r0.xyz + fParamCB;
  r1.xyz = r0.xyz * r1.xyz + fParamDE;
  r2.xyz = fParamA * r0.xyz + fParamB;
  r0.xyz = r0.xyz * r2.xyz + fParamDF;
  o0.w = r0.w;
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = -fParamEperF + r0.xyz;

  // float3 midgray = renodx::tonemap::uncharted2::BT709(float3(0.18f, 0.18f, 0.18f), 1.14999998);
  float mid_gray_nits = renodx::color::y::from::BT709(r0.xyz);
  untonemapped *= mid_gray_nits / 0.18f;  // scale untonemapped midgray, tonemappass expects 0.18f

  o0.rgba = ProcessColor(untonemapped, graded);
  // r0.xyz = log2(r0.xyz);
  // r0.xyz = fGamma * r0.xyz;
  // o0.xyz = exp2(r0.xyz);
  return;
}