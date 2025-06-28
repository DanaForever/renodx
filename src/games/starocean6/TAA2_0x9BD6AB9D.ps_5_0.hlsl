// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 05 03:30:26 2025
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
Texture2D<float4> asTexObject_1_ : register(t1);
Texture2D<float4> asTexObject_2_ : register(t2);
Texture2D<float4> asTexObject_3_ : register(t3);
Texture2D<uint2> tStencil : register(t4);
Texture2D<float4> asTexObject_5_ : register(t5);
Texture2D<float4> asTexObject_6_ : register(t6);


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
  r0.xy = (int2)r0.xy;
  r1.xyzw = (int4)r0.xyxy + int4(-2,-2,2,2);
  r2.xy = max(int2(0,0), (int2)r1.xy);
  r1.xy = (int2)r1.zw;
  r1.zw = cvConst_1.xy + float2(-1,-1);
  r1.xy = min(r1.xy, r1.zw);
  r1.xy = (int2)r1.xy;
  r0.z = 0;
  r0.w = asTexObject_1_.Load(r0.xyz).x;
  r2.z = 0;
  r2.w = asTexObject_1_.Load(r2.xyz).x;
  r3.x = cmp(r0.w < r2.w);
  r3.xyz = r3.xxx ? r2.xyw : r0.xyw;
  r1.zw = r2.yz;
  r4.z = asTexObject_1_.Load(r1.xzw).x;
  r0.w = cmp(r3.z < r4.z);
  r4.xy = r1.xz;
  r3.xyz = r0.www ? r4.xyz : r3.xyz;
  r2.y = r1.y;
  r2.w = asTexObject_1_.Load(r2.xyz).x;
  r0.w = cmp(r3.z < r2.w);
  r2.xyz = r0.www ? r2.xyw : r3.xyz;
  r0.w = asTexObject_1_.Load(r1.xyw).x;
  r0.w = cmp(r2.z < r0.w);
  r1.xy = r0.ww ? r1.xy : r2.xy;
  r1.zw = float2(0,0);
  r1.xy = asTexObject_2_.Load(r1.xyz).xy;
  r1.zw = v1.xy + -r1.xy;
  r2.xy = float2(-0.5,-0.5) + r1.zw;
  r2.xy = cmp(abs(r2.xy) < float2(0.5,0.5));
  r0.w = r2.y ? r2.x : 0;
  if (r0.w != 0) {
    r0.w = asTexObject_5_.Load(r0.xyz).x;
    r2.x = cmp(r0.w >= 0);
    if (r2.x != 0) {
      r0.w = abs(r0.w) * cvConst_6.x + cvConst_6.y;
      r2.x = cmp(r0.w < cvConst_5.y);
      if (r2.x != 0) {
        r2.xy = cvConst_1.xy * r1.zw;
        r2.xy = (int2)r2.xy;
        r2.zw = float2(0,0);
        r2.x = asTexObject_6_.Load(r2.xyz).x;
        r2.z = abs(r2.x) * cvConst_6.z + cvConst_6.w;
        r3.x = r2.z * cvConst_8.x + cvConst_8.y;
        r3.yz = r1.zw * float2(2,-2) + float2(-1,1);
        r3.xy = r3.yz * r3.xx + cvConst_7.zw;
        r2.xy = cvConst_7.xy * r3.xy;
        r2.w = 1;
        r2.x = dot(r2.xyzw, cvConst_9.xyzw);
        r2.x = -r2.x + r0.w;
        r0.w = cvConst_5.x * r0.w;
        r0.w = cmp(r0.w >= r2.x);
      } else {
        r0.w = -1;
      }
    } else {
      r0.w = -1;
    }
    if (r0.w != 0) {
      r2.xyzw = asTexObject_0_.Sample(asTexSamp_3__s, r1.zw).xyzw;
      r1.xy = cvConst_1.xy * r1.xy;
      r0.w = dot(r1.xy, r1.xy);
      r0.w = saturate(cvConst_3.z * r0.w);
      r1.x = cvConst_3.y + -cvConst_3.x;
      r0.w = r0.w * r1.x + cvConst_3.x;
      r1.x = 1 + r2.w;
      r1.x = r2.w / r1.x;
      r0.w = max(r1.x, r0.w);
    } else {
      r2.xyz = float3(0,0,0);
      r0.w = 1;
    }
  } else {
    r2.xyz = float3(0,0,0);
    r0.w = 1;
  }
  r1.xy = v1.xy * cvConst_1.xy + cvConst_2.zw;
  r1.zw = floor(r1.xy);
  r1.zw = float2(0.5,0.5) + r1.zw;
  r3.xy = r1.xy + -r1.zw;
  r4.yz = cvConst_1.wz * r1.wz;
  r4.xw = r1.zw * cvConst_1.zw + -cvConst_1.zw;
  r1.xy = r1.zw * cvConst_1.zw + cvConst_1.zw;
  r5.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.zy).xyz;
  r2.w = dot(r3.xy, r3.xy);
  r2.w = cvConst_4.z * -r2.w;
  r2.w = 1.44269502 * r2.w;
  r2.w = exp2(r2.w);
  r6.xyzw = float4(-1,-1,1,1) + r3.xyxy;
  r7.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.xw).xyz;
  r8.x = dot(float3(0.25,0.5,0.25), r7.xyz);
  r5.w = dot(r6.xy, r6.xy);
  r5.w = cvConst_4.z * -r5.w;
  r5.w = 1.44269502 * r5.w;
  r5.w = exp2(r5.w);
  r7.w = max(0, r8.x);
  r7.w = r7.w * cvConst_3.w + 1;
  r5.w = r5.w / r7.w;
  r7.w = r5.w + r2.w;
  r9.xyz = r7.xyz * r5.www;
  r9.xyz = r5.xyz * r2.www + r9.xyz;
  r10.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.zw).xyz;
  r11.x = dot(float3(0.25,0.5,0.25), r10.xyz);
  r3.zw = float2(-1,-1) + r3.yx;
  r2.w = dot(r3.xz, r3.xz);
  r2.w = cvConst_4.z * -r2.w;
  r2.w = 1.44269502 * r2.w;
  r2.w = exp2(r2.w);
  r3.z = max(0, r11.x);
  r3.z = r3.z * cvConst_3.w + 1;
  r2.w = r2.w / r3.z;
  r3.z = r7.w + r2.w;
  r9.xyz = r10.xyz * r2.www + r9.xyz;
  r1.zw = r4.wy;
  r12.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xz).xyz;
  r13.x = dot(float3(0.25,0.5,0.25), r12.xyz);
  r1.z = dot(r6.yz, r6.yz);
  r1.z = cvConst_4.z * -r1.z;
  r1.z = 1.44269502 * r1.z;
  r1.z = exp2(r1.z);
  r2.w = max(0, r13.x);
  r2.w = r2.w * cvConst_3.w + 1;
  r1.z = r1.z / r2.w;
  r2.w = r3.z + r1.z;
  r9.xyz = r12.xyz * r1.zzz + r9.xyz;
  r14.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.xy).xyz;
  r15.x = dot(float3(0.25,0.5,0.25), r14.xyz);
  r16.xyzw = float4(-1,0,1,0) + r3.xyxy;
  r1.z = dot(r3.wy, r16.xy);
  r1.z = cvConst_4.z * -r1.z;
  r1.z = 1.44269502 * r1.z;
  r1.z = exp2(r1.z);
  r3.z = max(0, r15.x);
  r3.z = r3.z * cvConst_3.w + 1;
  r1.z = r1.z / r3.z;
  r2.w = r2.w + r1.z;
  r9.xyz = r14.xyz * r1.zzz + r9.xyz;
  r17.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xw).xyz;
  r18.x = dot(float3(0.25,0.5,0.25), r17.xyz);
  r1.z = dot(r16.zw, r16.zw);
  r1.z = cvConst_4.z * -r1.z;
  r1.z = 1.44269502 * r1.z;
  r1.z = exp2(r1.z);
  r1.w = max(0, r18.x);
  r1.w = r1.w * cvConst_3.w + 1;
  r1.z = r1.z / r1.w;
  r1.w = r2.w + r1.z;
  r9.xyz = r17.xyz * r1.zzz + r9.xyz;
  r4.y = r1.y;
  r16.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.xy).xyz;
  r19.x = dot(float3(0.25,0.5,0.25), r16.xyz);
  r1.z = dot(r6.xw, r6.xw);
  r1.z = cvConst_4.z * -r1.z;
  r1.z = 1.44269502 * r1.z;
  r1.z = exp2(r1.z);
  r2.w = max(0, r19.x);
  r2.w = r2.w * cvConst_3.w + 1;
  r1.z = r1.z / r2.w;
  r1.w = r1.w + r1.z;
  r9.xyz = r16.xyz * r1.zzz + r9.xyz;
  r4.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r4.zy).xyz;
  r20.x = dot(float3(0.25,0.5,0.25), r4.xyz);
  r3.xy = float2(0,1) + r3.xy;
  r1.z = dot(r3.xy, r3.xy);
  r1.z = cvConst_4.z * -r1.z;
  r1.z = 1.44269502 * r1.z;
  r1.z = exp2(r1.z);
  r2.w = max(0, r20.x);
  r2.w = r2.w * cvConst_3.w + 1;
  r1.z = r1.z / r2.w;
  r1.w = r1.w + r1.z;
  r3.xyz = r4.xyz * r1.zzz + r9.xyz;
  r1.xyz = asTexObject_3_.Sample(asTexSamp_0__s, r1.xy).xyz;
  r9.x = dot(float3(0.25,0.5,0.25), r1.xyz);
  r2.w = dot(r6.zw, r6.zw);
  r2.w = cvConst_4.z * -r2.w;
  r2.w = 1.44269502 * r2.w;
  r2.w = exp2(r2.w);
  r3.w = max(0, r9.x);
  r3.w = r3.w * cvConst_3.w + 1;
  r2.w = r2.w / r3.w;
  r1.w = r2.w + r1.w;
  r3.xyz = r1.xyz * r2.www + r3.xyz;
  r3.xyz = r3.xyz / r1.www;
  r1.w = cmp(0.000000 == cvConst_4.w);
  if (r1.w != 0) {
    r2.xyz = cvConst_2.xxx * r2.xyz;
    r2.xyz = cvConst_2.yyy * r2.xyz;
    r6.x = dot(float3(0.25,0.5,0.25), r5.xyz);
    r6.y = dot(float2(0.5,-0.5), r5.xz);
    r6.z = dot(float3(-0.25,0.5,-0.25), r5.xyz);
    r8.y = dot(float2(0.5,-0.5), r7.xz);
    r8.z = dot(float3(-0.25,0.5,-0.25), r7.xyz);
    r5.xyz = min(r8.xyz, r6.xyz);
    r6.xyz = max(r8.xyz, r6.xyz);
    r11.y = dot(float2(0.5,-0.5), r10.xz);
    r11.z = dot(float3(-0.25,0.5,-0.25), r10.xyz);
    r5.xyz = min(r11.xyz, r5.xyz);
    r6.xyz = max(r11.xyz, r6.xyz);
    r13.y = dot(float2(0.5,-0.5), r12.xz);
    r13.z = dot(float3(-0.25,0.5,-0.25), r12.xyz);
    r5.xyz = min(r13.xyz, r5.xyz);
    r6.xyz = max(r13.xyz, r6.xyz);
    r15.y = dot(float2(0.5,-0.5), r14.xz);
    r15.z = dot(float3(-0.25,0.5,-0.25), r14.xyz);
    r5.xyz = min(r15.xyz, r5.xyz);
    r6.xyz = max(r15.xyz, r6.xyz);
    r18.y = dot(float2(0.5,-0.5), r17.xz);
    r18.z = dot(float3(-0.25,0.5,-0.25), r17.xyz);
    r5.xyz = min(r18.xyz, r5.xyz);
    r6.xyz = max(r18.xyz, r6.xyz);
    r19.y = dot(float2(0.5,-0.5), r16.xz);
    r19.z = dot(float3(-0.25,0.5,-0.25), r16.xyz);
    r5.xyz = min(r19.xyz, r5.xyz);
    r6.xyz = max(r19.xyz, r6.xyz);
    r20.y = dot(float2(0.5,-0.5), r4.xz);
    r20.z = dot(float3(-0.25,0.5,-0.25), r4.xyz);
    r4.xyz = min(r20.xyz, r5.xyz);
    r5.xyz = max(r20.xyz, r6.xyz);
    r9.y = dot(float2(0.5,-0.5), r1.xz);
    r9.z = dot(float3(-0.25,0.5,-0.25), r1.xyz);
    r1.xyz = min(r9.xyz, r4.xyz);
    r4.xyz = max(r9.xyz, r5.xyz);
    r5.x = dot(float3(0.25,0.5,0.25), r2.xyz);
    r5.y = dot(float2(0.5,-0.5), r2.xz);
    r5.z = dot(float3(-0.25,0.5,-0.25), r2.xyz);
    r1.xyz = max(r5.xyz, r1.xyz);
    r1.xyz = min(r1.xyz, r4.xyz);
    r2.x = dot(float3(1,1,-1), r1.xyz);
    r2.y = dot(float2(1,1), r1.xz);
    r2.z = dot(float3(1,-1,-1), r1.xyz);
    r1.x = (uint)cvConst_4.y;
    r1.x = 1 << (int)r1.x;
    r0.x = tStencil.Load(r0.xyz).y;
    r0.x = (int)r1.x & (int)r0.x;
    r0.y = max(cvConst_4.x, r0.w);
    r3.w = r0.x ? r0.y : r0.w;
    r0.x = 1 + -r3.w;
    r0.y = dot(float3(0.25,0.5,0.25), r2.xyz);
    r0.y = max(0, r0.y);
    r0.y = r0.y * cvConst_3.w + 1;
    r0.x = r0.x / r0.y;
    r0.z = dot(float3(0.25,0.5,0.25), r3.xyz);
    r0.z = max(0, r0.z);
    r0.z = r0.z * cvConst_3.w + 1;
    r0.y = r3.w / r0.z;
    r0.z = r0.x + r0.y;
    r0.z = rcp(r0.z);
    r0.xy = r0.xy * r0.zz;
    r0.yzw = r3.xyz * r0.yyy;
    r3.xyz = r2.xyz * r0.xxx + r0.yzw;
  } else {
    r3.w = 1;
  }
  r0.xyzw = (int4)r3.xyzw & int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000);
  r0.xyzw = cmp((int4)r0.xyzw == int4(0x7f800000,0x7f800000,0x7f800000,0x7f800000));
  r0.x = (int)r0.y | (int)r0.x;
  r0.x = (int)r0.z | (int)r0.x;
  r0.x = (int)r0.w | (int)r0.x;
  o0.xyzw = r0.xxxx ? float4(0,0,0,1) : r3.xyzw;
  return;
}