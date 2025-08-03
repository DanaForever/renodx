// ---- Created with 3Dmigoto v1.3.16 on Wed Jul 02 06:41:19 2025
#include "../cs4/common.hlsl"
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


  struct
  {
    float4x4 m_split0Transform;
    float4x4 m_split1Transform;
    float4 m_splitDistances;
  } LightShadow0 : packoffset(c64);

  float GameMaterialID : packoffset(c73) = {0};
  float4 GameMaterialDiffuse : packoffset(c74) = {1,1,1,1};
  float4 GameMaterialEmission : packoffset(c75) = {0,0,0,0};
  float GameMaterialMonotone : packoffset(c76) = {0};
  float4 GameMaterialTexcoord : packoffset(c77) = {0,0,1,1};
  float4 GameDitherParams : packoffset(c78) = {0,0,0,0};
  float4 UVaMUvColor : packoffset(c79) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c80) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c81) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c82) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c83) = {0,0,1,1};
  float Shininess : packoffset(c84) = {0.5};
  float SpecularPower : packoffset(c84.y) = {50};
  float2 ProjectionScale : packoffset(c84.z) = {1,1};
  float BloomIntensity : packoffset(c85) = {1};
  float MaskEps : packoffset(c85.y);
  float4 PointLightParams : packoffset(c86) = {0,2,1,1};
  float4 PointLightColor : packoffset(c87) = {1,0,0,0};
}

SamplerState LinearWrapSamplerState_s : register(s0);
SamplerState PointWrapSamplerState_s : register(s1);
SamplerState PointClampSamplerState_s : register(s2);
SamplerState DiffuseMapSamplerSampler_s : register(s4);
SamplerState NormalMapSamplerSampler_s : register(s5);
SamplerState SpecularMapSamplerSampler_s : register(s6);
SamplerState DiffuseMap2SamplerSampler_s : register(s7);
SamplerState SpecularMap2SamplerSampler_s : register(s8);
SamplerState NormalMap2SamplerSampler_s : register(s9);
SamplerComparisonState LinearClampCmpSamplerState_s : register(s3);
Texture2D<float4> DitherNoiseTexture : register(t0);
Texture2D<float4> LowResDepthTexture : register(t1);
Texture2D<float4> LightShadowMap0 : register(t2);
Texture2D<float4> DiffuseMapSampler : register(t3);
Texture2D<float4> NormalMapSampler : register(t4);
Texture2D<float4> SpecularMapSampler : register(t5);
Texture2D<float4> DiffuseMap2Sampler : register(t6);
Texture2D<float4> SpecularMap2Sampler : register(t7);
Texture2D<float4> NormalMap2Sampler : register(t8);
Texture2D<float4> ProjectionMapSampler : register(t9);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float2 v3 : TEXCOORD0,
  float2 w3 : TEXCOORD2,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float4 v7 : TEXCOORD6,
  float4 v8 : TEXCOORD9,
  float4 v9 : TEXCOORD10,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1,
  out float4 o2 : SV_TARGET2)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(0.25,0.25) * v0.xy;
  r0.x = DitherNoiseTexture.SampleLevel(PointWrapSamplerState_s, r0.xy, 0).x;
  r0.x = v8.y + -r0.x;
  r0.y = cmp(0 < v8.z);
  r0.z = cmp(v8.z < 0);
  r0.y = (int)-r0.y + (int)r0.z;
  r0.y = cmp((int)r0.y < 0);
  r0.x = r0.y ? -r0.x : r0.x;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.xyz = DiffuseMapSampler.Sample(DiffuseMapSamplerSampler_s, v3.xy).xyz;
  r1.xyzw = DiffuseMap2Sampler.Sample(DiffuseMap2SamplerSampler_s, w3.xy).xyzw;
  r0.w = UVaMUvColor.w * r1.w;
  r0.w = v1.w * r0.w;
  r1.xyz = r1.xyz * UVaMUvColor.xyz + -r0.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r1.x = cmp(LightShadow0.m_splitDistances.y >= v4.w);
  if (r1.x != 0) {
    r1.xyz = Light0.m_direction.xyz * float3(0.0500000007,0.0500000007,0.0500000007) + v4.xyz;
    r1.xyz = v6.xyz * float3(0.0500000007,0.0500000007,0.0500000007) + r1.xyz;
    r2.x = cmp(v4.w < LightShadow0.m_splitDistances.x);
    if (r2.x != 0) {
      r1.w = 1;
      r2.x = dot(r1.xyzw, LightShadow0.m_split0Transform._m00_m10_m20_m30);
      r2.y = dot(r1.xyzw, LightShadow0.m_split0Transform._m01_m11_m21_m31);
      r2.z = dot(r1.xyzw, LightShadow0.m_split0Transform._m02_m12_m22_m32);
      r2.w = 25 / LightShadow0.m_splitDistances.y;
      r3.x = (int)scene.DuranteSettings.x & 16;
      if (r3.x != 0) {
        r3.xy = float2(0.000937499979,0.00187499996) * r2.ww;
        r3.z = -6 + r2.z;
        r3.xy = r3.xy * r3.zz;
        r3.xy = r3.xy / r2.zz;
        r3.z = dot(v0.xy, float2(0.0671105608,0.00583714992));
        r3.z = frac(r3.z);
        r3.z = 52.9829178 * r3.z;
        r3.z = frac(r3.z);
        r3.z = 6.28318548 * r3.z;
        r4.xy = float2(0,0);
        r3.w = 0;
        while (true) {
          r4.z = cmp((int)r3.w >= 16);
          if (r4.z != 0) break;
          r4.z = (int)r3.w;
          r4.w = 0.5 + r4.z;
          r4.w = sqrt(r4.w);
          r4.w = 0.25 * r4.w;
          r4.z = r4.z * 2.4000001 + r3.z;
          sincos(r4.z, r5.x, r6.x);
          r6.x = r6.x * r4.w;
          r6.y = r5.x * r4.w;
          r4.zw = r6.xy * r3.xy + r2.xy;
          r4.z = LightShadowMap0.SampleLevel(PointClampSamplerState_s, r4.zw, 0).x;
          r4.w = cmp(r4.z < r2.z);
          r5.y = r4.y + r4.z;
          r5.x = 1 + r4.x;
          r4.xy = r4.ww ? r5.xy : r4.xy;
          r3.w = (int)r3.w + 1;
        }
        r3.x = cmp(r4.x >= 1);
        if (r3.x != 0) {
          r3.xy = float2(0.000624999986,0.00124999997) * r2.ww;
          r3.w = r4.y / r4.x;
          r3.w = -r3.w + r2.z;
          r3.w = min(0.0700000003, r3.w);
          r3.w = 60 * r3.w;
          r3.xy = r3.ww * r3.xy;
          LightShadowMap0.GetDimensions(0, fDest.x, fDest.y, fDest.z);
          r4.xy = fDest.xy;
          r4.xy = float2(0.5,0.5) / r4.xy;
          r3.xy = max(r4.xy, r3.xy);
          r3.w = 0;
          r4.x = 0;
          while (true) {
            r4.y = cmp((int)r4.x >= 16);
            if (r4.y != 0) break;
            r4.y = (int)r4.x;
            r4.z = 0.5 + r4.y;
            r4.z = sqrt(r4.z);
            r4.z = 0.25 * r4.z;
            r4.y = r4.y * 2.4000001 + r3.z;
            sincos(r4.y, r5.x, r6.x);
            r6.x = r6.x * r4.z;
            r6.y = r5.x * r4.z;
            r4.yz = r6.xy * r3.xy;
            r4.yz = r4.yz * float2(3,3) + r2.xy;
            r4.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.yz, r2.z).x;
            r3.w = r4.y + r3.w;
            r4.x = (int)r4.x + 1;
          }
          r3.x = 0.0625 * r3.w;
        } else {
          r3.x = 1;
        }
      } else {
        r3.y = (int)scene.DuranteSettings.x & 8;
        if (r3.y != 0) {
          r3.yz = float2(0.000375000003,0.000750000007) * r2.ww;
          r3.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
          r3.w = frac(r3.w);
          r3.w = 52.9829178 * r3.w;
          r3.w = frac(r3.w);
          r3.w = 6.28318548 * r3.w;
          r4.xy = float2(0,0);
          while (true) {
            r4.z = cmp((int)r4.y >= 16);
            if (r4.z != 0) break;
            r4.z = (int)r4.y;
            r4.w = 0.5 + r4.z;
            r4.w = sqrt(r4.w);
            r4.w = 0.25 * r4.w;
            r4.z = r4.z * 2.4000001 + r3.w;
            sincos(r4.z, r5.x, r6.x);
            r6.x = r6.x * r4.w;
            r6.y = r5.x * r4.w;
            r4.zw = r6.xy * r3.yz;
            r4.zw = r4.zw * float2(3,3) + r2.xy;
            r4.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.zw, r2.z).x;
            r4.x = r4.x + r4.z;
            r4.y = (int)r4.y + 1;
          }
          r3.x = 0.0625 * r4.x;
        } else {
          r3.y = dot(r1.xyzw, LightShadow0.m_split0Transform._m03_m13_m23_m33);
          r3.z = (int)scene.DuranteSettings.x & 4;
          if (r3.z != 0) {
            r3.zw = scene.MiscParameters4.xy * r3.yy;
            r4.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
            r5.xy = -r3.zw * r2.ww;
            r5.z = 0;
            r4.yzw = r5.xyz + r2.xyz;
            r4.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.yz, r4.w).x;
            r4.y = 0.0625 * r4.y;
            r4.x = r4.x * 0.5 + r4.y;
            r6.x = r3.z * r2.w;
            r6.y = -r3.w * r2.w;
            r6.z = 0;
            r4.yzw = r6.xyz + r2.xyz;
            r4.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.yz, r4.w).x;
            r4.x = r4.y * 0.0625 + r4.x;
            r7.x = -r3.z * r2.w;
            r7.y = r3.w * r2.w;
            r7.z = 0;
            r4.yzw = r7.xyz + r2.xyz;
            r4.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.yz, r4.w).x;
            r4.x = r4.y * 0.0625 + r4.x;
            r7.xy = r3.zw * r2.ww;
            r7.z = 0;
            r4.yzw = r7.xyz + r2.xyz;
            r3.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.yz, r4.w).x;
            r3.z = r3.z * 0.0625 + r4.x;
            r4.xyz = r5.zyz + r2.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r3.z = r3.w * 0.0625 + r3.z;
            r4.xyz = r5.xzz + r2.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r3.z = r3.w * 0.0625 + r3.z;
            r4.xyz = r6.xzz + r2.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r3.z = r3.w * 0.0625 + r3.z;
            r4.xyz = r7.zyz + r2.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r3.x = r3.w * 0.0625 + r3.z;
          } else {
            r3.z = (int)scene.DuranteSettings.x & 2;
            if (r3.z != 0) {
              r3.yz = scene.MiscParameters4.xy * r3.yy;
              r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
              r4.xy = -r3.yz * r2.ww;
              r4.z = 0;
              r4.xyz = r4.xyz + r2.xyz;
              r4.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r4.x = scene.MiscParameters5.y * r4.x;
              r3.w = r3.w * scene.MiscParameters5.x + r4.x;
              r4.x = r3.y * r2.w;
              r4.y = -r3.z * r2.w;
              r4.z = 0;
              r4.xyz = r4.xyz + r2.xyz;
              r4.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r3.w = r4.x * scene.MiscParameters5.y + r3.w;
              r4.x = -r3.y * r2.w;
              r4.y = r3.z * r2.w;
              r4.z = 0;
              r4.xyz = r4.xyz + r2.xyz;
              r4.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r3.w = r4.x * scene.MiscParameters5.y + r3.w;
              r4.xy = r3.yz * r2.ww;
              r4.z = 0;
              r4.xyz = r4.xyz + r2.xyz;
              r2.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r3.x = r2.w * scene.MiscParameters5.y + r3.w;
            } else {
              r3.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
            }
          }
        }
      }
    } else {
      r1.w = 1;
      r2.x = dot(r1.xyzw, LightShadow0.m_split1Transform._m00_m10_m20_m30);
      r2.y = dot(r1.xyzw, LightShadow0.m_split1Transform._m01_m11_m21_m31);
      r2.z = dot(r1.xyzw, LightShadow0.m_split1Transform._m02_m12_m22_m32);
      r2.w = 10 / LightShadow0.m_splitDistances.y;
      r3.y = (int)scene.DuranteSettings.x & 16;
      if (r3.y != 0) {
        r3.yz = float2(0.000937499979,0.00187499996) * r2.ww;
        r3.w = -6 + r2.z;
        r3.yz = r3.yz * r3.ww;
        r3.yz = r3.yz / r2.zz;
        r3.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
        r3.w = frac(r3.w);
        r3.w = 52.9829178 * r3.w;
        r3.w = frac(r3.w);
        r3.w = 6.28318548 * r3.w;
        r4.xyz = float3(0,0,0);
        while (true) {
          r4.w = cmp((int)r4.z >= 16);
          if (r4.w != 0) break;
          r4.w = (int)r4.z;
          r5.x = 0.5 + r4.w;
          r5.x = sqrt(r5.x);
          r5.x = 0.25 * r5.x;
          r4.w = r4.w * 2.4000001 + r3.w;
          sincos(r4.w, r6.x, r7.x);
          r7.x = r7.x * r5.x;
          r7.y = r6.x * r5.x;
          r5.xy = r7.xy * r3.yz + r2.xy;
          r4.w = LightShadowMap0.SampleLevel(PointClampSamplerState_s, r5.xy, 0).x;
          r5.x = cmp(r4.w < r2.z);
          r6.y = r4.y + r4.w;
          r6.x = 1 + r4.x;
          r4.xy = r5.xx ? r6.xy : r4.xy;
          r4.z = (int)r4.z + 1;
        }
        r3.y = cmp(r4.x >= 1);
        if (r3.y != 0) {
          r3.yz = float2(0.000624999986,0.00124999997) * r2.ww;
          r4.x = r4.y / r4.x;
          r4.x = -r4.x + r2.z;
          r4.x = min(0.0700000003, r4.x);
          r4.x = 60 * r4.x;
          r3.yz = r4.xx * r3.yz;
          LightShadowMap0.GetDimensions(0, fDest.x, fDest.y, fDest.z);
          r4.xy = fDest.xy;
          r4.xy = float2(0.5,0.5) / r4.xy;
          r3.yz = max(r4.xy, r3.yz);
          r4.xy = float2(0,0);
          while (true) {
            r4.z = cmp((int)r4.y >= 16);
            if (r4.z != 0) break;
            r4.z = (int)r4.y;
            r4.w = 0.5 + r4.z;
            r4.w = sqrt(r4.w);
            r4.w = 0.25 * r4.w;
            r4.z = r4.z * 2.4000001 + r3.w;
            sincos(r4.z, r5.x, r6.x);
            r6.x = r6.x * r4.w;
            r6.y = r5.x * r4.w;
            r4.zw = r6.xy * r3.yz;
            r4.zw = r4.zw * float2(3,3) + r2.xy;
            r4.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.zw, r2.z).x;
            r4.x = r4.x + r4.z;
            r4.y = (int)r4.y + 1;
          }
          r3.x = 0.0625 * r4.x;
        } else {
          r3.x = 1;
        }
      } else {
        r3.y = (int)scene.DuranteSettings.x & 8;
        if (r3.y != 0) {
          r3.yz = float2(0.000375000003,0.000750000007) * r2.ww;
          r3.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
          r3.w = frac(r3.w);
          r3.w = 52.9829178 * r3.w;
          r3.w = frac(r3.w);
          r3.w = 6.28318548 * r3.w;
          r4.xy = float2(0,0);
          while (true) {
            r4.z = cmp((int)r4.y >= 16);
            if (r4.z != 0) break;
            r4.z = (int)r4.y;
            r4.w = 0.5 + r4.z;
            r4.w = sqrt(r4.w);
            r4.w = 0.25 * r4.w;
            r4.z = r4.z * 2.4000001 + r3.w;
            sincos(r4.z, r5.x, r6.x);
            r6.x = r6.x * r4.w;
            r6.y = r5.x * r4.w;
            r4.zw = r6.xy * r3.yz;
            r4.zw = r4.zw * float2(3,3) + r2.xy;
            r4.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.zw, r2.z).x;
            r4.x = r4.x + r4.z;
            r4.y = (int)r4.y + 1;
          }
          r3.x = 0.0625 * r4.x;
        } else {
          r1.x = dot(r1.xyzw, LightShadow0.m_split1Transform._m03_m13_m23_m33);
          r1.y = (int)scene.DuranteSettings.x & 4;
          if (r1.y != 0) {
            r1.yz = scene.MiscParameters4.xy * r1.xx;
            r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
            r4.xy = -r1.yz * r2.ww;
            r4.z = 0;
            r3.yzw = r4.xyz + r2.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r3.y = 0.0625 * r3.y;
            r1.w = r1.w * 0.5 + r3.y;
            r5.x = r1.y * r2.w;
            r5.y = -r1.z * r2.w;
            r5.z = 0;
            r3.yzw = r5.xyz + r2.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.w = r3.y * 0.0625 + r1.w;
            r6.x = -r1.y * r2.w;
            r6.y = r1.z * r2.w;
            r6.z = 0;
            r3.yzw = r6.xyz + r2.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.w = r3.y * 0.0625 + r1.w;
            r7.xy = r1.yz * r2.ww;
            r7.z = 0;
            r3.yzw = r7.xyz + r2.xyz;
            r1.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.y = r1.y * 0.0625 + r1.w;
            r3.yzw = r4.zyz + r2.xyz;
            r1.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.y = r1.z * 0.0625 + r1.y;
            r3.yzw = r6.xzz + r2.xyz;
            r1.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.y = r1.z * 0.0625 + r1.y;
            r3.yzw = r5.xzz + r2.xyz;
            r1.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r1.y = r1.z * 0.0625 + r1.y;
            r3.yzw = r6.zyz + r2.xyz;
            r1.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r3.x = r1.z * 0.0625 + r1.y;
          } else {
            r1.y = (int)scene.DuranteSettings.x & 2;
            if (r1.y != 0) {
              r1.xy = scene.MiscParameters4.xy * r1.xx;
              r1.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
              r4.xy = -r1.xy * r2.ww;
              r4.z = 0;
              r3.yzw = r4.xyz + r2.xyz;
              r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
              r1.w = scene.MiscParameters5.y * r1.w;
              r1.z = r1.z * scene.MiscParameters5.x + r1.w;
              r4.x = r1.x * r2.w;
              r4.y = -r1.y * r2.w;
              r4.z = 0;
              r3.yzw = r4.xyz + r2.xyz;
              r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
              r1.z = r1.w * scene.MiscParameters5.y + r1.z;
              r4.x = -r1.x * r2.w;
              r4.y = r1.y * r2.w;
              r4.z = 0;
              r3.yzw = r4.xyz + r2.xyz;
              r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
              r1.z = r1.w * scene.MiscParameters5.y + r1.z;
              r4.xy = r1.xy * r2.ww;
              r4.z = 0;
              r1.xyw = r4.xyz + r2.xyz;
              r1.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r1.xy, r1.w).x;
              r3.x = r1.x * scene.MiscParameters5.y + r1.z;
            } else {
              r3.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r2.xy, r2.z).x;
            }
          }
        }
      }
    }
  } else {
    r3.x = 1;
  }
  r1.x = saturate(v4.w / LightShadow0.m_splitDistances.y);
  r1.y = r1.x * r1.x;
  r1.z = -scene.MiscParameters2.y + v4.y;
  r1.z = scene.MiscParameters2.x * abs(r1.z);
  r1.z = min(1, r1.z);
  r1.w = r1.z * r1.z;
  r1.z = r1.z * r1.w;
  r1.w = cmp(0 >= scene.MiscParameters2.x);
  r1.z = r1.w ? 0 : r1.z;
  r1.x = r1.x * r1.y + r1.z;
  r1.y = dot(v6.xyz, Light0.m_direction.xyz);
  r1.y = r1.y * 0.5 + 0.5;
  r1.z = 0.400000006 * scene.MiscParameters4.w;
  r1.w = max(0, -v6.y);
  r1.z = -r1.z * r1.w + 0.400000006;
  r1.w = cmp(r1.z < r1.y);
  r1.y = r1.y + -r1.z;
  r1.z = 1 + -r1.z;
  r1.y = r1.y / r1.z;
  r1.y = r1.w ? r1.y : 0;
  r1.y = 1 + -r1.y;
  r1.z = r1.y * r1.y;
  r1.x = r1.y * r1.z + r1.x;
  r1.x = min(1, r1.x);
  r1.x = r3.x + r1.x;
  r1.x = min(1, r1.x);
  r1.yz = ProjectionMapSampler.Sample(LinearWrapSamplerState_s, v5.xy).xw;
  r1.y = -r1.y * r1.z + 1;
  r1.x = min(r1.x, r1.y);
  r1.y = 1 + -r1.x;
  r1.z = 1 + -scene.MiscParameters2.w;
  r1.x = r1.y * r1.z + r1.x;
  r1.y = 1 + -r1.x;
  r1.z = 1 + -GameMaterialEmission.w;
  r1.x = r1.y * r1.z + r1.x;
  r1.y = SpecularMapSampler.Sample(SpecularMapSamplerSampler_s, v3.xy).x;
  r1.z = SpecularMap2Sampler.Sample(SpecularMap2SamplerSampler_s, w3.xy).x;
  r1.z = r1.z + -r1.y;
  r1.y = r0.w * r1.z + r1.y;
  r2.xyz = NormalMapSampler.Sample(NormalMapSamplerSampler_s, v3.xy).xyz;
  r2.xyz = r2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = dot(v7.xyz, v7.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = v7.xyz * r1.zzz;
  r1.z = dot(v6.xyz, v6.xyz);
  r1.z = rsqrt(r1.z);
  r4.xyz = v6.xyz * r1.zzz;
  r5.xyz = r4.zxy * r3.yzx;
  r5.xyz = r4.yzx * r3.zxy + -r5.xyz;
  r1.zw = cmp(v3.xy < float2(0,0));
  r1.zw = r1.zw ? float2(-1,-1) : float2(1,1);
  r1.z = r2.x * r1.z;
  r2.xyw = r5.xyz * r2.yyy;
  r2.xyw = r1.zzz * r3.xyz + r2.xyw;
  r2.xyz = r2.zzz * r4.xyz + r2.xyw;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = rsqrt(r1.z);
  r2.xyz = r2.xyz * r1.zzz;
  r6.xyz = NormalMap2Sampler.Sample(NormalMap2SamplerSampler_s, w3.xy).xyz;
  r6.xyz = r6.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.z = r6.x * r1.w;
  r5.xyz = r6.yyy * r5.xyz;
  r3.xyz = r1.zzz * r3.xyz + r5.xyz;
  r3.xyz = r6.zzz * r4.xyz + r3.xyz;
  r1.z = dot(r3.xyz, r3.xyz);
  r1.z = rsqrt(r1.z);
  r3.xyz = r3.xyz * r1.zzz + -r2.xyz;
  r2.xyz = r0.www * r3.xyz + r2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r3.xyz = scene.EyePosition.xyz + -v4.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r4.xyz = r3.xyz * r0.www;
  r1.z = saturate(dot(r2.xyz, r4.xyz));
  r1.y = Shininess * r1.y;
  r1.w = max(Light0.m_colorIntensity.x, Light0.m_colorIntensity.y);
  r2.w = max(0.00100000005, Light0.m_colorIntensity.z);
  r1.w = max(r2.w, r1.w);
  r4.xyz = Light0.m_colorIntensity.xyz / r1.www;
  r3.xyz = r3.xyz * r0.www + scene.FakeRimLightDir.xyz;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = saturate(dot(r2.xyz, r3.xyz));
  r0.w = log2(r0.w);
  r0.w = SpecularPower * r0.w;
  r0.w = exp2(r0.w);
  r0.w = min(1, r0.w);
  r0.w = r0.w * r1.y;
  r3.xyz = min(float3(1.5,1.5,1.5), r4.xyz);
  r3.xyz = Light0.m_colorIntensity.xyz * r0.www + r3.xyz;
  r0.w = 1 + -r1.x;
  r1.xyw = r3.xyz * scene.MiscParameters1.xyz + -r3.xyz;
  r1.xyw = r0.www * r1.xyw + r3.xyz;
  r1.xyw = max(scene.GlobalAmbientColor.xyz, r1.xyw);
  r1.xyw = v1.xyz * r1.xyw;
  r0.xyz = r1.xyw * r0.xyz;
  r0.w = 1 + -r1.z;
  r0.w = log2(r0.w);
  r0.w = PointLightColor.x * r0.w;
  r0.w = exp2(r0.w);
  r0.w = -1 + r0.w;
  r0.w = PointLightColor.y * r0.w + 1;
  r1.xyz = GameMaterialEmission.xyz * r0.www;
  r0.xyz = r0.xyz * GameMaterialDiffuse.xyz + r1.xyz;
  r0.w = cmp(0 < scene.MiscParameters6.w);
  if (r0.w != 0) {
    r1.xy = GlobalTexcoordFactor * scene.MiscParameters6.xy;
    r1.xz = r1.xy * float2(30,30) + v4.xz;
    r1.y = v4.y;
    r1.xyz = scene.MiscParameters6.zzz * r1.xyz;
    r3.x = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.xy, 0).x;
    r3.y = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.xz, 0).x;
    r3.z = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.yz, 0).x;
    r0.w = dot(r3.xyz, float3(0.333299994,0.333299994,0.333299994));
    r0.w = v2.w * r0.w;
    r0.w = -r0.w * scene.MiscParameters6.w + v2.w;
    r0.w = max(0, r0.w);
  } else {
    r0.w = v2.w;
  }
  r1.xyz = scene.FogColor.xyz + -r0.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r0.w = -r0.w * 0.5 + 1;
  r0.w = r0.w * r0.w;
  r0.w = PointLightParams.z * r0.w;
  r1.x = calculateLuminanceSRGB(r0.xyz);
  r1.xyz = r1.xxx * scene.MonotoneMul.xyz + scene.MonotoneAdd.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  r0.xyz = GameMaterialMonotone * r1.xyz + r0.xyz;
  r1.xyz = BloomIntensity * r0.xyz;
  r1.x = calculateLuminanceSRGB(r1.xyz);
  r1.x = -scene.MiscParameters2.z + r1.x;
  r1.x = max(0, r1.x);
  r1.x = 0.5 * r1.x;
  r1.x = min(1, r1.x);
  o0.w = r1.x * r0.w;
  o1.xyz = r2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o1.w = 0.466666698 + MaskEps;
  r0.w = v9.z / v9.w;
  r1.x = 256 * r0.w;
  r1.x = trunc(r1.x);
  r0.w = r0.w * 256 + -r1.x;
  r1.w = 256 * r0.w;
  r1.y = trunc(r1.w);
  r1.z = r0.w * 256 + -r1.y;
  o2.xyz = float3(0.00390625,0.00390625,1) * r1.xyz;
  o0.xyz = r0.xyz;
  o2.w = MaskEps;

  o0 = saturate(o0);
  o1 = saturate(o1);
  o2 = saturate(o2);
  return;
}