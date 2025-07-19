// ---- Created with 3Dmigoto v1.3.16 on Sat Jul 19 17:15:16 2025
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
  bool PhyreMaterialSwitches : packoffset(c43.y);
  float4x4 World : packoffset(c44);
  float GlobalTexcoordFactor : packoffset(c48);

  struct
  {
    float3 m_direction;
    float3 m_colorIntensity;
  } Light0 : packoffset(c49);

  float GameMaterialID : packoffset(c50.w) = {0};
  float4 GameMaterialDiffuse : packoffset(c51) = {1,1,1,1};
  float4 GameMaterialEmission : packoffset(c52) = {0,0,0,0};
  float GameMaterialMonotone : packoffset(c53) = {0};
  float4 GameMaterialTexcoord : packoffset(c54) = {0,0,1,1};
  float4 GameDitherParams : packoffset(c55) = {0,0,0,0};
  float4 UVaMUvColor : packoffset(c56) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c57) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c58) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c59) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c60) = {0,0,1,1};
  float AlphaThreshold : packoffset(c61) = {0.5};
  float3 ShadowColorShift : packoffset(c61.y) = {0.100000001,0.0199999996,0.0199999996};
  float3 RimLitColor : packoffset(c62) = {1,1,1};
  float RimLitIntensity : packoffset(c62.w) = {4};
  float RimLitPower : packoffset(c63) = {2};
  float RimLightClampFactor : packoffset(c63.y) = {2};
  float BloomIntensity : packoffset(c63.z) = {1};
  float4 PointLightParams : packoffset(c64) = {0,0,0,0};
  float4 PointLightColor : packoffset(c65) = {0,0,0,0};
}

SamplerState DiffuseMapSamplerSampler_s : register(s0);
Texture2D<float4> DiffuseMapSampler : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  float3 v5 : TEXCOORD4,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = DiffuseMapSampler.Sample(DiffuseMapSamplerSampler_s, v3.xy).xyzw;
  r1.x = r0.w * v1.w + -0.00400000019;
  r1.x = cmp(r1.x < 0);
  if (r1.x != 0) discard;
  r1.x = max(Light0.m_colorIntensity.x, Light0.m_colorIntensity.y);
  r1.y = max(0.00100000005, Light0.m_colorIntensity.z);
  r1.x = max(r1.x, r1.y);
  r1.xyz = Light0.m_colorIntensity.xyz / r1.xxx;
  r1.xyz = min(float3(1.5,1.5,1.5), r1.xyz);
  r2.xyz = min(float3(1,1,1), r1.xyz);
  r2.xyz = float3(1,1,1) + -r2.xyz;
  r2.xyz = ShadowColorShift.xyz * r2.xyz;
  r3.xyz = Light0.m_colorIntensity.xyz + Light0.m_colorIntensity.xyz;
  r3.xyz = max(float3(1,1,1), r3.xyz);
  r1.xyz = r2.xyz * r3.xyz + r1.xyz;
  r1.xyz = v1.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.w = v1.w * r0.w;
  r0.xyz = r0.xyz * GameMaterialDiffuse.xyz + GameMaterialEmission.xyz;
  r0.xyz = v2.xyz + r0.xyz;
  // r1.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = renodx::color::y::from::NTSC1953(r0.xyz);
  r1.xyz = r1.xxx * scene.MonotoneMul.xyz + scene.MonotoneAdd.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = GameMaterialMonotone * r1.xyz + r0.xyz;
  r0.xyz = scene.EyePosition.xyz + -v4.xyz;
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.x = dot(v5.xyz, v5.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = v5.xyz * r1.xxx;
  // r0.x = saturate(dot(r1.xyz, r0.xyz));
  r0.x = (dot(r1.xyz, r0.xyz));
  r0.x = 1 + -r0.x;
  // r0.x = log2(r0.x);
  // r0.x = RimLitPower * r0.x;
  // r0.x = exp2(r0.x);
  r0.x = renodx::math::SafePow(r0.x, RimLitPower);
  r0.x = -r0.x * RimLitIntensity + 1;
  r0.x = r0.w * r0.x;
  r0.x = GameMaterialDiffuse.w * r0.x;
  o0.w = r0.x;

  o0.w = max(o0.w, 0.f);
  return;
}