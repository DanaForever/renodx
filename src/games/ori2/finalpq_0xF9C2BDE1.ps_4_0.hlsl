#include "./DICE.hlsl"
#include "./hueHelper.hlsl"
#include "./shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Thu Aug 15 21:16:03 2024

cbuffer HDRDisplayMappingCB : register(b0) {
  float _NitsForPaperWhite : packoffset(c0);
  uint _DisplayCurve : packoffset(c0.y);
  float _SoftShoulderStart : packoffset(c0.z);
  float _MaxBrightnessOfTV : packoffset(c0.w);
  float _MaxBrightnessOfHDRScene : packoffset(c1);
  float _ColorGamutExpansion : packoffset(c1.y);
}

SamplerState _Sampler0_s : register(s0);
Texture2D<float4> _MainTex : register(t0);

float4 ori_bt2020(float4 r0)  {

  float4 r1, r2;

  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r0.w = -2 + r0.w;
  r0.w = saturate(0.125 * r0.w);
  r1.x = dot(float3(0.710796118, 0.247670293, 0.0415336005), r0.xyz);
  r1.y = dot(float3(0.0434204005, 0.943510771, 0.0130687999), r0.xyz);
  r1.z = dot(float3(-0.00108149997, 0.0272474997, 0.973834097), r0.xyz);
  r1.xyz = r1.xyz * r0.www;
  r0.w = 1 + -r0.w;
  r2.x = dot(float3(0.627403975, 0.329281986, 0.0433136001), r0.xyz);
  r2.y = dot(float3(0.0457456, 0.941776991, 0.0124771995), r0.xyz);
  r2.z = dot(float3(-0.00121054996, 0.0176040996, 0.983606994), r0.xyz);
  r1.xyz = r0.www * r2.xyz + r1.xyz;
  r1.xyz = _ColorGamutExpansion * r1.xyz;
  r0.w = 1 + -_ColorGamutExpansion;
  r2.x = dot(float3(0.627403975, 0.329281986, 0.0433136001), r0.xyz);
  r2.y = dot(float3(0.0690969974, 0.919539988, 0.0113612004), r0.xyz);
  r2.z = dot(float3(0.0163915996, 0.088013202, 0.895595014), r0.xyz);
  r0.xyz = r0.www * r2.xyz + r1.xyz;

  return r0;
}


float3 GammaCorrectHuePreserving(float3 incorrect_color, float gamma = 2.2f) {
  float3 ch = renodx::color::correct::GammaSafe(incorrect_color, false, gamma);

  // return ch;
  const float y_in = renodx::color::y::from::BT709(incorrect_color);
  const float y_out = max(0, renodx::color::correct::Gamma(y_in, false, gamma));

  float3 lum = incorrect_color * (y_in > 0 ? y_out / y_in : 0.f);

  // use chrominance from channel gamma correction and apply hue shifting from per channel tonemap
  // float3 result = renodx::color::correct::ChrominanceICtCp(lum, ch);
  float3 result = renodx::color::correct::Chrominance(lum, ch);

  return result;
}

// 3Dmigoto declarations
#define cmp -

void main(
    float4 v0: SV_POSITION0,
    float2 v1: TEXCOORD0,
    out float4 o0: SV_TARGET0) {
  float4 r0, r1, r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = _MainTex.Sample(_Sampler0_s, v1.xy).xyzw;
  o0.w = r0.w;

  // 
  

  if (injectedData.toneMapType == 0) {

    r0.xyz = sign(r0.xyz) * pow(abs(r0.xyz), 2.2f);  // linearize
    // bt2020 conversion + gamut expansion
    r0.w = max(r0.x, r0.y);
    r0.w = max(r0.w, r0.z);
    r0.w = -2 + r0.w;
    r0.w = saturate(0.125 * r0.w);
    r1.x = dot(float3(0.710796118, 0.247670293, 0.0415336005), r0.xyz);
    r1.y = dot(float3(0.0434204005, 0.943510771, 0.0130687999), r0.xyz);
    r1.z = dot(float3(-0.00108149997, 0.0272474997, 0.973834097), r0.xyz);
    r1.xyz = r1.xyz * r0.www;
    r0.w = 1 + -r0.w;
    r2.x = dot(float3(0.627403975, 0.329281986, 0.0433136001), r0.xyz);
    r2.y = dot(float3(0.0457456, 0.941776991, 0.0124771995), r0.xyz);
    r2.z = dot(float3(-0.00121054996, 0.0176040996, 0.983606994), r0.xyz);
    r1.xyz = r0.www * r2.xyz + r1.xyz;
    r1.xyz = _ColorGamutExpansion * r1.xyz;
    r0.w = 1 + -_ColorGamutExpansion;
    r2.x = dot(float3(0.627403975, 0.329281986, 0.0433136001), r0.xyz);
    r2.y = dot(float3(0.0690969974, 0.919539988, 0.0113612004), r0.xyz);
    r2.z = dot(float3(0.0163915996, 0.088013202, 0.895595014), r0.xyz);
    r0.xyz = r0.www * r2.xyz + r1.xyz;

    // paper white + pq encoding
    r0.w = 9.99999975e-005 * _NitsForPaperWhite;
    r0.xyz = r0.xyz * r0.www;
    r0.xyz = pow(abs(r0.xyz), 0.1593017578125f);
    r1.xyz = r0.xyz * float3(18.8515625, 18.8515625, 18.8515625) + float3(0.8359375, 0.8359375, 0.8359375);
    r0.xyz = r0.xyz * float3(18.6875, 18.6875, 18.6875) + float3(1, 1, 1);
    r0.xyz = r1.xyz / r0.xyz;
    r0.xyz = pow(r0.xyz, 78.84375f);
  } else {
    r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);

    r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.2);

    if (injectedData.toneMapType >= 2.f) {
      r0.xyz = Hue(r0.xyz, injectedData.toneMapHueCorrection);
      // Declare DICE parameters
      DICESettings config = DefaultDICESettings();
      config.Type = 3;
      config.ShoulderStart = 0.3333f;
      const float dicePaperWhite = injectedData.toneMapGameNits / renodx::color::srgb::REFERENCE_WHITE;
      const float dicePeakWhite = injectedData.toneMapPeakNits / renodx::color::srgb::REFERENCE_WHITE;

      // multiply paper white in for tonemapping and out for output
      r0.xyz = DICETonemap(r0.xyz * dicePaperWhite, dicePeakWhite, config) / dicePaperWhite;
      // r0.rgb = renodx::draw::ToneMapPass(r0.rgb);
      // float frostbitePeak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
      // r0.rgb = renodx::tonemap::frostbite::BT709(r0.rgb, frostbitePeak); 
    }

    
    // r0.xyz = renodx::color::bt2020::from::BT709(r0.xyz);
    r0 = ori_bt2020(r0);

    r0.xyz = renodx::color::pq::EncodeSafe(r0.xyz, injectedData.toneMapGameNits);
  }
  o0.xyz = r0.xyz;
  return;
}
