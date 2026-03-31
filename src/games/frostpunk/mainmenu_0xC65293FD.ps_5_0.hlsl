// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:24:14 2025
#include "shared.h"
Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

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
  r0.zw = cb0[13].ww * r0.xy;
  r1.xyw = t0.Sample(s0_s, v1.xy).xyw;
  r2.x = 0.0399999991 * cb1[0].w;
  r2.yzw = cmp(float3(0,0,0) < cb1[0].wxy);
  r3.xy = float2(-0.5,-0.5) + r1.xy;
  r3.xy = r3.xy * r1.ww;
  r3.xy = r3.xy * r2.xx;
  r2.xy = r2.yy ? r3.xy : 0;
  r0.xy = r0.xy * cb0[13].ww + r2.xy;
  r3.xyz = t1.Sample(s1_s, r0.xy).xyz;
  // if (RENODX_TONE_MAP_TYPE == 0.f) {
  //   r3.xyz = log2(abs(r3.xyz));
  //   r3.xyz = float3(2.20000005,2.20000005,2.20000005) * r3.xyz;
  //   r3.xyz = exp2(r3.xyz);
  // }
  r3.xyz = renodx::color::srgb::DecodeSafe(r3.xyz);
  r0.x = renodx::color::y::from::BT709(r3.xyz);
  // r0.x = dot(r3.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r3.xyz = r3.xyz + -r0.xxx;
  r1.xyz = v2.xxx * r3.xyz + r0.xxx;
  r3.x = 1;
  r3.w = v2.w;
  r4.xyzw = r3.xxxw * r1.xyzw;
  r0.x = r3.w * r1.w + -cb1[0].z;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  if (r2.z != 0) {
    r0.x = -cb1[0].x * 2 + 3;
    r0.y = -1 + cb1[0].x;
    r1.x = t3.Sample(s3_s, r0.zw).w;
    r0.x = r1.x * r0.x + r0.y;
    r1.xyzw = r4.xyzw * r0.xxxx;
    r0.x = r4.w * r0.x + -0.00999999978;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
    r4.xyzw = r1.xyzw;
  }
  if (r2.w != 0) {
    r0.xyz = t2.Sample(s2_s, r0.zw).xyz;
    // if (RENODX_TONE_MAP_TYPE == 0.f) {
    //   r0.xyz = log2(abs(r0.xyz));
    //   r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
    //   r0.xyz = exp2(r0.xyz);
    // }
    r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
    r1.xyz = cmp(r0.xyz < float3(0.5,0.5,0.5));
    r2.xyz = r4.xyz * r0.xyz;
    r2.xyz = r2.xyz + r2.xyz;
    r3.xyz = float3(1,1,1) + -r0.xyz;
    r3.xyz = r3.xyz + r3.xyz;
    r5.xyz = float3(1,1,1) + -r4.xyz;
    r3.xyz = -r3.xyz * r5.xyz + float3(1,1,1);
    r1.xyz = r1.xyz ? r2.xyz : r3.xyz;
    r0.w = 1 + -r4.w;
    r0.xyz = r0.xyz * r0.www;
    r4.xyz = r1.xyz * r4.www + r0.xyz;
    r0.x = -0.00999999978 + r4.w;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  o0.xyzw = r4.xyzw;

  if (RENODX_TONE_MAP_TYPE != 0.f)
    o0.rgb = renodx::tonemap::Reinhard(o0.rgb, 1.0f);
  // o0.rgb /= 2;
  return;
}