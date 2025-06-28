// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 14:26:39 2025
#include "shared.h"
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[67];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  uint v2 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (shader_injection.depthoffield == 1.f) {
    o0.xyzw = t0.SampleLevel(s0_s, v1.xy, 0.f).xyzw;
    return;
  }

  r0.xy = t1.Sample(s1_s, v1.xy).xw;
  r0.z = cb0[0].z * r0.x;
  r0.z = log2(r0.z);
  r0.z = cb0[0].w + r0.z;
  r1.xy = cb0[1].zw * r0.xx + v1.xy;
  r1.xyz = t0.SampleLevel(s0_s, r1.xy, r0.z).xyz;
  r2.xyz = r1.xyz;
  r0.w = 0;
  while (true) {
    r1.w = cmp((int)r0.w >= 65);
    if (r1.w != 0) break;
    r1.w = (int)r0.w + 1;

    int r0w2 = r0.w + 2;
    r3.xyzw = cb0[r0w2].xyzw * r0.xxxx + v1.xyxy;
    r4.xyz = t0.SampleLevel(s0_s, r3.xy, r0.z).xyz;
    r4.xyz = r4.xyz + r2.xyz;
    r3.xyz = t0.SampleLevel(s0_s, r3.zw, r0.z).xyz;
    r2.xyz = r4.xyz + r3.xyz;
    r0.w = r1.w;
  }
  o0.xyz = cb0[0].yyy * r2.xyz;
  o0.w = r0.y;
  return;
}