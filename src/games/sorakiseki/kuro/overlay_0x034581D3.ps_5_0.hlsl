// ---- Created with 3Dmigoto v1.3.16 on Mon Sep 01 23:53:15 2025
#include "../common.hlsl"
cbuffer cb_local : register(b2)
{
  float alpha : packoffset(c0);
}

SamplerState samPoint_s : register(s0);
SamplerState samLinear_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture : register(t1);


float3 hdrScreenBlend(float3 base, float3 blend) {

  blend = max(0.f, blend);
  blend *= shader_injection.bloom_strength; 

  // float3 bloom = base + (blend / (1.f + base));

  base = max(0.f, base);
  
  float3 addition = renodx::math::SafeDivision(blend, (1.f + base), 0.f);

  return base + addition;
  
}

float3 overlay(float3 base, float3 blend) {
    // Per-channel overlay
    // float3 m = step(base, 0.5f);                     // 1 where base <= 0.5
    // float3 low  = base * blend;                   // if base <= 0.5
    // // float3 high = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend); // else
    // float3 high = hdrScreenBlend(base, blend);
    // return m * low + (1.0 - m) * high;                  // branchless select
    return hdrScreenBlend(base, blend);
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

  r0.xyz = blurTexture.SampleLevel(samLinear_s, v1.xy, 0).xyz;

  float3 blur = r0.rgb;
  r1.xyz = float3(1,1,1) + -r0.xyz; // 1 - color
  r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;

  float3 color = r2.rgb;
  blur = max(blur, 0.f);
  color = max(color, 0.f);

  // r3.xyz = float3(1,1,1) + -r2.xyz;  // 1 - blur
  // r3.xyz = r3.xyz + r3.xyz; // 2 * (1 - blur)
  // r1.xyz = -r3.xyz * r1.xyz + float3(1,1,1); // 2 * (1 - blur) * (1 - color) + 1 
  // r0.xyz = r2.xyz * r0.xyz; // blur * color
  // r0.xyz = r0.xyz * float3(2,2,2) + -r1.xyz; 2 * (blur * color) - (2 * (1 - blur) * (1 - color) + 1 )
  // r3.xyz = cmp(float3(0.5,0.5,0.5) >= r2.xyz);
  // r3.xyz = r3.xyz ? float3(1,1,1) : 0;
  // r0.xyz = r3.xyz * r0.xyz + r1.xyz;
  // r0.xyz = r0.xyz + -r2.xyz;
  // o0.xyz = alpha * r0.xyz + r2.xyz;
  color = srgbDecode(color);
  blur = srgbDecode(blur);
  // o0.rgb = hdrScreenBlend(color, blur * alpha);
  float3 target = overlay(color, blur);
  o0.rgb = lerp(srgbEncode(color), srgbEncode(target), alpha);
  // o0.rgb = color;

  // o0.rgb = srgbEncode(o0.rgb);
  // o0.rgb = r2.rgb;
  o0.w = r2.w;
  return;
}