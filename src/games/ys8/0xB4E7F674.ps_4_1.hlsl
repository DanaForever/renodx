// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 17:29:46 2025
#include "common.hlsl"
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
  float4 lightColor : packoffset(c4);
  float4 specColor : packoffset(c5);
  float4 lightvec : packoffset(c6);
  float numLight : packoffset(c1.w);

  struct
  {
    float4 pos;
    float4 color;
  } lightinfo[64] : packoffset(c7);

}

SamplerState tex_samp_s : register(s0);
SamplerState gradmap_samp_s : register(s1);
SamplerState toonmap_samp_s : register(s2);
SamplerState specmap_samp_s : register(s3);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> gradmap_tex : register(t1);
Texture2D<float4> toonmap_tex : register(t2);
Texture2D<float4> specmap_tex : register(t3);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float2 v1 : TEXCOORD1,
  float w1 : TEXCOORD9,
  float4 v2 : TEXCOORD2,
  float3 v3 : TEXCOORD3,
  float4 v4 : COLOR0,
  float4 v5 : COLOR1,
  float4 v6 : TEXCOORD8,
  float4 v7 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v2.xyz, v2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v2.xyz * r0.xxx;
  r1.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).xyzw;
  r2.xyzw = v4.xyzw * r1.xyzw;
  r1.x = cmp(0.000000 == lightvec.w);
  if (r1.x != 0) {
    r3.x = dot(-r0.yzw, v3.xyz);
    r3.y = 0.5;
    r3.xyzw = gradmap_tex.Sample(gradmap_samp_s, r3.xy).xyzw;
    r4.y = r3.w * r2.w;
  } else {
    r4.y = r2.w;
    r3.xyzw = float4(1,1,1,1);
  }
  r0.yz = cmp(float2(0,0) != noalpha);
  r0.y = ~(int)r0.y;
  r4.x = r3.w * r1.w;
  r5.x = -altest;
  r5.yw = float2(-0.00400000019,0.5);
  r1.yz = r5.xy + r4.xy;
  r1.yz = cmp(r1.yz < float2(0,0));
  r0.w = (int)r1.z | (int)r1.y;
  r0.y = r0.y ? r0.w : 0;
  if (r0.y != 0) discard;
  r0.y = dot(v3.xyz, lightvec.xyz);
  r0.y = 1 + -r0.y;
  r0.y = 0.5 * r0.y;
  r1.yzw = -v2.xyz * r0.xxx + lightvec.xyz;
  r0.w = dot(r1.yzw, r1.yzw);
  r0.w = rsqrt(r0.w);
  r1.yzw = r1.yzw * r0.www;
  r0.w = dot(r1.yzw, v3.xyz);
  r6.xyzw = specmap_tex.Sample(specmap_samp_s, v1.xy).xyzw;
  r1.y = numLight;
  r1.z = cmp(0 < r6.w);
  r4.xzw = float3(0,0,0);
  r7.xyz = float3(0,0,0);
  r1.w = 0;
  while (true) {
    r2.w = cmp((int)r1.w >= (int)r1.y);
    if (r2.w != 0) break;
    r2.w = (uint)r1.w << 1;
    r8.xyz = lightinfo[r2.w].pos.xyz + -v2.xyz;
    r3.w = dot(r8.xyz, r8.xyz);
    r8.w = sqrt(r3.w);
    r3.w = cmp(r8.w >= lightinfo[r2.w].pos.w);
    if (r3.w != 0) {
      r3.w = (int)r1.w + 1;
      r1.w = r3.w;
      continue;
    }
    r9.x = r8.w;
    r9.w = lightinfo[r2.w].pos.w;
    r8.xyzw = r8.xyzw / r9.xxxw;
    r3.w = 1 + -r8.w;
    r3.w = log2(r3.w);
    r3.w = lightinfo[r2.w].color.w * r3.w;
    r3.w = exp2(r3.w);
    r9.xyz = -v2.xyz * r0.xxx + r8.xyz;
    r5.x = dot(r9.xyz, r9.xyz);
    r5.x = rsqrt(r5.x);
    r9.xyz = r9.xyz * r5.xxx;
    r5.x = dot(r8.xyz, v3.xyz);
    r5.x = r5.x * 0.5 + 0.5;
    r5.y = dot(r9.xyz, v3.xyz);
    r7.w = cmp(r5.x >= 0);
    r8.x = max(0, r5.x);
    r5.x = cmp(r5.y >= 0);
    r5.x = r7.w ? r5.x : 0;
    r5.y = log2(r5.y);
    r5.y = r6.w * r5.y;
    r5.y = exp2(r5.y);
    r8.y = r5.x ? r5.y : 0;
    r5.xy = r8.xy * r3.ww;
    r4.xzw = lightinfo[r2.w].color.xyz * r5.xxx + r4.xzw;
    r8.xyz = lightinfo[r2.w].color.xyz * r5.yyy + r7.xyz;
    r7.xyz = r1.zzz ? r8.xyz : r7.xyz;
    r1.w = (int)r1.w + 1;
  }
  r1.yz = float2(0.224250004,0.440250009) * r4.xz;
  r1.y = r1.y + r1.z;
  r1.y = r4.w * 0.0855000019 + r1.y;
  r1.y = saturate(1 + -r1.y);
  r5.z = r1.y * r0.y;
  r1.yzw = r7.xyz * float3(0.100000001,0.100000001,0.100000001) + v5.xyz;
  r7.xyz = lightColor.xyz + r4.xzw;
  r4.xzw = -lightColor.xyz * r4.xzw + r7.xyz;
  r0.y = cmp(0 < lightvec.w);
  if (r0.y != 0) {
    r0.y = cmp(0 < v3.z);
    r2.w = dot(v3.xy, v3.xy);
    r2.w = rsqrt(r2.w);
    r5.xy = v3.xy * r2.ww;
    r5.xy = r0.yy ? r5.xy : v3.xy;
    r0.xy = v2.xy * r0.xx + r5.xy;
    r7.xy = r0.xy * float2(0.5,-0.5) + float2(-0.5,0.5);
    r7.z = -r7.x;
    r7.xyzw = gradmap_tex.Sample(gradmap_samp_s, r7.zy).xyzw;
    r0.x = cmp(0 < lightColor.w);
    r7.xyz = r7.xyz * r4.xzw;
    r0.y = lightvec.w * r7.w;
    r8.xyz = r7.xyz * r0.yyy + r1.yzw;
    r7.xyz = r7.xyz * v4.xyz + -r2.xyz;
    r7.xyz = r0.yyy * r7.xyz + r2.xyz;
    r1.yzw = r0.xxx ? r8.xyz : r1.yzw;
    r2.xyz = r0.xxx ? r2.xyz : r7.xyz;
  }
  r5.xyz = toonmap_tex.Sample(toonmap_samp_s, r5.zw).xyz;
  r0.x = cmp(0.000000 != lightColor.w);
  r0.x = r0.x ? r1.x : 0;
  r7.xyz = float3(1,1,1) + -r4.xzw;
  r7.xyz = r6.yyy * r7.xyz + r4.xzw;
  r7.xyz = r7.xyz * r2.xyz;
  r8.xyzw = specColor.xyzw * r6.xxxw;
  r8.xyz = r8.xyz * r4.xzw;
  r0.y = max(2, r8.w);
  r0.w = max(0, r0.w);
  r0.w = log2(r0.w);
  r0.y = r0.y * r0.w;
  r0.y = exp2(r0.y);
  r8.xyz = r8.xyz * r0.yyy;
  r2.xyz = r2.xyz * r4.xzw;
  r9.xyz = specColor.xyz * r6.xyz;
  r9.xyz = r9.xyz * r4.xzw;
  r9.xyz = r9.xyz * r0.yyy;
  r2.xyz = r0.xxx ? r7.xyz : r2.xyz;
  r8.w = r6.y;
  r9.w = 0;
  r7.xyzw = r0.xxxx ? r8.xyzw : r9.xyzw;
  r2.xyz = r7.xyz + r2.xyz;
  r2.xyz = min(float3(1,1,1), r2.xyz);
  r0.y = cmp(0 < r7.w);
  r6.xyw = float3(1,1,1) + -r5.xyz;
  r6.xyw = r7.www * r6.xyw + r5.xyz;
  r5.xyz = r0.yyy ? r6.xyw : r5.xyz;
  r5.xyz = shadowcolor.xyz * v5.www + r5.xyz;
  r5.xyz = min(float3(1,1,1), r5.xyz);
  r3.xyz = r3.xyz * r4.xzw + r1.yzw;
  r1.xyz = r1.xxx ? r3.xyz : r1.yzw;
  r1.xyz = r2.xyz * r5.xyz + r1.xyz;
  r1.xyz = min(float3(1,1,1), r1.xyz);
  r0.y = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  r0.w = dot(v6.xyz, float3(0.298999995,0.587000012,0.114));
  r0.y = -r0.w * 0.5 + r0.y;
  r0.y = max(0, r0.y);
  r0.w = 1 + -v6.w;
  r0.w = w1.x * r0.w;
  r0.y = r0.y * r0.w;
  r2.xyz = r1.xyz * v6.www + v6.xyz;
  r3.xyz = r1.xyz * r0.yyy;
  r4.xzw = r1.xyz * r0.yyy + r2.xyz;
  r2.xyz = -r2.xyz * r3.xyz + r4.xzw;
  r1.xyz = -r2.xyz + r1.xyz;
  r1.xyz = r6.zzz * r1.xyz + r2.xyz;
  r0.xyw = r0.xxx ? r1.xyz : r2.xyz;
  r1.x = -r4.y * v6.w + 1;
  r1.yzw = float3(1,1,1) + -r0.xyw;
  r1.xyz = r1.xxx * r1.yzw + r0.xyw;
  o0.xyz = r0.zzz ? r1.xyz : r0.xyw;
  r0.x = cmp(0 < zwrite);
  r0.y = cmp(8.000000 == zwrite);
  r1.xyz = v3.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = 0;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.w = r4.y;

  
  return;
}