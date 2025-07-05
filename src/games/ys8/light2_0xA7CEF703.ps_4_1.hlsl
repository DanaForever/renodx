// ---- Created with 3Dmigoto v1.3.16 on Sat Jul 05 00:36:15 2025
#include "shared.h"
cbuffer CB0 : register(b0)
{
  float altest : packoffset(c0);
  float useshadow : packoffset(c0.y);
  float mulblend : packoffset(c0.z);
  float noalpha : packoffset(c0.w);
  float znear : packoffset(c1);
  float zfar : packoffset(c1.y);
  float zwrite : packoffset(c1.z);
  float4 shadowcolor : packoffset(c2);
  float4 cascadeBound : packoffset(c3);
  float4 param : packoffset(c4);
  float2 depthuv : packoffset(c5);
  float numLight : packoffset(c1.w);

  struct
  {
    float4 pos;
    float4 color;
  } lightinfo[64] : packoffset(c6);

}

SamplerState tex_samp_s : register(s0);
SamplerState linearztex_samp_s : register(s1);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> linearztex_tex : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float w0 : TEXCOORD9,
  float4 v1 : TEXCOORD1,
  float3 v2 : TEXCOORD2,
  float4 v3 : COLOR0,
  float4 v4 : COLOR1,
  float4 v5 : TEXCOORD8,
  float4 v6 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v1.xyz, v1.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v1.xyz * r0.xxx;
  r1.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).xyzw;
  r2.xyzw = v3.xyzw * r1.xyzw;
  r3.x = cmp(0 != noalpha);
  r3.x = ~(int)r3.x;
  r4.x = -altest;
  r4.y = -0.00400000019;
  r5.x = r1.w;
  r5.y = r2.w;
  r3.yz = r5.xy + r4.xy;
  r3.yz = cmp(r3.yz < float2(0,0));
  r1.w = (int)r3.z | (int)r3.y;
  r1.w = r3.x ? r1.w : 0;
  if (r1.w != 0) discard;
  r1.w = cmp(param.x < 10);
  r0.y = dot(-r0.yzw, v2.xyz);
  // r0.y = saturate(1 + -r0.y);
  r0.y = (1 + -r0.y);
  // r0.y = log2(r0.y);
  // r0.y = param.x * r0.y;
  // r0.y = exp2(r0.y);
  r0.y = renodx::math::SafePow(r0.y, param.x);
  r0.y = 1 + -r0.y;
  r0.y = r2.w * r0.y;
  r0.z = cmp(r0.y < 0.00100000005);
  r0.z = r0.z ? r1.w : 0;
  if (r0.z != 0) discard;
  r3.w = r1.w ? r0.y : r2.w;
  r0.y = cmp(0 < param.z);
  if (r0.y != 0) {
    r0.y = -param.y + v6.w;
    r0.y = r0.y / param.z;
    r0.y = min(1, r0.y);
    r0.z = cmp(0 != zwrite);
    if (r0.z != 0) {
      r0.zw = float2(0.25,0.25) * v6.yx;
      r4.xy = cmp(r0.zw >= -r0.zw);
      r0.zw = frac(abs(r0.zw));
      r0.zw = r4.xy ? r0.zw : -r0.zw;
      r0.zw = float2(4,4) * r0.zw;
      r0.zw = (uint2)r0.zw;
      r4.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r0.w+0].xyzw);
      r4.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r0.w+0].xyzw);
      r4.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r0.w+0].xyzw);
      r4.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r0.w+0].xyzw);
      r4.x = dot(r4.xyzw, icb[r0.z+0].xyzw);
      r4.y = 0.00400000019;
      r0.zw = -r4.xy + r0.yy;
      r0.zw = cmp(r0.zw < float2(0,0));
      r0.z = (int)r0.w | (int)r0.z;
      if (r0.z != 0) discard;
    } else {
      r3.w = r3.w * r0.y;
      r0.y = cmp(r3.w < 0.00400000019);
      if (r0.y != 0) discard;
    }
  }
  r0.y = cmp(0 < param.w);
  if (r0.y != 0) {
    r0.yz = v6.xy / depthuv.xy;
    r0.yzw = linearztex_tex.Sample(linearztex_samp_s, r0.yz).xyz;
    r0.y = dot(r0.yz, float2(65536,256));
    r0.y = r0.y + r0.w;
    r0.y = saturate(1.52587891e-005 * r0.y);
    r0.y = 1 + -r0.y;
    r0.z = zfar + -znear;
    r0.y = r0.y * r0.z + znear;
    r0.y = v6.w + -r0.y;
    r0.z = cmp(r0.y >= param.w);
    if (r0.z != 0) discard;
    r0.z = cmp(0 < r0.y);
    r0.y = r0.y / param.w;
    r0.y = 1 + -r0.y;
    r0.y = r3.w * r0.y;
    r3.w = r0.z ? r0.y : r3.w;
  }
  r0.y = numLight;
  r4.xyz = float3(0,0,0);
  r5.xyz = float3(0,0,0);
  r0.z = 0;
  while (true) {
    r0.w = cmp((int)r0.z >= (int)r0.y);
    if (r0.w != 0) break;
    r0.w = (uint)r0.z << 1;
    r6.xyz = lightinfo[r0.w].pos.xyz + -v1.xyz;
    r1.w = dot(r6.xyz, r6.xyz);
    r6.w = sqrt(r1.w);
    r1.w = cmp(r6.w >= lightinfo[r0.w].pos.w);
    if (r1.w != 0) {
      r1.w = (int)r0.z + 1;
      r0.z = r1.w;
      continue;
    }
    r7.x = r6.w;
    r7.w = lightinfo[r0.w].pos.w;
    r6.xyzw = r6.xyzw / r7.xxxw;
    r1.w = 1 + -r6.w;
    // r1.w = log2(r1.w);
    // r1.w = lightinfo[r0.w].color.w * r1.w;
    // r1.w = exp2(r1.w);
    r1.w = renodx::math::SafePow(r1.w, lightinfo[r0.w].color.w);
    r7.xyz = -v1.xyz * r0.xxx + r6.xyz;
    r2.w = dot(r7.xyz, r7.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r7.xyz * r2.www;
    r2.w = dot(r6.xyz, v2.xyz);
    r4.w = dot(r7.xyz, v2.xyz);
    r5.w = cmp(r2.w >= 0);
    r6.x = max(0, r2.w);
    r2.w = cmp(r4.w >= 0);
    r2.w = r5.w ? r2.w : 0;
    r4.w = r4.w * r4.w;
    r6.y = r2.w ? r4.w : 0;
    r6.xy = r6.xy * r1.ww;
    r4.xyz = lightinfo[r0.w].color.xyz * r6.xxx + r4.xyz;
    r5.xyz = lightinfo[r0.w].color.xyz * r6.yyy + r5.xyz;
    r0.z = (int)r0.z + 1;
  }
  r0.xyz = r4.xyz * r1.xyz;
  r1.xyz = r1.xyz * v3.xyz + r0.xyz;
  r0.xyz = -r2.xyz * r0.xyz + r1.xyz;
  r1.xyz = r5.xyz * float3(0.100000001,0.100000001,0.100000001) + v4.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  // r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r0.w = renodx::color::y::from::BT709(r0.xyz);
  // r1.x = dot(v5.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = renodx::color::y::from::BT709(v5.xyz);
  r0.w = -r1.x * 0.5 + r0.w;
  r0.w = max(0, r0.w);
  r1.x = 1 + -v5.w;
  r1.x = w0.x * r1.x;
  r0.w = r1.x * r0.w;
  r1.xyz = r0.xyz * v5.www + v5.xyz;
  r2.xyz = r0.xyz * r0.www;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r0.xyz = -r1.xyz * r2.xyz + r0.xyz;
  r0.w = cmp(0 != mulblend);
  r1.x = -r3.w * v5.w + 1;
  r1.yzw = float3(1,1,1) + -r0.xyz;
  r1.xyz = r1.xxx * r1.yzw + r0.xyz;
  r3.xyz = r0.www ? r1.xyz : r0.xyz;
  r0.x = cmp(0 < zwrite);
  r0.y = cmp(8.000000 == zwrite);
  r1.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = v5.w;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.xyzw = r3.xyzw;
  return;
}