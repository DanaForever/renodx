// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 20:11:30 2025
#include "common.hlsl"
#include "shared.h"
cbuffer CB0 : register(b0)
{
  float4 fparam : packoffset(c0);
}

cbuffer CB2 : register(b2)
{
  float4 fparam3 : packoffset(c0);
}

SamplerState tex_samp_s : register(s0);
SamplerState gradtex_samp_s : register(s1);
SamplerState darktex_samp_s : register(s2);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> gradtex_tex : register(t1);
Texture2D<float4> darktex_tex : register(t2);

// 3Dmigoto declarations
#define cmp -

float3 compositeColor(float4 r0, float4 r1, float2 v1, float4 v2, bool hdr = true) {
  float4 r2, r3, r4, r5, r6, r7, r8;

  if (!hdr) {
    r1.rgb = renodx::color::srgb::DecodeSafe(r1.rgb);
    r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);

    r1.rgb = renodx::tonemap::neutwo::MaxChannel(r1.rgb);
    r0.rgb = renodx::tonemap::neutwo::MaxChannel(r0.rgb);
    // r1.rgb = renodx::tonemap::uncharted2::BT709(r1.rgb);
    // r0.rgb = renodx::tonemap::uncharted2::BT709(r0.rgb);

    r1.rgb = renodx::color::srgb::EncodeSafe(r1.rgb);
    r0.rgb = renodx::color::srgb::EncodeSafe(r0.rgb);
  }

  r2.xyz = r1.xyz + r0.xyz;
  r0.xyz = -r0.xyz * r1.xyz + r2.xyz;
  r1.xyz = v2.xyz * r0.xyz;
  r2.xyz = r1.xyz * r1.xyz;
  r2.xyz = r2.xyz + r2.xyz;

  if (!hdr) {
    r3.xyz = r1.xyz * float3(4, 4, 4) + -r2.xyz;
    r3.xyz = float3(-1, -1, -1) + r3.xyz;
    r4.xyz = cmp(float3(0.5, 0.5, 0.5) < r1.xyz);
    r2.xyz = r4.xyz ? r3.xyz : r2.xyz;
  }

  r0.xyz = -r0.xyz * v2.xyz + r2.xyz;

  r0.xyz = fparam.xxx * r0.xyz + r1.xyz;
  r0.w = cmp(0 < fparam.y);
  if (r0.w != 0) {
    r1.xyzw = darktex_tex.Sample(darktex_samp_s, v1.xy).xyzw;
    r0.w = fparam.y * r1.w;
    r1.xyz = r1.xyz + -r0.xyz;
    r0.xyz = r0.www * r1.xyz + r0.xyz;
  }
  r0.w = cmp(0 < fparam3.w);
  r1.xy = float2(-0.5, -0.5) + v1.xy;
  r1.xy = fparam3.ww * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.x = max(r1.x, r1.y);
  r1.yzw = fparam3.xyz + -r0.xyz;
  r1.xyz = r1.xxx * r1.yzw + r0.xyz;
  float3 output = r0.www ? r1.xyz : r0.xyz;

  return output;
}



void main(
  float4 v0 : TEXCOORD0,
  float2 v1 : TEXCOORD1,
  float4 v2 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex_tex.Sample(tex_samp_s, v0.xy).xyz;
  tex_tex.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r1.xy = fDest.xy;
  r1.xy = v0.xy * r1.xy;
  r1.xy = (int2)r1.xy;
  r1.zw = float2(0,0);
  r2.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r3.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r4.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r5.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r6.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r7.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r8.xyz = tex_tex.Load(r1.xyw, int3(0, 0, 0)).xyz;
  r1.xyz = tex_tex.Load(r1.xyz, int3(0, 0, 0)).xyz;
  r0.w = cmp(fparam.w != 0.000000);
  r2.xyz = r2.xyz * float3(0.25,0.25,0.25) + r3.xyz;
  r2.xyz = r4.xyz * float3(0.25,0.25,0.25) + r2.xyz;
  r2.xyz = r2.xyz + r5.xyz;
  r2.xyz = r0.xyz * float3(2,2,2) + r2.xyz;
  r2.xyz = r2.xyz + r6.xyz;
  r2.xyz = r7.xyz * float3(0.25,0.25,0.25) + r2.xyz;
  r2.xyz = r2.xyz + r8.xyz;
  r1.xyz = r1.xyz * float3(0.25,0.25,0.25) + r2.xyz;
  r1.xyz = r1.xyz * float3(0.142857149,0.142857149,0.142857149) + -r0.xyz;
  r1.xyz = -fparam.www * r1.xyz + r0.xyz;
  r0.xyz = r0.www ? r1.xyz : r0.xyz;
  r1.xyz = gradtex_tex.Sample(gradtex_samp_s, v0.zw).xyz;
  // r2.xyz = r1.xyz + r0.xyz;
  // r0.xyz = -r0.xyz * r1.xyz + r2.xyz;
  // r1.xyz = v2.xyz * r0.xyz;
  // r2.xyz = r1.xyz * r1.xyz;
  // r2.xyz = r2.xyz + r2.xyz;
  // r3.xyz = r1.xyz * float3(4,4,4) + -r2.xyz;
  // r3.xyz = float3(-1,-1,-1) + r3.xyz;
  // r4.xyz = cmp(float3(0.5,0.5,0.5) < r1.xyz);
  // r2.xyz = r4.xyz ? r3.xyz : r2.xyz;
  // r0.xyz = -r0.xyz * v2.xyz + r2.xyz;
  // r0.xyz = fparam.xxx * r0.xyz + r1.xyz;
  // r0.w = cmp(0 < fparam.y);
  // if (r0.w != 0) {
  //   r1.xyzw = darktex_tex.Sample(darktex_samp_s, v1.xy).xyzw;
  //   r0.w = fparam.y * r1.w;
  //   r1.xyz = r1.xyz + -r0.xyz;
  //   r0.xyz = r0.www * r1.xyz + r0.xyz;
  // }
  // r0.w = cmp(0 < fparam3.w);
  // r1.xy = float2(-0.5,-0.5) + v1.xy;
  // r1.xy = fparam3.ww * r1.xy;
  // r1.xy = r1.xy * r1.xy;
  // r1.x = max(r1.x, r1.y);
  // r1.yzw = fparam3.xyz + -r0.xyz;
  // r1.xyz = r1.xxx * r1.yzw + r0.xyz;
  // o0.xyz = r0.www ? r1.xyz : r0.xyz;

  float3 sdr = compositeColor(r0, r1, v1, v2, false);
  float3 hdr = compositeColor(r0, r1, v1, v2, true);
  o0.w = 1;

  // ToneMapPass here?
  if (RENODX_TONE_MAP_TYPE > 0.f) {
    sdr = renodx::color::srgb::DecodeSafe(sdr);
    hdr = renodx::color::srgb::DecodeSafe(hdr);
    // float3 neutral_sdr = renodx::tonemap::renodrt::NeutralSDR(hdr);
    // sdr = saturate(sdr);

    // hdr = renodx::tonemap::UpgradeToneMap(hdr, neutral_sdr, sdr, shader_injection.color_grade_strength);
    // o0.rgb = HueAndChrominanceOKLab(hdr, sdr, sdr, shader_injection.color_grade_strength, shader_injection.color_grade_strength);
    o0.rgb = CorrectPurityMB(hdr, sdr, shader_injection.color_grade_strength);

    o0.rgb = ToneMap(o0.rgb);
  } else {
    o0.xyz = sdr;
    o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
    // o0.rgb = saturate(o0.rgb);
  }

  float3 color = o0.rgb;
  if (shader_injection.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (shader_injection.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  }

  color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;

  [branch]
  if (shader_injection.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else if (shader_injection.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  }

  color = renodx::color::srgb::EncodeSafe(color);
  o0.rgb = color;
  o0.w = 1;
  
  return;
}