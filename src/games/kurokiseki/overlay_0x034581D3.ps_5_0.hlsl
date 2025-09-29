// ---- Created with 3Dmigoto v1.3.16 on Mon Sep 01 23:53:15 2025
#include "./common.hlsl"

float3 LogMap(float3 c) { return log(1.0 + c); }
float3 LogMapInv(float3 l) { return exp(l) - 1.0; }

cbuffer cb_local : register(b2)
{
  float alpha : packoffset(c0);
}

SamplerState samPoint_s : register(s0);
SamplerState samLinear_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture : register(t1);


float3 addBloom(float3 base, float3 blend) {
  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);

  return base + addition;
}

float3 hdrScreenBlend(float3 base, float3 blend, float scale = 0.f) {
  base = srgbDecode(base);
  blend = srgbDecode(blend);

  base = max(0.f, base);
  blend = max(0.f, blend);

  // if (shader_injection.bloom != 2.f)
  blend *= shader_injection.bloom_strength;
  // blend *= 2.f;

  float3 bloom_texture = blend;

  float mid_gray_bloomed = (0.18 + renodx::color::y::from::BT709(bloom_texture)) / 0.18;

  float scene_luminance = renodx::color::y::from::BT709(base) * mid_gray_bloomed;
  float bloom_blend = saturate(smoothstep(0.f, 0.18f, scene_luminance));

  float3 bloom_scaled = lerp(float3(0.f, 0.f, 0.f), bloom_texture, bloom_blend);  // = bloom_blend
  bloom_texture = lerp(bloom_texture, bloom_scaled, 0.5f);

  blend = bloom_texture;

  blend = addBloom(base, blend);

  blend = srgbEncode(blend);

  return blend;
}

float3 UpgradeToneMap(
    float3 color_untonemapped,
    float3 color_tonemapped,
    float3 color_tonemapped_graded,
    float post_process_strength = 1.f,
    float auto_correction = 0.f) {
  float ratio = 1.f;


  float y_untonemapped = renodx::color::y::from::BT709(color_untonemapped);
  float y_tonemapped = renodx::color::y::from::BT709(color_tonemapped);
  float y_tonemapped_graded = renodx::color::y::from::BT709(color_tonemapped_graded);

  if (y_untonemapped < y_tonemapped) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    ratio = renodx::math::SafeDivision(y_untonemapped, y_tonemapped, 1.f);
  } else {
    float y_delta = y_untonemapped - y_tonemapped;
    y_delta = max(0, y_delta);  // Cleans up NaN
    const float y_new = y_tonemapped_graded + y_delta;

    const bool y_valid = (y_tonemapped_graded > 0);  // Cleans up NaN and ignore black
    ratio = y_valid ? (y_new / y_tonemapped_graded) : 0;
    // ratio = 1.f;
    // ratio = renodx::math::SafeDivision(y_untonemapped, y_tonemapped_graded, 1.f);
  }
  float auto_correct_ratio = lerp(1.f, ratio, saturate(y_untonemapped));
  ratio = lerp(ratio, auto_correct_ratio, auto_correction);

  float3 color_scaled = color_tonemapped_graded * ratio;

  // return color_tonemapped_graded;
  // return color_scaled;
  // Match hue
  color_scaled = renodx::color::correct::HueICtCp(color_scaled, color_tonemapped_graded);
  return lerp(color_untonemapped, color_scaled, post_process_strength);
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  static const float EPS = 0.01;

  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = blurTexture.SampleLevel(samLinear_s, v1.xy, 0).xyz;

  float3 B = r0.rgb;

  r1.xyz = float3(1,1,1) + -r0.xyz; // 1 - blur
  r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  float3 C = r2.rgb;

  // r3.xyz = float3(1,1,1) + -r2.xyz;  // 1 - color
  // r3.xyz = r3.xyz + r3.xyz; // 2 * (1 - color)
  // r1.xyz = -r3.xyz * r1.xyz + float3(1,1,1); // 2 * (1 - blur) * (1 - color) + 1 
  // r0.xyz = r2.xyz * r0.xyz; // blur * color
  // r0.xyz = r0.xyz * float3(2,2,2) + -r1.xyz; // 2 * (blur * color) - (2 * (1 - blur) * (1 - color) + 1 )
  // r3.xyz = cmp(float3(0.5,0.5,0.5) >= r2.xyz);
  // r3.xyz = r3.xyz ? float3(1,1,1) : 0;
  float3 Dark  = 2.0 * C * B;
  float3 Light = 1.0 - 2.0 * (1.0 - C) * (1.0 - saturate(B));
  float3 oldLight = Light;

  // per-channel mask: 1 when C <= 0.5, else 0
  float3 M = step(C, 0.5f);

  // overlay result (per channel)
  float3 Overlay = lerp(Light, Dark, M);
  float3 sdr = Overlay;
  if (shader_injection.bloom == 1.f) {
    Overlay = hdrScreenBlend(C, B);
  }

  [branch]
  if (shader_injection.bloom == 1.f)  {
    
    float3 hdr = Overlay;

    sdr = lerp(C, sdr, alpha);
    hdr = lerp(C, hdr, alpha);

    sdr = srgbDecode(sdr);
    hdr = srgbDecode(hdr);
    // sat = srgbDecode(sat);

    sdr = max(0.f, sdr);
    hdr = expandGamut(hdr, shader_injection.inverse_tonemap_extra_hdr_saturation);
    hdr = UpgradeToneMap(hdr, renodx::tonemap::renodrt::NeutralSDR(hdr), sdr, shader_injection.bloom_hue_correction);

    o0.rgb = srgbEncode(hdr);

  } else {
    // final: add delta scaled by alpha
    float3 Out = C + alpha * (Overlay - C);
    o0.rgb = Out;
  }

  o0.w = r2.w;

  o0.rgb = processAndToneMap(o0.rgb, true);

  return;
}