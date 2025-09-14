// ---- Created with 3Dmigoto v1.3.16 on Mon Sep 08 19:58:20 2025
#include "common.hlsl"
cbuffer cb_local : register(b2)
{
  float4 offsetsAndWeights[15] : packoffset(c0);
}

SamplerState samLinear_s : register(s0);
Texture2D<float4> colorTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.yz = offsetsAndWeights[1].xy + v1.xy;
  r0.x = min(offsetsAndWeights[1].w, r0.y);
  r0.xyzw = colorTexture.SampleLevel(samLinear_s, r0.xz, 0).xyzw;
  r0 = compress(r0);
  r0.xyzw = offsetsAndWeights[1].zzzz * r0.xyzw;
  
  r1.yz = offsetsAndWeights[0].xy + v1.xy;
  r1.x = min(offsetsAndWeights[0].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[0].zzzz + r0.xyzw;
  
  r1.yz = offsetsAndWeights[2].xy + v1.xy;
  r1.x = min(offsetsAndWeights[2].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[2].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[3].xy + v1.xy;
  r1.x = min(offsetsAndWeights[3].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[3].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[4].xy + v1.xy;
  r1.x = min(offsetsAndWeights[4].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[4].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[5].xy + v1.xy;
  r1.x = min(offsetsAndWeights[5].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[5].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[6].xy + v1.xy;
  r1.x = min(offsetsAndWeights[6].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[6].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[7].xy + v1.xy;
  r1.x = min(offsetsAndWeights[7].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[7].zzzz + r0.xyzw;
  
  r1.yz = offsetsAndWeights[8].xy + v1.xy;
  r1.x = min(offsetsAndWeights[8].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[8].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[9].xy + v1.xy;
  r1.x = min(offsetsAndWeights[9].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[9].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[10].xy + v1.xy;
  r1.x = min(offsetsAndWeights[10].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[10].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[11].xy + v1.xy;
  r1.x = min(offsetsAndWeights[11].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[11].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[12].xy + v1.xy;
  r1.x = min(offsetsAndWeights[12].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[12].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[13].xy + v1.xy;
  r1.x = min(offsetsAndWeights[13].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  r0.xyzw = r1.xyzw * offsetsAndWeights[13].zzzz + r0.xyzw;
  r1.yz = offsetsAndWeights[14].xy + v1.xy;
  r1.x = min(offsetsAndWeights[14].w, r1.y);
  r1.xyzw = colorTexture.SampleLevel(samLinear_s, r1.xz, 0).xyzw;
  r1 = compress(r1);
  o0.xyzw = r1.xyzw * offsetsAndWeights[14].zzzz + r0.xyzw;

  return;
}