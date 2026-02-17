// ---- Created with 3Dmigoto v1.3.16 on Sun May 25 17:37:38 2025
#include "shared.h"
#include "common.hlsl"


cbuffer CB0 : register(b0)
{
  float4 fparam : packoffset(c0);
  float4 fparam2 : packoffset(c1);
  float4 fparam3 : packoffset(c2);
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
  float4 r2, r3, r4;

  if (!hdr) {
    r1.rgb = saturate(r1.rgb);
    r0.rgb = saturate(r0.rgb);
  }

  r2.xyz = r1.xyz + r0.xyz;
  r0.xyz = -r0.xyz * r1.xyz + r2.xyz;

  float3 v = v2.xyz;
  r1.xyz = v * r0.xyz; // x

  r2.xyz = r1.xyz * r1.xyz;
  r2.xyz = r2.xyz + r2.xyz; // 2 * x^2

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
  r1.xy = r1.xy * r1.xy;
  r1.x = max(r1.x, r1.y);
  r1.y = calculateLuminanceSRGB(r0.rgb);
  r1.z = fparam3.w * 0.349999994;
  r2.xyz = r1.yyy + -r0.xyz;
  r1.yzw = r1.zzz * r2.xyz + r0.xyz;
  r2.xyz = fparam3.xyz + -r1.yzw;
  r1.xyz = r1.xxx * r2.xyz + r1.yzw;
  float3 output = r0.www ? r1.xyz : r0.xyz;

  return output;

}


void main(
  float4 v0 : TEXCOORD0,
  float2 v1 : TEXCOORD1,
  float4 v2 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex_tex.Sample(tex_samp_s, v0.xy).xyz;
  r1.xyz = gradtex_tex.Sample(gradtex_samp_s, v0.zw).xyz;
  // r2.xyz = r1.xyz + r0.xyz;
  // r0.xyz = -r0.xyz * r1.xyz + r2.xyz;
  // r1.xyz = v2.xyz * r0.xyz;
  // r2.xyz = r1.xyz * r1.xyz;
  // r2.xyz = r2.xyz + r2.xyz;
  // r3.xyz = r1.xyz * float3(4, 4, 4) + -r2.xyz;
  // r3.xyz = float3(-1, -1, -1) + r3.xyz;
  // r4.xyz = cmp(float3(0.5, 0.5, 0.5) < r1.xyz);
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
  // r1.xy = float2(-0.5, -0.5) + v1.xy;
  // r1.xy = fparam3.ww * r1.xy;
  // r1.xy = r1.xy * r1.xy;
  // r1.xy = r1.xy * r1.xy;
  // r1.x = max(r1.x, r1.y);
  // r1.y = dot(r0.xyz, float3(0.298911989, 0.586610973, 0.114478));
  // r1.z = fparam3.w * 0.349999994;
  // r2.xyz = r1.yyy + -r0.xyz;
  // r1.yzw = r1.zzz * r2.xyz + r0.xyz;
  // r2.xyz = fparam3.xyz + -r1.yzw;
  // r1.xyz = r1.xxx * r2.xyz + r1.yzw;
  // o0.xyz = r0.www ? r1.xyz : r0.xyz;

  float3 sdr = compositeColor(r0, r1, v1, v2, false);
  float3 hdr = compositeColor(r0, r1, v1, v2, true);

  o0.w = 1;

  // ToneMapPass here?
  if (RENODX_TONE_MAP_TYPE > 0.f) {
    sdr = renodx::color::srgb::DecodeSafe(sdr);
    hdr = renodx::color::srgb::DecodeSafe(hdr);

    // hdr = renodx::tonemap::UpgradeToneMap(hdr, neutral_sdr, sdr);
    // hdr = HueAndChrominanceOKLab(hdr, sdr, sdr, 0.5f, 0.5f);
    hdr = CorrectHueAndPurity(hdr, sdr, shader_injection.tone_map_hue_correction);
    hdr = LMS_Vibrancy(hdr, shader_injection.tone_map_saturation, shader_injection.tone_map_contrast);
    hdr = CastleDechroma_CVVDPStyle_NakaRushton(hdr, 50.f);

    o0.rgb = hdr;
    o0.rgb = expandGamut(o0.rgb, shader_injection.inverse_tonemap_extra_hdr_saturation);

  } else {
    o0.rgb = sdr;
    o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
  }

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    o0.rgb = GammaCorrectHuePreserving(o0.rgb, 2.2f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    o0.rgb = GammaCorrectHuePreserving(o0.rgb, 2.4f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.4f);
  } else if (RENODX_GAMMA_CORRECTION == 3.f) {
    o0.rgb = GammaCorrectHuePreserving(o0.rgb, 2.3f);
    // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.3f);
  }

  float3 color = o0.rgb;
  renodx::draw::Config config = renodx::draw::BuildConfig();
  [branch]
  if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT709D93(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT601NTSCU(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::ARIBTRB9(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  }

  // Gamut Compression
  color = renodx::color::bt2020::from::BT709(color);
  float grayscale = renodx::color::convert::Luminance(color, renodx::color::convert::COLOR_SPACE_BT2020);
  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
  float encode_gamma = MID_GRAY_GAMMA;
  float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
  float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
  float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
  color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);

  color = max(0.f, color);
  color = renodx::color::bt709::from::BT2020(color);

  // srgb encoding to match the UI decoding (later)
  color = renodx::color::srgb::EncodeSafe(color);
  o0.rgb = color;
  o0.w = 1;

  return;
}