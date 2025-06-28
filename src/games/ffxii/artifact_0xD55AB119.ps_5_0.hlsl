#include "./shared.h"
// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 03 12:07:56 2025
Texture2D<float4> t13 : register(t13);

TextureCube<float4> t12 : register(t12);

TextureCube<float4> t11 : register(t11);

TextureCube<float4> t10 : register(t10);

TextureCube<float4> t9 : register(t9);

TextureCube<float4> t8 : register(t8);

TextureCube<float4> t7 : register(t7);

TextureCube<float4> t6 : register(t6);

TextureCube<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[91];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[57];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : COLOR0,
  float3 v1 : COLOR1,
  float4 v2 : SV_POSITION0,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD2,
  float4 v6 : TEXCOORD3,
  float4 v7 : TEXCOORD4,
  float4 v8 : TEXCOORD5,
  float4 v9 : TEXCOORD6,
  float4 v10 : TEXCOORD7,
  float4 v11 : TEXCOORD8,
  float3 v12 : TEXCOORD9,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1,
  out uint oMask : SV_Coverage)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cb0[25].y + v9.z;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.x = cmp(asint(cb0[50].y) == 2);
  r0.yzw = (v0.xyz);
  r0.yzw = r0.yzw + r0.yzw;
  r0.xyz = r0.xxx ? float3(1,1,1) : r0.yzw;
  if (cb0[49].x == 0) {
    r1.xy = cb0[27].xy + v3.xy;
    r1.xyzw = t0.Sample(s0_s, r1.xy).xyzw;
  } else {
    r2.xy = cb0[27].xy + v3.xy;
    t2.GetDimensions(0, fDest.x, fDest.y, fDest.z);
    r3.xy = fDest.xy;
    r4.xy = float2(1,1) / r3.xy;
    r2.z = 1 + -r2.y;
    r2.xy = r3.xy * r2.xz + float2(-0.5,-0.5);
    r2.zw = floor(r2.xy);
    r2.zw = float2(0.400000006,0.400000006) + r2.zw;
    r3.xy = r2.zw * r4.xy;
    r2.xy = frac(r2.xy);
    r3.x = t2.Sample(s4_s, r3.xy).x;
    r3.x = 255 * r3.x;
    r3.x = (uint)r3.x;
    r4.z = 0;
    r5.xyzw = r2.zwzw * r4.xyxy + r4.xzzy;
    r4.z = t2.Sample(s4_s, r5.xy).x;
    r4.z = 255 * r4.z;
    r6.x = (uint)r4.z;
    r4.z = t2.Sample(s4_s, r5.zw).x;
    r4.z = 255 * r4.z;
    r5.x = (uint)r4.z;
    r2.zw = r2.zw * r4.xy + r4.xy;
    r2.z = t2.Sample(s4_s, r2.zw).x;
    r2.z = 255 * r2.z;
    r4.x = (uint)r2.z;
    r3.yzw = float3(0,0,0);
    r3.xyzw = t1.Load(r3.xyz).xyzw;
    r6.yzw = float3(0,0,0);
    r6.xyzw = t1.Load(r6.xyz).xyzw;
    r5.yzw = float3(0,0,0);
    r5.xyzw = t1.Load(r5.xyz).xyzw;
    r4.yzw = float3(0,0,0);
    r4.xyzw = t1.Load(r4.xyz).xyzw;
    r2.zw = float2(1,1) + -r2.yx;
    r7.x = r2.w * r2.z;
    r2.zw = r2.xy * r2.zw;
    r6.xyzw = r6.xyzw * r2.zzzz;
    r3.xyzw = r3.xyzw * r7.xxxx + r6.xyzw;
    r3.xyzw = r5.xyzw * r2.wwww + r3.xyzw;
    r2.x = r2.x * r2.y;
    r1.xyzw = r4.xyzw * r2.xxxx + r3.xyzw;
  }
  r0.w = 2 * v0.w;
  r2.xyzw = r1.xyzw * r0.xyzw;
  if (cb0[49].y != 0) {
    if (cb0[49].x != 0) {
      t2.GetDimensions(0, fDest.x, fDest.y, fDest.z);
      r0.xy = fDest.xy;
    } else {
      t0.GetDimensions(0, fDest.x, fDest.y, fDest.z);
      r0.xy = fDest.xy;
    }
    r0.xy = v3.yx * r0.yx;
    r0.xy = float2(0.0625,0.0625) * r0.xy;
    r0.xy = frac(r0.xy);
    r1.xy = cmp(float2(0.5,0.5) < r0.yx);
    r0.xy = cmp(float2(0.5,0.5) >= r0.xy);
    r0.xy = r0.xy ? r1.xy : 0;
    r0.x = (int)r0.y | (int)r0.x;
    r2.xyz = r0.xxx ? float3(1,1,1) : 0;
  }
  if (cb0[49].x == 0) {
    r0.x = v0.w + v0.w;
    r3.xyzw = ddx_coarse(v3.xyxy);
    r4.xyzw = ddy_coarse(v3.xyxy);
    r0.y = cmp(asint(cb1[87].y) == 2);
    if (r0.y != 0) {
      r5.xyzw = float4(0.25,0.25,-0.25,-0.25) * r4.zwzw;
      r5.xyzw = r3.zwzw * float4(0.25,0.25,-0.25,-0.25) + r5.xyzw;
      r6.xyzw = cb0[27].xyxy + v3.xyxy;
      r5.xyzw = r6.xyzw + r5.xyzw;
      r0.y = t0.Sample(s0_s, r5.xy).w;
      r0.z = max(0.00196078443, cb0[25].x);
      r0.y = r0.x * r0.y + -r0.z;
      r0.y = cmp(r0.y >= 0);
      r1.x = r0.y ? 0.000000 : 0;
      r1.y = t0.Sample(s0_s, r5.zw).w;
      r0.z = r0.x * r1.y + -r0.z;
      r0.z = cmp(r0.z >= 0);
      bitmask.y = ((~(-1 << 1)) << 0) & 0xffffffff;  r0.y = (((uint)r0.y << 0) & bitmask.y) | ((uint)2 & ~bitmask.y);
      r0.y = r0.z ? r0.y : r1.x;
    } else {
      r0.z = cmp(asint(cb1[87].y) == 4);
      if (r0.z != 0) {
        r5.xyzw = float4(-0.375,-0.375,-0.125,-0.125) * r4.zwzw;
        r5.xyzw = r3.zwzw * float4(-0.125,-0.125,0.375,0.375) + r5.xyzw;
        r6.xyzw = cb0[27].xyxy + v3.xyxy;
        r5.xyzw = r6.zwzw + r5.xyzw;
        r0.z = t0.Sample(s0_s, r5.xy).w;
        r1.x = max(0.00196078443, cb0[25].x);
        r0.z = r0.x * r0.z + -r1.x;
        r0.z = cmp(r0.z >= 0);
        r1.y = r0.z ? 0.000000 : 0;
        r1.z = t0.Sample(s0_s, r5.zw).w;
        r1.z = r0.x * r1.z + -r1.x;
        r1.z = cmp(r1.z >= 0);
        bitmask.z = ((~(-1 << 1)) << 0) & 0xffffffff;  r0.z = (((uint)r0.z << 0) & bitmask.z) | ((uint)2 & ~bitmask.z);
        r0.z = r1.z ? r0.z : r1.y;
        r5.xyzw = float4(0.125,0.125,0.375,0.375) * r4.zwzw;
        r5.xyzw = r3.zwzw * float4(-0.375,-0.375,0.125,0.125) + r5.xyzw;
        r5.xyzw = r6.xyzw + r5.xyzw;
        r1.y = t0.Sample(s0_s, r5.xy).w;
        r1.y = r0.x * r1.y + -r1.x;
        r1.y = cmp(r1.y >= 0);
        r1.z = (int)r0.z + 4;
        r0.z = r1.y ? r1.z : r0.z;
        r1.y = t0.Sample(s0_s, r5.zw).w;
        r1.x = r0.x * r1.y + -r1.x;
        r1.x = cmp(r1.x >= 0);
        r1.y = (int)r0.z + 8;
        r0.y = r1.x ? r1.y : r0.z;
      } else {
        r0.z = cmp(asint(cb1[87].y) == 8);
        if (r0.z != 0) {
          r5.xyzw = float4(-0.1875,-0.1875,0.1875,0.1875) * r4.zwzw;
          r5.xyzw = r3.zwzw * float4(0.0625,0.0625,-0.0625,-0.0625) + r5.xyzw;
          r6.xyzw = cb0[27].xyxy + v3.xyxy;
          r5.xyzw = r6.zwzw + r5.xyzw;
          r0.z = t0.Sample(s0_s, r5.xy).w;
          r1.x = max(0.00196078443, cb0[25].x);
          r0.z = r0.x * r0.z + -r1.x;
          r0.z = cmp(r0.z >= 0);
          r1.y = r0.z ? 0.000000 : 0;
          r1.z = t0.Sample(s0_s, r5.zw).w;
          r1.z = r0.x * r1.z + -r1.x;
          r1.z = cmp(r1.z >= 0);
          bitmask.z = ((~(-1 << 1)) << 0) & 0xffffffff;  r0.z = (((uint)r0.z << 0) & bitmask.z) | ((uint)2 & ~bitmask.z);
          r0.z = r1.z ? r0.z : r1.y;
          r5.xyzw = float4(0.0625,0.0625,-0.3125,-0.3125) * r4.zwzw;
          r5.xyzw = r3.zwzw * float4(0.3125,0.3125,-0.1875,-0.1875) + r5.xyzw;
          r5.xyzw = r6.zwzw + r5.xyzw;
          r1.y = t0.Sample(s0_s, r5.xy).w;
          r1.y = r0.x * r1.y + -r1.x;
          r1.y = cmp(r1.y >= 0);
          r1.z = (int)r0.z + 4;
          r0.z = r1.y ? r1.z : r0.z;
          r1.y = t0.Sample(s0_s, r5.zw).w;
          r1.y = r0.x * r1.y + -r1.x;
          r1.y = cmp(r1.y >= 0);
          r1.z = (int)r0.z + 8;
          r0.z = r1.y ? r1.z : r0.z;
          r5.xyzw = float4(0.3125,0.3125,-0.0625,-0.0625) * r4.zwzw;
          r5.xyzw = r3.zwzw * float4(-0.3125,-0.3125,-0.4375,-0.4375) + r5.xyzw;
          r5.xyzw = r6.zwzw + r5.xyzw;
          r1.y = t0.Sample(s0_s, r5.xy).w;
          r1.y = r0.x * r1.y + -r1.x;
          r1.y = cmp(r1.y >= 0);
          r1.z = (int)r0.z + 16;
          r0.z = r1.y ? r1.z : r0.z;
          r1.y = t0.Sample(s0_s, r5.zw).w;
          r1.y = r0.x * r1.y + -r1.x;
          r1.y = cmp(r1.y >= 0);
          r1.z = (int)r0.z + 32;
          r0.z = r1.y ? r1.z : r0.z;
          r4.xyzw = float4(0.4375,0.4375,-0.4375,-0.4375) * r4.xyzw;
          r3.xyzw = r3.xyzw * float4(0.1875,0.1875,0.4375,0.4375) + r4.xyzw;
          r3.xyzw = r6.xyzw + r3.xyzw;
          r1.y = t0.Sample(s0_s, r3.xy).w;
          r1.y = r0.x * r1.y + -r1.x;
          r1.y = cmp(r1.y >= 0);
          r1.z = (int)r0.z + 64;
          r0.z = r1.y ? r1.z : r0.z;
          r1.y = t0.Sample(s0_s, r3.zw).w;
          r0.x = r0.x * r1.y + -r1.x;
          r0.x = cmp(r0.x >= 0);
          r1.x = (int)r0.z + 128;
          r0.y = r0.x ? r1.x : r0.z;
        } else {
          r0.x = max(0.00196078443, cb0[25].x);
          r0.x = r0.w * r1.w + -r0.x;
          r0.x = cmp(r0.x < 0);
          if (r0.x != 0) discard;
          r0.y = 1;
        }
      }
    }
    if (r0.y == 0) discard;
    oMask = 255;
  } else {
    r0.x = max(0.00196078443, cb0[25].x);
    r0.x = r0.w * r1.w + -r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
    oMask = 255;
  }
  r0.x = dot(v4.xyz, v4.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v4.xyz * r0.xxx;
  r0.w = cb0[43].z * cb0[43].w;
  r0.w = v8.w * -cb0[43].z + r0.w;
  r0.w = saturate(max(cb0[43].x, r0.w));
  r1.x = -0.300000012 + r0.w;
  r1.x = saturate(5 * r1.x);
  r1.y = asint(cb0[42].x);
  r1.x = -1 + r1.x;
  r1.x = r1.y * r1.x + 1;
  r3.xyzw = cb1[34].xyzw * r2.xyzw;
  r1.y = cmp(asint(cb0[50].y) != 1);
  r1.z = cmp(r1.x >= 0.0500000007);
  r4.xy = cb0[27].xy + v3.xy;
  r4.zw = t3.Sample(s1_s, r4.xy).xy;
  r1.w = cmp(asint(cb0[53].x) == 3);
  r5.xyz = r1.www ? v11.yzx : v7.yzx;
  r6.xyz = ddx_coarse(r5.yzx);
  r7.xyz = ddy_coarse(r5.xyz);
  r8.x = cb0[53].w;
  r8.y = cb0[54].x;
  r9.xyzw = r5.xyyz * r8.xyxy + cb0[53].yzyz;
  r5.xy = r5.zx * r8.xy + cb0[53].yz;
  r5.zw = t13.Sample(s3_s, r9.xy).xy;
  r8.xy = t13.Sample(s3_s, r9.zw).xy;
  r5.xy = t13.Sample(s3_s, r5.xy).xy;
  r9.xyzw = t4.Sample(s1_s, r4.xy).zxyw;
  if (r1.z != 0) {
    if (cb0[51].y != 0) {
      r1.z = dot(-cb0[55].xyz, r0.xyz);
      r4.xy = r4.zw * float2(2,2) + float2(-1,-1);
      r1.w = -r4.x * r4.x + 1;
      r1.w = -r4.y * r4.y + r1.w;
      r1.w = max(0, r1.w);
      r4.z = sqrt(r1.w);
      r1.w = dot(r4.xyz, r4.xyz);
      r1.w = rsqrt(r1.w);
      r4.xyz = r4.xyz * r1.www;
      r1.w = dot(v5.xyz, v5.xyz);
      r1.w = rsqrt(r1.w);
      r10.xyz = v5.xyz * r1.www;
      r1.w = dot(v6.xyz, v6.xyz);
      r1.w = rsqrt(r1.w);
      r11.xyz = v6.xyz * r1.www;
      r10.xyz = r10.xyz * r4.yyy;
      r4.xyw = r4.xxx * r11.xyz + r10.xyz;
      r4.xyz = r4.zzz * r0.xyz + r4.xyw;
      if (cb0[53].x != 0) {
        r10.xyz = r7.xyz * r6.xyz;
        r6.xyz = r6.zxy * r7.yzx + -r10.xyz;
        r1.w = dot(r6.xyz, r6.xyz);
        r1.w = rsqrt(r1.w);
        r6.xyz = r6.xyz * r1.www;
        r6.xyz = abs(r6.xyz) * float3(7,7,7) + float3(-3.5,-3.5,-3.5);
        r6.xyz = max(float3(0,0,0), r6.xyz);
        r1.w = r6.x + r6.y;
        r1.w = r1.w + r6.z;
        r6.xyz = r6.xyz / r1.www;
        r7.xyz = cmp(float3(0,0,0) < r6.xyz);
        r5.xyzw = r6.zzxx * r5.xyzw;
        r6.xy = r8.xy * r6.yy;
        r6.xy = r7.yy ? r6.xy : 0;
        r5.xyzw = r7.zzxx ? r5.xyzw : 0;
        r5.zw = r5.zw + r6.xy;
        r5.xy = r5.zw + r5.xy;
        r5.xy = r5.xy * float2(2,2) + float2(-1,-1);
        r1.w = -r5.x * r5.x + 1;
        r1.w = -r5.y * r5.y + r1.w;
        r1.w = max(0, r1.w);
        r6.z = sqrt(r1.w);
        r6.xy = cb0[54].yy * r5.xy;
        r1.w = dot(r6.xyz, r6.xyz);
        r1.w = rsqrt(r1.w);
        r5.xyz = r6.xyz * r1.www;
        r5.w = 1 + r4.z;
        r4.w = 1 + r4.z;
        r6.z = dot(r4.xyw, r5.xyz);
        r5.w = r6.z / r5.w;
        r5.xyz = r4.xyw * r5.www + -r5.xyz;
        r4.w = dot(r5.xyz, r5.xyz);
        r4.w = rsqrt(r4.w);
        r5.xyz = r5.xyz * r4.www;
        r4.xy = -r6.xy * r1.ww + r4.xy;
        r1.w = dot(r4.xyz, r4.xyz);
        r1.w = rsqrt(r1.w);
        r4.w = saturate(r0.y * 10 + 10);
        r6.xyz = r4.xyz * r1.www + -r5.xyz;
        r5.xyz = r4.www * r6.xyz + r5.xyz;
        r1.w = dot(r5.xyz, r5.xyz);
        r1.w = rsqrt(r1.w);
        r4.xyz = r5.xyz * r1.www;
      }
      r1.w = dot(-cb0[55].xyz, r4.xyz);
    } else {
      r4.xyz = r0.xyz;
      r1.zw = float2(0,0);
    }
    r4.w = dot(r4.xyz, r4.xyz);
    r4.w = rsqrt(r4.w);
    r4.xyz = r4.xyz * r4.www;
    if (r1.y != 0) {
      r1.z = -cb1[35].x * r1.z + 1;
      r5.xyz = cb1[34].xyz * r1.zzz;
      r6.xyz = cb0[56].xyz * r1.www;
      r5.xyz = r5.xyz * v1.xyz + r6.xyz;
      r5.w = cb1[34].w;
      r6.xyzw = r5.xyzw * r2.xyzw;
      if (cb0[51].z != 0) {
        r7.xyz = -cb1[20].xyz + v7.xyz;
        r1.z = dot(r7.xyz, r7.xyz);
        r1.z = rsqrt(r1.z);
        r7.xyz = r7.xyz * r1.zzz;
        r1.z = 1 + -r9.z;
        r1.z = max(0.00999999978, r1.z);
        r1.z = min(1, r1.z);
        r1.w = dot(-r7.xyz, r4.xyz);
        r4.w = max(0, r1.w);
        r5.w = min(1, r4.w);
        r8.xyzw = r1.zzzz * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
        r7.w = r8.x * r8.x;
        r5.w = -9.27999973 * r5.w;
        r5.w = exp2(r5.w);
        r7.w = min(r7.w, r5.w);
        r7.w = r7.w * r8.x + r8.y;
        r8.xy = r7.ww * float2(-1.03999996,1.03999996) + r8.zw;
        if (cb0[51].w != 0) {
          r7.w = dot(r7.xyz, r4.xyz);
          r7.w = r7.w + r7.w;
          r10.xyz = r4.xyz * -r7.www + r7.xyz;
          // r7.w = log2(r1.z);
          // r7.w = cb0[50].x * r7.w;
          // r7.w = exp2(r7.w);
          r7.w = renodx::math::SafePow(r1.z, cb0[50].x);
          r7.w = 6 * r7.w;
          r11.xyzw = cmp(float4(0,0,0,0) < cb0[52].xyzw);
          r10.xyz = -r10.xyz;
          r12.xyz = t5.SampleLevel(s2_s, r10.xyz, r7.w).xyz;
          r12.xyz = cb0[52].xxx * r12.xyz;
          r12.xyz = r11.xxx ? r12.xyz : 0;
          r13.xyz = t6.SampleLevel(s2_s, r10.xyz, r7.w).xyz;
          r13.xyz = cb0[52].yyy * r13.xyz;
          r13.xyz = r11.yyy ? r13.xyz : 0;
          r12.xyz = r13.xyz + r12.xyz;
          r13.xyz = t7.SampleLevel(s2_s, r10.xyz, r7.w).xyz;
          r13.xyz = cb0[52].zzz * r13.xyz;
          r11.xyz = r11.zzz ? r13.xyz : 0;
          r11.xyz = r12.xyz + r11.xyz;
          r10.xyz = t8.SampleLevel(s2_s, r10.xyz, r7.w).xyz;
          r10.xyz = cb0[52].www * r10.xyz;
          r10.xyz = r11.www ? r10.xyz : 0;
          r10.xyz = r11.xyz + r10.xyz;
          r7.w = r9.y * r8.x + r8.y;
          r10.xyz = (r10.xyz * r7.www);
        } else {
          r10.xyz = float3(0,0,0);
        }
        r7.w = cmp(r9.w < 0.501960814);
        r8.z = cmp(0.5 < cb0[50].z);
        r8.w = cmp(asint(cb1[25].z) != 0);
        r8.w = r8.w ? r8.z : 0;
        if (r8.w != 0) {
          r11.xyz = cb1[20].xyz + -v7.xyz;
          r8.w = dot(r11.xyz, r11.xyz);
          r8.w = sqrt(r8.w);
          r9.z = cmp(r9.x < 0.501960814);
          r10.w = saturate(r9.x * -2 + 1);
          r11.x = r1.w + r1.w;
          r11.xyz = r11.xxx * r4.xyz + r7.xyz;
          r12.xyz = v0.xyz * float3(0.300000012,0.300000012,0.300000012) + float3(0.699999988,0.699999988,0.699999988);
          r11.w = r2.x + r2.y;
          r11.w = r11.w + r2.z;
          r12.w = 0.333333343 * r11.w;
          r11.w = r11.w * 0.333333343 + -0.5;
          r13.xyz = (-r11.www + r2.xyz);
          r14.xyz = cb1[29].yzw + cb1[6].xyz;
          r11.w = dot(r14.xyz, r14.xyz);
          r11.w = rsqrt(r11.w);
          r14.xyz = r14.xyz * r11.www;
          r11.w = cmp(0 < cb1[87].z);
          if (r11.w != 0) {
            r15.xyzw = cmp(float4(0,0,0,0) < cb0[52].xyzw);
            r16.xyz = t9.SampleLevel(s2_s, r14.xyz, 0).xyz;
            r16.xyz = cb0[52].xxx * r16.xyz;
            r16.xyz = r15.xxx ? r16.xyz : 0;
            r17.xyz = t10.SampleLevel(s2_s, r14.xyz, 0).xyz;
            r17.xyz = cb0[52].yyy * r17.xyz;
            r17.xyz = r15.yyy ? r17.xyz : 0;
            r16.xyz = r17.xyz + r16.xyz;
            r17.xyz = t11.SampleLevel(s2_s, r14.xyz, 0).xyz;
            r17.xyz = cb0[52].zzz * r17.xyz;
            r15.xyz = r15.zzz ? r17.xyz : 0;
            r15.xyz = r16.xyz + r15.xyz;
            r16.xyz = t12.SampleLevel(s2_s, r14.xyz, 0).xyz;
            r16.xyz = cb0[52].www * r16.xyz;
            r16.xyz = r15.www ? r16.xyz : 0;
            r15.xyz = r16.xyz + r15.xyz;
            r15.xyz = r15.xyz * cb1[35].yyy + float3(-1,-1,-1);
            r15.xyz = cb1[87].zzz * r15.xyz + float3(1,1,1);
          } else {
            r15.xyz = float3(1,1,1);
          }
          r13.w = cb0[56].x + cb0[56].y;
          r13.w = cb0[56].z + r13.w;
          r13.w = r13.w * 0.333333343 + -0.5;
          r16.xyz = (cb0[56].xyz + -r13.www);
          r17.x = cb1[27].w + cb1[6].x;
          r17.yz = cb1[28].xy + cb1[6].yz;
          r13.w = dot(r17.xyz, r17.xyz);
          r13.w = rsqrt(r13.w);
          r17.xyz = r17.xyz * r13.www;
          if (r11.w != 0) {
            r18.xyzw = cmp(float4(0,0,0,0) < cb0[52].xyzw);
            r19.xyz = t9.SampleLevel(s2_s, r17.xyz, 0).xyz;
            r19.xyz = cb0[52].xxx * r19.xyz;
            r19.xyz = r18.xxx ? r19.xyz : 0;
            r20.xyz = t10.SampleLevel(s2_s, r17.xyz, 0).xyz;
            r20.xyz = cb0[52].yyy * r20.xyz;
            r20.xyz = r18.yyy ? r20.xyz : 0;
            r19.xyz = r20.xyz + r19.xyz;
            r20.xyz = t11.SampleLevel(s2_s, r17.xyz, 0).xyz;
            r20.xyz = cb0[52].zzz * r20.xyz;
            r18.xyz = r18.zzz ? r20.xyz : 0;
            r18.xyz = r19.xyz + r18.xyz;
            r19.xyz = t12.SampleLevel(s2_s, r17.xyz, 0).xyz;
            r19.xyz = cb0[52].www * r19.xyz;
            r19.xyz = r18.www ? r19.xyz : 0;
            r18.xyz = r19.xyz + r18.xyz;
            r18.xyz = r18.xyz * cb1[35].yyy + float3(-1,-1,-1);
            r18.xyz = cb1[87].zzz * r18.xyz + float3(1,1,1);
          } else {
            r18.xyz = float3(1,1,1);
          }
          if (r7.w == 0) {
            r11.w = dot(r11.xyz, -cb0[55].xyz);
            r13.w = r1.z * r1.z;
            r13.w = r13.w * r13.w;
            r13.w = rcp(r13.w);
            r14.w = r13.w * 0.721347511 + 0.396741122;
            r11.w = r14.w * r11.w + -r14.w;
            r11.w = exp2(r11.w);
            r11.w = r13.w * r11.w;
            r13.w = r9.y * r8.x + r8.y;
            r11.w = r13.w * r11.w;
            r19.xyz = (cb0[56].xyz * r11.www);
            r20.xyz = cb0[49].www * r10.xyz;
            r19.xyz = r19.xyz * cb0[49].zzz + r20.xyz;
            r11.w = cb1[30].y * r8.w;
            r11.w = r1.z * cb1[30].x + r11.w;
            r13.w = dot(-r7.xyz, -r7.xyz);
            r13.w = rsqrt(r13.w);
            r21.xyz = r13.www * -r7.xyz;
            r13.w = (dot(r21.xyz, r4.xyz));
            r21.xyzw = r11.wwww * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
            r14.w = r21.x * r21.x;
            r13.w = -9.27999973 * r13.w;
            r13.w = exp2(r13.w);
            r13.w = min(r14.w, r13.w);
            r13.w = r13.w * r21.x + r21.y;
            r21.xy = r13.ww * float2(-1.03999996,1.03999996) + r21.zw;
            r13.w = r15.x + r15.y;
            r13.w = r13.w + r15.z;
            r13.w = r13.w * 0.333333343 + -0.5;
            r15.xyz = (r15.xyz + -r13.www);
            r21.zw = r16.xy * r15.xy;
            r13.w = r21.z + r21.w;
            r13.w = r16.z * r15.z + r13.w;
            r13.w = r13.w * 0.333333343 + -0.5;
            r15.xyz = (r16.xyz * r15.xyz + -r13.www);
            r13.w = dot(r11.xyz, r14.xyz);
            r11.w = r11.w * r11.w;
            r11.w = r11.w * r11.w;
            r11.w = rcp(r11.w);
            r14.x = r11.w * 0.721347511 + 0.396741122;
            r14.yzw = r15.xyz * r13.xyz;
            r13.w = r14.x * r13.w + -r14.x;
            r13.w = exp2(r13.w);
            r11.w = r13.w * r11.w;
            r13.w = r9.y * r21.x + r21.y;
            r11.w = r13.w * r11.w;
            r14.xyz = r14.yzw * r11.www;
            r11.w = r8.w * cb1[30].w + cb1[30].z;
            r14.xyz = (r14.xyz * r11.www);
            r11.w = r8.w * cb1[31].y + cb1[31].x;
            r14.xyz = r14.xyz * r11.www;
            r14.xyz = r14.xyz * cb0[49].zzz + r20.xyz;
            r14.xyz = r14.xyz * r12.xyz;
            r14.xyz = r9.zzz ? r14.xyz : 0;
            r15.xyz = r19.xyz * r12.xyz + r6.xyz;
            r5.xyz = r5.xyz * r2.xyz + r14.xyz;
            r11.w = 1 + -r10.w;
            r11.w = r9.z ? r11.w : 1;
            r14.xyz = r15.xyz * r11.www;
            r6.xyz = r5.xyz * r10.www + r14.xyz;
          } else {
            r5.x = saturate(r9.w * -2 + 1);
            r5.y = cb1[26].x * r8.w;
            r5.y = r1.z * cb1[25].w + r5.y;
            r14.xyzw = r5.yyyy * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
            r5.z = r14.x * r14.x;
            r5.z = min(r5.z, r5.w);
            r5.z = r5.z * r14.x + r14.y;
            r5.zw = r5.zz * float2(-1.03999996,1.03999996) + r14.zw;
            r9.w = r18.x + r18.y;
            r9.w = r9.w + r18.z;
            r9.w = r9.w * 0.333333343 + -0.5;
            r14.xyz = (r18.xyz + -r9.www);
            r15.xy = r16.xy * r14.xy;
            r9.w = r15.x + r15.y;
            r9.w = r16.z * r14.z + r9.w;
            r9.w = r9.w * 0.333333343 + -0.5;
            r14.xyz = (r16.xyz * r14.xyz + -r9.www);
            r9.w = dot(r11.xyz, r17.xyz);
            r5.y = r5.y * r5.y;
            r5.y = r5.y * r5.y;
            r5.y = rcp(r5.y);
            r11.x = r5.y * 0.721347511 + 0.396741122;
            r11.yzw = r14.xyz * r13.xyz;
            r9.w = r11.x * r9.w + -r11.x;
            r9.w = exp2(r9.w);
            r5.y = r9.w * r5.y;
            r5.z = r9.y * r5.z + r5.w;
            r5.y = r5.y * r5.z;
            r11.xyz = r11.yzw * r5.yyy;
            r5.z = r11.x + r11.y;
            r5.y = r11.w * r5.y + r5.z;
            r5.y = -r5.y * 0.333333343 + r12.w;
            r5.yzw = (-r5.yyy + r2.xyz);
            r5.yzw = r11.xyz * r5.yzw;
            r9.w = r8.w * cb1[26].z + cb1[26].y;
            r5.yzw = (r9.www * r5.yzw);
            r8.w = r8.w * cb1[27].x + cb1[26].w;
            r5.yzw = r8.www * r5.yzw;
            r8.w = cb1[27].y * r5.x;
            r10.xyz = r10.xyz * r8.www;
            r8.w = 1 + -r5.x;
            r8.w = r9.z ? 0 : r8.w;
            r11.xyz = cb0[49].www * r10.xyz;
            r5.yzw = r5.yzw * cb0[49].zzz + r11.xyz;
            r5.yzw = r5.yzw * r12.xyz;
            r9.z = cb1[34].x + cb1[34].y;
            r9.z = cb1[34].z + r9.z;
            r9.z = 0.333333343 * r9.z;
            r9.w = cmp(cb1[29].x >= r9.z);
            r11.x = 1 + -cb1[28].w;
            r11.x = r11.x / cb1[29].x;
            r9.z = r9.z * r11.x + cb1[28].w;
            r9.z = r9.w ? r9.z : 1;
            r5.yzw = r9.zzz * r5.yzw;
            r11.xyz = cb1[28].zzz * r6.xyz;
            // r12.xyz = log2(r5.yzw);
            // r12.xyz = cb1[27].zzz * r12.xyz;
            // r12.xyz = exp2(r12.xyz);
            r12.xyz = renodx::math::SafePow(r5.yzw, cb1[27].z);

            r12.xyz = min(float3(1,1,1), r12.xyz);
            r13.xyz = float3(1,1,1) + -r12.xyz;
            r5.yzw = r12.xyz * r5.yzw;
            r5.yzw = r11.xyz * r13.xyz + r5.yzw;
            r11.xyz = r10.www * r6.xyz;
            r5.xyz = r5.yzw * r5.xxx + r11.xyz;
            r6.xyz = r6.xyz * r8.www + r5.xyz;
          }
        } else {
          r5.x = r1.w + r1.w;
          r5.xyz = r5.xxx * r4.xyz + r7.xyz;
          r5.x = dot(r5.xyz, -cb0[55].xyz);
          r1.z = r1.z * r1.z;
          r1.z = r1.z * r1.z;
          r1.z = rcp(r1.z);
          r5.y = r1.z * 0.721347511 + 0.396741122;
          r5.x = r5.y * r5.x + -r5.y;
          r5.x = exp2(r5.x);
          r1.z = r5.x * r1.z;
          r5.x = r9.y * r8.x + r8.y;
          r1.z = r5.x * r1.z;
          r5.xyz = (cb0[56].xyz * r1.zzz);
          r7.xyz = cb0[49].www * r10.xyz;
          r5.xyz = r5.xyz * cb0[49].zzz + r7.xyz;
          r7.xyz = v0.xyz * float3(0.300000012,0.300000012,0.300000012) + float3(0.699999988,0.699999988,0.699999988);
          r6.xyz = r5.xyz * r7.xyz + r6.xyz;
        }
        r1.z = cmp(asint(cb1[24].y) != 0);
        r1.z = r8.z ? r1.z : 0;
        r5.x = cmp((int)r7.w == 0);
        r1.z = r1.z ? r5.x : 0;
        if (r1.z != 0) {
          r1.z = cmp(r1.w >= cb1[25].x);
          if (r1.z != 0) {
            r1.z = 1 + -r4.w;
            r1.z = max(0, r1.z);
            // r1.z = log2(r1.z);
            // r1.z = cb1[24].w * r1.z;
            // r1.z = exp2(r1.z);

            r1.z = renodx::math::SafePow(r1.z, cb1[24].w);
            r1.z = r1.z * r9.y;
            r1.z = cb1[24].z * r1.z;
            r1.w = saturate(-0.501960814 + r9.x);
            r1.w = cb1[25].y * r1.w;
            r1.w = r1.w * 1.99218738 + 1;
            r5.xyz = r1.zzz * r1.www;
          } else {
            r5.xyz = float3(0,0,0);
          }
          r7.xyz = r5.xyz * r10.xyz;
          r5.xyz = cb0[51].www ? r7.xyz : r5.xyz;
          r6.xyz = r6.xyz + r5.xyz;
        }
      } else {
        r9.x = 0;
      }
      r1.z = cmp(0 != cb0[50].z);
      r1.w = cmp(asint(cb1[90].x) != 0);
      r1.z = r1.w ? r1.z : 0;
      if (r1.z != 0) {
        r1.z = saturate(-0.501960814 + r9.x);
        r1.z = 1.99218738 * r1.z;
        r1.w = 0.346355766 * cb1[88].w;
        r1.w = -r1.w * r1.w;
        r5.xyzw = float4(225.421097,29.8077488,7.71494675,2.5444355) * r1.wwww;
        r5.xyzw = exp2(r5.xyzw);
        r7.xyz = float3(0.100000001,0.335999995,0.344000012) * r5.yyy;
        r7.xyz = r5.xxx * float3(0.232999995,0.455000013,0.648999989) + r7.xyz;
        r5.xyz = r5.zzz * float3(0.118000001,0.197999999,0) + r7.xyz;
        r5.xyz = r5.www * float3(0.112999998,0.00700000022,0.00700000022) + r5.xyz;
        r7.xy = float2(0.724972367,0.194695681) * r1.ww;
        r7.xy = exp2(r7.xy);
        r5.xyz = r7.xxx * float3(0.35800001,0.00400000019,0) + r5.xyz;
        r5.xyz = r7.yyy * float3(0.0780000016,0,0) + r5.xyz;
        r1.w = dot(cb1[89].xyz, -r0.xyz);
        r1.w = saturate(0.300000012 + r1.w);
        r5.xyz = r5.xyz * r1.www;
        r6.xyz = r1.zzz * r5.xyz + r6.xyz;
      }
      r2.xyzw = -cb1[34].xyzw * r2.xyzw + r6.xyzw;
      r3.xyzw = r1.xxxx * r2.xyzw + r3.xyzw;
    } else {
      r3.xyz = r4.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
      r9.x = 0;
    }
  } else {
    r0.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
    r3.xyz = r1.yyy ? r3.xyz : r0.xyz;
    r9.x = 0;
  }
  r0.x = dot(v10.xyz, v10.xyz);
  r0.x = rsqrt(r0.x);
  o1.xy = v10.xy * r0.xx;
  r0.xyz = -cb0[44].xyz + r3.xyz;
  r0.xyz = r0.www * r0.xyz + cb0[44].xyz;
  o0.xyz = cb0[42].xxx ? r0.xyz : r3.xyz;
  r0.x = max(0, r3.w);
  o0.w = min(0.999000013, r0.x);
  r0.x = cmp(0 != cb0[50].z);
  r0.y = cmp(0.99000001 < r9.x);
  r0.x = r0.y ? r0.x : 0;
  o1.z = r0.x ? 1 : 0.300000012;
  o1.w = 1;
  return;
}