#include "./common.hlsl"

cbuffer GFD_PSCONST_CORRECT : register(b12) {
  float3 colorBalance : packoffset(c0);  // 0,0,0
  float _reserve00 : packoffset(c0.w);   // 0
  float2 colorBlend : packoffset(c1);    // 0.8, 0.9
}

cbuffer GFD_PSCONST_HDR : register(b11) {
  float middleGray : packoffset(c0.x);  // 0.06
  float adaptedLum : packoffset(c0.y);  // 0.0003
  float bloomScale : packoffset(c0.z);  // 1.15
  float starScale : packoffset(c0.w);   // 0
}

SamplerState opaueSampler_s : register(s0);
SamplerState bloomSampler_s : register(s1);
SamplerState brightSampler_s : register(s2);
Texture2D<float4> opaueTexture : register(t0);
Texture2D<float4> bloomTexture : register(t1);
Texture2D<float4> brightTexture : register(t2);


// 3Dmigoto declarations
#define cmp -

void main(float4 v0 : SV_POSITION0, float2 v1 : TEXCOORD0, out float4 o0 : SV_TARGET0) {
  float4 r0, r1, r2, r3;

  r0.rgb = bloomTexture.Sample(bloomSampler_s, v1).rgb;

  r1.rgb = brightTexture.Sample(brightSampler_s, v1).rgb; 
  r2.rgb = opaueTexture.Sample(opaueSampler_s, v1).rgb;

  // r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);
  // r1.rgb = renodx::color::srgb::DecodeSafe(r1.rgb);
  // r2.rgb = renodx::color::srgb::DecodeSafe(r2.rgb);

  r1.rgb *= bloomScale * injectedData.fxBloom;
  r0.rgb *= bloomScale * injectedData.fxBloom;

  r0.xyz = (r1.xyz + r0.xyz) - (r1.xyz * r0.xyz);
  

  r1.rgb = r2.rgb - r1.rgb;

  // r1.rgb = max(0, r1.rgb);  // Clamp

  r0.rgb = (r1.xyz + r0.xyz) - (r1.xyz + r0.xyz);

  r0.xyz = max(r2.xyz, r0.xyz);  // Only apply if lighter than input
  

  r0.w = max(r0.x, max(r0.y, r0.z));  // max channel
  float maxChannel = r0.w;

  r2.x = 1 - r0.w;  // 1-maxchannel

  r0.xyz = 1 - r0.xyz;  //
  
  r0.xyz = r0.xyz - r2.x;  // remove maxchannel
  r0.rgb = renodx::math::SafeDivision(r0.rgb, r0.www, 0.f);

  r0.xyz = colorBalance.xyz + r0.xyz;  // Add to tonemapped

  r0.xyz = 1 - (r0.xyz * r0.w + r2.x);  // Readd max channel
  
  // r0.xyz = 1 - (r0.xyz / colorBlend.x);

  // r1.xyz = 1 - (r0.xyz / colorBlend.y);

  // float3 x = saturate(r0.xyz);  // gamma
  float3 untonemapped = r0.xyz;
  float3 x = r0.xyz;  // gamma

  float3 y = 1.0 - (x / colorBlend.x);
  y = 1.0 - (y / colorBlend.y);

  r1.rgb = restoreBlackLevelSRGB(untonemapped, y);
  // r1.rgb = y;
  // r1.rgb = r0.rgb;
  // r1.xyz = lerp(untonemapped, r1.xyz, injectedData.colorGradeLUTStrength);
  // float l = renodx::color::y::from::BT709(renodx::color::srgb::DecodeSafe(untonemapped));
  // r1.rgb = lerp(y, x, )

  r0.xyz = r1.xyz;

  o0.rgb = r0.rgb;
  o0.a = 1.f;

  o0.rgb = UserColorGradeSRGB(o0.rgb);

  return;
}
