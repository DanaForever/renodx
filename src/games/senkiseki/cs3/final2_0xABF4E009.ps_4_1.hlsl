// ---- Created with 3Dmigoto v1.3.16 on Thu Jul 03 16:53:09 2025
#include "../cs4/common.hlsl"
#include "../shared.h"
cbuffer _Globals : register(b0)
{
  uint4 DuranteSettings : packoffset(c0);

  struct
  {
    float3 EyePosition;
    float4x4 View;
    float4x4 Projection;
    float4x4 ViewProjection;
    float4x4 ViewInverse;
    float4x4 ProjectionInverse;
    float2 cameraNearFar;
    float cameraNearTimesFar;
    float cameraFarMinusNear;
    float cameraFarMinusNearInv;
    float2 ViewportWidthHeight;
    float2 screenWidthHeightInv;
    float3 GlobalAmbientColor;
    float Time;
    float3 FakeRimLightDir;
    float3 FogColor;
    float4 FogRangeParameters;
    float3 MiscParameters1;
    float4 MiscParameters2;
    float3 MonotoneMul;
    float3 MonotoneAdd;
    float3 UserClipPlane2;
    float4 UserClipPlane;
    float4 MiscParameters3;
    float AdditionalShadowOffset;
    float AlphaTestDirection;
    float4 MiscParameters4;
    float3 MiscParameters5;
    float4 light1_attenuation;
    float3 light2_position;
    float3 light2_colorIntensity;
    float4 light2_attenuation;
  } scene : packoffset(c1);

  bool PhyreContextSwitches : packoffset(c43);
  float4 FilterColor : packoffset(c44) = {1,1,1,1};
  float4 FadingColor : packoffset(c45) = {1,1,1,1};
  float4 _MonotoneMul : packoffset(c46) = {1,1,1,1};
  float4 _MonotoneAdd : packoffset(c47) = {0,0,0,0};
  float4 GlowIntensity : packoffset(c48) = {1,1,1,1};
  float4 GodrayParams : packoffset(c49) = {0,0,0,0};
  float4 GodrayParams2 : packoffset(c50) = {0,0,0,0};
  float4 GodrayColor : packoffset(c51) = {0,0,0,1};
  float4 SSRParams : packoffset(c52) = {5,0.300000012,15,1024};
  float4 ToneFactor : packoffset(c53) = {1,1,1,1};
  float4 UvScaleBias : packoffset(c54) = {1,1,0,0};
  float4 GaussianBlurParams : packoffset(c55) = {0,0,0,0};
  float4 DofParams : packoffset(c56) = {0,0,0,0};
  float4 DofParams2 : packoffset(c57) = {0,0,0,0};
  float4 GammaParameters : packoffset(c58) = {1,1,1,0};
  float4 NoiseParams : packoffset(c59) = {0,0,0,0};
  float4 WhirlPinchParams : packoffset(c60) = {0,0,0,0};
  float4 UVWarpParams : packoffset(c61) = {0,0,0,0};
  float4 MotionBlurParams : packoffset(c62) = {0,0,0,0};
  float GlobalTexcoordFactor : packoffset(c63);
}

SamplerState LinearClampSamplerState_s : register(s0);
Texture2D<float4> ColorBuffer : register(t0);
Texture2D<float4> GlareBuffer : register(t1);
Texture2D<float4> FilterTexture : register(t2);

float3 CompositeColor(float4 color, float4 toneColor, float4 glareColor, float4 filterColor, bool Bloom) {
  float4 r0, r1, r2, r3;
  r0 = color;
  r1 = toneColor;
  r2 = filterColor;
  r3 = glareColor;

  r3.xyz = GlowIntensity.www * r3.xyz;
  if (!Bloom) {
    r3.xyz = 0.f;
  }
  r0.xyz = r3.xyz * r0.xyz + r1.xyz;
  r1.xyz = float3(1, 1, 1) + -r0.xyz;
  r3.xyz = r2.xyz * r2.www;
  r2.xyz = r2.xyz * r2.www + r0.xyz;
  r0.xyz = r3.xyz * r1.xyz + r0.xyz;
  r0.xyz = r0.xyz + -r2.xyz;
  float3 output = r0.xyz * float3(0.5, 0.5, 0.5) + r2.xyz;

  output = decodeColor(output);

  return output;
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy * UvScaleBias.xy + UvScaleBias.zw;
  r0.xyz = ColorBuffer.SampleLevel(LinearClampSamplerState_s, r0.xy, 0).xyz;
  r1.xyz = ToneFactor.xxx * r0.xyz;
  r0.xyz = -r0.xyz * ToneFactor.xxx + float3(1,1,1);
  r2.xy = v1.xy * float2(1,-1) + float2(0,1);
  r3.xyz = GlareBuffer.SampleLevel(LinearClampSamplerState_s, r2.xy, 0).xyz;
  r2.xyzw = FilterTexture.SampleLevel(LinearClampSamplerState_s, r2.xy, 0).xyzw;
  r2.xyzw = FilterColor.xyzw * r2.xyzw;

  float3 bloomOutput = CompositeColor(r0, r1, r3, r2, true);
  float3 noBloomOutput = CompositeColor(r0, r1, r3, r2, false);

  o0.rgb = scaleColor(noBloomOutput, bloomOutput);
  o0.w = 1;

  // ToneMapPass here?
  o0.rgb = ToneMap(o0.rgb, noBloomOutput);  // for some reason ToneMapPass causes Artifact
  o0.rgb = expandColorGamut(o0.rgb);
  o0.rgb = renodx::draw::RenderIntermediatePass(o0.rgb);
  o0.w = 1;
  // r3.xyz = GlowIntensity.www * r3.xyz;
  // r0.xyz = r3.xyz * r0.xyz + r1.xyz;
  // r1.xyz = float3(1,1,1) + -r0.xyz;
  // r3.xyz = r2.xyz * r2.www;
  // r2.xyz = r2.xyz * r2.www + r0.xyz;
  // r0.xyz = r3.xyz * r1.xyz + r0.xyz;
  // r0.xyz = r0.xyz + -r2.xyz;
  // o0.xyz = r0.xyz * float3(0.5,0.5,0.5) + r2.xyz;
  // o0.w = 1;
  return;
}