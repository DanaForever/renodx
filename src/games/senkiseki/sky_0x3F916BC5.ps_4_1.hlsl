// ---- Created with 3Dmigoto v1.3.16 on Fri Jun 06 17:20:47 2025
#include "shared.h"
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

  bool PhyreContextSwitches : packoffset(c48);
  bool PhyreMaterialSwitches : packoffset(c48.y);
  float4x4 World : packoffset(c49);
  float4x4 WorldViewProjection : packoffset(c53);
  float4x4 WorldViewProjectionPrev : packoffset(c57);
  float GlobalTexcoordFactor : packoffset(c61);
  float GameMaterialID : packoffset(c61.y) = {0};
  float4 GameMaterialDiffuse : packoffset(c62) = {1,1,1,1};
  float4 GameMaterialEmission : packoffset(c63) = {0,0,0,0};
  float GameMaterialMonotone : packoffset(c64) = {0};
  float4 GameMaterialTexcoord : packoffset(c65) = {0,0,1,1};
  float4 GameDitherParams : packoffset(c66) = {0,0,0,0};
  float4 UVaMUvColor : packoffset(c67) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c68) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c69) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c70) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c71) = {0,0,1,1};
  float BloomIntensity : packoffset(c72) = {1};
  float MaskEps : packoffset(c72.y);
  float4 PointLightParams : packoffset(c73) = {0,2,1,1};
  float4 PointLightColor : packoffset(c74) = {1,0,0,0};
}

SamplerState DiffuseMapSamplerSampler_s : register(s0);
SamplerState DiffuseMap2SamplerSampler_s : register(s1);
Texture2D<float4> DiffuseMapSampler : register(t0);
Texture2D<float4> DiffuseMap2Sampler : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float2 v3 : TEXCOORD0,
  float2 w3 : TEXCOORD2,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD10,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1,
  out float4 o2 : SV_TARGET2)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = DiffuseMap2Sampler.Sample(DiffuseMap2SamplerSampler_s, w3.xy).xyzw;
  r0.w = UVaMUvColor.w * r0.w;
  r0.w = v1.w * r0.w;
  r1.xyz = DiffuseMapSampler.Sample(DiffuseMapSamplerSampler_s, v3.xy).xyz;
  r0.xyz = r0.xyz * UVaMUvColor.xyz + -r1.xyz;
  r0.xyz = r0.www * r0.xyz + r1.xyz;
  r1.xyz = max(float3(1,1,1), scene.GlobalAmbientColor.xyz);
  r1.xyz = min(float3(1.5,1.5,1.5), r1.xyz);
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r1.xyz = scene.EyePosition.xyz + -v4.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  // r0.w = saturate(dot(r2.xyz, r1.xyz));
  r0.w = (dot(r2.xyz, r1.xyz));
  o1.xyz = r2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.w = 1 + -r0.w;
  // r0.w = log2(r0.w);
  // r0.w = PointLightColor.x * r0.w;
  // r0.w = exp2(r0.w);
  r0.w = renodx::math::SafePow(r0.w, PointLightColor.x);
  r0.w = -1 + r0.w;
  r0.w = PointLightColor.y * r0.w + 1;
  r1.xyz = GameMaterialEmission.xyz * r0.www;
  r0.xyz = r0.xyz * GameMaterialDiffuse.xyz + r1.xyz;
  // r0.w = dot(r0.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.w = renodx::color::y::from::NTSC1953(r0.xyz);
  r1.xyz = r0.www * scene.MonotoneMul.xyz + scene.MonotoneAdd.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  r0.xyz = GameMaterialMonotone * r1.xyz + r0.xyz;
  r1.xyz = BloomIntensity * r0.xyz;
  o0.xyz = r0.xyz;
  // r0.x = dot(r1.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.x = renodx::color::y::from::NTSC1953(r1.xyz);
  r0.x = -scene.MiscParameters2.z + r0.x;
  r0.x = max(0, r0.x);
  r0.x = 0.5 * r0.x;
  r0.x = min(1, r0.x);
  o0.w = PointLightParams.z * r0.x;
  o1.w = 0.466666698 + MaskEps;
  r0.x = v6.z / v6.w;
  r0.y = 256 * r0.x;
  r1.x = trunc(r0.y);
  r0.x = r0.x * 256 + -r1.x;
  r0.y = 256 * r0.x;
  r1.y = trunc(r0.y);
  r1.z = r0.x * 256 + -r1.y;
  o2.xyz = float3(0.00390625,0.00390625,1) * r1.xyz;
  // float value = v6.z / v6.w;
  // o2.xyz = value;
  o2.w = 0.00784313772 + MaskEps;
  return;
}