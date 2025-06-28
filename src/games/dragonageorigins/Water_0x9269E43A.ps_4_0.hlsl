#include "./shared.h"

TextureCube<float4> t26 : register(t26);
Texture2D<float4> t2 : register(t2);

SamplerState s10_s : register(s10);
SamplerState s2_s : register(s2);

cbuffer cb4 : register(b4)
{
  float4 cb4[236];
}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD8,
  float4 v2 : COLOR0,
  float4 v3 : COLOR1,
  float4 v4 : TEXCOORD9,
  float4 v5 : TEXCOORD0,
  float4 v6 : TEXCOORD1,
  float4 v7 : TEXCOORD2,
  float4 v8 : TEXCOORD3,
  float4 v9 : TEXCOORD4,
  float4 v10 : TEXCOORD5,
  float4 v11 : TEXCOORD6,
  float4 v12 : TEXCOORD7,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1)
{
  float4 r0,r1,r2,r3,r4,r5,r6;

  r0.xyzw = t2.Sample(s2_s, v8.xy).xyzw;
  r0.xz = r0.wy * float2(2,2) + float2(-1,-1);
  r1.xy = r0.wy + r0.wy;
  r5.x = dot(r0.xz, -r0.xz);
  r0.x = 1 + r5.x;
  r5.y = rsqrt(abs(r0.x));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r0.x = r5.x ? 9.99999993e+36 : r5.y;
  r5.y = cmp(0 < abs(r0.x));
  r5.x = 1 / r0.x;
  r1.z = r5.y ? r5.x : 9.99999993e+36;
  r0.xyz = float3(-1,-1,-1) + r1.xyz;
  r1.xw = float2(0,1);
  r0.xyz = cb4[12].xxx * r0.xyz + r1.xxw;
  r1.xyzw = t2.Sample(s2_s, v8.zw).xyzw;
  r1.xz = r1.wy * float2(2,2) + float2(-1,-1);
  r2.xy = r1.wy + r1.wy;
  r5.w = dot(r1.xz, -r1.xz);
  r0.w = 1 + r5.w;
  r5.y = rsqrt(abs(r0.w));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r0.w = r5.x ? 9.99999993e+36 : r5.y;
  r5.y = cmp(0 < abs(r0.w));
  r5.x = 1 / r0.w;
  r2.z = r5.y ? r5.x : 9.99999993e+36;
  r1.xyz = float3(-1,-1,-1) + r2.xyz;
  r0.xyz = cb4[12].yyy * r1.xyz + r0.xyz;
  r1.xyzw = t2.Sample(s2_s, v9.xy).xyzw;
  r1.xz = r1.wy * float2(2,2) + float2(-1,-1);
  r2.xy = r1.wy + r1.wy;
  r5.w = dot(r1.xz, -r1.xz);
  r0.w = 1 + r5.w;
  r5.y = rsqrt(abs(r0.w));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r0.w = r5.x ? 9.99999993e+36 : r5.y;
  r5.y = cmp(0 < abs(r0.w));
  r5.x = 1 / r0.w;
  r2.z = r5.y ? r5.x : 9.99999993e+36;
  r1.xyz = float3(-1,-1,-1) + r2.xyz;
  r0.xyz = cb4[12].zzz * r1.xyz + r0.xyz;
  r0.xyz = float3(0,0,2) + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r5.y = rsqrt(abs(r0.w));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r0.w = r5.x ? 9.99999993e+36 : r5.y;
  r0.xyz = r0.xyz * r0.www + float3(-0,-0,-1);
  r0.w = max(0, v7.w);
  r5.y = rsqrt(abs(r0.w));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r1.x = r5.x ? 9.99999993e+36 : r5.y;
  r5.x = log2(abs(r0.w));
  r5.x = cb4[13].w * r5.x;
  r5.y = cmp(r5.x != r5.x);
  r5.x = r5.y ? 0 : r5.x;
  r1.y = exp2(r5.x);
  r5.y = cmp(0 < abs(r1.x));
  r5.x = 1 / r1.x;
  r0.w = r5.y ? r5.x : 9.99999993e+36;
  r0.xyz = r0.www * r0.xyz + float3(0,0,1);
  r5.x = dot(r0.xyz, r0.xyz);
  r5.x = rsqrt(r5.x);
  r5.y = cmp((int)r5.x != 0x7f800000);
  r6.xyzw = r0.xyzw * r5.xxxx;
  r2.xyz = r5.yyy ? r6.xyz : 0;
  r0.x = dot(v6.xyz, v6.xyz);
  r5.y = rsqrt(abs(r0.x));
  r5.x = cmp((int)r5.y == 0x7f800000);
  r0.x = r5.x ? 9.99999993e+36 : r5.y;
  r0.yzw = v6.xyz * r0.xxx;
  r1.xzw = v6.xyz * r0.xxx + -cb4[10].xyz;
  r0.x = dot(r0.yzw, r2.xyz);
  r2.w = saturate(r0.x);
  r2.w = 1 + -r2.w;
  r5.x = log2(abs(r2.w));
  r5.x = cb4[13].x * r5.x;
  r5.y = cmp(r5.x != r5.x);
  r5.x = r5.y ? 0 : r5.x;
  r3.x = exp2(r5.x);
  r2.w = r3.x * 0.980000019 + 0.0199999996;
  r5.x = cmp(r0.x >= 0);
  r0.x = r5.x ? r2.w : 0;
  r2.w = 1 + -r1.y;
  o0.w = r0.x * r2.w + r1.y;
  r1.y = dot(-r0.yzw, r2.xyz);
  r1.y = r1.y + r1.y;
  r0.yzw = r2.xyz * -r1.yyy + -r0.yzw;
  r5.x = dot(r0.yzw, r0.yzw);
  r5.x = rsqrt(r5.x);
  r5.y = cmp((int)r5.x != 0x7f800000);
  r6.xyzw = r0.yzww * r5.xxxx;
  r3.xyz = r5.yyy ? r6.xyz : 0;
  r5.xyzw = t26.Sample(s10_s, r3.xyz).xyzw;
  r3.xyzw = r5.xyzw;
  r5.x = dot(r1.xzw, r1.xzw);
  r5.x = rsqrt(r5.x);
  r5.y = cmp((int)r5.x != 0x7f800000);
  r6.xyzw = r1.xzww * r5.xxxx;
  r4.xyz = r5.yyy ? r6.xyz : 0;
  r0.y = dot(r2.xyz, r4.xyz);
  r0.z = dot(r2.xyz, -cb4[10].xyz);
  r1.x = max(0, r0.y);
  r5.y = cmp(r0.z >= 0);
  r0.y = r5.y ? r1.x : 0;
  r1.xyz = v7.xyz * r0.zzz;
  r5.x = log2(abs(r0.y));
  r5.x = cb4[13].z * r5.x;
  r5.y = cmp(r5.x != r5.x);
  r5.x = r5.y ? 0 : r5.x;
  r1.w = exp2(r5.x);
  r0.yzw = r1.www * cb4[11].xyz + r3.xyz;
  r0.yzw = r0.yzw * cb4[13].yyy + -r1.xyz;
  r0.xyz = saturate(r0.xxx * r0.yzw + r1.xyz);
  r0.xyz = -cb4[15].xyz + r0.xyz;
  r0.w = max(cb4[16].y, v11.w);
  o0.xyz = r0.www * r0.xyz + cb4[15].xyz;
  r5.y = cmp(0 < abs(cb4[14].x));
  r5.x = 1 / cb4[14].x;
  r0.x = r5.y ? r5.x : 9.99999993e+36;
  r0.x = saturate(v6.w * r0.x);
  r0.xyzw = float4(16777246,65536,256,1) * r0.xxxx;
  r0.xyzw = frac(r0.xyzw);
  o1.xyz = r0.xyz * float3(-0.00390599994,-0.00390599994,-0.00390599994) + r0.yzw;
  o1.w = 1;

  o0.a = saturate(o0.a);
}