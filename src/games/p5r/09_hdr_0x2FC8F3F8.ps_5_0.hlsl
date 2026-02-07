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
  untonemapped = r0.rgb;

  // // r0.xyz = r0.xyz / colorBlend.x;
  // // r0.xyz = -r0.xyz;
  // // r0.xyz = float3(1, 1, 1) + r0.xyz;
  // r0.xyz = 1 - (r0.xyz / colorBlend.x);

  // // r0.xyz = r0.xyz / colorBlend.y;
  // // r0.xyz = -r0.xyz;
  // // r1.xyz = float3(1, 1, 1) + r0.xyz;
  // r1.xyz = 1 - (r0.xyz / colorBlend.y);

  float3 x = r0.xyz;  // gamma

  float3 y = 1.0 - (x / colorBlend.x);
  y = 1.0 - (y / colorBlend.y);

  r1.rgb = restoreBlackLevelSRGB(x, y);

  // r1.xyz = r1.xyz;
  r1.xyz = lerp(untonemapped, r1.xyz, injectedData.colorGradeLUTStrength);

  r0.xyz = r1.xyz;

  o0.rgb = r0.rgb;

  o0.rgb = UserColorGradeSRGB(o0.rgb);
  o0.w = 1.f;

  return;
}