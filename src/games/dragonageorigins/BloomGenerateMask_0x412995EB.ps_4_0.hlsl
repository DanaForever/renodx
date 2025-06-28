#include "./shared.h"

Texture2D<float4> sceneTexture : register(t0);
SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[236];
}


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD8,
  float4 v2 : COLOR0,
  float4 v3 : COLOR1,
  float4 v4 : TEXCOORD9,
  float4 v5 : TEXCOORD0,
  float4 v6 : TEXCOORD1,
  float4 v7 : TEXCOORD2,
  float4 v8 : TEXCOORD3,
  float4 v9 : TEXCOORD4,
  float4 v10 : TEXCOORD5,
  float4 v11 : TEXCOORD6,
  float4 v12 : TEXCOORD7,
  out float4 o0 : SV_TARGET0)
{
  //v5.xy *= 2;
  float4 sceneColor = sceneTexture.Sample(s0_s, v5.xy);

  // cb4[8] - vanilla shader brightness? 0.5
  // cb4[9] - vanilla shader contrast? 0.5

  float finalMult;
  if (injectedData.improvedBloom) {
    // linearize
    float3 linearColor = renodx::math::PowSafe(sceneColor.rgb, 2.2f);

    // calc luminance
    float luminance = dot(linearColor.rgb, float3(0.212500006,0.715399981,0.0720999986));  // luminance

    // back to gamma
    luminance = renodx::math::PowSafe(luminance, 1.f / 2.2f);

    // apply bloom threshold
    luminance = max(0, luminance - injectedData.bloomThreshold);

    // apply contrast
    luminance *= injectedData.bloomContrast;
    
    finalMult = luminance;
  } else {
    float luminance = dot(sceneColor.xyz, float3(0.212500006,0.715399981,0.0720999986));  // luminance
    float offsettedLuminance = luminance + cb4[8].x;
    float someMultiplier = 1.f + cb4[9].x;
    finalMult = someMultiplier * offsettedLuminance;
  }

  o0 = sceneColor * finalMult;

  if (injectedData.toneMapType == 0 || injectedData.clampBloom == 2) {
    o0 = saturate(o0);
  } else if (injectedData.clampBloom == 1) {
    o0.a = saturate(o0.a);
  }
}