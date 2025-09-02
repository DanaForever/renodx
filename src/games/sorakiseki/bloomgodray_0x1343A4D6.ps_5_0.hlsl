// ---- Created with 3Dmigoto v1.3.16 on Thu Aug 21 16:18:31 2025
#include "./shared.h"
#include "common.hlsl"
cbuffer cb_godray : register(b2)
{
  float2 blurCenter_g : packoffset(c0);
  float2 blurScale_g : packoffset(c0.z);
  float zThreshold_g : packoffset(c1);
  float isFlip_g : packoffset(c1.y);
  float brightnessThreshold_g : packoffset(c1.z);
  float centricSharpness_g : packoffset(c1.w);
  float3 godrayColor_g : packoffset(c2);
  float4 uvClamp_g : packoffset(c3);
}

SamplerState samPoint_s : register(s0);
SamplerState samLinear_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> godrayTexture : register(t1);

float3 hdrScreenBlend(float3 base, float3 blend) {

  blend = max(0.f, blend);
  blend *= shader_injection.bloom_strength; 

  // float3 bloom = base + (blend / (1.f + base));

  base = max(0.f, base);
  
  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);

  return base + addition;
  
}


// 3Dmigoto declarations
#define cmp -

float4 blendGodRaySrgb(Texture2D<float4> godrayTexture, Texture2D<float4> colorTexture, float4 v1)  {

  float4 r0,r1,r2, output;
  r0.xyz = godrayTexture.SampleLevel(samLinear_s, v1.xy, 0).xyz;
  r0.xyz = godrayColor_g.xyz * r0.xyz;
  r1.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = max(float3(0,0,0), r2.xyz);
  output.xyz = r0.xyz * r2.xyz + r1.xyz;
  output.w = r1.w;

  return output;
}


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;
 
  float4 vanilla = blendGodRaySrgb(godrayTexture, colorTexture, v1);
  if (RENODX_TONE_MAP_TYPE == 0 || shader_injection.bloom == 0.f) {
    o0 = vanilla;
    return;
  }
  
  r0.xyz = godrayTexture.SampleLevel(samLinear_s, v1.xy, 0).xyz;
  r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);
  r0.xyz = godrayColor_g.xyz * r0.xyz;
  r1.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  r1.rgb = renodx::color::srgb::DecodeSafe(r1.rgb);

  o0.rgb = hdrScreenBlend(r1.rgb, r0.rgb);

  o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  
  o0.w = r1.w;
  return;
}