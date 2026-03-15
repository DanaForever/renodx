// ---- Created with 3Dmigoto v1.3.16 on Thu Feb 19 15:06:29 2026
#include "./common.hlsl"
#include "uncharted2extended.hlsli"
Texture2D<float4> sScene : register(t0);
Texture2D<float4> sEffect : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = floor(v0.xy);
  r0.xy = (int2)r0.xy;
  r0.zw = float2(0,0);
  r1.xyz = sScene.Load(r0.xyw).xyz;
  r0.xyzw = sEffect.Load(r0.xyz).xyzw;
  r0.xyz = r1.xyz * r0.www + r0.xyz;

  o0.rgb = r0.rgb;
  return;

  float3 untonemapped = r0.rgb;

  // r0.xyz = max(float3(0,0,0), r0.xyz);
  // r1.xyz = r0.xyz * float3(0.219999999,0.219999999,0.219999999) + float3(0.0299999993,0.0299999993,0.0299999993);
  // r1.xyz = r0.xyz * r1.xyz + float3(0.00200000009,0.00200000009,0.00200000009);
  // r2.xyz = r0.xyz * float3(0.219999999,0.219999999,0.219999999) + float3(0.300000012,0.300000012,0.300000012);
  // r0.xyz = r0.xyz * r2.xyz + float3(0.0599999987,0.0599999987,0.0599999987);
  // r0.xyz = r1.xyz / r0.xyz;
  // r0.xyz = float3(-0.0333000012,-0.0333000012,-0.0333000012) + r0.xyz;
  // r0.xyz = float3(2.49263, 2.49263, 2.49263) * r0.xyz;
  // o0.rgb = r0.rgb;
  // float precompute_white = 2.49263;

  // if (RENODX_TONE_MAP_TYPE == 0.f) {
  //   // o0.rgb = r0.rgb;
  // } else {
  //   const float A = 0.22, B = 0.30, C = 0.10, D = 0.20, E = 0.01, F = 0.30, W = 2.2;
  //   // const float A = cb0[4].w, B = cb0[5].z, C = cb0[5].x / cb0[5].z, D = 0.20, E = 0.01, F = 0.30, W = 2.2;

  //   float coeffs[6] = { A, B, C, D, E, F };
  //   // float white_precompute = 1.f / renodx::tonemap::ApplyCurve(W, A, B, C, D, E, F);
  //   Uncharted2::Config::Uncharted2ExtendedConfig uc2_config = Uncharted2::Config::CreateUncharted2ExtendedConfig(coeffs, precompute_white);

  //   float3 base = o0.xyz;
  //   float3 extended = Uncharted2::ApplyExtended(untonemapped, base, uc2_config);

  //   o0.rgb = extended;

  //   // o0.rgb = ToneMapLMS(o0.rgb);
  // }

  // // r0.xyz = log2(r0.xyz);
  // // r0.xyz = float3(0.454545468,0.454545468,0.454545468) * r0.xyz;
  // // o0.xyz = exp2(r0.xyz);
  // o0.rgb = renodx::color::gamma::EncodeSafe(o0.rgb, 2.2f);
  o0.w = 1;
  return;
}