// ---- Created with 3Dmigoto v1.3.16 on Sun Sep 14 17:39:23 2025
#include "./common.hlsl"
cbuffer cb_local : register(b2)
{
  float3 mulColor_g : packoffset(c0);
  float alpha_g : packoffset(c0.w);
  float3 addColor_g : packoffset(c1);
  float intensity_g : packoffset(c1.w);
}

SamplerState samPoint_s : register(s0);
Texture2D<float4> colorTexture : register(t0);


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
  
  // note: this shader is also used in "memorized" scenes, not just menu

  r0.xyz = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyz;
  r0.w = calculateLuminanceSRGB(r0.rgb);
  r1.xyz = r0.www * mulColor_g.xyz + addColor_g.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = intensity_g * r1.xyz + r0.xyz;

  o0.xyz = srgbDecode(o0.xyz);

  // o0.rgb = renodx::tonemap::renodrt::NeutralSDR(o0.rgb);
  // o0.rgb = ToneMapMaxCLL(o0.rgb);
  float3 sdr = renodx::tonemap::uncharted2::BT709(o0.rgb);

  // o0.rgb = renodx::color::correct::Luminance(o0.rgb, sdr, 1.f);
  // o0.rgb = renodx::tonemap::dice::BT709(o0.rgb, 1.0f);
  o0.rgb = sdr;
  o0.rgb = srgbEncode(o0.rgb);

  o0.w = alpha_g;
  return;
}