

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

// Geometric weights: w_l = 4^{-l} normalized so sum(w_l)=1
// For N levels this constant normalizer is: norm = 0.75 / (1 - pow(0.25, N))
float weight_for_level(int level, int N)
{
    float norm = 0.75 / (1.0 - pow(0.25, N));
    return norm * pow(0.25, level);
}


float3 hdrScreenBlend(float3 base, float3 blend) {

  blend = max(0.f, blend);
  blend *= shader_injection.bloom_strength; 

  // float3 bloom = base + (blend / (1.f + base));

  base = max(0.f, base);
  
  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);

  return base + addition;
  
}

float3 one_minus(float3 x)  {

  return 1 - x;
}

float3 vanillaSdrBlend(float3 base, float3 blend) {

  
  return 1.f - one_minus(base) * one_minus(blend);
}

float4 blendBloomSrgb(SamplerState samLinear_s, float4 v1) {

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
    float4 sdr = blendBloomSrgb(samLinear_s, v1);
    if (RENODX_TONE_MAP_TYPE == 0 || shader_injection.bloom == 0.f)  {
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

    hdr = hdrScreenBlend(hdr, blur1);
    hdr = hdrScreenBlend(hdr, blur2);
    
    float4 clampedUV1 = min(uv_clamp1_g, v1.xyxy);
    float3 blur3 = blurTexture3.SampleLevel(samLinear_s, clampedUV1.xy, 0).xyz;
    float3 blur4 = blurTexture4.SampleLevel(samLinear_s, clampedUV1.zw, 0).xyz;
    blur3 = renodx::color::srgb::DecodeSafe(blur3);
    blur4 = renodx::color::srgb::DecodeSafe(blur4);
    
    hdr = hdrScreenBlend(hdr, blur3);
    hdr = hdrScreenBlend(hdr, blur4);
    
    float2 clampedUV2 = min(uv_clamp2_g.xy, v1.xy);
    float3 blur5 = blurTexture5.SampleLevel(samLinear_s, clampedUV2, 0).xyz;
    blur5 = renodx::color::srgb::DecodeSafe(blur5);

    hdr = hdrScreenBlend(hdr, blur5);

    // Compute weights for N=5 levels (l=0..4 == b1..b5)
    // const int N = 5;
    // float w1 = weight_for_level(0, N);
    // float w2 = weight_for_level(1, N);
    // float w3 = weight_for_level(2, N);
    // float w4 = weight_for_level(3, N);
    // float w5 = weight_for_level(4, N);

    // // One weighted sum, then one screen-blend
    // float3 blended = (w1*blur1 + w2*blur2 + w3*blur3 + w4*blur4 + w5*blur5);
    // hdr = hdrScreenBlend(hdr, blended);

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