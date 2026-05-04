// ---- Created with 3Dmigoto v1.3.16 on Sun Sep 14 17:39:23 2025
#include "../common.hlsl"
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

  float3 sdr = renodx::tonemap::neutwo::BT709(srgbDecode(r0.rgb));

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    r0.xyz = saturate(r0.xyz);
    r0.w = dot(r0.xyz, float3(0.298999995, 0.587000012, 0.114));
  } else {

    r0.w = calculateLuminanceSRGB(r0.rgb);
  }
  r1.xyz = r0.www * mulColor_g.xyz + addColor_g.xyz;
  // r1.xyz = r1.xyz + -r0.xyz;
  // o0.xyz = intensity_g * r1.xyz + r0.xyz;

  o0.rgb = lerp(r0.xyz, r1.xyz, intensity_g);

  sdr = lerp(sdr, r1.rgb, intensity_g);

  // Lazy scene tonemap.
  //
  // Output stays linear-light, sRGB-encoded with no display gamma applied so
  // the existing UI compositing path keeps working unchanged. final/finalkai
  // checks scene_already_tonemapped and skips its own ToneMapLMS this frame
  // (the addon flips that flag in interpolate's on_drawn callback).
  //
  // When godray runs after interpolate, godray will operate on a tonemapped
  // base — bloom math is slightly off in that path but acceptable.
  if (RENODX_TONE_MAP_TYPE > 0.f) {
    o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);

    o0.rgb = ToneMapLMSHueShift(o0.rgb);

    // float strength = saturate(shader_injection.bloom_hue_correction);

    // o0.rgb = lerp(o0.rgb, CorrectHueAndPurityMBFullStrength(o0.rgb, sdr), strength);
    o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  }

  o0.w = alpha_g;
  return;
}