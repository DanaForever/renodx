// ---- Created with 3Dmigoto v1.3.16 on Tue Sep 02 00:19:34 2025
#include "common.hlsl"

SamplerState samLinear_s : register(s0);
SamplerState samPoint_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture1 : register(t1);
Texture2D<float4> blurTexture2 : register(t2);
Texture2D<float4> blurTexture3 : register(t3);
Texture2D<float4> blurTexture4 : register(t4);
Texture2D<float4> blurTexture5 : register(t5);

float3 blend(float3 base, float3 blur)  {

  // base = srgbDecode(base);
  // blur = srgbDecode(blur);
  
  // float3 bloom_texture = blur;
  // float mid_gray_bloomed = (0.18 + renodx::color::y::from::BT709(bloom_texture)) / 0.18;
  
  // float scene_luminance = renodx::color::y::from::BT709(base) * mid_gray_bloomed;
  // float bloom_blend = saturate(smoothstep(0.f, 0.18f, scene_luminance));

  // float3 bloom_scaled = lerp(0.f, bloom_texture, bloom_blend);
  // bloom_texture = lerp(bloom_texture, bloom_scaled, 0.5f);

  // blur = bloom_texture;

  // float3 blend_blur = base + (blur / (1.f + base));

  // return (srgbEncode(blend_blur));

  return base + blur;
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = blurTexture1.SampleLevel(samLinear_s, v1.zw, 0).xyz;
  r1.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  // r0.xyz = r1.xyz + r0.xyz;
  r0.rgb = blend(r1.rgb, r0.rgb);
  o0.w = r1.w;
  r1.xyz = blurTexture2.SampleLevel(samLinear_s, v1.zw, 0).xyz;
  // r0.xyz = r1.xyz + r0.xyz;
  r0.rgb = blend(r0.rgb, r1.rgb);
  r1.xyz = blurTexture3.SampleLevel(samLinear_s, v1.zw, 0).xyz;
  // r0.xyz = r1.xyz + r0.xyz;
  r0.rgb = blend(r0.rgb, r1.rgb);
  r1.xyz = blurTexture4.SampleLevel(samLinear_s, v1.zw, 0).xyz;
  // r0.xyz = r1.xyz + r0.xyz;
  r0.rgb = blend(r0.rgb, r1.rgb);
  r1.xyz = blurTexture5.SampleLevel(samLinear_s, v1.zw, 0).xyz;
  // o0.xyz = r1.xyz + r0.xyz;
  o0.rgb = blend(r0.rgb, r1.rgb);

  // o0.rgb /= 6;
  return;
}