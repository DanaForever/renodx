#include "./shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Mon Jun 02 14:01:26 2025
Texture2D<float4> t15 : register(t15);

TextureCube<float4> t14 : register(t14);

TextureCube<float4> t13 : register(t13);

TextureCube<float4> t12 : register(t12);

TextureCube<float4> t11 : register(t11);

TextureCube<float4> t10 : register(t10);

TextureCube<float4> t9 : register(t9);

TextureCube<float4> t8 : register(t8);

TextureCube<float4> t7 : register(t7);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s7_s : register(s7);

SamplerState s6_s : register(s6);

SamplerState s5_s : register(s5);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerComparisonState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[94];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[58];
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
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000},
                              { 1, 0.706334, -0.316203, 0},
                              { 4, -0.621560, 0.744969, 0},
                              { 7, -1.093365, -0.835738, 0},
                              { 1, 0.727999, 0.817255, 0},
                              { 4, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 1, 0, 0, 0},
                              { 7, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 7, 0.970434, -1.218860, 0},
                              { 13, 1.723564, 0.899942, 0},
                              { 0, -1.394010, 1.141620, 0},
                              { 0, -0.800471, -1.641304, 0},
                              { 0, -1.195371, -0.238957, 0},
                              { 0, 0.120446, 1.782226, 0},
                              { 0, 0.156671, 0.084856, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { -1, 0, 0, -1},
                              { -1, 0, 0, 1},
                              { 1, 2.729044, 1.001841, -1},
                              { 1, 1.200427, -2.210806, 1},
                              { 0, -2.878679, -0.096898, 0},
                              { 0, -0.231437, 2.371948, 0},
                              { 0, -0.076521, -1.246591, 0},
                              { 0, 2.460634, -0.625002, 0},
                              { 0, -1.072969, -2.459462, 0},
                              { -2, -1.708283, -0.763927, -2},
                              { -2, 1.518943, 0.972988, 0},
                              { -2, 0.448011, -0.161030, 2},
                              { 0, -2.219038, 1.159811, -2},
                              { 0, -0.798701, 0.973673, 0},
                              { 0, 1.116809, 2.122032, 2},
                              { 2, 0, 0, -2},
                              { 2, 0, 0, 0},
                              { 2, 0, 0, 2},
                              { 1.500000, 0, 0, 1.000000},
                              { 0, 1.500000, 0, 1.000000},
                              { 0, 0, 5.500000, 1.000000},
                              { 1.500000, 0, 5.500000, 1.000000},
                              { 1.500000, 1.500000, 0, 1.000000},
                              { 1.000000, 1.000000, 1.000000, 1.000000},
                              { 0, 1.000000, 5.500000, 1.000000},
                              { 0.500000, 3.500000, 0.750000, 1.000000} };
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
    t4.GetDimensions(0, fDest.x, fDest.y, fDest.z);
    r3.xy = fDest.xy;
    r4.xy = float2(1,1) / r3.xy;
    r2.z = 1 + -r2.y;
    r2.xy = r3.xy * r2.xz + float2(-0.5,-0.5);
    r2.zw = floor(r2.xy);
    r2.zw = float2(0.400000006,0.400000006) + r2.zw;
    r3.xy = r2.zw * r4.xy;
    r2.xy = frac(r2.xy);
    r3.x = t4.Sample(s7_s, r3.xy).x;
    r3.x = 255 * r3.x;
    r3.x = (uint)r3.x;
    r4.z = 0;
    r5.xyzw = r2.zwzw * r4.xyxy + r4.xzzy;
    r4.z = t4.Sample(s7_s, r5.xy).x;
    r4.z = 255 * r4.z;
    r6.x = (uint)r4.z;
    r4.z = t4.Sample(s7_s, r5.zw).x;
    r4.z = 255 * r4.z;
    r5.x = (uint)r4.z;
    r2.zw = r2.zw * r4.xy + r4.xy;
    r2.z = t4.Sample(s7_s, r2.zw).x;
    r2.z = 255 * r2.z;
    r4.x = (uint)r2.z;
    r3.yzw = float3(0,0,0);
    r3.xyzw = t3.Load(r3.xyz).xyzw;
    r6.yzw = float3(0,0,0);
    r6.xyzw = t3.Load(r6.xyz).xyzw;
    r5.yzw = float3(0,0,0);
    r5.xyzw = t3.Load(r5.xyz).xyzw;
    r4.yzw = float3(0,0,0);
    r4.xyzw = t3.Load(r4.xyz).xyzw;
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
      t4.GetDimensions(0, fDest.x, fDest.y, fDest.z);
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
    oMask = r0.y;
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
  r4.zw = t5.Sample(s4_s, r4.xy).xy;
  r1.w = cmp(asint(cb0[53].x) == 3);
  r5.xyz = r1.www ? v11.yzx : v7.yzx;
  r6.xyz = ddx_coarse(r5.yzx);
  r7.xyz = ddy_coarse(r5.xyz);
  r8.x = cb0[53].w;
  r8.y = cb0[54].x;
  r9.xyzw = r5.xyyz * r8.xyxy + cb0[53].yzyz;
  r5.xy = r5.zx * r8.xy + cb0[53].yz;
  r5.zw = t15.Sample(s6_s, r9.xy).xy;
  r8.xy = t15.Sample(s6_s, r9.zw).xy;
  r5.xy = t15.Sample(s6_s, r5.xy).xy;
  r9.xyzw = t6.Sample(s4_s, r4.xy).zxyw;
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
          r7.w = renodx::math::SafePow(r7.w, cb0[50].x);
          r7.w = 6 * r7.w;
          r11.xyzw = cmp(float4(0,0,0,0) < cb0[52].xyzw);
          r10.xyz = -r10.xyz;
          r12.xyz = t7.SampleLevel(s5_s, r10.xyz, r7.w).xyz;
          r12.xyz = cb0[52].xxx * r12.xyz;
          r12.xyz = r11.xxx ? r12.xyz : 0;
          r13.xyz = t8.SampleLevel(s5_s, r10.xyz, r7.w).xyz;
          r13.xyz = cb0[52].yyy * r13.xyz;
          r13.xyz = r11.yyy ? r13.xyz : 0;
          r12.xyz = r13.xyz + r12.xyz;
          r13.xyz = t9.SampleLevel(s5_s, r10.xyz, r7.w).xyz;
          r13.xyz = cb0[52].zzz * r13.xyz;
          r11.xyz = r11.zzz ? r13.xyz : 0;
          r11.xyz = r12.xyz + r11.xyz;
          r10.xyz = t10.SampleLevel(s5_s, r10.xyz, r7.w).xyz;
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
            r16.xyz = t11.SampleLevel(s5_s, r14.xyz, 0).xyz;
            r16.xyz = cb0[52].xxx * r16.xyz;
            r16.xyz = r15.xxx ? r16.xyz : 0;
            r17.xyz = t12.SampleLevel(s5_s, r14.xyz, 0).xyz;
            r17.xyz = cb0[52].yyy * r17.xyz;
            r17.xyz = r15.yyy ? r17.xyz : 0;
            r16.xyz = r17.xyz + r16.xyz;
            r17.xyz = t13.SampleLevel(s5_s, r14.xyz, 0).xyz;
            r17.xyz = cb0[52].zzz * r17.xyz;
            r15.xyz = r15.zzz ? r17.xyz : 0;
            r15.xyz = r16.xyz + r15.xyz;
            r16.xyz = t14.SampleLevel(s5_s, r14.xyz, 0).xyz;
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
            r19.xyz = t11.SampleLevel(s5_s, r17.xyz, 0).xyz;
            r19.xyz = cb0[52].xxx * r19.xyz;
            r19.xyz = r18.xxx ? r19.xyz : 0;
            r20.xyz = t12.SampleLevel(s5_s, r17.xyz, 0).xyz;
            r20.xyz = cb0[52].yyy * r20.xyz;
            r20.xyz = r18.yyy ? r20.xyz : 0;
            r19.xyz = r20.xyz + r19.xyz;
            r20.xyz = t13.SampleLevel(s5_s, r17.xyz, 0).xyz;
            r20.xyz = cb0[52].zzz * r20.xyz;
            r18.xyz = r18.zzz ? r20.xyz : 0;
            r18.xyz = r19.xyz + r18.xyz;
            r19.xyz = t14.SampleLevel(s5_s, r17.xyz, 0).xyz;
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
    r1.xzw = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
    r3.xyz = r1.yyy ? r3.xyz : r1.xzw;
    r9.x = 0;
  }
  r1.x = dot(v10.xyz, v10.xyz);
  r1.x = rsqrt(r1.x);
  o1.xy = v10.xy * r1.xx;
  r1.x = -0.300000012 + r3.w;
  r1.x = saturate(5 * r1.x);
  r0.x = dot(-cb0[55].xyz, r0.xyz);
  r0.x = -cb0[57].z + r0.x;
  r1.yzw = float3(9.99999975e-005,9.99999975e-005,9.99999975e-005) + cb0[21].xyz;
  r1.yzw = v0.xyz / r1.yzw;
  r0.y = dot(r1.yzw, float3(0.298999995,0.587000012,0.114));
  r0.y = -cb0[57].x + r0.y;
  r0.xy = saturate(r0.xy / cb0[57].wy);
  r0.y = r1.x * r0.y;
  r0.x = r0.y * r0.x;
  r0.y = cmp(0 < r0.x);
  r1.xyz = v7.xyz;
  r1.w = 1;
  r0.z = dot(r1.xyzw, cb1[47].xyzw);
  r2.x = dot(r1.xyzw, cb1[48].xyzw);
  r2.y = dot(r1.xyzw, cb1[49].xyzw);
  r0.z = r0.z * 0.5 + 0.5;
  r2.x = r2.x * -0.5 + 0.5;
  r2.z = cmp(asint(cb1[86].z) == 1);
  if (r2.z != 0) {
    r2.w = dot(r1.xyzw, cb0[7].xyzw);
    r4.xyzw = cmp(r2.wwww < cb1[79].xyzw);
    r5.x = ~(int)r4.x;
    if (r4.x != 0) {
      r5.yzw = float3(1.5,0,0) * r3.xyz;
    } else {
      r5.yzw = r3.xyz;
    }
    if (r4.y != 0) {
      r6.xyz = float3(0,1.5,0) * r3.xyz;
      r6.w = 1;
    } else {
      r6.xyzw = r5.yzwx;
    }
    r4.y = (int)r4.y | (int)r4.x;
    r4.y = r4.y ? r5.x : 0;
    r4.y = (int)r4.x | (int)r4.y;
    r5.xyz = r4.xxx ? r5.yzw : r6.xyz;
    r4.x = r4.x ? 0 : r6.w;
    if (r4.z != 0) {
      r6.xyz = float3(0,0,5.5) * r3.xyz;
      r5.w = 2;
    } else {
      r6.xyz = r5.xyz;
      r5.w = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyz;
    r4.x = r4.y ? r4.x : r5.w;
    r4.y = (int)r4.z | (int)r4.y;
    if (r4.w != 0) {
      r6.xyz = float3(1.5,0,5.5) * r3.xyz;
      r4.z = 3;
    } else {
      r6.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r4.w | (int)r4.y;
    r6.xyz = cmp(r2.www < cb1[80].yzw);
    if (r6.x != 0) {
      r7.xyz = float3(1.5,1.5,0) * r3.xyz;
      r4.z = 4;
    } else {
      r7.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r7.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r4.y | (int)r6.x;
    if (r6.y != 0) {
      r7.xyz = r3.xyz;
      r4.z = 5;
    } else {
      r7.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r7.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r6.y | (int)r4.y;
    if (r6.z != 0) {
      r6.xyw = float3(0,1,5.5) * r3.xyz;
      r4.z = 6;
    } else {
      r6.xyw = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyw;
    r6.x = r4.y ? r4.x : r4.z;
    r4.x = (int)r6.z | (int)r4.y;
    r4.y = r0.z;
    r7.y = r2.x;
    r4.z = r2.y;
  } else {
    r8.y = 1;
    r4.y = r0.z;
    r7.y = r2.x;
    r4.z = r2.y;
    r6.xy = float2(-1,0);
    r8.x = 0;
    while (true) {
      r4.w = cmp((int)r8.x < asint(cb1[46].w));
      r5.w = cmp((int)r6.y == 0);
      r4.w = r4.w ? r5.w : 0;
      if (r4.w == 0) break;
      r10.xyzw = cmp((int4)r8.xxxx == int4(1,2,3,4));
      r6.zw = cmp((int2)r8.xx == int2(5,6));
      r11.xyzw = r6.wwww ? cb1[71].xyzw : cb1[75].xyzw;
      r12.xyzw = r6.wwww ? cb1[72].xyzw : cb1[76].xyzw;
      r13.xyzw = r6.wwww ? cb1[73].xyzw : cb1[77].xyzw;
      r11.xyzw = r6.zzzz ? cb1[67].xyzw : r11.xyzw;
      r12.xyzw = r6.zzzz ? cb1[68].xyzw : r12.xyzw;
      r13.xyzw = r6.zzzz ? cb1[69].xyzw : r13.xyzw;
      r11.xyzw = r10.wwww ? cb1[63].xyzw : r11.xyzw;
      r12.xyzw = r10.wwww ? cb1[64].xyzw : r12.xyzw;
      r13.xyzw = r10.wwww ? cb1[65].xyzw : r13.xyzw;
      r11.xyzw = r10.zzzz ? cb1[59].xyzw : r11.xyzw;
      r12.xyzw = r10.zzzz ? cb1[60].xyzw : r12.xyzw;
      r13.xyzw = r10.zzzz ? cb1[61].xyzw : r13.xyzw;
      r11.xyzw = r10.yyyy ? cb1[55].xyzw : r11.xyzw;
      r12.xyzw = r10.yyyy ? cb1[56].xyzw : r12.xyzw;
      r13.xyzw = r10.yyyy ? cb1[57].xyzw : r13.xyzw;
      r11.xyzw = r10.xxxx ? cb1[51].xyzw : r11.xyzw;
      r12.xyzw = r10.xxxx ? cb1[52].xyzw : r12.xyzw;
      r10.xyzw = r10.xxxx ? cb1[53].xyzw : r13.xyzw;
      r11.xyzw = r8.xxxx ? r11.xyzw : cb1[47].xyzw;
      r12.xyzw = r8.xxxx ? r12.xyzw : cb1[48].xyzw;
      r10.xyzw = r8.xxxx ? r10.xyzw : cb1[49].xyzw;
      r4.w = dot(r1.xyzw, r11.xyzw);
      r5.w = dot(r1.xyzw, r12.xyzw);
      r4.z = dot(r1.xyzw, r10.xyzw);
      r4.y = r4.w * 0.5 + 0.5;
      r7.y = r5.w * -0.5 + 0.5;
      r4.w = min(r7.y, r4.y);
      r4.w = cmp(cb1[84].x < r4.w);
      r5.w = max(r7.y, r4.y);
      r5.w = cmp(r5.w < cb1[84].y);
      r4.w = r4.w ? r5.w : 0;
      r5.w = cmp(r4.z < 1);
      r4.w = r4.w ? r5.w : 0;
      r6.xy = r4.ww ? r8.xy : r6.xy;
      r8.x = (int)r8.x + 1;
    }
    r5.xyz = r3.xyz;
    r2.w = 1;
    r4.x = 0;
  }
  r0.z = (int)r6.x;
  r0.z = cb1[85].x * r0.z;
  r7.x = r4.y * cb1[85].x + r0.z;
  r2.xy = t2.Sample(s2_s, r7.xy).xy;
  if (r0.y != 0) {
    r0.y = cmp(asint(cb0[22].z) != 1);
    if (r0.y != 0) {
      if (r4.x == 0) {
        r0.y = cmp((int)r6.x == -1);
        if (r0.y != 0) {
          r5.xyz = r3.xyz;
        }
        if (r0.y == 0) {
          if (r2.z != 0) {
            r0.y = cmp(asint(cb1[86].w) != 0);
            r0.z = cmp(1 < asint(cb1[46].w));
            r0.y = r0.z ? r0.y : 0;
            if (r0.y != 0) {
              r0.y = cmp((int)r6.x < 4);
              r0.z = dot(cb1[79].xyzw, icb[r6.x+0].xyzw);
              r4.xw = (int2)r6.xx + int2(-3,-1);
              r2.z = dot(cb1[80].xyzw, icb[r4.x+0].xyzw);
              r0.y = r0.y ? r0.z : r2.z;
              r0.z = min(0, (int)r4.w);
              r0.z = dot(cb1[79].xyzw, icb[r0.z+0].xyzw);
              r2.z = r2.w + -r0.z;
              r0.y = r0.y + -r0.z;
              r0.y = rcp(r0.y);
              r0.z = -r2.z * r0.y + 1;
              r2.z = rcp(cb1[84].z);
              r0.y = r2.z * r0.z;
            } else {
              r0.yz = float2(1,1);
            }
          } else {
            r2.z = 1 + -r4.y;
            r2.w = 1 + -r7.y;
            r4.x = min(r4.y, r7.y);
            r2.z = min(r2.z, r2.w);
            r4.y = min(r4.x, r2.z);
            r2.z = rcp(cb1[84].z);
            r4.x = r4.y * r2.z;
            r0.yz = cb1[86].ww ? r4.xy : float2(1,1);
          }
          r2.z = -cb1[84].w + r4.z;
          r2.w = dot(cb1[80].xyzw, icb[r6.x+0].xyzw);
          r4.x = rcp(r2.w);
          r4.x = cb1[85].w * r4.x;
          r4.y = (int)-r6.x + asint(cb1[90].w);
          r4.y = max(2, (int)r4.y);
          r4.y = min(4, (int)r4.y);
          r4.z = (int)r4.y + -2;
          r4.w = mad(asint(cb1[86].y), 3, (int)r4.z);
          r5.w = cmp(1 == (int)icb[r4.w+4].x);
          if (r5.w != 0) {
            r5.w = t1.SampleCmpLevelZero(s1_s, r7.xy, r2.z).x;
            r6.y = asint(cb1[86].x) | asint(cb1[91].z);
            if (r6.y != 0) {
              r8.xyzw = t1.Gather(s3_s, r7.xy).xyzw;
              r10.xyzw = cmp(r8.xyzw >= r2.zzzz);
              r10.xyzw = r10.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
              r6.y = dot(r10.xyzw, float4(1,1,1,1));
              r6.z = dot(r8.xyzw, r10.xyzw);
              r6.w = rcp(r6.y);
              r6.y = cmp(0 < r6.y);
              r6.z = -r6.z * r6.w + r2.z;
              r6.w = rcp(r4.x);
              r6.w = r6.z * r6.w + -1;
              r6.w = saturate(r6.w + r6.w);
              r6.y = r6.y ? r6.w : 0;
              r6.y = cb1[86].x ? r6.y : 0;
              if (cb1[91].z != 0) {
                r8.xyzw = t2.Gather(s3_s, r7.xy).xyzw;
                r10.xyzw = cmp(r8.xyzw < float4(1,1,1,1));
                r10.xyzw = r10.xyzw ? float4(1,1,1,1) : 0;
                r6.w = dot(r10.xyzw, float4(1,1,1,1));
                r7.z = cmp(0 < r6.w);
                if (r7.z != 0) {
                  r7.z = dot(r8.xyzw, r10.xyzw);
                  r6.w = rcp(r6.w);
                  r7.w = r7.z * r6.w;
                  r6.z = r6.z * r2.w;
                  r6.z = abs(cb1[81].y) * r6.z;
                  r6.z = 0.5 * r6.z;
                  r8.x = cmp(0.5 < r7.w);
                  r6.w = r7.z * r6.w + -0.5;
                  r6.w = cb1[90].y * r6.w;
                  r6.w = dot(r6.ww, cb1[93].ww);
                  r6.w = r6.z / r6.w;
                  r6.w = -1 + r6.w;
                  r7.z = cb1[90].y * r7.w;
                  r7.z = dot(r7.zz, cb1[93].zz);
                  r6.z = r6.z / r7.z;
                  r6.z = -1 + r6.z;
                  r6.zw = saturate(cb1[93].xy * r6.zw);
                  r6.z = r8.x ? r6.w : r6.z;
                } else {
                  r6.z = 0;
                }
              } else {
                r6.z = 0;
              }
            } else {
              r6.yz = float2(0,0);
            }
            r6.w = 1 + -r5.w;
            r5.w = r6.y * r6.w + r5.w;
            r5.w = r5.w + r6.z;
            r5.w = min(1, r5.w);
          } else {
            r6.y = (int)r4.z * 13;
            r6.zw = icb[r6.y+4].yz * cb1[85].zy + r7.xy;
            r6.z = t1.SampleCmpLevelZero(s1_s, r6.zw, r2.z).x;
            r7.zw = icb[r6.y+5].yz * cb1[85].zy + r7.xy;
            r6.w = t1.SampleCmpLevelZero(s1_s, r7.zw, r2.z).x;
            r6.z = r6.z + r6.w;
            r7.zw = icb[r6.y+6].yz * cb1[85].zy + r7.xy;
            r6.w = t1.SampleCmpLevelZero(s1_s, r7.zw, r2.z).x;
            r6.z = r6.z + r6.w;
            r6.yw = icb[r6.y+7].yz * cb1[85].zy + r7.xy;
            r6.y = t1.SampleCmpLevelZero(s1_s, r6.yw, r2.z).x;
            r5.w = r6.z + r6.y;
            r6.y = cmp(3.99959993 < r5.w);
            if (r6.y != 0) {
              r5.w = 1;
            }
            if (r6.y == 0) {
              r6.y = asint(cb1[86].x) | asint(cb1[91].z);
              if (r6.y != 0) {
                r4.y = (int)r4.y + -1;
                r4.y = (int)r4.y * (int)r4.y;
                r6.yzw = float3(0,0,0);
                while (true) {
                  r7.z = cmp((int)r6.w >= (int)r4.y);
                  if (r7.z != 0) break;
                  r7.z = mad((int)r4.z, 9, (int)r6.w);
                  r8.xyzw = t1.Gather(s3_s, r7.xy).xyzw;
                  r10.xyzw = cmp(r8.xyzw >= r2.zzzz);
                  r10.xyzw = r10.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                  r7.z = dot(r10.xyzw, float4(1,1,1,1));
                  r6.y = r7.z + r6.y;
                  r7.z = dot(r8.xyzw, r10.xyzw);
                  r6.z = r7.z + r6.z;
                  r6.w = (int)r6.w + 1;
                }
                r6.w = rcp(r6.y);
                r6.y = cmp(0 < r6.y);
                r6.z = -r6.z * r6.w + r2.z;
                r4.x = rcp(r4.x);
                r4.x = dot(r6.zz, r4.xx);
                r4.x = saturate(-2 + r4.x);
                r4.x = r6.y ? r4.x : 0;
                r8.y = cb1[86].x ? r4.x : 0;
                if (cb1[91].z != 0) {
                  r6.yw = float2(0,0);
                  r4.x = 0;
                  while (true) {
                    r7.z = cmp((int)r4.x >= (int)r4.y);
                    if (r7.z != 0) break;
                    r7.z = mad((int)r4.z, 9, (int)r4.x);
                    r10.xyzw = t2.Gather(s3_s, r7.xy).xyzw;
                    r11.xyzw = cmp(r10.xyzw < float4(1,1,1,1));
                    r11.xyzw = r11.xyzw ? float4(1,1,1,1) : 0;
                    r7.z = dot(r11.xyzw, float4(1,1,1,1));
                    r6.y = r7.z + r6.y;
                    r7.z = dot(r10.xyzw, r11.xyzw);
                    r6.w = r7.z + r6.w;
                    r4.x = (int)r4.x + 1;
                  }
                  r4.x = cmp(0 < r6.y);
                  if (r4.x != 0) {
                    r4.x = rcp(r6.y);
                    r4.y = r6.w * r4.x;
                    r2.w = r6.z * r2.w;
                    r2.w = abs(cb1[81].y) * r2.w;
                    r2.w = 0.5 * r2.w;
                    r6.y = cmp(0.5 < r4.y);
                    r4.x = r6.w * r4.x + -0.5;
                    r4.xy = cb1[90].yy * r4.xy;
                    r4.x = dot(r4.xx, cb1[93].ww);
                    r4.x = r2.w / r4.x;
                    r4.x = -1 + r4.x;
                    r4.x = saturate(cb1[93].y * r4.x);
                    r4.y = dot(r4.yy, cb1[93].zz);
                    r2.w = r2.w / r4.y;
                    r2.w = -1 + r2.w;
                    r2.w = saturate(cb1[93].x * r2.w);
                    r8.x = r6.y ? r4.x : r2.w;
                  } else {
                    r8.x = 0;
                  }
                } else {
                  r8.x = 0;
                }
              } else {
                r8.xy = float2(0,0);
              }
              r2.w = cmp(r5.w < 0.00039999999);
              if (r2.w != 0) {
                r4.x = r8.y + r8.x;
                r5.w = min(1, r4.x);
              }
              if (r2.w == 0) {
                r2.w = r5.w;
                r4.x = 4;
                while (true) {
                  r4.y = cmp((int)r4.x >= (int)icb[r4.w+4].x);
                  if (r4.y != 0) break;
                  r4.y = mad((int)r4.z, 13, (int)r4.x);
                  r6.yz = icb[r4.y+4].yz * cb1[85].zy + r7.xy;
                  r4.y = t1.SampleCmpLevelZero(s1_s, r6.yz, r2.z).x;
                  r2.w = r4.y + r2.w;
                  r4.x = (int)r4.x + 1;
                }
                r2.z = (int)icb[r4.w+4].x;
                r2.z = rcp(r2.z);
                r4.x = r2.w * r2.z;
                r2.z = -r2.w * r2.z + 1;
                r2.z = r8.y * r2.z + r4.x;
                r5.w = saturate(r2.z + r8.x);
              }
            }
          }
          r2.x = saturate(r2.x);
          r2.x = 1 + -r2.x;
          r2.z = cmp(asint(cb1[86].w) != 0);
          r2.w = cmp(1 < asint(cb1[46].w));
          r2.z = r2.w ? r2.z : 0;
          if (r2.z != 0) {
            r0.z = cmp(r0.z < cb1[84].z);
            if (r0.z != 0) {
              r0.z = (int)r6.x + 1;
              r0.z = cb1[86].w ? r0.z : 0;
              if (cb1[86].z == 0) {
                r4.xyzw = cmp((int4)r0.zzzz == int4(1,2,3,4));
                r2.zw = cmp((int2)r0.zz == int2(5,6));
                r7.xyzw = r2.wwww ? cb1[71].xyzw : cb1[75].xyzw;
                r8.xyzw = r2.wwww ? cb1[72].xyzw : cb1[76].xyzw;
                r10.xyzw = r2.wwww ? cb1[73].xyzw : cb1[77].xyzw;
                r7.xyzw = r2.zzzz ? cb1[67].xyzw : r7.xyzw;
                r8.xyzw = r2.zzzz ? cb1[68].xyzw : r8.xyzw;
                r10.xyzw = r2.zzzz ? cb1[69].xyzw : r10.xyzw;
                r7.xyzw = r4.wwww ? cb1[63].xyzw : r7.xyzw;
                r8.xyzw = r4.wwww ? cb1[64].xyzw : r8.xyzw;
                r10.xyzw = r4.wwww ? cb1[65].xyzw : r10.xyzw;
                r7.xyzw = r4.zzzz ? cb1[59].xyzw : r7.xyzw;
                r8.xyzw = r4.zzzz ? cb1[60].xyzw : r8.xyzw;
                r10.xyzw = r4.zzzz ? cb1[61].xyzw : r10.xyzw;
                r7.xyzw = r4.yyyy ? cb1[55].xyzw : r7.xyzw;
                r8.xyzw = r4.yyyy ? cb1[56].xyzw : r8.xyzw;
                r10.xyzw = r4.yyyy ? cb1[57].xyzw : r10.xyzw;
                r7.xyzw = r4.xxxx ? cb1[51].xyzw : r7.xyzw;
                r8.xyzw = r4.xxxx ? cb1[52].xyzw : r8.xyzw;
                r4.xyzw = r4.xxxx ? cb1[53].xyzw : r10.xyzw;
                r7.xyzw = r0.zzzz ? r7.xyzw : cb1[47].xyzw;
                r8.xyzw = r0.zzzz ? r8.xyzw : cb1[48].xyzw;
                r4.xyzw = r0.zzzz ? r4.xyzw : cb1[49].xyzw;
                r2.z = dot(r1.xyzw, r7.xyzw);
                r2.w = dot(r1.xyzw, r8.xyzw);
                r1.x = dot(r1.xyzw, r4.xyzw);
                r1.y = r2.z * 0.5 + 0.5;
                r4.y = r2.w * -0.5 + 0.5;
              } else {
                r4.y = 0;
                r1.xy = float2(0,0);
              }
              r1.z = (int)r0.z;
              r1.z = cb1[85].x * r1.z;
              r4.x = r1.y * cb1[85].x + r1.z;
              r1.y = cmp((int)r0.z < asint(cb1[46].w));
              r1.x = -cb1[84].w + r1.x;
              r1.z = dot(cb1[80].xyzw, icb[r0.z+0].xyzw);
              r1.w = rcp(r1.z);
              r1.w = cb1[85].w * r1.w;
              r0.z = (int)-r0.z + asint(cb1[90].w);
              r0.z = max(2, (int)r0.z);
              r0.z = min(4, (int)r0.z);
              r2.z = (int)r0.z + -2;
              r2.w = mad(asint(cb1[86].y), 3, (int)r2.z);
              r4.z = cmp(1 == (int)icb[r2.w+4].x);
              if (r4.z != 0) {
                r4.z = t1.SampleCmpLevelZero(s1_s, r4.xy, r1.x).x;
                r4.w = asint(cb1[86].x) | asint(cb1[91].z);
                if (r4.w != 0) {
                  r7.xyzw = t1.Gather(s3_s, r4.xy).xyzw;
                  r8.xyzw = cmp(r7.xyzw >= r1.xxxx);
                  r8.xyzw = r8.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                  r4.w = dot(r8.xyzw, float4(1,1,1,1));
                  r6.y = dot(r7.xyzw, r8.xyzw);
                  r6.z = rcp(r4.w);
                  r4.w = cmp(0 < r4.w);
                  r6.y = -r6.y * r6.z + r1.x;
                  r6.z = rcp(r1.w);
                  r6.z = r6.y * r6.z + -1;
                  r6.z = saturate(r6.z + r6.z);
                  r4.w = r4.w ? r6.z : 0;
                  r4.w = cb1[86].x ? r4.w : 0;
                  if (cb1[91].z != 0) {
                    r7.xyzw = t2.Gather(s3_s, r4.xy).xyzw;
                    r8.xyzw = cmp(r7.xyzw < float4(1,1,1,1));
                    r8.xyzw = r8.xyzw ? float4(1,1,1,1) : 0;
                    r6.z = dot(r8.xyzw, float4(1,1,1,1));
                    r6.w = cmp(0 < r6.z);
                    if (r6.w != 0) {
                      r6.w = dot(r7.xyzw, r8.xyzw);
                      r6.z = rcp(r6.z);
                      r7.x = r6.w * r6.z;
                      r6.y = r6.y * r1.z;
                      r6.y = abs(cb1[81].y) * r6.y;
                      r6.y = 0.5 * r6.y;
                      r7.y = cmp(0.5 < r7.x);
                      r6.z = r6.w * r6.z + -0.5;
                      r6.z = cb1[90].y * r6.z;
                      r6.z = dot(r6.zz, cb1[93].ww);
                      r6.z = r6.y / r6.z;
                      r6.z = -1 + r6.z;
                      r6.w = cb1[90].y * r7.x;
                      r6.w = dot(r6.ww, cb1[93].zz);
                      r6.y = r6.y / r6.w;
                      r6.y = -1 + r6.y;
                      r6.yz = saturate(cb1[93].xy * r6.yz);
                      r6.y = r7.y ? r6.z : r6.y;
                    } else {
                      r6.y = 0;
                    }
                  } else {
                    r6.y = 0;
                  }
                } else {
                  r6.y = 0;
                  r4.w = 0;
                }
                r6.z = 1 + -r4.z;
                r4.z = r4.w * r6.z + r4.z;
                r4.z = r4.z + r6.y;
                r4.z = min(1, r4.z);
              } else {
                r4.w = (int)r2.z * 13;
                r6.yz = icb[r4.w+4].yz * cb1[85].zy + r4.xy;
                r6.y = t1.SampleCmpLevelZero(s1_s, r6.yz, r1.x).x;
                r6.zw = icb[r4.w+5].yz * cb1[85].zy + r4.xy;
                r6.z = t1.SampleCmpLevelZero(s1_s, r6.zw, r1.x).x;
                r6.y = r6.y + r6.z;
                r6.zw = icb[r4.w+6].yz * cb1[85].zy + r4.xy;
                r6.z = t1.SampleCmpLevelZero(s1_s, r6.zw, r1.x).x;
                r6.y = r6.y + r6.z;
                r6.zw = icb[r4.w+7].yz * cb1[85].zy + r4.xy;
                r4.w = t1.SampleCmpLevelZero(s1_s, r6.zw, r1.x).x;
                r4.z = r6.y + r4.w;
                r4.w = cmp(3.99959993 < r4.z);
                if (r4.w != 0) {
                  r4.z = 1;
                }
                if (r4.w == 0) {
                  r4.w = asint(cb1[86].x) | asint(cb1[91].z);
                  if (r4.w != 0) {
                    r0.z = (int)r0.z + -1;
                    r0.z = (int)r0.z * (int)r0.z;
                    r6.yz = float2(0,0);
                    r4.w = 0;
                    while (true) {
                      r6.w = cmp((int)r4.w >= (int)r0.z);
                      if (r6.w != 0) break;
                      r6.w = mad((int)r2.z, 9, (int)r4.w);
                      r7.xyzw = t1.Gather(s3_s, r4.xy).xyzw;
                      r8.xyzw = cmp(r7.xyzw >= r1.xxxx);
                      r8.xyzw = r8.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                      r6.w = dot(r8.xyzw, float4(1,1,1,1));
                      r6.y = r6.y + r6.w;
                      r6.w = dot(r7.xyzw, r8.xyzw);
                      r6.z = r6.z + r6.w;
                      r4.w = (int)r4.w + 1;
                    }
                    r4.w = rcp(r6.y);
                    r6.y = cmp(0 < r6.y);
                    r4.w = -r6.z * r4.w + r1.x;
                    r1.w = rcp(r1.w);
                    r1.w = dot(r4.ww, r1.ww);
                    r1.w = saturate(-2 + r1.w);
                    r1.w = r6.y ? r1.w : 0;
                    r7.y = cb1[86].x ? r1.w : 0;
                    if (cb1[91].z != 0) {
                      r6.yz = float2(0,0);
                      r1.w = 0;
                      while (true) {
                        r6.w = cmp((int)r1.w >= (int)r0.z);
                        if (r6.w != 0) break;
                        r6.w = mad((int)r2.z, 9, (int)r1.w);
                        r8.xyzw = t2.Gather(s3_s, r4.xy).xyzw;
                        r10.xyzw = cmp(r8.xyzw < float4(1,1,1,1));
                        r10.xyzw = r10.xyzw ? float4(1,1,1,1) : 0;
                        r6.w = dot(r10.xyzw, float4(1,1,1,1));
                        r6.y = r6.y + r6.w;
                        r6.w = dot(r8.xyzw, r10.xyzw);
                        r6.z = r6.z + r6.w;
                        r1.w = (int)r1.w + 1;
                      }
                      r0.z = cmp(0 < r6.y);
                      if (r0.z != 0) {
                        r0.z = rcp(r6.y);
                        r1.w = r6.z * r0.z;
                        r1.z = r4.w * r1.z;
                        r1.z = abs(cb1[81].y) * r1.z;
                        r1.z = 0.5 * r1.z;
                        r4.w = cmp(0.5 < r1.w);
                        r0.z = r6.z * r0.z + -0.5;
                        r0.z = cb1[90].y * r0.z;
                        r0.z = dot(r0.zz, cb1[93].ww);
                        r0.z = r1.z / r0.z;
                        r0.z = -1 + r0.z;
                        r0.z = saturate(cb1[93].y * r0.z);
                        r1.w = cb1[90].y * r1.w;
                        r1.w = dot(r1.ww, cb1[93].zz);
                        r1.z = r1.z / r1.w;
                        r1.z = -1 + r1.z;
                        r1.z = saturate(cb1[93].x * r1.z);
                        r7.x = r4.w ? r0.z : r1.z;
                      } else {
                        r7.x = 0;
                      }
                    } else {
                      r7.x = 0;
                    }
                  } else {
                    r7.xy = float2(0,0);
                  }
                  r0.z = cmp(r4.z < 0.00039999999);
                  if (r0.z != 0) {
                    r1.z = r7.y + r7.x;
                    r4.z = min(1, r1.z);
                  }
                  if (r0.z == 0) {
                    r0.z = r4.z;
                    r1.z = 4;
                    while (true) {
                      r1.w = cmp((int)r1.z >= (int)icb[r2.w+4].x);
                      if (r1.w != 0) break;
                      r1.w = mad((int)r2.z, 13, (int)r1.z);
                      r6.yz = icb[r1.w+4].yz * cb1[85].zy + r4.xy;
                      r1.w = t1.SampleCmpLevelZero(s1_s, r6.yz, r1.x).x;
                      r0.z = r1.w + r0.z;
                      r1.z = (int)r1.z + 1;
                    }
                    r1.x = (int)icb[r2.w+4].x;
                    r1.x = rcp(r1.x);
                    r1.z = r1.x * r0.z;
                    r0.z = -r0.z * r1.x + 1;
                    r0.z = r7.y * r0.z + r1.z;
                    r4.z = saturate(r0.z + r7.x);
                  }
                }
              }
              r0.z = r1.y ? r4.z : 1;
              r1.x = r5.w + -r0.z;
              r5.w = r0.y * r1.x + r0.z;
            }
          }
          r0.y = 1 + -r5.w;
          r0.y = r2.x * r0.y + r5.w;
          r1.xyz = cb1[87].xxx ? icb[r6.x+46].xyz : float3(1,1,1);
          r0.z = 1 + -cb1[92].x;
          r0.y = r0.y * r0.z + cb1[92].x;
          r0.z = 1 + -r0.y;
          r2.xzw = cb1[82].xyz * r0.zzz + r0.yyy;
          r1.xyz = r2.xzw * r1.xyz;
          r1.xyz = r1.xyz * r3.xyz;
          r0.y = cmp(r2.y < 0.5);
          r2.xyz = float3(1,1,1) + -cb1[83].xyz;
          r2.xyz = r5.www * r2.xyz + cb1[83].xyz;
          r2.xyz = r2.xyz * r1.xyz;
          r5.xyz = r0.yyy ? r2.xyz : r1.xyz;
        }
      }
    } else {
      r5.xyz = r3.xyz;
    }
    r1.xyz = r5.xyz + -r3.xyz;
    r3.xyz = r0.xxx * r1.xyz + r3.xyz;
  }
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