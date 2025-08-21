
#include "./shared.h"
float3 LogMap(float3 c) { return log(1.0 + c); }
float3 LogMapInv(float3 l) { return exp(l) - 1.0; }

// ---- Created with 3Dmigoto v1.3.16 on Thu Aug 21 11:48:23 2025

cbuffer cb_glow : register(b2)
{
  float4 uv_clamp0_g : packoffset(c0);
  float4 uv_clamp1_g : packoffset(c1);
  float2 uv_clamp2_g : packoffset(c2);
  float2 intensityLum_g : packoffset(c2.z);
  float2 chrIntensityLum_g : packoffset(c3);
  float atmosphereFadeBegin_g : packoffset(c3.z);
  float atmosphereFadeRangeInv_g : packoffset(c3.w);
  float atmosphereIntensity_g : packoffset(c4);
}

SamplerState samLinear_s : register(s0);
SamplerState samPoint_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture1 : register(t1);
Texture2D<float4> blurTexture2 : register(t2);
Texture2D<float4> blurTexture3 : register(t3);
Texture2D<float4> blurTexture4 : register(t4);
Texture2D<float4> blurTexture5 : register(t5);

float4 blendBloomLinear(SamplerState samLinear_s, float4 v1) {

  float4 r0, r1, r2, r3;
  float4 output;

  r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
  r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
  r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
  r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;

  r3.xyz = float3(1,1,1) + -r2.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r1.xyz = r1.xyz * r3.xyz + r2.xyz;
  output.w = r2.w;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = max(float3(0,0,0), r2.xyz);
  r0.xyz = r0.xyz * r2.xyz + r1.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
  r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  
  r0.xyz = r3.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyz = r2.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xy = min(uv_clamp2_g.xy, v1.xy);
  r2.xyz = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  output.xyz = r2.xyz * r1.xyz + r0.xyz;
  
  return output;
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 linearBloom = blendBloomLinear(samLinear_s, v1);
  if (RENODX_TONE_MAP_TYPE == 0)  {
    o0 = linearBloom;
    return;
  }

  r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
  r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
  r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
  r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  
  r2.rgb = LogMap(r2.rgb);
  r0.rgb = LogMap(r0.rgb);
  r1.rgb = LogMap(r1.rgb);
  
  r3.xyz = float3(1,1,1) + -r2.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r1.xyz = r1.xyz * r3.xyz + r2.xyz;
  o0.w = r2.w;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = max(float3(0,0,0), r2.xyz);
  r0.xyz = r0.xyz * r2.xyz + r1.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
  r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  
  r3.rgb = LogMap(r3.rgb);
  r2.rgb = LogMap(r2.rgb);
  
  r0.xyz = r3.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyz = r2.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xy = min(uv_clamp2_g.xy, v1.xy);
  r2.xyz = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  
  r2.rgb = LogMap(r2.rgb);
  
  o0.xyz = r2.xyz * r1.xyz + r0.xyz;
  
  o0.rgb = LogMapInv(o0.rgb);

  // o0.rgb = renodx::color::correct::Chrominance(o0.rgb, linearBloom.rgb, 1.f);
  o0.rgb = renodx::color::correct::Hue(o0.rgb, linearBloom.rgb, shader_injection.bloom_hue_correction, RENODX_TONE_MAP_HUE_PROCESSOR);

  return;
}

// #include "./shared.h"
// #include "common.hlsl"

// // ---- Created with 3Dmigoto v1.3.16 on Thu Aug 21 11:48:23 2025

// cbuffer cb_glow : register(b2)
// {
//   float4 uv_clamp0_g : packoffset(c0);
//   float4 uv_clamp1_g : packoffset(c1);
//   float2 uv_clamp2_g : packoffset(c2);
//   float2 intensityLum_g : packoffset(c2.z);
//   float2 chrIntensityLum_g : packoffset(c3);
//   float atmosphereFadeBegin_g : packoffset(c3.z);
//   float atmosphereFadeRangeInv_g : packoffset(c3.w);
//   float atmosphereIntensity_g : packoffset(c4);
// }

// SamplerState samLinear_s : register(s0);
// SamplerState samPoint_s : register(s1);
// Texture2D<float4> colorTexture : register(t0);
// Texture2D<float4> blurTexture1 : register(t1);
// Texture2D<float4> blurTexture2 : register(t2);
// Texture2D<float4> blurTexture3 : register(t3);
// Texture2D<float4> blurTexture4 : register(t4);
// Texture2D<float4> blurTexture5 : register(t5);


// // 3Dmigoto declarations
// #define cmp -

// float3 hdrScreenBlend(float3 base, float3 blend) {
// 	return base + renodx::math::SafeDivision(blend / (1.f + base), 1.f);
// }

// float3 vanillaSdrBlend(float3 base, float3 blend) {
//   return 1.f - (1.f - base) * (1.f - blend);
// }

// void main(
//     float4 v0 : SV_Position0,
//     float4 v1 : TEXCOORD0,
//     out float4 o0 : SV_Target0)
// {
//     float4 gameScene = colorTexture.SampleLevel(samPoint_s, v1.xy, 0);
//     o0.w = gameScene.w; 
    
//     float4 clampedUV0 = min(uv_clamp0_g, v1.xyxy);
//     float3 blur1 = blurTexture1.SampleLevel(samLinear_s, clampedUV0.xy, 0).xyz;
//     float3 blur2 = blurTexture2.SampleLevel(samLinear_s, clampedUV0.zw, 0).xyz;
    
//     float3 result = hdrScreenBlend(gameScene.xyz, blur1);
//     result = hdrScreenBlend(result, blur2);
    
//     float4 clampedUV1 = min(uv_clamp1_g, v1.xyxy);
//     float3 blur3 = blurTexture3.SampleLevel(samLinear_s, clampedUV1.xy, 0).xyz;
//     float3 blur4 = blurTexture4.SampleLevel(samLinear_s, clampedUV1.zw, 0).xyz;
    
//     result = hdrScreenBlend(result, blur3);
//     result = hdrScreenBlend(result, blur4);
    
//     float2 clampedUV2 = min(uv_clamp2_g.xy, v1.xy);
//     float3 blur5 = blurTexture5.SampleLevel(samLinear_s, clampedUV2, 0).xyz;
//     result = hdrScreenBlend(result, blur5);

//     float3 hdrScreenBlended = result;
	
// 	// second vanilla/sdr run
//     result = vanillaSdrBlend(gameScene.rgb, blur1);
//     result = vanillaSdrBlend(result, blur2);
//     result = vanillaSdrBlend(result, blur3);
//     result = vanillaSdrBlend(result, blur4);
//     result = vanillaSdrBlend(result, blur5);

//     float3 sdrVanillaBlended = saturate(result);

//     o0.rgb = hdrScreenBlended;

    
//     // o0.rgb = renodx::color::correct::Chrominance(o0.rgb, sdrVanillaBlended, 0.5f);
//     // o0.rgb = renodx::color::correct::Hue(o0.rgb, sdrVanillaBlended, RENODX_TONE_MAP_HUE_CORRECTION, RENODX_TONE_MAP_HUE_PROCESSOR);	
//     o0.rgb = RestoreHue(o0.rgb, sdrVanillaBlended, RENODX_TONE_MAP_HUE_CORRECTION);	
// }