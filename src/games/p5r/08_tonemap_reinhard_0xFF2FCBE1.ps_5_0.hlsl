// ---- Created with 3Dmigoto v1.3.16 on Thu Apr 16 22:21:24 2026
#include "./common.hlsl"

cbuffer GFD_PSCONST_HDR : register(b11)
{
  float middleGray : packoffset(c0);
  float adaptedLum : packoffset(c0.y);
  float bloomScale : packoffset(c0.z);
  float starScale : packoffset(c0.w);
}

SamplerState opaueSampler_s : register(s0);
SamplerState bloomSampler_s : register(s1);
SamplerState starSampler_s : register(s2);
SamplerState toneSampler_s : register(s3);
Texture2D<float4> opaueTexture : register(t0);
Texture2D<float4> bloomTexture : register(t1);
Texture2D<float4> starTexture : register(t2);
Texture2D<float4> toneTexture : register(t3);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = bloomTexture.Sample(bloomSampler_s, v1.xy).xyz;
  r0.xyz = r0.xyz;
  r1.xyz = starTexture.Sample(starSampler_s, v1.xy).xyz;
  r1.xyz = r1.xyz;
  r0.w = toneTexture.Sample(toneSampler_s, float2(0.5,0.5)).x;
  r0.w = r0.w;
  r2.xyz = opaueTexture.Sample(opaueSampler_s, v1.xy).xyz;
  r2.xyz = r2.xyz;
  r3.w = 1;
  r0.w = 0.00100000005 + r0.w;
  r0.w = middleGray / r0.w;

  r2.xyz = r2.xyz * r0.www;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    // Reinhard-5: simple, preserves highlights but can look flat
    r4.xyz = float3(10, 10, 10) + r2.xyz;
    r2.xyz = r2.xyz / r4.xyz;
  } else {
  // Extended Reinhard-10: linear tangent above middleGray pivot to preserve highlights
    float pivot_x = middleGray;
    float pivot_y = pivot_x / (pivot_x + 10.0);
    float slope   = 10.0 / ((pivot_x + 10.0) * (pivot_x + 10.0));
    r4.xyz = float3(10,10,10) + r2.xyz;
    float3 base_tm  = r2.xyz / r4.xyz;
    float3 extended = pivot_y + slope * (r2.xyz - pivot_x);
    r2.xyz = lerp(base_tm, extended, step(pivot_x, r2.xyz));
  }


  r1.xyz = starScale * r1.xyz;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = bloomScale * r0.xyz;
  r3.xyz = r1.xyz + r0.xyz;
  r3.xyz = r3.xyz;
  r3.w = r3.w;
  o0.xyzw = r3.xyzw;
  return;
}