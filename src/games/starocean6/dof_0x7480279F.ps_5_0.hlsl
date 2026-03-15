// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 14:26:39 2025
#include "shared.h"
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[115];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  uint v2 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (shader_injection.depthoffield == 1.f) {
    o0.xyzw = t0.SampleLevel(s0_s, v1.xy, 0.f).xyzw;
    return;
  }

  r0.x = t1.Sample(s1_s, v1.xy).y;
  r0.y = cb0[0].z * r0.x;
  r0.y = log2(r0.y);
  r0.y = cb0[0].w + r0.y;
  r0.zw = cb0[1].zw * r0.xx;
  r1.xy = cb0[1].zw * r0.xx + v1.xy;
  r2.xyzw = t0.SampleLevel(s0_s, r1.xy, r0.y).xyzw;
  r1.x = t1.Sample(s1_s, r1.xy).y;
  r0.w = cb0[0].x * r0.w;
  r0.w = r0.w * r0.w;
  r0.z = r0.z * r0.z + r0.w;
  r0.z = sqrt(r0.z);
  r0.z = cb0[0].y * r0.z;
  r0.z = cmp(r1.x < r0.z);
  r1.xyzw = r0.zzzz ? float4(0,0,0,0) : r2.xyzw;
  r2.xyz = r1.xyz;
  r0.z = r1.w;
  r0.w = 0;
  while (true) {
    r2.w = cmp((int)r0.w >= 113);
    if (r2.w != 0) break;
    r2.w = (int)r0.w + 1;

    int r0w2 = r0.w + 2;
    r3.xyzw = cb0[r0w2].xyzw * r0.xxxx;
    r4.xyzw = cb0[r0w2].xyzw * r0.xxxx + v1.xyxy;
    r5.xyzw = t0.SampleLevel(s0_s, r4.xy, r0.y).xyzw;
    r4.x = t1.Sample(s1_s, r4.xy).y;
    r3.yw = cb0[0].xx * r3.yw;
    r3.yw = r3.yw * r3.yw;
    r3.xy = r3.xz * r3.xz + r3.yw;
    r3.xy = sqrt(r3.xy);
    r3.xy = cb0[0].yy * r3.xy;
    r3.x = cmp(r4.x < r3.x);
    r5.xyzw = r3.xxxx ? float4(0,0,0,0) : r5.xyzw;
    r3.xzw = r5.xyz + r2.xyz;
    r4.x = r5.w + r0.z;
    r5.xyzw = t0.SampleLevel(s0_s, r4.zw, r0.y).xyzw;
    r4.y = t1.Sample(s1_s, r4.zw).y;
    r3.y = cmp(r4.y < r3.y);
    r5.xyzw = r3.yyyy ? float4(0,0,0,0) : r5.xyzw;
    r2.xyz = r5.xyz + r3.xzw;
    r0.z = r5.w + r4.x;
    r0.w = r2.w;
  }
  r0.y = max(0.00100000005, r0.z);
  r0.y = 1 / r0.y;
  o0.xyz = r2.xyz * r0.yyy;
  o0.w = r0.x;
  return;
}