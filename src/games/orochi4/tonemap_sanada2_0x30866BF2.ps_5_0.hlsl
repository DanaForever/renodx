// ---- Created with 3Dmigoto v1.3.16 on Thu Feb 19 17:29:24 2026
#include "./common.hlsl"
#include "uncharted2extended.hlsli"

cbuffer _Globals : register(b0)
{
  float4 vTexUVOffset : packoffset(c0);
  int nSceneID : packoffset(c1);
  float fExposure : packoffset(c1.y);
  float fBloomWeight : packoffset(c1.z);
  float4 vLightShaftPower : packoffset(c2);
  float4 vColorScale : packoffset(c3);
  float4 vSaturationScale : packoffset(c4);
  float4 vScreen : packoffset(c5);
  float4 vSpotParams : packoffset(c6);
  float fLimbDarkening : packoffset(c7);
  float fLimbDarkeningWeight : packoffset(c7.y);
  float fToneMapInvWhitePoint : packoffset(c7.z);
}

SamplerState smplAdaptedLumLast_s : register(s0);
SamplerState smplDoFMergeScene_s : register(s1);
SamplerState smplBloom_s : register(s2);
SamplerState smplLightShaftLinWork2_s : register(s3);
SamplerState smplFXAA_s : register(s4);
SamplerState smplBlurFront_s : register(s5);
SamplerState smplBlurBack_s : register(s6);
Texture2D<float4> smplAdaptedLumLast_Tex : register(t0);
Texture2D<float4> smplDoFMergeScene_Tex : register(t1);
Texture2D<float4> smplBloom_Tex : register(t2);
Texture2D<float4> smplLightShaftLinWork2_Tex : register(t3);
Texture2D<float4> smplFXAA_Tex : register(t4);
Texture2D<float4> smplBlurFront_Tex : register(t5);
Texture2D<float4> smplBlurBack_Tex : register(t6);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = nSceneID;
  r0.x = 0.5 + r0.x;
  r0.x = 0.5 * r0.x;
  r0.y = 0.5;
  r0.x = smplAdaptedLumLast_Tex.Sample(smplAdaptedLumLast_s, r0.xy).x;
  r0.yz = v1.xy * vTexUVOffset.zw + vTexUVOffset.xy;
  r1.xyz = smplFXAA_Tex.Sample(smplFXAA_s, r0.yz).xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = fExposure * r1.xyz;
  r2.xyz = r1.xyz * r0.xxx;
  r0.w = smplDoFMergeScene_Tex.Sample(smplDoFMergeScene_s, r0.yz).w;
  r1.w = cmp(r0.w < 0.5);
  r0.w = -0.5 + r0.w;
  r0.w = abs(r0.w) * -2 + 1;
  r0.w = max(0, r0.w);
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 1 / r0.w;
  r0.w = -1 + r0.w;
  r0.w = saturate(0.25 * r0.w);
  r3.xyz = smplBlurBack_Tex.Sample(smplBlurBack_s, r0.yz).xyz;
  r4.xyzw = smplBlurFront_Tex.Sample(smplBlurFront_s, r0.yz).xyzw;
  r3.xyz = r1.www ? r2.xyz : r3.xyz;
  r0.xyz = -r1.xyz * r0.xxx + r3.xyz;
  r0.xyz = r0.www * r0.xyz + r2.xyz;
  r1.xyz = r4.xyz + -r0.xyz;
  r0.w = -0.5 + r4.w;
  r0.w = abs(r0.w) * -2 + 1;
  r0.w = max(0, r0.w);
  r0.w = 9.99999975e-006 + r0.w;
  r0.w = 1 / r0.w;
  r0.w = -1 + r0.w;
  r0.w = saturate(0.25 * r0.w);
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r1.xyz = smplBloom_Tex.Sample(smplBloom_s, v1.xy).xyz;
  r0.xyz = r1.xyz * fBloomWeight + r0.xyz;
  r1.xyz = smplLightShaftLinWork2_Tex.Sample(smplLightShaftLinWork2_s, v1.xy).xyz;
  r0.xyz = r1.xyz * vLightShaftPower.xyz + r0.xyz;
  r0.w = dot(float3(0.298909992,0.586610019,0.114480004), r0.xyz);
  r0.xyz = r0.xyz * vColorScale.xyz + -r0.www;
  r0.xyz = vSaturationScale.xyz * r0.xyz + r0.www;
  r1.xy = v1.xy * vScreen.xy + -vSpotParams.xy;
  r0.w = dot(r1.xy, r1.xy);
  r1.x = fLimbDarkening + r0.w;
  r0.w = sqrt(r0.w);
  r0.w = -vSpotParams.z + r0.w;
  r1.x = fLimbDarkening / r1.x;
  r1.x = r1.x * r1.x;
  r1.xyz = r1.xxx * r0.xyz;
  r1.w = cmp(0 >= r0.w);
  r0.w = saturate(vSpotParams.w / r0.w);
  r0.w = r1.w ? 1 : r0.w;
  r1.xyz = r1.xyz * r0.www;
  r1.xyz = fLimbDarkeningWeight * r1.xyz;
  r0.w = 1 + -fLimbDarkeningWeight;
  r0.xyz = r0.xyz * r0.www + r1.xyz;

  float3 untonemapped = r0.rgb;

  r0.xyz = max(float3(0,0,0), r0.xyz);
  r1.xyz = r0.xyz * float3(0.219999999,0.219999999,0.219999999) + float3(0.0299999993,0.0299999993,0.0299999993);
  r1.xyz = r0.xyz * r1.xyz + float3(0.00200000009,0.00200000009,0.00200000009);
  r2.xyz = r0.xyz * float3(0.219999999,0.219999999,0.219999999) + float3(0.300000012,0.300000012,0.300000012);
  r0.xyz = r0.xyz * r2.xyz + float3(0.0599999987,0.0599999987,0.0599999987);
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = float3(-0.0333000012,-0.0333000012,-0.0333000012) + r0.xyz;
  o0.xyz = fToneMapInvWhitePoint * r0.xyz;

  float precompute_white = fToneMapInvWhitePoint;

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    o0.rgb = r0.rgb;
  } else {
    const float A = 0.22, B = 0.30, C = 0.10, D = 0.20, E = 0.01, F = 0.30, W = 2.2;
    // const float A = cb0[4].w, B = cb0[5].z, C = cb0[5].x / cb0[5].z, D = 0.20, E = 0.01, F = 0.30, W = 2.2;

    float coeffs[6] = { A, B, C, D, E, F };
    // float white_precompute = 1.f / renodx::tonemap::ApplyCurve(W, A, B, C, D, E, F);
    Uncharted2::Config::Uncharted2ExtendedConfig uc2_config = Uncharted2::Config::CreateUncharted2ExtendedConfig(coeffs, precompute_white);

    float3 base = o0.xyz;
    float3 extended = Uncharted2::ApplyExtended(untonemapped, base, uc2_config);

    o0.rgb = extended;

    o0.rgb = ToneMapLMS(o0.rgb);
  }
  o0.rgb = PostToneMapProcess(o0.rgb);

  o0.w = 1;
  return;
}