// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:42:15 2025
#include "shared.h"
cbuffer Constants : register(b2)
{

  struct
  {
    float4 VerticalBlurMul_DiagonalBlurMul;
    float4 SamplesCount_InputSizeInv;
  } PerDrawCall : packoffset(c0);

}

SamplerState InputTextureSampler_s : register(s0);
Texture2D<float4> InputTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 x0[2];
  r0.xyzw = InputTexture.Sample(InputTextureSampler_s, v1.xy).xyzw;
  r0.xyz = float3(1024,1024,1024) * r0.xyz;
  x0[0].x = 0;
  x0[1].x = 0;
  r1.x = cmp(0 < r0.w);
  r1.y = r0.w + r0.w;
  r2.xyz = float3(0,0,0);
  r3.xyz = float3(0,0,0);
  r2.w = r0.w;
  r3.w = r0.w;
  r1.z = 0.5;
  while (true) {
    r1.w = cmp(r1.z >= PerDrawCall.SamplesCount_InputSizeInv.x);
    if (r1.w != 0) break;
    r1.w = PerDrawCall.SamplesCount_InputSizeInv.y * r1.z;
    r4.xyzw = PerDrawCall.VerticalBlurMul_DiagonalBlurMul.xyzw * r1.zzzz + v1.xyxy;
    r5.xyzw = InputTexture.Sample(InputTextureSampler_s, r4.xy).xyzw;
    r4.x = cmp(r5.w < 0);
    r4.y = cmp(r1.w < abs(r5.w));
    r6.x = cmp(abs(r5.w) < r1.y);
    r6.x = r1.x ? r6.x : 0;
    r6.x = (int)r4.x | (int)r6.x;
    r4.y = r4.y ? r6.x : 0;
    r5.xyz = float3(1024,1024,1024) * r5.xyz;
    r6.x = cmp(r2.w < 0);
    r6.y = min(r5.w, r2.w);
    r6.z = cmp(r2.w < -r5.w);
    r6.z = r6.z ? r5.w : r2.w;
    r6.x = r6.x ? r6.y : r6.z;
    r6.w = r4.x ? r6.x : r2.w;
    r4.x = -r1.z * PerDrawCall.SamplesCount_InputSizeInv.y + abs(r5.w);
    r4.x = saturate(PerDrawCall.SamplesCount_InputSizeInv.y * r4.x);
    r6.xyz = r4.xxx * r5.xyz + r2.xyz;
    r2.xyzw = r4.yyyy ? r6.xyzw : r2.xyzw;
    r4.x = r4.y ? r4.x : 0;
    r4.y = x0[0].x;
    r4.x = r4.y + r4.x;
    x0[0].x = r4.x;
    r4.xyzw = InputTexture.Sample(InputTextureSampler_s, r4.zw).xyzw;
    r5.x = cmp(r4.w < 0);
    r1.w = cmp(r1.w < abs(r4.w));
    r5.y = cmp(abs(r4.w) < r1.y);
    r5.y = r1.x ? r5.y : 0;
    r5.y = (int)r5.y | (int)r5.x;
    r1.w = r1.w ? r5.y : 0;
    r4.xyz = float3(1024,1024,1024) * r4.xyz;
    r5.y = cmp(r3.w < 0);
    r5.z = min(r4.w, r3.w);
    r5.w = cmp(r3.w < -r4.w);
    r5.w = r5.w ? r4.w : r3.w;
    r5.y = r5.y ? r5.z : r5.w;
    r5.w = r5.x ? r5.y : r3.w;
    r4.w = -r1.z * PerDrawCall.SamplesCount_InputSizeInv.y + abs(r4.w);
    r4.w = saturate(PerDrawCall.SamplesCount_InputSizeInv.y * r4.w);
    r5.xyz = r4.www * r4.xyz + r3.xyz;
    r3.xyzw = r1.wwww ? r5.xyzw : r3.xyzw;
    r1.w = r1.w ? r4.w : 0;
    r4.x = x0[1].x;
    r1.w = r4.x + r1.w;
    x0[1].x = r1.w;
    r1.z = 1 + r1.z;
  }
  r0.w = x0[0].x;
  r1.x = cmp(0 < r0.w);
  r1.yzw = r2.xyz / r0.www;
  r1.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.w = x0[1].x;
  r1.w = cmp(0 < r0.w);
  r2.xyz = r3.xyz / r0.www;
  r0.xyz = r1.www ? r2.xyz : r0.xyz;
  r0.w = cmp(abs(r3.w) < abs(r2.w));
  o1.w = r0.w ? r2.w : r3.w;
  o0.xyz = float3(0.0009765625,0.0009765625,0.0009765625) * r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  o1.xyz = float3(0.0009765625,0.0009765625,0.0009765625) * r0.xyz;
  o0.w = r2.w;

  o0 = saturate(o0);
  o1 = saturate(o1);

  return;
}