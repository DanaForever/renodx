// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:24:14 2025
#include "shared.h"
Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[1];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[14];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.xy * cb0[7].xy + cb0[8].xy;
  r0.xy = cb0[13].ww * r0.xy;
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r2.xyzw = v2.xyzw * r1.xyzw;
  r0.z = v2.w * r1.w + -cb1[0].z;
  r0.z = cmp(r0.z < 0);
  if (r0.z != 0) discard;
  r0.zw = cmp(float2(0,0) < cb1[0].xy);
  if (r0.z != 0) {
    r0.z = -cb1[0].x * 2 + 3;
    r1.x = -1 + cb1[0].x;
    r1.y = t3.Sample(s3_s, r0.xy).w;
    r0.z = r1.y * r0.z + r1.x;
    r1.xyzw = r2.xyzw * r0.zzzz;
    r0.z = r2.w * r0.z + -0.00999999978;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
    r2.xyzw = r1.xyzw;
  }
  if (r0.w != 0) {
    r0.xyz = t2.Sample(s2_s, r0.xy).xyz;

    if (RENODX_TONE_MAP_TYPE == 0.f) {
      r0.xyz = log2(abs(r0.xyz));
      r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
      r0.xyz = exp2(r0.xyz);
    }
    r1.xyz = cmp(r0.xyz < float3(0.5,0.5,0.5));
    r3.xyz = r2.xyz * r0.xyz;
    r3.xyz = r3.xyz + r3.xyz;
    r4.xyz = float3(1,1,1) + -r0.xyz;
    r4.xyz = r4.xyz + r4.xyz;
    r5.xyz = float3(1,1,1) + -r2.xyz;
    r4.xyz = -r4.xyz * r5.xyz + float3(1,1,1);
    r1.xyz = r1.xyz ? r3.xyz : r4.xyz;
    r0.w = 1 + -r2.w;
    r0.xyz = r0.xyz * r0.www;
    r2.xyz = r1.xyz * r2.www + r0.xyz;
    r0.x = -0.00999999978 + r2.w;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  o0.xyzw = r2.xyzw;
  return;
}