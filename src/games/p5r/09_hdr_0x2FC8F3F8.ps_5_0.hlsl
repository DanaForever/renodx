#include "./common.hlsl"

cbuffer GFD_PSCONST_CORRECT : register(b12) {
 float3 colorBalance : packoffset(c0);
 float _reserve00 : packoffset(c0.w);
 float2 colorBlend : packoffset(c1);
}

cbuffer GFD_PSCONST_HDR : register(b11) {
 float middleGray : packoffset(c0.x);
 float adaptedLum : packoffset(c0.y);
 float bloomScale : packoffset(c0.z);
 float starScale : packoffset(c0.w);
}

SamplerState opaueSampler_s : register(s0);
SamplerState bloomSampler_s : register(s1);
Texture2D<float4> opaueTexture : register(t0);
Texture2D<float4> bloomTexture : register(t1);

// 3Dmigoto declarations
#define cmp -

void main(float4 v0 : SV_POSITION0, float2 v1 : TEXCOORD0, out float4 o0 : SV_TARGET0) {
  float4 r0, r1, r2;

  //r0.xyz = bloomTexture.Sample(bloomSampler_s, v1.xy).xyz;
  //r0.xyz = bloomScale * r0.xyz;
  r0.rgb = bloomTexture.Sample(bloomSampler_s, v1).rgb * bloomScale;
    
  //r1.xyz = opaueTexture.Sample(opaueSampler_s, v1.xy).xyz;
  r1.rgb = opaueTexture.Sample(opaueSampler_s, v1).rgb;
    
  //r1.xyz = r1.xyz;
  //r2.xyz = r1.xyz + r0.xyz;
  //r0.xyz = r1.xyz * r0.xyz;
  //r0.xyz = -r0.xyz;    
  //r0.xyz = r2.xyz + r0.xyz;
  r0.xyz = (r1.xyz + r0.xyz) - (r1.xyz * r0.xyz);
  r0.w = max(r0.x, max(r0.y, r0.z));  // max channel
  r2.x = 1 - r0.w;                    // 1-maxchannel
  float3 untonemapped = r0.rgb;
  // o0 = ToneMapPersona(r0);
  r0.rgb = SDRTonemap(untonemapped);
  // r0.rgb = untonemapped;
// 
  r0.xyz = colorBalance.xyz + r0.xyz;  // Add to tonemapped
  // r0.xyz = r0.xyz * r0.www; // scale up by max channel
  // r0.xyz = r0.xyz + r2.xxx; // add (1 )
  // r0.xyz = -r0.xyz;
  // r0.xyz = float3(1, 1, 1) + r0.xyz;
  r0.xyz = 1 - (r0.xyz * r0.w + r2.x);

  // r0.xyz = r0.xyz / colorBlend.x;
  // r0.xyz = -r0.xyz;
  // r0.xyz = float3(1, 1, 1) + r0.xyz;
  r0.xyz = 1 - (r0.xyz / colorBlend.x);

  // r0.xyz = r0.xyz / colorBlend.y;
  // r0.xyz = -r0.xyz;
  // r1.xyz = float3(1, 1, 1) + r0.xyz;
  r1.xyz = 1 - (r0.xyz / colorBlend.y);

  // r1.xyz = r1.xyz;
  r1.xyz = lerp(untonemapped, r1.xyz, injectedData.colorGradeLUTStrength);

  r0.xyz = r1.xyz;

  o0.rgb = r0.rgb;
  o0.w = 1.f;

  // o0.rgb = renodx::color::gamma::DecodeSafe(o0.rgb, 2.2f);

  // float3 color = o0.rgb;
  // // o0.rgb = ToneMap(o0.rgb);

  // color = renodx::color::bt709::clamp::BT2020(color);
  // color = LMS_ToneMap_Stockman(color, 1.f,
  //                              1.f);
  // // color = GamutCompress(color);
  // color = renodx::color::bt709::clamp::BT2020(color);
  // // color = renodx::draw::ToneMapPass(color, config);
  // float peak = injectedData.toneMapPeakNits / injectedData.toneMapGameNits;

  // float3 lum_color = renodx::tonemap::HermiteSplineLuminanceRolloff(color, peak);
  // float3 perch_color = renodx::tonemap::HermiteSplinePerChannelRolloff(color, peak);
// 
  // color = renodx::color::correct::Chrominance(lum_color, perch_color, 0.5f);
  // color = lum_color;

  // if (injectedData.toneMapGammaCorrection) {
  //   color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  // }

  // color *= injectedData.toneMapGameNits / injectedData.toneMapUINits;

  // if (injectedData.toneMapGammaCorrection) {
  //   color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  // }

  // o0.rgb = color;
  // o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  // o0.rgb = renodx::color::gamma::EncodeSafe(o0.rgb, 2.2f);

  return;
}