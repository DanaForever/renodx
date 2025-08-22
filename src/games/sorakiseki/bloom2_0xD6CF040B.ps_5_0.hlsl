
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

  float y = renodx::color::y::from::BT709(base);
  float g = 1.0 / (1.0 + y);
  return base + blend * g;
  
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
    float y = renodx::color::y::from::BT709(gameScene.rgb);
    o0.w = gameScene.w; 
    
    float4 clampedUV0 = min(uv_clamp0_g, v1.xyxy);
    float3 blur1 = blurTexture1.SampleLevel(samLinear_s, clampedUV0.xy, 0).xyz;
    float3 blur2 = blurTexture2.SampleLevel(samLinear_s, clampedUV0.zw, 0).xyz;

    hdr = hdrScreenBlend(hdr, blur1, 1.f);
    hdr = hdrScreenBlend(hdr, blur2, 1.f);
    
    float4 clampedUV1 = min(uv_clamp1_g, v1.xyxy);
    float3 blur3 = blurTexture3.SampleLevel(samLinear_s, clampedUV1.xy, 0).xyz;
    float3 blur4 = blurTexture4.SampleLevel(samLinear_s, clampedUV1.zw, 0).xyz;
    
    // hdr = vanillaSdrBlend(hdr, blur3);
    // hdr = vanillaSdrBlend(hdr, blur4);
    hdr = hdrScreenBlend(hdr, blur3, 1.f);
    hdr = hdrScreenBlend(hdr, blur4, 1.f);
    
    float2 clampedUV2 = min(uv_clamp2_g.xy, v1.xy);
    float3 blur5 = blurTexture5.SampleLevel(samLinear_s, clampedUV2, 0).xyz;
    hdr = hdrScreenBlend(hdr, blur5, 1.f);

    // const float3 Y = float3(0.2126, 0.7152, 0.0722);
    // float L1 = max(dot(blur1, Y), 0.0);
    // float L2 = max(dot(blur2, Y), 0.0);
    // float L3 = max(dot(blur3, Y), 0.0);
    // float L4 = max(dot(blur4, Y), 0.0);
    // float L5 = max(dot(blur5, Y), 0.0);

    // // Energy-based weights (sum to 1); falls back to geometric prior if all zero
    // float S = L1 + L2 + L3 + L4 + L5;
    // float w1, w2, w3, w4, w5;

    // if (S > 1e-6)
    // {
    //     w1 = L1 / S; w2 = L2 / S; w3 = L3 / S; w4 = L4 / S; w5 = L5 / S;
    // }
    // else
    // {
    //     // zero-energy fallback (still “no knobs”): 1,1/2,1/4,1/8,1/16 normalized
    //     float p1=1.0, p2=0.5, p3=0.25, p4=0.125, p5=0.0625;
    //     float P = p1+p2+p3+p4+p5;
    //     w1=p1/P; w2=p2/P; w3=p3/P; w4=p4/P; w5=p5/P;
    // }

    // float3 bloom = w1*blur1 + w2*blur2 + w3*blur3 + w4*blur4 + w5*blur5;

    // // float3 bloom = blur1
    // //              + 0.5   * blur2
    // //              + 0.25  * blur3
    // //              + 0.125 * blur4
    // //              + 0.0625* blur5;

    // // hdr = gameScene.rgb;
    // float ys = max(renodx::color::y::from::BT709(gameScene.rgb), 1e-6);
    // float yb = renodx::color::y::from::BT709(bloom);

    // // Detail-preserving gain: scale scene by (1 + bloom/scene)
    // float gain = 1.0 + (yb / ys);
    // hdr = sdr.rgb * gain;
    // hdr = scaleByLuminance(sdr.rgb, hdr, 9999.f);
    float3 sat = saturate(sdr.rgb);
    hdr = renodx::color::correct::Chrominance(hdr, sat, (1 - saturate(y)));
    hdr = renodx::color::correct::Hue(hdr, sat, shader_injection.bloom_hue_correction);
    // hdr = renodx::color::bt709::clamp::BT2020(hdr);
    // hdr = RestoreHue(hdr, sat, shader_injection.bloom_hue_correction);
    o0.rgb = hdr;
    // o0.rgb = scaleByPerceptualLuminance(gameScene.rgb, hdr, 9999.f);
    // o0.rgb = renodx::color::correct::Hue(hdr, sat, shader_injection.bloom_hue_correction, RENODX_TONE_MAP_HUE_PROCESSOR);
    // o0.rgb = sdr.rgb;
    // o0.w = sdr.w;
    // o0.rgb = gameScene.rgb;
    // if (RENODX_TONE_MAP_TYPE == 0)
    // o0.rgb = sdr.rgb;

    
    // 
    // o0.rgb = RestoreHue(o0.rgb, sdrVanillaBlended, RENODX_TONE_MAP_HUE_CORRECTION);	
}