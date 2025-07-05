// ---- Created with 3Dmigoto v1.3.16 on Sat Jul 05 00:32:13 2025
#include "shared.h"
cbuffer CB0 : register(b0)
{
  float altest : packoffset(c0);
  float danalightmode : packoffset(c0.y);
  float mulblend : packoffset(c0.z);
  float noalpha : packoffset(c0.w);
  float znear : packoffset(c1);
  float zfar : packoffset(c1.y);
  float zwrite : packoffset(c1.z);
  float4 shadowcolor : packoffset(c2);
  float4 cascadeBound : packoffset(c3);
  float4 lightColor : packoffset(c4);
  float4 specColor : packoffset(c5);
  float4 rimcolor : packoffset(c6);
  float4 lightvec : packoffset(c7);
  float4 param : packoffset(c8);
  float4 danalight : packoffset(c9);
  float numLight : packoffset(c1.w);

  struct
  {
    float4 pos;
    float4 color;
  } lightinfo[64] : packoffset(c10);

}

SamplerState tex_samp_s : register(s0);
SamplerState normalmap_samp_s : register(s1);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> normalmap_tex : register(t1);


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

  r0.xyzw = tex_tex.Sample(tex_samp_s, v2.xy).xyzw;
  r1.x = v0.w * r0.w;
  r1.z = cmp(0 != noalpha);
  r1.z = ~(int)r1.z;
  r2.x = altest;
  r2.y = 0.00400000019;
  r1.y = r0.w;
  r1.yw = -r2.xy + r1.yx;
  r1.yw = cmp(r1.yw < float2(0,0));
  r0.w = (int)r1.w | (int)r1.y;
  r0.w = r1.z ? r0.w : 0;
  if (r0.w != 0) discard;
  r0.w = cmp(0 < param.w);
  if (r0.w != 0) {
    r0.w = -param.z + v9.w;
    r0.w = r0.w / param.w;
    r0.w = min(1, r0.w);
    r1.y = cmp(0 != zwrite);
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
  r0.w = cmp(0 < danalightmode);
  r1.y = cmp(0 >= danalight.w);
  r1.w = ~(int)r1.y;
  r2.x = r0.w ? r1.y : 0;
  r2.yz = cmp(float2(1,2) == danalightmode);
  r2.x = r2.y ? r2.x : 0;
  if (r2.x != 0) discard;
  r1.w = r0.w ? r1.w : 0;
  r2.xyw = -danalight.xyz + v6.xyz;
  r2.x = dot(r2.xyw, r2.xyw);
  r2.x = sqrt(r2.x);
  r2.x = r2.x / danalight.w;
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
  r3.xyz = normalmap_tex.Sample(normalmap_samp_s, v2.xy).xyz;
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
  r2.z = cmp(param.y < 10);
  r2.y = log2(r2.y);
  r2.w = param.y * r2.y;
  r2.w = exp2(r2.w);
  // r2.w = renodx::math::SafePow(r2.y, param.y);
  r2.w = 1 + -r2.w;
  r4.x = cmp(r2.w < altest);
  r1.z = r1.z ? r4.x : 0;
  r1.z = r1.z ? r2.z : 0;
  if (r1.z != 0) discard;
  r1.y = r1.y ? r1.x : r2.x;
  r0.w = r0.w ? r1.y : r1.x;
  r1.x = r0.w * r2.w;
  r4.xyz = v0.xyz * r0.xyz;
  r5.xyz = lightColor.xyz * r4.xyz;
  r0.w = r2.z ? r1.x : r0.w;
  r1.x = dot(r3.xyw, lightvec.xyz);
  // r1.x = saturate(1 + -r1.x);
  r1.x = (1 + -r1.x);
  // r1.x = log2(r1.x);
  // r1.x = lightvec.w * r1.x;
  // r1.x = exp2(r1.x);
  r1.x = renodx::math::SafePow(r1.x, lightvec.w);
  r1.y = numLight;
  r1.z = cmp(0 < specColor.w);
  r2.xzw = float3(0,0,0);
  r6.xyz = float3(0,0,0);
  r4.w = 0;
  while (true) {
    r5.w = cmp((int)r4.w >= (int)r1.y);
    if (r5.w != 0) break;
    r5.w = (uint)r4.w << 1;
    r7.xyz = lightinfo[r5.w].pos.xyz + -v6.xyz;
    r6.w = dot(r7.xyz, r7.xyz);
    r7.w = sqrt(r6.w);
    r6.w = cmp(r7.w >= lightinfo[r5.w].pos.w);
    if (r6.w != 0) {
      r6.w = (int)r4.w + 1;
      r4.w = r6.w;
      continue;
    }
    r8.x = r7.w;
    r8.w = lightinfo[r5.w].pos.w;
    r7.xyzw = r7.xyzw / r8.xxxw;
    r6.w = 1 + -r7.w;
    r6.w = log2(r6.w);
    r6.w = lightinfo[r5.w].color.w * r6.w;
    r6.w = exp2(r6.w);
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
    r7.y = log2(r7.y);
    r7.y = specColor.w * r7.y;
    r7.y = exp2(r7.y);
    r8.y = r7.x ? r7.y : 0;
    r7.xy = r8.xy * r6.ww;
    r2.xzw = lightinfo[r5.w].color.xyz * r7.xxx + r2.xzw;
    if (r1.z != 0) {
      r6.xyz = lightinfo[r5.w].color.xyz * r7.yyy + r6.xyz;
    }
    r4.w = (int)r4.w + 1;
  }
  r1.yz = float2(0.224250004,0.440250009) * r2.xz;
  r1.y = r1.y + r1.z;
  r1.y = r2.w * 0.0855000019 + r1.y;
  r1.y = saturate(1 + -r1.y);
  r1.x = r1.x * r1.y;
  r0.xyz = r2.xzw * r0.xyz;
  r4.xyz = r4.xyz * lightColor.xyz + r0.xyz;
  r0.xyz = -r5.xyz * r0.xyz + r4.xyz;
  r4.xyz = lightColor.xyz + r2.xzw;
  r2.xzw = -r2.xzw * lightColor.xyz + r4.xyz;
  r2.xzw = rimcolor.xyz * r2.xzw;
  r1.y = rimcolor.w * r2.y;
  r1.y = exp2(r1.y);
  r2.xyz = r2.xzw * r1.yyy + v1.xyz;
  r2.xyz = r6.xyz * r3.zzz + r2.xyz;
  r4.xyz = shadowcolor.xyz * r0.xyz + -r0.xyz;
  r0.xyz = r1.xxx * r4.xyz + r0.xyz;
  r1.yzw = -v6.xyz * r1.www + lightvec.xyz;
  r2.w = dot(r1.yzw, r1.yzw);
  r2.w = rsqrt(r2.w);
  r1.yzw = r2.www * r1.yzw;
  // r1.y = saturate(dot(r1.yzw, r3.xyw));
  r1.y = (dot(r1.yzw, r3.xyw));
  // r1.y = log2(r1.y);
  // r1.y = specColor.w * r1.y;
  // r1.y = exp2(r1.y);
  r1.y = renodx::math::SafePow(r1.y, specColor.w);
  r1.y = r1.y * r3.z;
  r4.xyz = specColor.xyz * lightColor.xyz;
  r1.yzw = r4.xyz * r1.yyy;
  r2.w = cmp(param.x < 1);
  r3.z = param.x + -1;
  r1.x = r1.x * r3.z + 1;
  r4.xyz = r1.yzw * r1.xxx;
  r1.xyz = r2.www ? r4.xyz : r1.yzw;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  // r1.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = renodx::color::y::from::BT709(r0.xyz);
  // r1.y = dot(v8.xyz, float3(0.298999995,0.587000012,0.114));
  r1.y = renodx::color::y::from::BT709(v8.xyz);
  r1.x = -r1.y * 0.5 + r1.x;
  r1.x = max(0, r1.x);
  r1.y = 1 + -v8.w;
  r1.y = v7.w * r1.y;
  r1.x = r1.x * r1.y;
  r1.yzw = r0.xyz * v8.www + v8.xyz;
  r2.xyz = r1.xxx * r0.xyz;
  r0.xyz = r0.xyz * r1.xxx + r1.yzw;
  r0.xyz = -r1.yzw * r2.xyz + r0.xyz;
  r1.x = cmp(0 != mulblend);
  r1.y = -r0.w * v8.w + 1;
  r2.xyz = float3(1,1,1) + -r0.xyz;
  r1.yzw = r1.yyy * r2.xyz + r0.xyz;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.x = cmp(0 < zwrite);
  r0.y = cmp(8.000000 == zwrite);
  r1.xyz = r3.xyw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r2.xy = r1.xy;
  r2.z = v8.w;
  r1.xyz = r0.yyy ? r1.xyz : r2.xyz;
  r1.w = 1;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.w = r0.w;
  return;
}