// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:39:32 2025
#include "shared.h"
cbuffer Constants : register(b0)
{

  struct
  {
    float4x3 InvTViewMatrix;
    float4x4 InvViewMatrix;
    float4 GlobalGBufferScale;
    float4 GlobalGBufferOffset;
    float4 GlobalPosDecodingParams;
    float4 GlobalFogColorAndHFogMaxOpacity;
    float4 ShadowParams;
    float4 NearPlaneDist_DetailMapSoftnessInteriorMap;
    float4 EngineTime_GameTime_ScreenScale_InvScreenScale;
    float4 InvSunDiffuseDirection;
    float4 DirLightColorAlphaOverdraw;
    float4 DirLightIlluminanceAndExposureAndInvExposure;
    float4 SunInvLightDirectionAndAmbientStrength;
    float4x4 ViewSpaceToShadowCascadeSpace[4];
    float4x4 ViewSpaceToTranslucentShadowCascadeSpace[4];
  } PerFrame : packoffset(c0);

}

SamplerState MainTextureSampler_s : register(s0);
Texture2D<float4> MainTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = PerFrame.EngineTime_GameTime_ScreenScale_InvScreenScale.zz * v1.xy;
  r0.xyzw = MainTexture.Sample(MainTextureSampler_s, r0.xy).xyzw;
  o0.xyzw = v2.xyzw * r0.xyzw;

  o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);
  return;
}