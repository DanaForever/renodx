// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 03 14:57:25 2025
#include "shared.h"
#include "so6utils.hlsl"
cbuffer cb_std : register(b2)
{
  float4 cvColorMultiplier : packoffset(c0);
  float4 cvColorOffset : packoffset(c1);
  float4 cvLightMask : packoffset(c8);
  float4 cvLightBufferCoef[2] : packoffset(c9);
  float4 cvIBL[2] : packoffset(c11);
  float4 cvIBLPos[2] : packoffset(c13);
  float4 cvLightContext0[5] : packoffset(c15);
  float4 cvLightContext1[5] : packoffset(c20);
  float4 cvLightContext2[5] : packoffset(c25);
  float4 cvLightContext3[5] : packoffset(c30);
  float4 cvClusterBufferParam : packoffset(c35);
  uint4 cvClusterLightParam : packoffset(c36);
  uint4 cvShadowBufferIndex : packoffset(c37);
  float4 cvSpecularModifyCoef : packoffset(c38);
  float4 cvIBLDiffuseTexSizeInv : packoffset(c39);
  float4 cvSHAmbContext[8] : packoffset(c40);
  float4 cvHDRTransform : packoffset(c48);
  float4 cvScreenNormalize : packoffset(c49);
  float4 cfAlphaThreshold : packoffset(c50);
  float4 cvDebugConstant : packoffset(c51);
  row_major float3x4 cmView : packoffset(c52);
  float4 cvScreenDepthRow : packoffset(c55);
  row_major float4x4 cmViewScreen : packoffset(c56);
  float4 cvFogCoef[4] : packoffset(c60);
  float4 cvRoughnessIntegral : packoffset(c64);
  float4 cvSSL : packoffset(c65);
  float4 cvMicrofacetMapping : packoffset(c66);
  float4 cvHDROutputParam : packoffset(c67);
  uint4 cvTAADitherOffset : packoffset(c68);
  row_major float4x4 cvUITonemapMatrix : packoffset(c69);
  float4 cvVolumeFogCoef : packoffset(c73);
  float4 cvWorldEyePos : packoffset(c76);
  float4 cvSemanticConstant : packoffset(c77);
  float4 cvTime : packoffset(c78);
  float4 cvLightMaskMixer[4] : packoffset(c80);
  float4 cvIBLContext0[5] : packoffset(c84);
  float4 cvIBLContext1[5] : packoffset(c89);
}

SamplerState asTexSamp_0__s : register(s0);
Texture2D<float4> asTexObject_0_ : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : COLOR0,
  linear centroid float4 v3 : TEXCOORD1,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = asTexObject_0_.Sample(asTexSamp_0__s, v3.xy).xyzw;
  r0.xyzw = r0.xyzw * cvColorMultiplier.xyzw + cvColorOffset.xyzw;
  r0.xyz = cvHDRTransform.yyy * r0.xyz;
  r1.w = dot(cvUITonemapMatrix._m30_m31_m32_m33, r0.xyzw);
  r0.w = cmp(cfAlphaThreshold.x >= r1.w);
  if (r0.w != 0) discard;
  r0.xyz = saturate(r0.xyz);
  r2.xyz = float3(0.0773993805,0.0773993805,0.0773993805) * r0.xyz;
  r3.xyz = float3(0.0549999997,0.0549999997,0.0549999997) + r0.xyz;
  r3.xyz = float3(0.947867334,0.947867334,0.947867334) * r3.xyz;
  r3.xyz = log2(r3.xyz);
  r3.xyz = float3(2.4000001,2.4000001,2.4000001) * r3.xyz;
  r3.xyz = exp2(r3.xyz);
  r0.xyz = cmp(float3(0.0404499993,0.0404499993,0.0404499993) >= r0.xyz);
  r0.xyz = r0.xyz ? r2.xyz : r3.xyz;
  r0.w = 1;
  r2.x = dot(cvUITonemapMatrix._m00_m01_m02_m03, r0.xyzw);
  r2.y = dot(cvUITonemapMatrix._m10_m11_m12_m13, r0.xyzw);
  r2.z = dot(cvUITonemapMatrix._m20_m21_m22_m23, r0.xyzw);
  r0.x = cmp(0 < cvHDROutputParam.x);
  if (r0.x != 0) {
    r1.xyz = UIToPQ(r2.xyz, cvHDROutputParam.y, true);
  } else {
    r2.xyz = saturate(r2.xyz);
    r0.xyz = float3(12.9200001,12.9200001,12.9200001) * r2.xyz;
    r3.xyz = log2(r2.xyz);
    r3.xyz = float3(0.416666657,0.416666657,0.416666657) * r3.xyz;
    r3.xyz = exp2(r3.xyz);
    r3.xyz = r3.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
    r2.xyz = cmp(float3(0.00313080009,0.00313080009,0.00313080009) >= r2.xyz);
    r1.xyz = r2.xyz ? r0.xyz : r3.xyz;
  }
  o0.xyzw = r1.xyzw;
  return;
}