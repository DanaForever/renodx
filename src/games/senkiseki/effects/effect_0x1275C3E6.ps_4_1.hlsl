// ---- Created with 3Dmigoto v1.3.16 on Sun Jul 13 22:44:58 2025
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


  struct
  {
    float4x4 m_split0Transform;
    float4x4 m_split1Transform;
    float4 m_splitDistances;
  } LightShadow0 : packoffset(c64);

  float3 LightDirForChar : packoffset(c73);
  float GameMaterialID : packoffset(c73.w) = {0};
  float4 GameMaterialDiffuse : packoffset(c74) = {1,1,1,1};
  float4 GameMaterialEmission : packoffset(c75) = {0,0,0,0};
  float GameMaterialMonotone : packoffset(c76) = {0};
  float4 GameMaterialTexcoord : packoffset(c77) = {0,0,1,1};
  float4 UVaMUvColor : packoffset(c78) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c79) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c80) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c81) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c82) = {0,0,1,1};
  float AlphaThreshold : packoffset(c83) = {0.5};
  float Shininess : packoffset(c83.y) = {0.5};
  float SpecularPower : packoffset(c83.z) = {50};
  float3 RimLitColor : packoffset(c84) = {1,1,1};
  float RimLitIntensity : packoffset(c84.w) = {4};
  float RimLitPower : packoffset(c85) = {2};
  float RimLightClampFactor : packoffset(c85.y) = {2};
  float ShadowReceiveOffset : packoffset(c85.z) = {0.600000024};
  float BloomIntensity : packoffset(c85.w) = {0.699999988};
  float4 GameEdgeParameters : packoffset(c86) = {1,1,1,0.00300000003};
  float MaskEps : packoffset(c87);
  float4 PointLightParams : packoffset(c88) = {0,2,1,1};
  float4 PointLightColor : packoffset(c89) = {1,0,0,0};
}

SamplerState LinearWrapSamplerState_s : register(s0);
SamplerState LinearClampSamplerState_s : register(s1);
SamplerState PointClampSamplerState_s : register(s2);
SamplerState DiffuseMapSamplerSampler_s : register(s4);
SamplerState NormalMapSamplerSampler_s : register(s5);
SamplerComparisonState LinearClampCmpSamplerState_s : register(s3);
Texture2D<float4> LowResDepthTexture : register(t0);
Texture2D<float4> LightShadowMap0 : register(t1);
Texture2D<float4> DiffuseMapSampler : register(t2);
Texture2D<float4> NormalMapSampler : register(t3);
Texture2D<float4> CartoonMapSampler : register(t4);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD6,
  uint v7 : SV_SampleIndex0,
  out float4 o0 : SV_TARGET0)
{
  const float4 icb[] = { { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0.250000, 0.250000, 0, 0},
                              { -0.250000, -0.250000, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { -0.125000, -0.375000, 0, 0},
                              { 0.375000, -0.125000, 0, 0},
                              { -0.375000, 0.125000, 0, 0},
                              { 0.125000, 0.375000, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0.062500, -0.187500, 0, 0},
                              { -0.062500, 0.187500, 0, 0},
                              { 0.312500, 0.062500, 0, 0},
                              { -0.187500, -0.312500, 0, 0},
                              { -0.312500, 0.312500, 0, 0},
                              { -0.437500, -0.062500, 0, 0},
                              { 0.187500, 0.437500, 0, 0},
                              { 0.437500, -0.437500, 0, 0} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = (int)scene.DuranteSettings.x & 1;
  if (r0.x != 0) {
    r0.xy = ddx(v3.xy);
    r0.zw = ddy(v3.xy);
    r1.x = (uint)scene.DuranteSettings.y << 3;
    r1.x = (int)r1.x + (int)v7.x;
    r0.zw = icb[r1.x+0].yy * r0.zw;
    r0.xy = icb[r1.x+0].xx * r0.xy + r0.zw;
    r0.xy = v3.xy + r0.xy;
  } else {
    r0.xy = v3.xy;
  }
  r1.xyzw = DiffuseMapSampler.Sample(DiffuseMapSamplerSampler_s, r0.xy).xyzw;
  r2.w = v1.w * r1.w;
  r0.z = -AlphaThreshold * v1.w + r2.w;
  r0.z = cmp(r0.z < 0);
  if (r0.z != 0) discard;
  r0.z = cmp(LightShadow0.m_splitDistances.y >= v4.w);
  if (r0.z != 0) {
    r3.xyz = Light0.m_direction.xyz * ShadowReceiveOffset + v4.xyz;
    r3.xyz = v5.xyz * float3(0.0500000007,0.0500000007,0.0500000007) + r3.xyz;
    r0.z = cmp(v4.w < LightShadow0.m_splitDistances.x);
    if (r0.z != 0) {
      r3.w = 1;
      r4.x = dot(r3.xyzw, LightShadow0.m_split0Transform._m00_m10_m20_m30);
      r4.y = dot(r3.xyzw, LightShadow0.m_split0Transform._m01_m11_m21_m31);
      r4.z = dot(r3.xyzw, LightShadow0.m_split0Transform._m02_m12_m22_m32);
      r0.z = 25 / LightShadow0.m_splitDistances.y;
      r0.w = (int)scene.DuranteSettings.x & 16;
      if (r0.w != 0) {
        r5.xy = float2(0.000937499979,0.00187499996) * r0.zz;
        r0.w = -6 + r4.z;
        r5.xy = r5.xy * r0.ww;
        r5.xy = r5.xy / r4.zz;
        r0.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
        r0.w = frac(r0.w);
        r0.w = 52.9829178 * r0.w;
        r0.w = frac(r0.w);
        r0.w = 6.28318548 * r0.w;
        r5.zw = float2(0,0);
        r1.w = 0;
        while (true) {
          r4.w = cmp((int)r1.w >= 16);
          if (r4.w != 0) break;
          r4.w = (int)r1.w;
          r6.x = 0.5 + r4.w;
          r6.x = sqrt(r6.x);
          r6.x = 0.25 * r6.x;
          r4.w = r4.w * 2.4000001 + r0.w;
          sincos(r4.w, r7.x, r8.x);
          r8.x = r8.x * r6.x;
          r8.y = r7.x * r6.x;
          r6.xy = r8.xy * r5.xy + r4.xy;
          r4.w = LightShadowMap0.SampleLevel(PointClampSamplerState_s, r6.xy, 0).x;
          r6.x = cmp(r4.w < r4.z);
          r7.y = r5.w + r4.w;
          r7.x = 1 + r5.z;
          r5.zw = r6.xx ? r7.xy : r5.zw;
          r1.w = (int)r1.w + 1;
        }
        r1.w = cmp(r5.z >= 1);
        if (r1.w != 0) {
          r5.xy = float2(0.000624999986,0.00124999997) * r0.zz;
          r1.w = r5.w / r5.z;
          r1.w = r4.z + -r1.w;
          r1.w = min(0.0700000003, r1.w);
          r1.w = 60 * r1.w;
          r5.xy = r1.ww * r5.xy;
          LightShadowMap0.GetDimensions(0, fDest.x, fDest.y, fDest.z);
          r5.zw = fDest.xy;
          r5.zw = float2(0.5,0.5) / r5.zw;
          r5.xy = max(r5.zw, r5.xy);
          r1.w = 0;
          r4.w = 0;
          while (true) {
            r5.z = cmp((int)r4.w >= 16);
            if (r5.z != 0) break;
            r5.z = (int)r4.w;
            r5.w = 0.5 + r5.z;
            r5.w = sqrt(r5.w);
            r5.w = 0.25 * r5.w;
            r5.z = r5.z * 2.4000001 + r0.w;
            sincos(r5.z, r6.x, r7.x);
            r7.x = r7.x * r5.w;
            r7.y = r6.x * r5.w;
            r5.zw = r7.xy * r5.xy;
            r5.zw = r5.zw * float2(3,3) + r4.xy;
            r5.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.zw, r4.z).x;
            r1.w = r5.z + r1.w;
            r4.w = (int)r4.w + 1;
          }
          r0.w = 0.0625 * r1.w;
        } else {
          r0.w = 1;
        }
      } else {
        r1.w = (int)scene.DuranteSettings.x & 8;
        if (r1.w != 0) {
          r5.xy = float2(0.000375000003,0.000750000007) * r0.zz;
          r1.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
          r1.w = frac(r1.w);
          r1.w = 52.9829178 * r1.w;
          r1.w = frac(r1.w);
          r1.w = 6.28318548 * r1.w;
          r4.w = 0;
          r5.z = 0;
          while (true) {
            r5.w = cmp((int)r5.z >= 16);
            if (r5.w != 0) break;
            r5.w = (int)r5.z;
            r6.x = 0.5 + r5.w;
            r6.x = sqrt(r6.x);
            r6.x = 0.25 * r6.x;
            r5.w = r5.w * 2.4000001 + r1.w;
            sincos(r5.w, r7.x, r8.x);
            r8.x = r8.x * r6.x;
            r8.y = r7.x * r6.x;
            r6.xy = r8.xy * r5.xy;
            r6.xy = r6.xy * float2(3,3) + r4.xy;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r4.z).x;
            r4.w = r5.w + r4.w;
            r5.z = (int)r5.z + 1;
          }
          r0.w = 0.0625 * r4.w;
        } else {
          r1.w = dot(r3.xyzw, LightShadow0.m_split0Transform._m03_m13_m23_m33);
          r4.w = (int)scene.DuranteSettings.x & 4;
          if (r4.w != 0) {
            r5.xy = scene.MiscParameters4.xy * r1.ww;
            r4.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r6.xy = -r5.xy * r0.zz;
            r6.z = 0;
            r6.xyz = r6.xyz + r4.xyz;
            r5.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
            r5.z = 0.0625 * r5.z;
            r4.w = r4.w * 0.5 + r5.z;
            r6.x = r5.x * r0.z;
            r6.y = -r5.y * r0.z;
            r6.z = 0;
            r7.xyz = r6.xyz + r4.xyz;
            r5.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r7.xy, r7.z).x;
            r4.w = r5.z * 0.0625 + r4.w;
            r7.x = -r5.x * r0.z;
            r7.y = r5.y * r0.z;
            r7.z = 0;
            r8.xyz = r7.xyz + r4.xyz;
            r5.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r8.xy, r8.z).x;
            r4.w = r5.z * 0.0625 + r4.w;
            r5.xy = r5.xy * r0.zz;
            r5.z = 0;
            r8.xyz = r5.xyz + r4.xyz;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r8.xy, r8.z).x;
            r4.w = r5.w * 0.0625 + r4.w;
            r6.xyz = r6.zyz + r4.xyz;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
            r4.w = r5.w * 0.0625 + r4.w;
            r6.xyz = r7.xzz + r4.xyz;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
            r4.w = r5.w * 0.0625 + r4.w;
            r6.xyz = r5.xzz + r4.xyz;
            r5.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
            r4.w = r5.x * 0.0625 + r4.w;
            r5.xyz = r5.zyz + r4.xyz;
            r5.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.xy, r5.z).x;
            r0.w = r5.x * 0.0625 + r4.w;
          } else {
            r4.w = (int)scene.DuranteSettings.x & 2;
            if (r4.w != 0) {
              r5.xy = scene.MiscParameters4.xy * r1.ww;
              r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r6.xy = -r5.xy * r0.zz;
              r6.z = 0;
              r6.xyz = r6.xyz + r4.xyz;
              r4.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
              r4.w = scene.MiscParameters5.y * r4.w;
              r1.w = r1.w * scene.MiscParameters5.x + r4.w;
              r6.x = r5.x * r0.z;
              r6.y = -r5.y * r0.z;
              r6.z = 0;
              r6.xyz = r6.xyz + r4.xyz;
              r4.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
              r1.w = r4.w * scene.MiscParameters5.y + r1.w;
              r6.x = -r5.x * r0.z;
              r6.y = r5.y * r0.z;
              r6.z = 0;
              r6.xyz = r6.xyz + r4.xyz;
              r4.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
              r1.w = r4.w * scene.MiscParameters5.y + r1.w;
              r5.xy = r5.xy * r0.zz;
              r5.z = 0;
              r5.xyz = r5.xyz + r4.xyz;
              r0.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.xy, r5.z).x;
              r0.w = r0.z * scene.MiscParameters5.y + r1.w;
            } else {
              r0.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            }
          }
        }
      }
    } else {
      r3.w = 1;
      r4.x = dot(r3.xyzw, LightShadow0.m_split1Transform._m00_m10_m20_m30);
      r4.y = dot(r3.xyzw, LightShadow0.m_split1Transform._m01_m11_m21_m31);
      r4.z = dot(r3.xyzw, LightShadow0.m_split1Transform._m02_m12_m22_m32);
      r0.z = 10 / LightShadow0.m_splitDistances.y;
      r1.w = (int)scene.DuranteSettings.x & 16;
      if (r1.w != 0) {
        r5.xy = float2(0.000937499979,0.00187499996) * r0.zz;
        r1.w = -6 + r4.z;
        r5.xy = r5.xy * r1.ww;
        r5.xy = r5.xy / r4.zz;
        r1.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
        r1.w = frac(r1.w);
        r1.w = 52.9829178 * r1.w;
        r1.w = frac(r1.w);
        r1.w = 6.28318548 * r1.w;
        r5.zw = float2(0,0);
        r4.w = 0;
        while (true) {
          r6.x = cmp((int)r4.w >= 16);
          if (r6.x != 0) break;
          r6.x = (int)r4.w;
          r6.y = 0.5 + r6.x;
          r6.y = sqrt(r6.y);
          r6.y = 0.25 * r6.y;
          r6.x = r6.x * 2.4000001 + r1.w;
          sincos(r6.x, r6.x, r7.x);
          r7.x = r7.x * r6.y;
          r7.y = r6.y * r6.x;
          r6.xy = r7.xy * r5.xy + r4.xy;
          r6.x = LightShadowMap0.SampleLevel(PointClampSamplerState_s, r6.xy, 0).x;
          r6.y = cmp(r6.x < r4.z);
          r7.y = r6.x + r5.w;
          r7.x = 1 + r5.z;
          r5.zw = r6.yy ? r7.xy : r5.zw;
          r4.w = (int)r4.w + 1;
        }
        r4.w = cmp(r5.z >= 1);
        if (r4.w != 0) {
          r5.xy = float2(0.000624999986,0.00124999997) * r0.zz;
          r4.w = r5.w / r5.z;
          r4.w = r4.z + -r4.w;
          r4.w = min(0.0700000003, r4.w);
          r4.w = 60 * r4.w;
          r5.xy = r4.ww * r5.xy;
          LightShadowMap0.GetDimensions(0, fDest.x, fDest.y, fDest.z);
          r5.zw = fDest.xy;
          r5.zw = float2(0.5,0.5) / r5.zw;
          r5.xy = max(r5.zw, r5.xy);
          r4.w = 0;
          r5.z = 0;
          while (true) {
            r5.w = cmp((int)r5.z >= 16);
            if (r5.w != 0) break;
            r5.w = (int)r5.z;
            r6.x = 0.5 + r5.w;
            r6.x = sqrt(r6.x);
            r6.x = 0.25 * r6.x;
            r5.w = r5.w * 2.4000001 + r1.w;
            sincos(r5.w, r7.x, r8.x);
            r8.x = r8.x * r6.x;
            r8.y = r7.x * r6.x;
            r6.xy = r8.xy * r5.xy;
            r6.xy = r6.xy * float2(3,3) + r4.xy;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r4.z).x;
            r4.w = r5.w + r4.w;
            r5.z = (int)r5.z + 1;
          }
          r0.w = 0.0625 * r4.w;
        } else {
          r0.w = 1;
        }
      } else {
        r1.w = (int)scene.DuranteSettings.x & 8;
        if (r1.w != 0) {
          r5.xy = float2(0.000375000003,0.000750000007) * r0.zz;
          r1.w = dot(v0.xy, float2(0.0671105608,0.00583714992));
          r1.w = frac(r1.w);
          r1.w = 52.9829178 * r1.w;
          r1.w = frac(r1.w);
          r1.w = 6.28318548 * r1.w;
          r4.w = 0;
          r5.z = 0;
          while (true) {
            r5.w = cmp((int)r5.z >= 16);
            if (r5.w != 0) break;
            r5.w = (int)r5.z;
            r6.x = 0.5 + r5.w;
            r6.x = sqrt(r6.x);
            r6.x = 0.25 * r6.x;
            r5.w = r5.w * 2.4000001 + r1.w;
            sincos(r5.w, r7.x, r8.x);
            r8.x = r8.x * r6.x;
            r8.y = r7.x * r6.x;
            r6.xy = r8.xy * r5.xy;
            r6.xy = r6.xy * float2(3,3) + r4.xy;
            r5.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r4.z).x;
            r4.w = r5.w + r4.w;
            r5.z = (int)r5.z + 1;
          }
          r0.w = 0.0625 * r4.w;
        } else {
          r1.w = dot(r3.xyzw, LightShadow0.m_split1Transform._m03_m13_m23_m33);
          r3.x = (int)scene.DuranteSettings.x & 4;
          if (r3.x != 0) {
            r3.xy = scene.MiscParameters4.xy * r1.ww;
            r3.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            r5.xy = -r3.xy * r0.zz;
            r5.z = 0;
            r6.xyz = r5.xyz + r4.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r6.xy, r6.z).x;
            r3.w = 0.0625 * r3.w;
            r3.z = r3.z * 0.5 + r3.w;
            r6.x = r3.x * r0.z;
            r6.y = -r3.y * r0.z;
            r6.z = 0;
            r7.xyz = r6.xyz + r4.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r7.xy, r7.z).x;
            r3.z = r3.w * 0.0625 + r3.z;
            r7.x = -r3.x * r0.z;
            r7.y = r3.y * r0.z;
            r7.z = 0;
            r8.xyz = r7.xyz + r4.xyz;
            r3.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r8.xy, r8.z).x;
            r3.z = r3.w * 0.0625 + r3.z;
            r8.xy = r3.xy * r0.zz;
            r8.z = 0;
            r3.xyw = r8.xyz + r4.xyz;
            r3.x = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.xy, r3.w).x;
            r3.x = r3.x * 0.0625 + r3.z;
            r3.yzw = r6.zyz + r4.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r3.x = r3.y * 0.0625 + r3.x;
            r3.yzw = r5.xzz + r4.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r3.x = r3.y * 0.0625 + r3.x;
            r3.yzw = r6.xzz + r4.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r3.x = r3.y * 0.0625 + r3.x;
            r3.yzw = r7.zyz + r4.xyz;
            r3.y = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.yz, r3.w).x;
            r0.w = r3.y * 0.0625 + r3.x;
          } else {
            r3.x = (int)scene.DuranteSettings.x & 2;
            if (r3.x != 0) {
              r3.xy = scene.MiscParameters4.xy * r1.ww;
              r1.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
              r5.xy = -r3.xy * r0.zz;
              r5.z = 0;
              r5.xyz = r5.xyz + r4.xyz;
              r3.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.xy, r5.z).x;
              r3.z = scene.MiscParameters5.y * r3.z;
              r1.w = r1.w * scene.MiscParameters5.x + r3.z;
              r5.x = r3.x * r0.z;
              r5.y = -r3.y * r0.z;
              r5.z = 0;
              r5.xyz = r5.xyz + r4.xyz;
              r3.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.xy, r5.z).x;
              r1.w = r3.z * scene.MiscParameters5.y + r1.w;
              r5.x = -r3.x * r0.z;
              r5.y = r3.y * r0.z;
              r5.z = 0;
              r5.xyz = r5.xyz + r4.xyz;
              r3.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r5.xy, r5.z).x;
              r1.w = r3.z * scene.MiscParameters5.y + r1.w;
              r3.xy = r3.xy * r0.zz;
              r3.z = 0;
              r3.xyz = r4.xyz + r3.xyz;
              r0.z = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r3.xy, r3.z).x;
              r0.w = r0.z * scene.MiscParameters5.y + r1.w;
            } else {
              r0.w = LightShadowMap0.SampleCmpLevelZero(LinearClampCmpSamplerState_s, r4.xy, r4.z).x;
            }
          }
        }
      }
    }
  } else {
    r0.w = 1;
  }
  r0.z = saturate(v4.w / LightShadow0.m_splitDistances.y);
  r1.w = r0.z * r0.z;
  r3.x = -scene.MiscParameters2.y + v4.y;
  r3.x = scene.MiscParameters2.x * abs(r3.x);
  r3.x = min(1, r3.x);
  r3.y = r3.x * r3.x;
  r3.x = r3.x * r3.y;
  r3.y = cmp(0 >= scene.MiscParameters2.x);
  r3.x = r3.y ? 0 : r3.x;
  r0.z = r0.z * r1.w + r3.x;
  r1.w = dot(v5.xyz, Light0.m_direction.xyz);
  r1.w = r1.w * 0.5 + 0.5;
  r3.x = r1.w * r1.w;
  r1.w = -r1.w * r3.x + 1;
  r0.z = r1.w * r1.w + r0.z;
  r0.z = min(1, r0.z);
  r0.z = r0.w + r0.z;
  r0.z = min(1, r0.z);
  r0.w = 1 + -r0.z;
  r1.w = 1 + -scene.MiscParameters2.w;
  r0.z = r0.w * r1.w + r0.z;
  r0.w = 1 + -r0.z;
  r1.w = 1 + -GameMaterialEmission.w;
  r0.z = r0.w * r1.w + r0.z;
  r0.w = r0.z * r0.z;
  r3.xyz = Light0.m_colorIntensity.xyz * r0.www;
  r4.xyz = NormalMapSampler.Sample(NormalMapSamplerSampler_s, r0.xy).xyz;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.y = dot(v6.xyz, v6.xyz);
  r0.y = rsqrt(r0.y);
  r5.xyz = v6.xyz * r0.yyy;
  r0.y = dot(v5.xyz, v5.xyz);
  r0.y = rsqrt(r0.y);
  r6.xyz = v5.xyz * r0.yyy;
  r7.xyz = r6.zxy * r5.yzx;
  r7.xyz = r6.yzx * r5.zxy + -r7.xyz;
  r0.x = cmp(r0.x < 0);
  r0.x = r0.x ? -1 : 1;
  r0.x = r4.x * r0.x;
  r4.xyw = r7.xyz * r4.yyy;
  r0.xyw = r0.xxx * r5.xyz + r4.xyw;
  r0.xyw = r4.zzz * r6.xyz + r0.xyw;
  r1.w = dot(r0.xyw, r0.xyw);
  r1.w = rsqrt(r1.w);
  r0.xyw = r1.www * r0.xyw;
  r4.xyz = scene.EyePosition.xyz + -v4.xyz;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r5.xyz = r4.xyz * r1.www;
  // r3.w = saturate(dot(r0.xyw, r5.xyz));
  r3.w = (dot(r0.xyw, r5.xyz));
  r4.w = dot(LightDirForChar.xyz, r0.xyw);
  r4.xyz = r4.xyz * r1.www + LightDirForChar.xyz;
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r4.xyz = r4.xyz * r1.www;
  // r0.x = saturate(dot(r0.xyw, r4.xyz));
  r0.x = (dot(r0.xyw, r4.xyz));
  // r0.x = log2(r0.x);
  // r0.x = SpecularPower * r0.x;
  // r0.x = exp2(r0.x);
  r0.x = renodx::math::SafePow(r0.x, SpecularPower);
  r0.x = min(1, r0.x);
  r0.x = Shininess * r0.x;
  r4.x = r4.w * 0.5 + 0.5;
  r4.y = 0;
  r0.y = CartoonMapSampler.SampleLevel(LinearClampSamplerState_s, r4.xy, 0).x;
  r4.xyz = Light0.m_colorIntensity.xyz * r0.yyy;
  r4.xyz = min(float3(1.5,1.5,1.5), r4.xyz);
  r0.xyw = Light0.m_colorIntensity.xyz * r0.xxx + r4.xyz;
  r0.z = 1 + -r0.z;
  r4.xyz = r0.xyw * scene.MiscParameters1.xyz + -r0.xyw;
  r0.xyz = r0.zzz * r4.xyz + r0.xyw;
  r0.w = 1 + -r3.w;
  // r0.w = log2(r0.w);
  // r1.w = RimLitPower * r0.w;
  // r1.w = exp2(r1.w);
  r1.w = renodx::math::SafePow(r0.w, RimLitPower);
  r1.w = RimLitIntensity * r1.w;
  r4.xyz = RimLitColor.xyz * r1.www;
  r0.xyz = r4.xyz * r3.xyz + r0.xyz;
  r0.xyz = min(RimLightClampFactor, r0.xyz);
  r0.xyz = v1.xyz * r0.xyz;
  r2.xyz = r1.xyz * r0.xyz;
  r1.xyzw = GameMaterialDiffuse.xyzw * r2.xyzw;
  // r0.x = PointLightColor.x * r0.w;
  // r0.x = exp2(r0.x);
  r0.x = renodx::math::SafePow(r0.x, PointLightColor.x);
  r0.x = -1 + r0.x;
  r0.x = PointLightColor.y * r0.x + 1;
  r0.xyz = GameMaterialEmission.xyz * r0.xxx + r1.xyz;
  r0.w = cmp(0 < scene.MiscParameters6.w);
  if (r0.w != 0) {
    r1.xy = GlobalTexcoordFactor * scene.MiscParameters6.xy;
    r1.xz = r1.xy * float2(30,30) + v4.xz;
    r1.y = v4.y;
    r1.xyz = scene.MiscParameters6.zzz * r1.xyz;
    r2.x = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.xy, 0).x;
    r2.y = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.xz, 0).x;
    r2.z = LowResDepthTexture.SampleLevel(LinearWrapSamplerState_s, r1.yz, 0).x;
    r0.w = dot(r2.xyz, float3(0.333299994,0.333299994,0.333299994));
    r0.w = v2.w * r0.w;
    r0.w = -r0.w * scene.MiscParameters6.w + v2.w;
    r0.w = max(0, r0.w);
  } else {
    r0.w = v2.w;
  }
  r0.xyz = r0.www * -r0.xyz + r0.xyz;
  r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.xyz = r0.www * scene.MonotoneMul.xyz + scene.MonotoneAdd.xyz;
  r1.xyz = r1.xyz + -r0.xyz;
  o0.xyz = GameMaterialMonotone * r1.xyz + r0.xyz;
  o0.w = r1.w;
  return;
}