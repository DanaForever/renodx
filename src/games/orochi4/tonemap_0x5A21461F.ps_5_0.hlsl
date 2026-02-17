// ---- Created with 3Dmigoto v1.3.16 on Fri May 23 15:41:51 2025
#include "./common.hlsl"
#include "uncharted2extended.hlsli"

cbuffer _Globals : register(b0)
{
  float4 vUVOffset : packoffset(c0) = {0,0,1,1};
  float fEdgeSharpness : packoffset(c1) = {8};
  float fPixelRange : packoffset(c1.y) = {2};
  float4 vRecipScreenSize : packoffset(c2) = {0.00052083336,0.00092592591,0.00026041668,0.000462962955};
  float4 vLightShaftPower : packoffset(c3) = {0.200000003,0.119999997,0.119999997,37};
  float fBloomWeight : packoffset(c4) = {1};
  float fMaxLum : packoffset(c4.y) = {4.19999981};
  float fStarWeight : packoffset(c4.z);
  float3 vColorScale : packoffset(c5);
  float3 vSaturationScale : packoffset(c6);
  float fParamA : packoffset(c6.w) = {0.219999999};
  float fParamCB : packoffset(c7) = {0.0299999993};
  float fParamDE : packoffset(c7.y) = {0.00200000009};
  float fParamB : packoffset(c7.z) = {0.300000012};
  float fParamDF : packoffset(c7.w) = {0.0599999987};
  float fParamEperF : packoffset(c8) = {0.0333000012};
  float fWhiteTone : packoffset(c8.y) = {1.14999998};
  float fGamma : packoffset(c8.z);
}

SamplerState smplAdaptedLumLast_s : register(s0);
SamplerState smplLightShaft_s : register(s1);
SamplerState smplBloom_s : register(s2);
SamplerState smplStar_s : register(s3);
SamplerState smplScene_s : register(s4);
Texture2D<float4> smplAdaptedLumLast_Tex : register(t0);
Texture2D<float4> smplLightShaft_Tex : register(t1);
Texture2D<float4> smplBloom_Tex : register(t2);
Texture2D<float4> smplStar_Tex : register(t3);
Texture2D<float4> smplScene_Tex : register(t4);


// 3Dmigoto declarations
#define cmp -

float3 convertFromBT709(float3 color) {

  float color_space = RENODX_TONE_MAP_WORKING_COLOR_SPACE;

  if (color_space == 1.f) {
    color = renodx::color::bt2020::from::BT709(color);
  } else if (color_space == 2.f) {
    color = renodx::color::ap1::from::BT709(color);
  }

  return color;
}

float3 convertToBT709(float3 color) {
  float color_space = RENODX_TONE_MAP_WORKING_COLOR_SPACE;

  if (color_space == 1.f) {
    color = renodx::color::bt709::from::BT2020(color);
  } else if (color_space == 2.f) {
    color = renodx::color::bt709::from::AP1(color);
  }

  return color;
}

float getLuminance(float3 color) {
  float color_space = RENODX_TONE_MAP_WORKING_COLOR_SPACE;

  if (color_space == 1.f) {
    return renodx::color::y::from::BT2020(color);
  } else if (color_space == 2.f) {
    return renodx::color::y::from::AP1(color);
  } else {
    return renodx::color::y::from::BT709(color);
  }
}

#define FLT16_MAX 65504.f
#define FLT_MIN   asfloat(0x00800000)  // 1.175494351e-38f
#define FLT_MAX   asfloat(0x7F7FFFFF)  // 3.402823466e+38f

static const float3x3 Wide_2_XYZ_MAT = float3x3(
    0.5441691, 0.2395926, 0.1666943,
    0.2394656, 0.7021530, 0.0583814,
    -0.0023439, 0.0361834, 1.0552183);

static const float3 AP1_RGB2Y = float3(
    0.2722287168,  // AP1_2_XYZ_MAT[0][1],
    0.6740817658,  // AP1_2_XYZ_MAT[1][1],
    0.0536895174   // AP1_2_XYZ_MAT[2][1]
);

float3 expandGamut(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
{
  // const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
  // const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
  // const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
  // const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  const float3x3 sRGB_2_AP1 = renodx::color::BT709_TO_AP1_MAT;
  const float3x3 AP1_2_sRGB = renodx::color::AP1_TO_BT709_MAT;
  const float3x3 Wide_2_AP1 = mul(renodx::color::XYZ_TO_AP1_MAT, Wide_2_XYZ_MAT);
  const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  // float3 ColorAP1 = mul(sRGB_2_AP1, vHDRColor);
  float3 ColorAP1 = renodx::color::ap1::from::BT709(vHDRColor);
  float LumaAP1 = renodx::color::y::from::AP1(ColorAP1);

  // float LumaAP1 = dot(ColorAP1, AP1_RGB2Y);
  if (LumaAP1 <= 0.f)
    {
    return vHDRColor;
  }
  float3 ChromaAP1 = ColorAP1 / LumaAP1;

  float ChromaDistSqr = dot(ChromaAP1 - 1, ChromaAP1 - 1);
  // float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));
  float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

  float3 ColorExpand = mul(ExpandMat, ColorAP1);

  // ColorAP1 = lerp(ColorAP1, ColorExpand, fExpandGamut);
  ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);
  // ColorAP1 = ColorExpand;

  // vHDRColor = mul(AP1_2_sRGB, ColorAP1);
  vHDRColor = renodx::color::bt709::from::AP1(ColorAP1);
  return vHDRColor;
}

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

  r0.xyzw = v2.xyzw * vUVOffset.zwzw + vUVOffset.xyxy;
  
  r1.xyz = smplScene_Tex.Sample(smplScene_s, r0.xy).xyz;
  r1.xyz = convertFromBT709(r1.xyz);

  r0.xyz = smplScene_Tex.Sample(smplScene_s, r0.zw).xyz;
  r0.xyz = convertFromBT709(r0.xyz);

  r0.w = getLuminance(r0.xyz);
  r0.z = getLuminance(r1.xyz);

  r1.xyzw = v3.xyzw * vUVOffset.zwzw + vUVOffset.xyxy;

  r2.xyz = smplScene_Tex.Sample(smplScene_s, r1.xy).xyz;
  r2.xyz = convertFromBT709(r2.xyz);

  r1.xyz = smplScene_Tex.Sample(smplScene_s, r1.zw).xyz;
  r1.xyz = convertFromBT709(r1.xyz);

  r0.x = getLuminance(r1.xyz);
  r0.y = getLuminance(r2.xyz);

  r1.xyzw = r0.yzzw + r0.xwyx;
  r1.xy = r1.xz + -r1.yw;
  r1.z = min(abs(r1.x), abs(r1.y));
  r1.z = r1.z * fEdgeSharpness + 0.00100000005;
  r1.zw = r1.xy / r1.zz;
  r2.xy = vRecipScreenSize.zw * r1.xy;
  r1.xy = max(-fPixelRange, r1.zw);
  r1.xy = min(fPixelRange, r1.xy);
  r1.zw = vRecipScreenSize.xy * fPixelRange;
  r2.zw = r1.xy * r1.zw;
  r1.xyzw = v1.xyxy * vUVOffset.zwzw + vUVOffset.xyxy;
  r3.xyzw = r1.zwzw + -r2.xyzw;
  r2.xyzw = r1.xyzw + r2.xyzw;

  r1.xyzw = smplScene_Tex.Sample(smplScene_s, r1.zw).xyzw;
  r1.xyz = convertFromBT709(r1.xyz);

  r4.xyz = smplScene_Tex.Sample(smplScene_s, r3.zw).xyz;
  r4.xyz = convertFromBT709(r4.xyz);

  r3.xyz = smplScene_Tex.Sample(smplScene_s, r3.xy).xyz;
  r3.xyz = convertFromBT709(r3.xyz);

  r5.xyz = smplScene_Tex.Sample(smplScene_s, r2.zw).xyz;
  r5.xyz = convertFromBT709(r5.xyz);

  r2.xyz = smplScene_Tex.Sample(smplScene_s, r2.xy).xyz;
  r2.xyz = convertFromBT709(r2.xyz);

  r2.xyz = r3.xyz + r2.xyz;
  r3.xyz = r4.xyz + r3.xyz;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r2.xyz * float3(0.25,0.25,0.25) + r3.xyz;
  r2.xyz = float3(0.5,0.5,0.5) * r2.xyz;

  r2.w = getLuminance(r3.xyz);
  r4.xy = min(r0.zy, r0.wx);
  r0.xy = max(r0.zy, r0.wx);
  r0.x = max(r0.x, r0.y);
  r0.y = min(r4.x, r4.y);
  r4.xyz = r1.xyz;
  r0.z = getLuminance(r4.xyz);
  r0.y = min(r0.z, r0.y);
  r0.x = max(r0.z, r0.x);
  r0.x = cmp(r0.x < r2.w);
  r0.y = cmp(r2.w < r0.y);
  r0.x = (int)r0.x | (int)r0.y;
  r0.xyz = r0.xxx ? r2.xyz : r3.xyz;

  // God-Ray
  r2.xyz = smplLightShaft_Tex.Sample(smplLightShaft_s, v1.xy).xyz;
  r2.xyz = convertFromBT709(r2.xyz);

  r2.xyz = vLightShaftPower.xyz * r2.xyz;
  r0.w = smplAdaptedLumLast_Tex.Sample(smplAdaptedLumLast_s, float2(0.5,0.5)).x;
  r1.xyz = r0.xyz * r0.www + r2.xyz;

  // Bloom Pass
  r0.xyzw = smplBloom_Tex.Sample(smplBloom_s, v1.xy).xyzw;
  r0.xyz = convertFromBT709(r0.xyz);
  r2.x = fBloomWeight / fMaxLum;
  r0.xyzw = r2.xxxx * r0.xyzw; // Bloom texture stored in r0?

  r0.xyzw = r0.xyzw * float4(0.5,0.5,0.5,0.5) + r1.xyzw;
  r1.xyzw = smplStar_Tex.Sample(smplStar_s, v1.xy).xyzw;
  r1.xyz = convertFromBT709(r1.xyz);
  r0.xyzw = r1.xyzw * fStarWeight + r0.xyzw;
  r1.xyz = vColorScale.xyz * r0.xyz;

  r1.x = getLuminance(r1.xyz);
  r0.xyz = r0.xyz * vColorScale.xyz + -r1.xxx;
  o0.w = r0.w;
  r0.xyz = vSaturationScale.xyz * r0.xyz + r1.xxx;

  float3 untonemapped = convertToBT709(r0.xyz);
  // r0.xyz = displayMap(untonemapped); 

  r1.xyz = fParamA * r0.xyz + fParamCB;
  r1.xyz = r0.xyz * r1.xyz + fParamDE;
  r2.xyz = fParamA * r0.xyz + fParamB;
  r0.xyz = r0.xyz * r2.xyz + fParamDF;
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = -fParamEperF + r0.xyz;
  r0.xyz = fWhiteTone * r0.xyz;

  float precompute_white = fWhiteTone;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    o0.rgb = r0.rgb;
  } else {

    const float A = 0.22, B = 0.30, C = 0.10, D = 0.20, E = 0.01, F = 0.30, W = 2.2;
    // const float A = cb0[4].w, B = cb0[5].z, C = cb0[5].x / cb0[5].z, D = 0.20, E = 0.01, F = 0.30, W = 2.2;

    float coeffs[6] = { A, B, C, D, E, F };
    // float white_precompute = 1.f / renodx::tonemap::ApplyCurve(W, A, B, C, D, E, F);
    Uncharted2::Config::Uncharted2ExtendedConfig uc2_config = Uncharted2::Config::CreateUncharted2ExtendedConfig(coeffs, precompute_white);

    float3 base = r0.xyz;
    float3 extended = Uncharted2::ApplyExtended(untonemapped, base, uc2_config);

    o0.rgb = extended;

    o0.rgb = ToneMapLMS(o0.rgb);
  }
  o0.rgb = PostToneMapProcess(o0.rgb);

  return;
}