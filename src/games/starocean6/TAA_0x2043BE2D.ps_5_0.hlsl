// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 05 03:07:23 2025
#include "shared.h"
cbuffer cb_gp : register(b2)
{
  float4 cvConst_0 : packoffset(c0);
  float4 cvConst_1 : packoffset(c1);
  float4 cvConst_2 : packoffset(c2);
  float4 cvConst_3 : packoffset(c3);
  float4 cvConst_4 : packoffset(c4);
  float4 cvConst_5 : packoffset(c5);
  float4 cvConst_6 : packoffset(c6);
  float4 cvConst_7 : packoffset(c7);
  float4 cvConst_8 : packoffset(c8);
  float4 cvConst_9 : packoffset(c9);
  float4 cvConst_10 : packoffset(c10);
  float4 cvConst_11 : packoffset(c11);
  float4 cvConst_12 : packoffset(c12);
  float4 cvConst_13 : packoffset(c13);
  float4 cvConst_14 : packoffset(c14);
  float4 cvConst_15 : packoffset(c15);
  float4 cvConst_16 : packoffset(c16);
  float4 cvConst_17 : packoffset(c17);
  float4 cvConst_18 : packoffset(c18);
  float4 cvConst_19 : packoffset(c19);
  float4 cvConst_20 : packoffset(c20);
  float4 cvConst_21 : packoffset(c21);
  float4 cvConst_22 : packoffset(c22);
  float4 cvConst_23 : packoffset(c23);
  float4 cvConst_24 : packoffset(c24);
  float4 cvUVOffsetTBR[5] : packoffset(c27);
  float4 cvConst_48 : packoffset(c48);
  float4 cvConst_95 : packoffset(c95);
}

SamplerState asTexSamp_0__s : register(s0);
SamplerState asTexSamp_3__s : register(s3);
Texture2D<float4> asTexObject_0_ : register(t0);
Texture2D<float4> asTexObject_3_ : register(t3);
Texture2D<uint2> tStencil : register(t4);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  uint v2 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (shader_injection.taa == 1.f) {
    o0.xyzw = asTexObject_3_.Sample(asTexSamp_0__s, v1.xy).xyzw;
    o0.w = 1;
    return;
  }

  r0.xy = cvConst_1.xy * v1.xy;
  r0.zw = v1.xy * cvConst_1.xy + cvConst_2.zw;
  r1.xy = floor(r0.zw);
  r1.xy = float2(0.5,0.5) + r1.xy;
  r2.xy = -r1.xy + r0.zw;
  r3.yz = cvConst_1.wz * r1.yx;
  r3.xw = r1.xy * cvConst_1.zw + -cvConst_1.zw;
  r1.xy = r1.xy * cvConst_1.zw + cvConst_1.zw;
  r4.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.zy).xyz;
  r0.z = dot(r2.xy, r2.xy);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r5.xyzw = float4(-1,-1,1,1) + r2.xyxy;
  r6.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.xw).xyz;
  r7.x = dot(float3(0.25,0.5,0.25), r6.xyz);
  r0.w = dot(r5.xy, r5.xy);
  r0.w = cvConst_4.z * -r0.w;
  r0.w = 1.44269502 * r0.w;
  r0.w = exp2(r0.w);
  r4.w = max(0, r7.x);
  r4.w = r4.w * cvConst_3.w + 1;
  r0.w = r0.w / r4.w;
  r4.w = r0.z + r0.w;
  r8.xyz = r6.xyz * r0.www;
  r8.xyz = r4.xyz * r0.zzz + r8.xyz;
  r9.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.zw).xyz;
  r10.x = dot(float3(0.25,0.5,0.25), r9.xyz);
  r2.zw = float2(-1,-1) + r2.yx;
  r0.z = dot(r2.xz, r2.xz);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r0.w = max(0, r10.x);
  r0.w = r0.w * cvConst_3.w + 1;
  r0.z = r0.z / r0.w;
  r0.w = r4.w + r0.z;
  r8.xyz = r9.xyz * r0.zzz + r8.xyz;
  r1.zw = r3.wy;
  r11.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xz).xyz;
  r12.x = dot(float3(0.25,0.5,0.25), r11.xyz);
  r0.z = dot(r5.yz, r5.yz);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.z = max(0, r12.x);
  r1.z = r1.z * cvConst_3.w + 1;
  r0.z = r0.z / r1.z;
  r0.w = r0.w + r0.z;
  r8.xyz = r11.xyz * r0.zzz + r8.xyz;
  r13.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.xy).xyz;
  r14.x = dot(float3(0.25,0.5,0.25), r13.xyz);
  r15.xyzw = float4(-1,0,1,0) + r2.xyxy;
  r0.z = dot(r2.wy, r15.xy);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.z = max(0, r14.x);
  r1.z = r1.z * cvConst_3.w + 1;
  r0.z = r0.z / r1.z;
  r0.w = r0.w + r0.z;
  r8.xyz = r13.xyz * r0.zzz + r8.xyz;
  r16.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xw).xyz;
  r17.x = dot(float3(0.25,0.5,0.25), r16.xyz);
  r0.z = dot(r15.zw, r15.zw);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.z = max(0, r17.x);
  r1.z = r1.z * cvConst_3.w + 1;
  r0.z = r0.z / r1.z;
  r0.w = r0.w + r0.z;
  r8.xyz = r16.xyz * r0.zzz + r8.xyz;
  r3.y = r1.y;
  r15.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.xy).xyz;
  r18.x = dot(float3(0.25,0.5,0.25), r15.xyz);
  r0.z = dot(r5.xw, r5.xw);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.z = max(0, r18.x);
  r1.z = r1.z * cvConst_3.w + 1;
  r0.z = r0.z / r1.z;
  r0.w = r0.w + r0.z;
  r8.xyz = r15.xyz * r0.zzz + r8.xyz;
  r3.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r3.zy).xyz;
  r19.x = dot(float3(0.25,0.5,0.25), r3.xyz);
  r1.zw = float2(0,1) + r2.xy;
  r0.z = dot(r1.zw, r1.zw);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.z = max(0, r19.x);
  r1.z = r1.z * cvConst_3.w + 1;
  r0.z = r0.z / r1.z;
  r0.w = r0.w + r0.z;
  r2.xyz = r3.xyz * r0.zzz + r8.xyz;
  // o0 = r2;
  // return;
  r1.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xy).xyz;
  r8.x = dot(float3(0.25,0.5,0.25), r1.xyz);
  r0.z = dot(r5.zw, r5.zw);
  r0.z = cvConst_4.z * -r0.z;
  r0.z = 1.44269502 * r0.z;
  r0.z = exp2(r0.z);
  r1.w = max(0, r8.x);
  r1.w = r1.w * cvConst_3.w + 1;
  r0.z = r0.z / r1.w;
  r0.w = r0.w + r0.z;
  r2.xyz = r1.xyz * r0.zzz + r2.xyz;
  r2.xyz = r2.xyz / r0.www;
  r0.z = cmp(0.000000 == cvConst_4.w);
  if (r0.z != 0) {
    r5.xyzw = asTexObject_0_.Sample(asTexSamp_3__s, v1.xy).xyzw;
    r5.xyz = cvConst_2.yyy * r5.xyz;
    r20.x = dot(float3(0.25,0.5,0.25), r4.xyz);
    r20.y = dot(float2(0.5,-0.5), r4.xz);
    r20.z = dot(float3(-0.25,0.5,-0.25), r4.xyz);
    r7.y = dot(float2(0.5,-0.5), r6.xz);
    r7.z = dot(float3(-0.25,0.5,-0.25), r6.xyz);
    r4.xyz = min(r20.xyz, r7.xyz);
    r6.xyz = max(r20.xyz, r7.xyz);
    r10.y = dot(float2(0.5,-0.5), r9.xz);
    r10.z = dot(float3(-0.25,0.5,-0.25), r9.xyz);
    r4.xyz = min(r10.xyz, r4.xyz);
    r6.xyz = max(r10.xyz, r6.xyz);
    r12.y = dot(float2(0.5,-0.5), r11.xz);
    r12.z = dot(float3(-0.25,0.5,-0.25), r11.xyz);
    r4.xyz = min(r12.xyz, r4.xyz);
    r6.xyz = max(r12.xyz, r6.xyz);
    r14.y = dot(float2(0.5,-0.5), r13.xz);
    r14.z = dot(float3(-0.25,0.5,-0.25), r13.xyz);
    r4.xyz = min(r14.xyz, r4.xyz);
    r6.xyz = max(r14.xyz, r6.xyz);
    r17.y = dot(float2(0.5,-0.5), r16.xz);
    r17.z = dot(float3(-0.25,0.5,-0.25), r16.xyz);
    r4.xyz = min(r17.xyz, r4.xyz);
    r6.xyz = max(r17.xyz, r6.xyz);
    r18.y = dot(float2(0.5,-0.5), r15.xz);
    r18.z = dot(float3(-0.25,0.5,-0.25), r15.xyz);
    r4.xyz = min(r18.xyz, r4.xyz);
    r6.xyz = max(r18.xyz, r6.xyz);
    r19.y = dot(float2(0.5,-0.5), r3.xz);
    r19.z = dot(float3(-0.25,0.5,-0.25), r3.xyz);
    r3.xyz = min(r19.xyz, r4.xyz);
    r4.xyz = max(r19.xyz, r6.xyz);
    r8.y = dot(float2(0.5,-0.5), r1.xz);
    r8.z = dot(float3(-0.25,0.5,-0.25), r1.xyz);
    r1.xyz = min(r8.xyz, r3.xyz);
    r3.xyz = max(r8.xyz, r4.xyz);
    r4.x = dot(float3(0.25,0.5,0.25), r5.xyz);
    r4.y = dot(float2(0.5,-0.5), r5.xz);
    r4.z = dot(float3(-0.25,0.5,-0.25), r5.xyz);
    r1.xyz = max(r4.xyz, r1.xyz);
    r1.xyz = min(r1.xyz, r3.xyz);
    r3.x = dot(float3(1,1,-1), r1.xyz);
    r3.y = dot(float2(1,1), r1.xz);
    r3.z = dot(float3(1,-1,-1), r1.xyz);
    r0.xy = (int2)r0.xy;
    r1.x = (uint)cvConst_4.y;
    r1.x = 1 << (int)r1.x;
    r0.zw = float2(0,0);
    r0.x = tStencil.Load(r0.xyz).y;
    r0.x = (int)r1.x & (int)r0.x;
    r0.y = max(cvConst_4.x, r5.w);
    r2.w = r0.x ? r0.y : r5.w;
    r0.x = 1 + -r2.w;
    r0.y = dot(float3(0.25,0.5,0.25), r3.xyz);
    r0.y = max(0, r0.y);
    r0.y = r0.y * cvConst_3.w + 1;
    r0.x = r0.x / r0.y;
    r0.z = dot(float3(0.25,0.5,0.25), r2.xyz);
    r0.z = max(0, r0.z);
    r0.z = r0.z * cvConst_3.w + 1;
    r0.y = r2.w / r0.z;
    r0.z = r0.x + r0.y;
    r0.z = rcp(r0.z);
    r0.xy = r0.xy * r0.zz;
    r0.yzw = r2.xyz * r0.yyy;
    r2.xyz = r3.xyz * r0.xxx + r0.yzw;
  } else {
    r2.w = 1;
  }
  r0.xyzw = (int4)r2.xyzw & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r0.xyzw = cmp((int4)r0.xyzw == int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  r0.x = (int)r0.w | (int)r0.x;
  o0.xyzw = r0.xxxx ? float4(0,0,0,1) : r2.xyzw;
  return;
}