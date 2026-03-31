// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 22:25:27 2025
Texture2D<float4> t11 : register(t11);

Texture2D<float4> t10 : register(t10);

Texture2D<float4> t0 : register(t0);

SamplerComparisonState s11_s : register(s11);

SamplerState s10_s : register(s10);

SamplerState s0_s : register(s0);

#include "shared.h"

cbuffer cb5 : register(b5)
{
  float4 cb5[222];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[50];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000},
                              { 0.002000, 0.002000, 0.002000, 0},
                              { 0.002000, 0.502000, 0.002000, 0},
                              { 0.002000, 0.335333, 0.668667, 0},
                              { 0.002000, 0.252000, 0.502000, 0.750000},
                              { 0.998000, -0.002000, -0.002000, 0},
                              { 0.498000, 0.998000, -0.002000, 0},
                              { 0.331333, 0.664667, 0.998000, 0},
                              { 0.248000, 0.498000, 0.748000, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.x = v2.w * r0.w;
  r1.x = r1.x * cb5[216].y + cb5[216].z;
  r1.x = cmp(r1.x < 0);
  if (r1.x != 0) discard;
  r1.xyzw = t0.Sample(s0_s, v1.zw).xyzw;
  r1.xyzw = r1.xyzw + -r0.xyzw;
  r0.xyzw = v6.xxxx * r1.xyzw + r0.xyzw;
  r1.x = cmp(0 < cb5[221].x);
  r1.y = 1 + -v2.w;
  r1.z = -r1.y + r0.w;
  r1.z = cmp(r1.z < 0);
  r1.z = r1.x ? r1.z : 0;
  if (r1.z != 0) discard;
  r1.z = cmp(0.000000 == cb5[221].y);
  r1.w = saturate(cb5[221].y + r1.y);
  r1.w = min(r1.w, r0.w);
  r1.y = r1.w + -r1.y;
  r1.y = r1.y / cb5[221].y;
  r1.y = r1.z ? 1 : r1.y;
  r0.xyzw = v2.xyzw * r0.xyzw;
  r0.w = r1.x ? r1.y : r0.w;
  r1.x = max(cb0[14].y, 0.00999999978);
  r1.x = min(0.150000006, r1.x);
  r1.x = -0.00999999978 + r1.x;
  r1.x = 7.14285707 * r1.x;
  r1.x = r1.x * r1.x;
  r1.y = cmp(0 < r1.x);
  if (r1.y != 0) {
    r1.y = (int)cb0[11].w;
    r1.z = cmp(1 < (int)r1.y);
    if (r1.z != 0) {
      r1.z = (int)r1.y + -1;
      r2.x = 0.00200000009;
      r2.yzw = icb[r1.z+4].yzw;
      r3.xyz = float3(0,0,0);
      r1.w = 0;
      while (true) {
        r3.w = cmp((int)r1.w >= (int)r1.y);
        if (r3.w != 0) break;
        r3.w = (uint)r1.w << 2;
        r4.xyzw = cb0[r3.w+19].xyzw * v7.yyyy;
        r4.xyzw = cb0[r3.w+18].xyzw * v7.xxxx + r4.xyzw;
        r4.xyzw = cb0[r3.w+20].xyzw * v7.zzzz + r4.xyzw;
        r4.xyzw = cb0[r3.w+21].xyzw + r4.xyzw;
        r4.xyz = r4.xyz / r4.www;
        r3.w = cmp(r4.z >= 0);
        r4.w = cmp(1 >= r4.z);
        r3.w = r3.w ? r4.w : 0;
        r5.x = cmp(0.00200000009 < r4.x);
        r5.y = cmp(r4.x < 0.998000026);
        r4.w = dot(r2.xyzw, icb[r1.w+0].xyzw);
        r5.z = cmp(r4.w < r4.y);
        r4.w = dot(icb[r1.z+8].xyzw, icb[r1.w+0].xyzw);
        r5.w = cmp(r4.y < r4.w);
        r5.xyzw = r5.xyzw ? float4(1,1,1,1) : 0;
        r4.w = dot(r5.xyzw, float4(1,1,1,1));
        r4.w = cmp(r4.w == 4.000000);
        r3.w = r3.w ? r4.w : 0;
        if (r3.w != 0) {
          r3.xyz = r4.xyz;
          break;
        }
        r1.w = (int)r1.w + 1;
        r3.xyz = r4.xyz;
      }
    } else {
      r3.w = (uint)r1.w << 2;
      r2.xyzw = cb0[r3.w+19].xyzw * v7.yyyy;
      r2.xyzw = cb0[r3.w+18].xyzw * v7.xxxx + r2.xyzw;
      r2.xyzw = cb0[r3.w+20].xyzw * v7.zzzz + r2.xyzw;
      r2.xyzw = cb0[r3.w+21].xyzw + r2.xyzw;
      r3.xyz = r2.xyz / r2.www;
    }
    r1.y = t11.SampleCmp(s11_s, r3.xy, r3.z).x;
    r1.y = dot(r1.yyyy, float4(0.25,0.25,0.25,0.25));
  } else {
    r1.y = 0;
  }
  r1.y = saturate(cb0[11].x + r1.y);
  r1.x = r1.y * r1.x;
  r1.yzw = cb0[16].xxx * cb0[15].xyz;
  r2.xyz = cb5[218].xyz * cb5[218].www;
  r2.xyz = v5.xxx * r2.xyz;
  r1.xyz = r1.yzw * r1.xxx + r2.xyz;
  r1.xyz = v5.zzz * r1.xyz;
  r0.xyz = r0.xyz * r1.xyz + v4.xyz;
  r1.x = max(cb0[10].w, v6.y);
  r1.x = saturate(min(v7.w, r1.x));
  r1.yzw = cb0[16].zzz * cb0[10].xyz;
  r0.xyz = -cb0[10].xyz * cb0[16].zzz + r0.xyz;
  r0.xyz = r1.xxx * r0.xyz + r1.yzw;
  r1.xy = v0.xy * cb0[7].xy + cb0[8].xy;
  r1.x = t10.Sample(s10_s, r1.xy).x;
  r1.x = r1.x * cb0[9].z + cb0[9].w;
  r1.x = 1 / r1.x;
  r1.x = saturate(r1.x * v6.z + v6.w);
  o0.w = r1.x * r0.w;
  o0.xyz = float3(0.0009765625,0.0009765625,0.0009765625) * r0.xyz;


  return;
}