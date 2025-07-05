// ---- Created with 3Dmigoto v1.3.16 on Sat Jul 05 00:29:36 2025
#include "./shared.h"
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
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float3 v2 : TEXCOORD2,
  float4 v3 : COLOR0,
  float4 v4 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v1.xyz, v1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v1.xyz * r0.xxx;
  r1.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).xyzw;
  r2.xyzw = v3.xyzw * r1.xyzw;
  r0.w = cmp(0 != noalpha);
  r0.w = ~(int)r0.w;
  r3.x = -altest;
  r3.y = -0.00400000019;
  r4.x = r1.w;
  r4.y = r2.w;
  r3.xy = r4.xy + r3.xy;
  r3.xy = cmp(r3.xy < float2(0,0));
  r1.w = (int)r3.y | (int)r3.x;
  r0.w = r0.w ? r1.w : 0;
  if (r0.w != 0) discard;
  r0.w = cmp(param.x < 10);
  r0.x = dot(-r0.xyz, v2.xyz);
  // r0.x = saturate(1 + -r0.x);
  r0.x = (1 + -r0.x);
  // r0.x = log2(r0.x);
  // r0.x = param.x * r0.x;
  // r0.x = exp2(r0.x);
  r0.x = renodx::math::SafePow(r0.x, param.x);
  r0.x = 1 + -r0.x;
  r0.x = r2.w * r0.x;
  r0.y = cmp(r0.x < 0.00100000005);
  r0.y = r0.y ? r0.w : 0;
  if (r0.y != 0) discard;
  r0.w = r0.w ? r0.x : r2.w;
  r1.w = cmp(0 < param.z);
  if (r1.w != 0) {
    r1.w = -param.y + v4.w;
    r1.w = r1.w / param.z;
    r1.w = min(1, r1.w);
    r2.w = cmp(0 != zwrite);
    if (r2.w != 0) {
      r3.xy = float2(0.25,0.25) * v4.yx;
      r3.zw = cmp(r3.xy >= -r3.xy);
      r3.xy = frac(abs(r3.xy));
      r3.xy = r3.zw ? r3.xy : -r3.xy;
      r3.xy = float2(4,4) * r3.xy;
      r3.xy = (uint2)r3.xy;
      r4.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r3.y+0].xyzw);
      r4.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r3.y+0].xyzw);
      r4.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r3.y+0].xyzw);
      r4.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r3.y+0].xyzw);
      r3.x = dot(r4.xyzw, icb[r3.x+0].xyzw);
      r3.y = 0.00400000019;
      r3.xy = -r3.xy + r1.ww;
      r3.xy = cmp(r3.xy < float2(0,0));
      r2.w = (int)r3.y | (int)r3.x;
      if (r2.w != 0) discard;
    } else {
      r0.w = r1.w * r0.w;
      r1.w = cmp(r0.w < 0.00400000019);
      if (r1.w != 0) discard;
    }
  }
  r1.w = cmp(0 < param.w);
  if (r1.w != 0) {
    r3.xy = v4.xy / depthuv.xy;
    r3.xyz = linearztex_tex.Sample(linearztex_samp_s, r3.xy).xyz;
    r1.w = dot(r3.xy, float2(65536,256));
    r1.w = r1.w + r3.z;
    r1.w = saturate(1.52587891e-005 * r1.w);
    r1.w = 1 + -r1.w;
    r2.w = zfar + -znear;
    r1.w = r1.w * r2.w + znear;
    r1.w = v4.w + -r1.w;
    r2.w = cmp(r1.w >= param.w);
    if (r2.w != 0) discard;
    r2.w = cmp(0 < r1.w);
    r1.w = r1.w / param.w;
    r1.w = 1 + -r1.w;
    r1.w = r1.w * r0.w;
    r0.w = r2.w ? r1.w : r0.w;
  }
  r1.w = cmp(0 != mulblend);
  r2.w = 1 + -r0.w;
  r1.xyz = -r1.xyz * v3.xyz + float3(1,1,1);
  r1.xyz = r2.www * r1.xyz + r2.xyz;
  r0.xyz = r1.www ? r1.xyz : r2.xyz;
  r1.x = cmp(0 < zwrite);
  r1.y = cmp(8.000000 == zwrite);
  r2.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r2.w = 1;
  r3.xyw = r2.xyw;
  r3.z = 0;
  r2.xyzw = r1.yyyy ? r2.xyzw : r3.xyzw;
  o1.xyzw = r1.xxxx ? r2.xyzw : 0;
  o0.xyzw = r0.xyzw;
  return;
}