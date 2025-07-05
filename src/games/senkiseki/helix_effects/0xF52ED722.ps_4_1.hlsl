// ---- Created with 3Dmigoto v1.3.16 on Wed Jul 02 00:30:54 2025
#include "../shared.h"
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

  struct
  {
    float3 m_direction;
    float3 m_colorIntensity;
  } Light0 : packoffset(c62);

  float GameMaterialID : packoffset(c63.w) = {0};
  float4 GameMaterialDiffuse : packoffset(c64) = {1,1,1,1};
  float4 GameMaterialEmission : packoffset(c65) = {0,0,0,0};
  float GameMaterialMonotone : packoffset(c66) = {0};
  float4 GameMaterialTexcoord : packoffset(c67) = {0,0,1,1};
  float4 UVaMUvColor : packoffset(c68) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c69) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c70) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c71) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c72) = {0,0,1,1};
  float AlphaThreshold : packoffset(c73) = {0.5};
  float3 RimLitColor : packoffset(c73.y) = {1,1,1};
  float RimLitIntensity : packoffset(c74) = {4};
  float RimLitPower : packoffset(c74.y) = {2};
  float RimLightClampFactor : packoffset(c74.z) = {2};
  float BloomIntensity : packoffset(c74.w) = {0.699999988};
  float4 GameEdgeParameters : packoffset(c75) = {1,1,1,0.00300000003};
  float MaskEps : packoffset(c76);
  float4 PointLightParams : packoffset(c77) = {0,2,1,1};
  float4 PointLightColor : packoffset(c78) = {1,0,0,0};
}

SamplerState LinearClampSamplerState_s : register(s0);
SamplerState DiffuseMapSamplerSampler_s : register(s1);
SamplerState DiffuseMap2SamplerSampler_s : register(s2);
Texture2D<float4> DiffuseMapSampler : register(t0);
Texture2D<float4> DiffuseMap2Sampler : register(t1);
Texture2D<float4> RefractionTexture : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float2 v3 : TEXCOORD0,
  float2 w3 : TEXCOORD2,
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
  r1.xyz = scene.EyePosition.xyz + -v4.xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r1.www;
  r1.w = dot(v5.xyz, v5.xyz);
  r1.w = rsqrt(r1.w);
  r2.xyz = v5.xyz * r1.www;
  r1.w = dot(-r1.xyz, r2.xyz);
  r1.w = r1.w + r1.w;
  r3.xyz = r2.xyz * -r1.www + -r1.xyz;
  r1.x = saturate(dot(r2.xyz, r1.xyz));
  r1.x = 1 + -r1.x;
  r1.x = log2(r1.x);
  r2.x = dot(r3.xyz, scene.View._m00_m10_m20);
  r2.y = dot(r3.xyz, scene.View._m01_m11_m21);
  r1.yz = v0.xy / scene.ViewportWidthHeight.xy;
  r2.zw = v0.ww * r1.yz;
  r2.xy = r2.xy * scene.AlphaTestDirection + r2.zw;
  r1.yz = r1.yz * v0.ww + -r2.xy;
  r1.yz = scene.AdditionalShadowOffset * r1.yz + r2.xy;
  r1.yz = r1.yz / v0.ww;
  r1.yzw = RefractionTexture.Sample(LinearClampSamplerState_s, r1.yz).xyz;
  r0.w = v1.w * r0.w;
  r2.xyzw = DiffuseMap2Sampler.Sample(DiffuseMap2SamplerSampler_s, w3.xy).xyzw;
  r2.xyzw = UVaMUvColor.xyzw * r2.xyzw;
  r0.xyz = r0.xyz * r2.xyz + -r1.yzw;
  r0.w = r2.w * r0.w;
  r2.x = RimLitPower * r1.x;
  r1.x = PointLightColor.x * r1.x;
  r1.x = exp2(r1.x);
  r1.x = -1 + r1.x;
  r1.x = PointLightColor.y * r1.x + 1;
  r2.x = exp2(r2.x);
  r2.x = -r2.x * RimLitIntensity + 1;
  r2.w = r2.x * r0.w;
  r0.w = PointLightParams.w * r2.w;
  r0.xyz = r0.www * r0.xyz + r1.yzw;
  r0.w = max(Light0.m_colorIntensity.x, Light0.m_colorIntensity.y);
  r1.y = max(0.00100000005, Light0.m_colorIntensity.z);
  r0.w = max(r1.y, r0.w);
  r1.yzw = Light0.m_colorIntensity.xyz / r0.www;
  r1.yzw = min(float3(1.5,1.5,1.5), r1.yzw);
  r1.yzw = max(scene.GlobalAmbientColor.xyz, r1.yzw);
  r1.yzw = v1.xyz * r1.yzw;
  r3.xyz = r1.yzw * r0.xyz;
  r0.xyz = -r0.xyz * r1.yzw + r0.xyz;
  r0.w = 1 + -PointLightParams.w;
  r0.w = scene.MiscParameters5.z * r0.w;
  r2.xyz = r0.www * r0.xyz + r3.xyz;
  r0.xyzw = GameMaterialDiffuse.xyzw * r2.xyzw;
  r0.xyz = GameMaterialEmission.xyz * r1.xxx + r0.xyz;
  o0.w = r0.w;
  // r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r0.w = renodx::color::y::from::BT709(r0.xyz);
  r1.xyz = r0.www * scene.MonotoneMul.xyz + scene.MonotoneAdd.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = GameMaterialMonotone * r1.xyz + r0.xyz;

  o0 = max(o0, 0.f);
  return;
}