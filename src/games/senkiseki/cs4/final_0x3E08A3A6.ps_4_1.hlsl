// ---- Created with 3Dmigoto v1.3.16 on Fri Jun 06 22:21:56 2025
#include "../shared.h"
#include "./common.hlsl"
cbuffer _Globals : register(b0)
{

  struct
  {
    float3 EyePosition;
    float3 EyeDirection;
    float4x4 View;
    float4x4 Projection;
    float4x4 ViewProjection;
    float4x4 ViewInverse;
    float4x4 ProjectionInverse;
    float4x4 ViewProjectionPrev;
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
    float4 MiscParameters6;
    float3 MiscParameters7;
    float3 light2_colorIntensity;
    float4 light2_attenuation;
    uint4 DuranteSettings;
  } scene : packoffset(c0);

  float MaskEps : packoffset(c48);
  bool PhyreContextSwitches : packoffset(c48.y);
  float4 CommonParams : packoffset(c49) = {0.00052083336,0.00092592591,1.77777779,0};
  float4 FilterColor : packoffset(c50) = {1,1,1,1};
  float4 FadingColor : packoffset(c51) = {1,1,1,1};
  float4 _MonotoneMul : packoffset(c52) = {1,1,1,1};
  float4 _MonotoneAdd : packoffset(c53) = {0,0,0,0};
  float4 GlowIntensity : packoffset(c54) = {1,1,1,1};
  float4 GodrayParams : packoffset(c55) = {0,0,0,0};
  float4 GodrayParams2 : packoffset(c56) = {0,0,0,0};
  float4 GodrayColor : packoffset(c57) = {0,0,0,1};
  float4 SSAOParams : packoffset(c58) = {1,0,1,30};
  float4 SSRParams : packoffset(c59) = {5,0.300000012,15,1024};
  float4 ToneFactor : packoffset(c60) = {1,1,1,1};
  float4 UvScaleBias : packoffset(c61) = {1,1,0,0};
  float4 GaussianBlurParams : packoffset(c62) = {0,0,0,0};
  float4 DofParams : packoffset(c63) = {0,0,0,0};
  float4 GammaParameters : packoffset(c64) = {1,1,1,0};
  float4 NoiseParams : packoffset(c65) = {0,0,0,0};
  float4 WhirlPinchParams : packoffset(c66) = {0,0,0,0};
  float4 UVWarpParams : packoffset(c67) = {0,0,0,0};
  float4 MotionBlurParams : packoffset(c68) = {0,0,0,0};
  float GlobalTexcoordFactor : packoffset(c69);
}

SamplerState LinearClampSamplerState_s : register(s0);
Texture2D<float4> ColorBuffer : register(t0);
Texture2DMS<float> DepthBuffer : register(t1);
Texture2D<float4> GlareBuffer : register(t2);
Texture2D<float4> FocusBuffer : register(t3);
Texture2D<float4> FilterTexture : register(t4);


// 3Dmigoto declarations
#define cmp -

float3 CompositeColor(float3 depthInput, float3 colorInput, float3 focusInput, float2 v1, bool Bloom) {
  float4 r0, r1, r2, r3;
  r0.xyz = depthInput;

  // r1.xyz is the difference between a blurred (focus) and sharp (color) buffer.
  r1.xyz = focusInput;
  r2.xyz = colorInput;
  r1.xyz = -r2.xyz + r1.xyz;

  // If out of focus, more blurred (focus buffer)
  // If in focus, just sharp (color buffer)
  r0.yzw = r0.yyy * r1.xyz + r2.xyz;

  // Applies a per-channel scale (ToneFactor) to the color.
  r1.xyz = ToneFactor.xxx * r0.yzw;

  // Computes 1 - (color * scale) for later masking/blending.
  r0.yzw = -r0.yzw * ToneFactor.xxx + float3(1, 1, 1);

  // Additional Texture Sampling (for Filters/Bloom)
  r2.xy = v1.xy * float2(1, -1) + float2(0, 1);

  r3.xyz = GlareBuffer.SampleLevel(LinearClampSamplerState_s, r2.xy, 0).xyz;
  r3.xyz = postProcessBloomBuffer(r3.xyz);
  r2.xyzw = FilterTexture.SampleLevel(LinearClampSamplerState_s, r2.xy, 0).xyzw;

  r2.xyzw = FilterColor.xyzw * r2.xyzw;
  r2.xyz = r2.xyz * r2.www;

  r3.xyz = GlowIntensity.w * r3.xyz;
  if (!Bloom) {
    r3.xyz = 0.f;
  }

  // Multiply “main color” by Bloom
  // If glare is strong, this can significantly brighten or “glow up” highlights.
  r0.yzw = r3.xyz * r0.yzw + r1.xyz;

  // Compositing colors
  r1.xyz = float3(1, 1, 1) + -r0.yzw;
  r3.xyz = r2.xyz * r0.xxx;
  r2.xyz = r2.xyz * r0.xxx + r0.yzw;
  r0.xyz = r3.xyz  * r1.xyz + r0.yzw;
  r0.xyz = r0.xyz + -r2.xyz;
  float3 output = r0.xyz * float3(0.5, 0.5, 0.5) + r2.xyz;

  output = decodeColor(output);

  return output;
}



void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  float glowIntensity = GlowIntensity.w;

  DepthBuffer.GetDimensions(uiDest.x, uiDest.y, uiDest.z);
  r0.xy = uiDest.xy;
  r0.xy = (uint2)r0.xy;
  r0.xy = w1.xy * r0.xy + float2(0.5,0.5);
  r0.xy = (int2)r0.xy;
  r0.zw = float2(0,0);
  r0.x = DepthBuffer.Load(r0.xy, 0).x;
  r0.x = r0.x * scene.cameraFarMinusNear + -scene.cameraNearFar.y;
  r0.x = scene.cameraNearTimesFar / r0.x;
  r0.x = -r0.x / scene.cameraNearFar.y;
  r0.y = -DofParams.x + r0.x;
  r0.x = ToneFactor.y + r0.x;
  r0.x = min(1, r0.x);
  r0.y = saturate(DofParams.y * abs(r0.y));
  r0.y = r0.y * r0.y;
  r0.y = DofParams.z * r0.y;

  // r1.xyz is the difference between a blurred (focus) and sharp (color) buffer.
  r1.xyz = FocusBuffer.SampleLevel(LinearClampSamplerState_s, v1.xy, 0).xyz;
  r2.xyz = ColorBuffer.SampleLevel(LinearClampSamplerState_s, w1.xy, 0).xyz;
  r2.xyz = processColorBuffer(r2.xyz);

  float3 bloomOutput = CompositeColor(r0.xyz, r2.xyz, r1.xyz, v1, true);
  float3 noBloomOutput = CompositeColor(r0.xyz, r2.xyz, r1.xyz, v1, false);

  o0.rgb = scaleColor(noBloomOutput, bloomOutput);
  float3 scaledColor = o0.rgb;
  // o0.rgb

  o0.w = 1;
  o0.rgb = processAndToneMap(o0.rgb);
  

  return;
}