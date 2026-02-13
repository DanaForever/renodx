// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 22:55:24 2025
#include "common.hlsl"
#include "shared.h"

Texture2D<float4> t13 : register(t13);
Texture1D<float4> t4 : register(t4);
Texture1D<float4> t3 : register(t3);
Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[10];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[17];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  out float4 o0 : SV_Target0)
{
// Needs manual fix for instruction:
// unknown dcl_: dcl_resource_texture1d (float,float,float,float) t3
// Needs manual fix for instruction:
// unknown dcl_: dcl_resource_texture1d (float,float,float,float) t4
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t13.Sample(s13_s, v1.xy).w;
  r0.y = -0.00999999978 + r0.x;
  r0.y = cmp(r0.y < 0);
  if (r0.y != 0) discard;
  r0.yz = cb2[6].xy + v1.xy;
  r0.yzw = t0.Sample(s0_s, r0.yz).xyz;
  r0.yzw = cb0[16].yyy * r0.yzw;
  r1.xyz = r0.yzw * float3(2570.23999,2570.23999,2570.23999) + float3(0.0299999993,0.0299999993,0.0299999993);
  r2.xyz = float3(1024,1024,1024) * r0.yzw;
  r0.yzw = r0.yzw * float3(2488.32007,2488.32007,2488.32007) + float3(0.589999974,0.589999974,0.589999974);
  r0.yzw = r2.xyz * r0.yzw + float3(0.140000001,0.140000001,0.140000001);
  r1.xyz = r2.xyz * r1.xyz;
  r0.yzw = saturate(r1.xyz / r0.yzw);
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.xyz = cb2[9].xyz * r1.xyz;
  o0.w = r1.w * r0.x;
  r1.xyz = cb0[16].yyy * r1.xyz;

  float3 untonemapped = r1.xyz;
  r1.xyz = displayMap(r1.xyz);

  r2.xyz = r1.xyz * float3(2570.23999,2570.23999,2570.23999) + float3(0.0299999993,0.0299999993,0.0299999993);
  r3.xyz = float3(1024,1024,1024) * r1.xyz;
  r1.xyz = r1.xyz * float3(2488.32007,2488.32007,2488.32007) + float3(0.589999974,0.589999974,0.589999974);
  r1.xyz = r3.xyz * r1.xyz + float3(0.140000001,0.140000001,0.140000001);
  r2.xyz = r3.xyz * r2.xyz;
  r1.xyz = saturate(r2.xyz / r1.xyz);
  r0.xyz = -r1.xyz + r0.yzw;
  r0.xyz = cb2[6].zzz * r0.xyz + r1.xyz;

  r1.x = t4.Sample(s4_s, r0.x).x;
  r1.y = t4.Sample(s4_s, r0.y).y;
  r1.z = t4.Sample(s4_s, r0.z).z;
  r0.xyz = cb2[8].xyz * r1.xyz;
  r2.xyz = sqrt(r0.xyz);
  r3.xyz = cb2[3].xyz + -r2.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = cb2[4].xyz + -r2.xyz;
  r0.w = dot(r2.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.w = min(1, r0.w);

  r3.xyzw = t3.Sample(s3_s, r0.w).xyzw;
  r3.y = dot(r4.xyz, r4.xyz);
  r3.xy = saturate(r3.xy * cb2[5].xy + cb2[5].zw);
  r2.w = 1.f;
  r0.w = r3.x * r2.w;
  r0.w = saturate(r0.w * r3.y);
  r1.xyz = -r1.xyz * cb2[8].xyz + r2.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.xyz = r0.xyz + -r0.www;
  r0.xyz = cb2[1].zzz * r0.xyz + r0.www;
  r0.xyz = r0.xyz + r0.xyz;
  r0.xyz = log2(abs(r0.xyz));
  r0.xyz = cb2[1].www * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = float3(0.5,0.5,0.5) * r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.xyz = v3.xyz * r0.xyz;
  r0.w = dot(v2.xy, v2.xy);
  r0.w = saturate(r0.w * cb2[1].x + cb2[1].y);
  r0.w = r0.w * r0.w;
  o0.xyz = r0.xyz * r0.www;

  if (RENODX_TONE_MAP_TYPE > 1.f) {
    o0.xyz = renodx::draw::ToneMapPass(untonemapped, o0.xyz);
  }

  // o0.xyz = renodx::draw::RenderIntermediatePass(o0.xyz);
  return;
}