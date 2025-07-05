// ---- Created with 3Dmigoto v1.3.16 on Wed May 21 16:53:47 2025
#include "./shared.h"
#include "./common.hlsl"

cbuffer _Globals : register(b0)
{
  float4 vUVOffset : packoffset(c0) = {0,0,1,1};
  float fEdgeThresholdMin : packoffset(c1) = {0.0500000007};
  float fEdgeThreshold : packoffset(c1.y) = {0.0500000007};
  float fEdgeSharpness : packoffset(c1.z) = {8};
  float fPixelRange : packoffset(c1.w) = {2};
  float4 vRecipScreenSize : packoffset(c2) = {0.00052083336,0.00092592591,0.00026041668,0.000462962955};
  float4 vLightShaftPower : packoffset(c3) = {0.200000003,0.119999997,0.119999997,37};
  float4 HFOG_hfogParams : packoffset(c4);
  float4 HFOG_hfogColor : packoffset(c5);
  float fParamA : packoffset(c6) = {0.219999999};
  float fParamCB : packoffset(c6.y) = {0.0299999993};
  float fParamDE : packoffset(c6.z) = {0.00200000009};
  float fParamB : packoffset(c6.w) = {0.300000012};
  float fParamDF : packoffset(c7) = {0.0599999987};
  float fParamEperF : packoffset(c7.y) = {0.0333000012};
  float fWhiteTone : packoffset(c7.z) = {1.35598528};
  float4 matV2W_1 : packoffset(c8) = {0,0,0,0};
  float4 matV2W_2 : packoffset(c9) = {0,0,0,0};
  float4 matV2W_3 : packoffset(c10) = {0,0,0,0};
  float4 matV2W_4 : packoffset(c11) = {0,0,0,0};
  float fBloomWeight : packoffset(c12) = {1};
  float4 vViewInfo : packoffset(c13);
  float3 vColorScale : packoffset(c14) = {1,1,1};
  float3 vSaturationScale : packoffset(c15) = {1,1,1};
  float fGamma : packoffset(c15.w) = {1};
}

SamplerState smplLightShaft_s : register(s0);
SamplerState smplFlare_s : register(s1);
SamplerState smplScene_s : register(s2);
SamplerState smplAdaptedLumLast_s : register(s3);
SamplerState smplZ_s : register(s4);
SamplerState smplBloom_s : register(s5);
Texture2D<float4> smplLightShaft_Tex : register(t0);
Texture2D<float4> smplFlare_Tex : register(t1);
Texture2D<float4> smplScene_Tex : register(t2);
Texture2D<float4> smplAdaptedLumLast_Tex : register(t3);
Texture2D<float4> smplZ_Tex : register(t4);
Texture2D<float4> smplBloom_Tex : register(t5);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = v1.xyxy * vUVOffset.zwzw + vUVOffset.xyxy;
  r1.xyzw = smplScene_Tex.Sample(smplScene_s, r0.zw).xyzw;
  r2.xyzw = v2.xyzw * vUVOffset.zwzw + vUVOffset.xyxy;
  r3.xyz = smplScene_Tex.Sample(smplScene_s, r2.xy).xyz;
  r2.xyz = smplScene_Tex.Sample(smplScene_s, r2.zw).xyz;
  r4.xyzw = v3.xyzw * vUVOffset.zwzw + vUVOffset.xyxy;
  r5.xyz = smplScene_Tex.Sample(smplScene_s, r4.xy).xyz;
  r4.xyz = smplScene_Tex.Sample(smplScene_s, r4.zw).xyz;
  // r2.w = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  // r3.z = dot(r3.xyz, float3(0.298999995,0.587000012,0.114));
  // r3.w = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
  // r3.y = dot(r5.xyz, float3(0.298999995,0.587000012,0.114));
  // r3.x = dot(r4.xyz, float3(0.298999995,0.587000012,0.114));
  r2.w = dot(r1.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r3.z = dot(r3.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r3.w = dot(r2.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r3.y = dot(r5.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r3.x = dot(r4.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r2.xy = min(r3.zy, r3.wx);
  r2.x = min(r2.x, r2.y);
  r2.x = min(r2.w, r2.x);
  r2.yz = max(r3.zy, r3.wx);
  r2.y = max(r2.y, r2.z);
  r2.y = max(r2.w, r2.y);
  r2.z = r2.y + -r2.x;
  r2.w = fEdgeThreshold * r2.y;
  r2.w = max(fEdgeThresholdMin, r2.w);
  r2.z = cmp(r2.z >= r2.w);
  r3.xyzw = r3.yzzw + r3.xwyx;
  r3.xy = r3.xz + -r3.yw;
  r2.w = min(abs(r3.x), abs(r3.y));
  r2.w = r2.w * fEdgeSharpness + 0.00100000005;
  r3.zw = r3.xy / r2.ww;
  r3.zw = max(-fPixelRange, r3.zw);
  r3.zw = min(fPixelRange, r3.zw);
  r4.xy = vRecipScreenSize.xy * fPixelRange;
  r5.xy = vRecipScreenSize.zw * r3.xy;
  r5.zw = r4.xy * r3.zw;
  r3.xyzw = -r5.xyzw + r0.zwzw;
  r0.xyzw = r5.xyzw + r0.xyzw;
  r4.xyz = smplScene_Tex.Sample(smplScene_s, r3.xy).xyz;
  r5.xyz = smplScene_Tex.Sample(smplScene_s, r0.xy).xyz;
  r3.xyz = smplScene_Tex.Sample(smplScene_s, r3.zw).xyz;
  r0.xyz = smplScene_Tex.Sample(smplScene_s, r0.zw).xyz;
  if (r2.z != 0) {
    r4.xyz = r5.xyz + r4.xyz;
    r5.xyz = float3(0.5,0.5,0.5) * r4.xyz;
    r0.xyz = r3.xyz + r0.xyz;
    r0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
    r0.xyz = r4.xyz * float3(0.25,0.25,0.25) + r0.xyz;
    // r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
    r0.w = dot(r0.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
    r2.x = cmp(r0.w < r2.x);
    r0.w = cmp(r2.y < r0.w);
    r0.w = (int)r0.w | (int)r2.x;
    r1.xyz = r0.www ? r5.xyz : r0.xyz;  
  }
  r0.x = smplAdaptedLumLast_Tex.Sample(smplAdaptedLumLast_s, float2(0.5,0.5)).x;
  r0.y = smplZ_Tex.Sample(smplZ_s, v1.xy).x;
  r2.xyz = smplLightShaft_Tex.Sample(smplLightShaft_s, v1.xy).xyz;
  r2.xyz = vLightShaftPower.xyz * r2.xyz;
  r2.xyz = r1.xyz * r0.xxx + r2.xyz;
  r3.xyz = smplFlare_Tex.Sample(smplFlare_s, v1.xy).xyz;
  r1.xyz = r3.xyz + r2.xyz;
  r2.xyzw = smplBloom_Tex.Sample(smplBloom_s, v1.xy).xyzw;
  r1.xyzw = r2.xyzw * fBloomWeight + r1.xyzw;

  float3 untonemapped = r1.xyz;
  r1.xyz = RestoreHighlightSaturation(untonemapped);

  r0.y = vViewInfo.z + r0.y;
  r0.y = vViewInfo.w / r0.y;
  r0.zw = float2(-0.5,-0.5) + v1.xy;
  r0.zw = vViewInfo.xy * r0.zw;
  r0.zw = r0.zw * -r0.yy;
  r0.w = matV2W_2.y * r0.w;
  r0.z = r0.z * matV2W_1.y + r0.w;
  r0.z = r0.y * matV2W_3.y + r0.z;
  r0.z = matV2W_4.y + r0.z;
  r0.z = saturate(r0.z * HFOG_hfogParams.z + HFOG_hfogParams.w);
  r0.z = -1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.z = 1 + -r0.z;
  r2.xyzw = HFOG_hfogColor.xyzw * r0.zzzz;
  r0.y = saturate(-r0.y * HFOG_hfogParams.x + HFOG_hfogParams.y);
  r0.y = saturate(r2.w * r0.y);
  r0.xzw = r2.xyz * r0.xxx;

  // Uncharted 2 Tonemapping 
  // A*x + B * C
  r2.xyz = r0.xzw * float3(0.219999999, 0.219999999, 0.219999999) + float3(0.0299999993, 0.0299999993, 0.0299999993);
  // x * (A*x + B * C) + D * E
  r2.xyz = r0.xzw * r2.xyz + float3(0.00200000009,0.00200000009,0.00200000009);

  // A*x + B
  r3.xyz = r0.xzw * float3(0.219999999,0.219999999,0.219999999) + float3(0.300000012,0.300000012,0.300000012);

  // x * (A*x + B) + D * F
  r0.xzw = r0.xzw * r3.xyz + float3(0.0599999987,0.0599999987,0.0599999987);

  // nom / denom
  r0.xzw = r2.xyz / r0.xzw;

  // nom / denom - E/F
  r0.xzw = float3(-0.0333000012,-0.0333000012,-0.0333000012) + r0.xzw;  

  r0.xzw = r0.xzw * float3(1.14999998,1.14999998,1.14999998) + -r1.xyz;
  r0.xyz = r0.yyy * r0.xzw + r1.xyz;
  r1.xyz = fParamA * r0.xyz + fParamCB;
  r1.xyz = r0.xyz * r1.xyz + fParamDE;
  r2.xyz = fParamA * r0.xyz + fParamB;
  r0.xyz = r0.xyz * r2.xyz + fParamDF;
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = -fParamEperF + r0.xyz;
  r0.xyz = fWhiteTone * r0.xyz;
  r1.xyz = vColorScale.xyz * r0.xyz;
  // r0.w = dot(r1.xyz, float3(0.298909992,0.586610019,0.114480004));
  r0.w = dot(r1.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r0.xyz = r0.xyz * vColorScale.xyz + -r0.www;
  o0.w = r0.w;
  r0.xyz = vSaturationScale.xyz * r0.xyz + r0.www;

  float3 graded = r0.xyz;

  float3 midgray = renodx::tonemap::uncharted2::BT709(float3(0.18f, 0.18f, 0.18f), 1.14999998);
  float mid_gray_nits = renodx::color::y::from::BT709(midgray);
  untonemapped *= mid_gray_nits / 0.18f;  // scale untonemapped midgray, tonemappass expects 0.18f

  o0.rgba = ProcessColor(untonemapped, graded);

  o0.w = r1.w;
  return;
}