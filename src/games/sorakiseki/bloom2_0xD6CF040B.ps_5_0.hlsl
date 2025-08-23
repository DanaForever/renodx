

#include "./shared.h"
#include "common.hlsl"

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


// 3Dmigoto declarations
#define cmp -

float3 hdrScreenBlend2(float3 base, float3 blend, float weight) {

  float y = renodx::color::y::from::BT709(base);
  float yb = renodx::color::y::from::BT709(blend);
  float g = 1.0 / (1.0 + y);
  float gain = 1.0 + g * yb;
  
  return base * gain;

	// return base + (blend / (1.f + base));
}

float3 hdrScreenBlend(float3 base, float3 blend, float weight) {

  return base + (blend / (1.f + base));

  // float y = renodx::color::y::from::BT709(base);
  // float g = 1.0 / (1.0 + y);
  // return base + blend * g;
  
	}

float3 one_minus(float3 x)  {

  return 1 - x;
}

float3 vanillaSdrBlend(float3 base, float3 blend) {

  
  return 1.f - one_minus(base) * one_minus(blend);
}

float4 blendBloomLinear(SamplerState samLinear_s, float4 v1) {

  float4 r0, r1, r2, r3;
  float4 output;

  float4 gameScene;

  r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
  r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
  r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
  gameScene.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  output.w = gameScene.w;

  r3.xyz = float3(1,1,1) + -gameScene.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r1.xyz = r1.xyz * r3.xyz + gameScene.xyz;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = max(float3(0,0,0), r2.xyz);

  r0.xyz = r0.xyz * r2.xyz + r1.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
  r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  float3 blur3 = r3.xyz;
  r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  float3 blur4 = r2.xyz;
  
  r0.xyz = blur3 * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyz = blur4 * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xy = min(uv_clamp2_g.xy, v1.xy);
  float3 blur5 = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  output.xyz = blur5 * r1.xyz + r0.xyz;
  
  return output;
}

void main(
    float4 v0 : SV_Position0,
    float4 v1 : TEXCOORD0,
    out float4 o0 : SV_Target0)
{
    float4 sdr = blendBloomLinear(samLinear_s, v1);
    if (RENODX_TONE_MAP_TYPE == 0)  {
      o0 = sdr;
      return;
    }
    float4 gameScene = colorTexture.SampleLevel(samPoint_s, v1.xy, 0);
    float3 hdr = gameScene.rgb;
    hdr = renodx::color::srgb::DecodeSafe(hdr);
    o0.w = gameScene.w; 
    
    float4 clampedUV0 = min(uv_clamp0_g, v1.xyxy);
    float3 blur1 = blurTexture1.SampleLevel(samLinear_s, clampedUV0.xy, 0).xyz;
    blur1 = renodx::color::srgb::DecodeSafe(blur1);
    float3 blur2 = blurTexture2.SampleLevel(samLinear_s, clampedUV0.zw, 0).xyz;
    blur2 = renodx::color::srgb::DecodeSafe(blur2);

    hdr = hdrScreenBlend(hdr, blur1, 1.f);
    hdr = hdrScreenBlend(hdr, blur2, 1.f);
    
    float4 clampedUV1 = min(uv_clamp1_g, v1.xyxy);
    float3 blur3 = blurTexture3.SampleLevel(samLinear_s, clampedUV1.xy, 0).xyz;
    float3 blur4 = blurTexture4.SampleLevel(samLinear_s, clampedUV1.zw, 0).xyz;
    blur3 = renodx::color::srgb::DecodeSafe(blur3);
    blur4 = renodx::color::srgb::DecodeSafe(blur4);
    
    hdr = hdrScreenBlend(hdr, blur3, 1.f);
    hdr = hdrScreenBlend(hdr, blur4, 1.f);
    
    float2 clampedUV2 = min(uv_clamp2_g.xy, v1.xy);
    float3 blur5 = blurTexture5.SampleLevel(samLinear_s, clampedUV2, 0).xyz;
    blur5 = renodx::color::srgb::DecodeSafe(blur5);

    hdr = hdrScreenBlend(hdr, blur5, 1.f);

    float3 sat = saturate(renodx::color::srgb::DecodeSafe(sdr.rgb));

    // hue and chrominance correction if desaturation is desired
    hdr = renodx::color::correct::ChrominanceICtCp(hdr, sat, shader_injection.bloom_hue_correction);
    hdr = renodx::color::correct::Hue(hdr, sat, shader_injection.bloom_hue_correction, RENODX_TONE_MAP_HUE_PROCESSOR);

    o0.rgb = hdr;
    o0.rgb = renodx::color::srgb::EncodeSafe(hdr);
  
}

//// OLD CODE



// #include "./shared.h"
// #include "./common.hlsl"
// float3 LogMap(float3 c) { return log(1.0 + c); }
// float3 LogMapInv(float3 l) { return exp(l) - 1.0; }

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

// float4 blendBloomLinear(SamplerState samLinear_s, float4 v1) {

//   float4 r0, r1, r2, r3;
//   float4 output;

//   r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
//   r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
//   r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
//   r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;

//   r3.xyz = float3(1,1,1) + -r2.xyz;
//   r3.xyz = max(float3(0,0,0), r3.xyz);
//   r1.xyz = r1.xyz * r3.xyz + r2.xyz;
//   output.w = r2.w;
//   r2.xyz = float3(1,1,1) + -r1.xyz;
//   r2.xyz = max(float3(0,0,0), r2.xyz);
//   r0.xyz = r0.xyz * r2.xyz + r1.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
//   r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
//   r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  
//   r0.xyz = r3.xyz * r1.xyz + r0.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r0.xyz = r2.xyz * r1.xyz + r0.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r2.xy = min(uv_clamp2_g.xy, v1.xy);
//   r2.xyz = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
//   output.xyz = r2.xyz * r1.xyz + r0.xyz;
  
//   return output;
// }


// // 3Dmigoto declarations
// #define cmp -


// void main(
//   float4 v0 : SV_Position0,
//   float4 v1 : TEXCOORD0,
//   out float4 o0 : SV_Target0)
// {
//   float4 r0,r1,r2,r3;
//   uint4 bitmask, uiDest;
//   float4 fDest;

//   float4 linearBloom = blendBloomLinear(samLinear_s, v1);
//   if (RENODX_TONE_MAP_TYPE == 0)  {
//     o0 = linearBloom;
//     return;
//   }

//   r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
//   r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
//   r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
//   r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  
//   r2.rgb = LogMap(r2.rgb);
//   r0.rgb = LogMap(r0.rgb);
//   r1.rgb = LogMap(r1.rgb);
  
//   r3.xyz = float3(1,1,1) + -r2.xyz;
//   r3.xyz = max(float3(0,0,0), r3.xyz);
//   r1.xyz = r1.xyz * r3.xyz + r2.xyz;
//   o0.w = r2.w;
//   r2.xyz = float3(1,1,1) + -r1.xyz;
//   r2.xyz = max(float3(0,0,0), r2.xyz);
//   r0.xyz = r0.xyz * r2.xyz + r1.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
//   r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
//   r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  
//   r3.rgb = LogMap(r3.rgb);
//   r2.rgb = LogMap(r2.rgb);
  
//   r0.xyz = r3.xyz * r1.xyz + r0.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r0.xyz = r2.xyz * r1.xyz + r0.xyz;
//   r1.xyz = float3(1,1,1) + -r0.xyz;
//   r1.xyz = max(float3(0,0,0), r1.xyz);
//   r2.xy = min(uv_clamp2_g.xy, v1.xy);
//   r2.xyz = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  
//   r2.rgb = LogMap(r2.rgb);
  
//   o0.xyz = r2.xyz * r1.xyz + r0.xyz;
  
//   o0.rgb = LogMapInv(o0.rgb);

//   // o0.rgb = renodx::color::correct::Chrominance(o0.rgb, linearBloom.rgb, 1.f);
//   // o0.rgb = renodx::color::correct::Hue(o0.rgb, linearBloom.rgb, shader_injection.bloom_hue_correction, RENODX_TONE_MAP_HUE_PROCESSOR);

//   // o0.rgb = scaleByPerceptualLuminance(linearBloom.rgb, o0.rgb, 9999.f)

//   return;
// }