// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 19:47:49 2025
#include "common.hlsl"
#include "shared.h"
Texture2D<float4> t0 : register(t0);
Texture1D<float4> t4 : register(t4);
Texture1D<float4> t3 : register(t3);

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

  r0.xy = cb2[6].xy + v1.xy;
  r0.xyz = t0.Sample(s0_s, r0.xy).xyz;
  
  // o0 = r0;
  // o0.w = 1;
  // return;
  r0.xyz = cb0[16].yyy * r0.xyz;
  
  
  
  // r1.xyz = r0.xyz * float3(2570.23999,2570.23999,2570.23999) + float3(0.0299999993,0.0299999993,0.0299999993);
  // r2.xyz = float3(1024,1024,1024) * r0.xyz;
  // r0.xyz = r0.xyz * float3(2488.32007,2488.32007,2488.32007) + float3(0.589999974,0.589999974,0.589999974);
  // r0.xyz = r2.xyz * r0.xyz + float3(0.140000001,0.140000001,0.140000001);
  // r1.xyz = r2.xyz * r1.xyz;
  // r0.xyz = (r1.xyz / r0.xyz);
  r0.xyz = renodx::tonemap::ACESFittedBT709(r0.xyz / 0.6f);
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.xyz = cb2[9].xyz * r1.xyz;
  o0.w = r1.w;
  r1.xyz = cb0[16].yyy * r1.xyz;
  float3 untonemapped = r1.xyz;
  r1.xyz = displayMap(r1.xyz);
  
  // r2.xyz = r1.xyz * float3(2570.23999,2570.23999,2570.23999) + float3(0.0299999993,0.0299999993,0.0299999993);
  // r3.xyz = float3(1024,1024,1024) * r1.xyz;
  // r1.xyz = r1.xyz * float3(2488.32007,2488.32007,2488.32007) + float3(0.589999974,0.589999974,0.589999974);
  // r1.xyz = r3.xyz * r1.xyz + float3(0.140000001,0.140000001,0.140000001);
  // r2.xyz = r3.xyz * r2.xyz;
  // r1.xyz = (r2.xyz / r1.xyz);
  // r0.xyz = -r1.xyz + r0.xyz;
  // r0.xyz = cb2[6].zzz * r0.xyz + r1.xyz;
  r1.xyz = renodx::tonemap::ACESFittedBT709(r1.xyz);
  r0.xyz = lerp(r1.xyz, r0.xyz, cb2[6].z);

  r1.x = t4.Sample(s4_s, r0.x).x;
  r1.y = t4.Sample(s4_s, r0.y).y;
  r1.z = t4.Sample(s4_s, r0.z).z;
  r0.xyz = cb2[8].xyz * r1.xyz;
  r2.xyz = sqrt(r0.xyz);
  r2.w = 1.f;
 
  r3.xyz = cb2[3].xyz + -r2.xyz;
  r3.x = dot(r3.xyz, r3.xyz);
  r4.xyz = cb2[4].xyz + -r2.xyz;
  r0.w = dot(r2.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r0.w = min(1, r0.w);
  r3.xyzw = t3.Sample(s3_s, r0.w).xyzw;
  r3.y = dot(r4.xyz, r4.xyz);
  r3.xy = saturate(r3.xy * cb2[5].xy + cb2[5].zw);
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
  
  o0.xyz = CustomRenderIntermediatePass(o0.xyz);
  return;
}