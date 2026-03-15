// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 15:52:21 2025
#include "shared.h"
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[138];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float4 v7 : TEXCOORD5,
  float4 v8 : TEXCOORD6,
  float4 v9 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.x = v0.w * r0.w;
  r1.z = cmp(0 != cb0[0].w);
  r1.z = ~(int)r1.z;
  r2.x = cb0[0].x;
  r2.y = 0.00400000019;
  r1.y = r0.w;
  r1.yw = -r2.xy + r1.yx;
  r1.yw = cmp(r1.yw < float2(0,0));
  r0.w = (int)r1.w | (int)r1.y;
  r0.w = r1.z ? r0.w : 0;
  if (r0.w != 0) discard;
  r0.w = cmp(0 < cb0[8].w);
  if (r0.w != 0) {
    r0.w = -cb0[8].z + v9.w;
    r0.w = r0.w / cb0[8].w;
    r0.w = min(1, r0.w);
    r1.y = cmp(0 != cb0[1].z);
    if (r1.y != 0) {
      r1.yw = float2(0.25,0.25) * v9.yx;
      r2.xy = cmp(r1.yw >= -r1.yw);
      r1.yw = frac(abs(r1.yw));
      r1.yw = r2.xy ? r1.yw : -r1.yw;
      r1.yw = float2(4,4) * r1.yw;
      r1.yw = (uint2)r1.yw;
      r2.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r1.w+0].xyzw);
      r2.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r1.w+0].xyzw);
      r2.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r1.w+0].xyzw);
      r2.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r1.w+0].xyzw);
      r2.x = dot(r2.xyzw, icb[r1.y+0].xyzw);
      r2.y = 0.00400000019;
      r1.yw = -r2.xy + r0.ww;
      r1.yw = cmp(r1.yw < float2(0,0));
      r1.y = (int)r1.w | (int)r1.y;
      if (r1.y != 0) discard;
    } else {
      r1.x = r1.x * r0.w;
      r0.w = cmp(r1.x < 0.00400000019);
      if (r0.w != 0) discard;
    }
  }
  r0.w = cmp(0 < cb0[0].y);
  r1.y = cmp(0 >= cb0[9].w);
  r1.w = ~(int)r1.y;
  r2.x = r0.w ? r1.y : 0;
  r2.yz = cmp(float2(1,2) == cb0[0].yy);
  r2.x = r2.y ? r2.x : 0;
  if (r2.x != 0) discard;
  r1.w = r0.w ? r1.w : 0;
  r2.xyw = -cb0[9].xyz + v6.xyz;
  r2.x = dot(r2.xyw, r2.xyw);
  r2.x = sqrt(r2.x);
  r2.x = r2.x / cb0[9].w;
  r2.x = min(1, r2.x);
  r2.x = 1 + -r2.x;
  r2.x = min(0.5, r2.x);
  r2.y = r2.x + r2.x;
  r2.x = -r2.x * 2 + 1;
  r2.x = r2.z ? r2.x : r2.y;
  r2.x = r2.x * r1.x;
  r2.y = cmp(r2.x < 0.00100000005);
  r1.w = r1.w ? r2.y : 0;
  if (r1.w != 0) discard;
  r1.w = dot(v6.xyz, v6.xyz);
  r1.w = rsqrt(r1.w);
  r2.yzw = v6.xyz * r1.www;
  r3.xyz = t1.Sample(s1_s, v2.xy).xyz;
  r3.xy = r3.xy * float2(2,2) + float2(-1,-1);
  r3.w = dot(r3.xy, r3.xy);
  r3.w = 1 + -r3.w;
  r3.w = max(0, r3.w);
  r3.w = sqrt(r3.w);
  r4.xyz = v3.xyz * r3.xxx;
  r4.xyz = -v4.xyz * r3.yyy + r4.xyz;
  r3.xyw = v7.xyz * r3.www + r4.xyz;
  r4.x = dot(r3.xyw, r3.xyw);
  r4.x = rsqrt(r4.x);
  r3.xyw = r4.xxx * r3.xyw;
  r2.y = dot(-r2.yzw, r3.xyw);
  r2.y = saturate(1 + -r2.y);
  r2.z = cmp(cb0[8].y < 10);
  float y = r2.y;
  // r2.y = log2(r2.y);
  // r2.w = cb0[8].y * r2.y;
  // r2.w = exp2(r2.w);
  r2.w = renodx::math::SafePow(r2.y, cb0[8].y);
  r2.w = 1 + -r2.w;
  r4.x = cmp(r2.w < cb0[0].x);
  r1.z = r1.z ? r4.x : 0;
  r1.z = r1.z ? r2.z : 0;
  if (r1.z != 0) discard;
  r1.y = r1.y ? r1.x : r2.x;
  r0.w = r0.w ? r1.y : r1.x;
  r1.x = r0.w * r2.w;
  r4.xyz = v0.xyz * r0.xyz;
  r5.xyz = cb0[4].xyz * r4.xyz;
  r0.w = r2.z ? r1.x : r0.w;
  r1.x = dot(r3.xyw, cb0[7].xyz);
  r1.x = saturate(1 + -r1.x);
  // r1.x = log2(r1.x);
  // r1.x = cb0[7].w * r1.x;
  // r1.x = exp2(r1.x);
  r1.x = renodx::math::SafePow(r1.x, cb0[7].w);
  r1.y = (int)cb0[1].w;
  r1.z = cmp(0 < cb0[5].w);
  r2.xzw = float3(0,0,0);
  r6.xyz = float3(0,0,0);
  r4.w = 0;
  while (true) {
    r5.w = cmp((int)r4.w >= (int)r1.y);
    if (r5.w != 0) break;
    r5.w = (uint)r4.w << 1;
    r7.xyz = cb0[r5.w+10].xyz + -v6.xyz;
    r6.w = dot(r7.xyz, r7.xyz);
    r7.w = sqrt(r6.w);
    r6.w = cmp(r7.w >= cb0[r5.w+10].w);
    if (r6.w != 0) {
      r6.w = (int)r4.w + 1;
      r4.w = r6.w;
      continue;
    }
    r8.x = r7.w;
    r8.w = cb0[r5.w+10].w;
    r7.xyzw = r7.xyzw / r8.xxxw;
    r6.w = 1 + -r7.w;
    // r6.w = log2(r6.w);
    // r6.w = cb0[r5.w+11].w * r6.w;
    // r6.w = exp2(r6.w);
    r6.w = renodx::math::SafePow(r6.w, cb0[r5.w + 11]);
    r8.xyz = -v6.xyz * r1.www + r7.xyz;
    r7.w = dot(r8.xyz, r8.xyz);
    r7.w = rsqrt(r7.w);
    r8.xyz = r8.xyz * r7.www;
    r7.x = dot(r7.xyz, r3.xyw);
    r7.y = dot(r8.xyz, r3.xyw);
    r7.z = cmp(r7.x >= 0);
    r8.x = max(0, r7.x);
    r7.x = cmp(r7.y >= 0);
    r7.x = r7.z ? r7.x : 0;
    // r7.y = log2(r7.y);
    // r7.y = cb0[5].w * r7.y;
    // r7.y = exp2(r7.y);
    r7.y = renodx::math::SafePow(r7.y, cb0[5].w);
    r8.y = r7.x ? r7.y : 0;
    r7.xy = r8.xy * r6.ww;
    r2.xzw = cb0[r5.w+11].xyz * r7.xxx + r2.xzw;
    if (r1.z != 0) {
      r6.xyz = cb0[r5.w+11].xyz * r7.yyy + r6.xyz;
    }
    r4.w = (int)r4.w + 1;
  }
  r1.yz = float2(0.224250004,0.440250009) * r2.xz;
  r1.y = r1.y + r1.z;
  r1.y = r2.w * 0.0855000019 + r1.y;
  r1.y = saturate(1 + -r1.y);
  r1.x = r1.x * r1.y;
  r0.xyz = r2.xzw * r0.xyz;
  r4.xyz = r4.xyz * cb0[4].xyz + r0.xyz;
  r0.xyz = -r5.xyz * r0.xyz + r4.xyz;
  r4.xyz = cb0[4].xyz + r2.xzw;
  r2.xzw = -r2.xzw * cb0[4].xyz + r4.xyz;
  r2.xzw = cb0[6].xyz * r2.xzw;
  // r1.y = cb0[6].w * r2.y;
  // r1.y = exp2(r1.y);
  r1.y = renodx::math::SafePow(y, cb0[6].w);
  r2.xyz = r2.xzw * r1.yyy + v1.xyz;
  r2.xyz = r6.xyz * r3.zzz + r2.xyz;
  r4.xyz = cb0[2].xyz * r0.xyz + -r0.xyz;
  r0.xyz = r1.xxx * r4.xyz + r0.xyz;
  r1.yzw = -v6.xyz * r1.www + cb0[7].xyz;
  r2.w = dot(r1.yzw, r1.yzw);
  r2.w = rsqrt(r2.w);
  r1.yzw = r2.www * r1.yzw;
  // r1.y = saturate(dot(r1.yzw, r3.xyw));
  r1.y = (dot(r1.yzw, r3.xyw));
  // r1.y = log2(r1.y);
  // r1.y = cb0[5].w * r1.y;
  // r1.y = exp2(r1.y);
  r1.y = renodx::math::SafePow(r1.y, cb0[5].w);
  r1.y = r1.y * r3.z;
  r4.xyz = cb0[5].xyz * cb0[4].xyz;
  r1.yzw = r4.xyz * r1.yyy;
  r2.w = cmp(cb0[8].x < 1);
  r3.z = cb0[8].x + -1;
  r1.x = r1.x * r3.z + 1;
  r4.xyz = r1.yzw * r1.xxx;
  r1.xyz = r2.www ? r4.xyz : r1.yzw;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r1.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.y = dot(v8.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = -r1.y * 0.5 + r1.x;
  r1.x = max(0, r1.x);
  r1.y = 1 + -v8.w;
  r1.y = v7.w * r1.y;
  r1.x = r1.x * r1.y;
  r1.yzw = r0.xyz * v8.www + v8.xyz;
  r2.xyz = r1.xxx * r0.xyz;
  r0.xyz = r0.xyz * r1.xxx + r1.yzw;
  r0.xyz = -r1.yzw * r2.xyz + r0.xyz;
  r1.x = cmp(0 != cb0[0].z);
  r1.y = -r0.w * v8.w + 1;
  r2.xyz = float3(1,1,1) + -r0.xyz;
  r1.yzw = r1.yyy * r2.xyz + r0.xyz;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.x = cmp(0 < cb0[1].z);
  r0.y = cmp(8.000000 == cb0[1].z);
  r1.xyz = r3.xyw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r2.xy = r1.xy;
  r2.z = v8.w;
  r1.xyz = r0.yyy ? r1.xyz : r2.xyz;
  r1.w = 1;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.w = r0.w;
  return;
}