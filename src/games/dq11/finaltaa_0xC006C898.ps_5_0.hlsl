// ---- Created with 3Dmigoto v1.3.16 on Sun Jul 20 18:07:06 2025
#include "shared.h"
Texture3D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[1];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[121];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[35];
}




// 3Dmigoto declarations
#define cmp -


void main(
  linear noperspective float2 v0 : TEXCOORD0,
  linear noperspective float2 w0 : TEXCOORD4,
  linear noperspective float4 v1 : TEXCOORD1,
  linear noperspective float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v2.w * 543.309998 + v2.z;
  r0.x = sin(r0.x);
  r0.x = 493013 * r0.x;
  r0.x = frac(r0.x);
  r0.y = -r0.x * r0.x + 1;
  r0.y = cb0[33].z * r0.y;
  r0.zw = v2.xy + -v0.xy;
  r0.yz = r0.yy * r0.zw + v0.xy;
  r1.xyz = t1.Sample(s1_s, r0.yz).xyz;
  r2.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, 0)).xyz;
  r3.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(1, 0)).xyz;
  r4.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, -1)).xyz;
  r0.yzw = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, 1)).xyz;
  r1.w = dot(r1.xyz, float3(0.300000012,0.589999974,0.109999999));
  r5.x = dot(r2.xyz, float3(0.300000012,0.589999974,0.109999999));
  r5.y = dot(r3.xyz, float3(0.300000012,0.589999974,0.109999999));
  r5.z = dot(r4.xyz, float3(0.300000012,0.589999974,0.109999999));
  r5.w = dot(r0.yzw, float3(0.300000012,0.589999974,0.109999999));
  r5.xyzw = -r5.xyzw + r1.wwww;
  r5.xy = max(abs(r5.xz), abs(r5.yw));
  r1.w = max(r5.x, r5.y);
  r1.w = saturate(-v1.x * r1.w + 1);
  r1.w = cb0[31].w * -r1.w;
  r2.xyz = r3.xyz + r2.xyz;
  r2.xyz = r2.xyz + r4.xyz;
  r0.yzw = r2.xyz + r0.yzw;
  r0.yzw = -r1.xyz * float3(4,4,4) + r0.yzw;
  r0.yzw = r0.yzw * r1.www + r1.xyz;
  r1.xyz = t2.Sample(s2_s, v0.xy).xyz;
  r2.xy = -cb1[119].xy + v4.xy;
  r2.xy = cb1[120].zw * r2.xy;
  r2.xyz = t0.Sample(s0_s, r2.xy).xyz;
  r2.xyz = r2.xyz * cb2[0].xyz + cb0[30].xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r0.yzw = r0.yzw * cb0[29].xyz + r1.xyz;
  r0.yzw = v1.xxx * r0.yzw;
  r1.xy = cb0[31].zz * v1.yz;
  r1.x = dot(r1.xy, r1.xy);
  r1.x = 1 + r1.x;
  r1.x = rcp(r1.x);
  r1.x = r1.x * r1.x;
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = r0.x * cb0[33].x + cb0[33].y;
  r1.yzw = r1.xxx * r0.yzw;
  r2.x = cmp(asuint(cb0[34].x) >= 3);
  // r1.yzw = float3(9.99999975e-005,9.99999975e-005,9.99999975e-005) * r1.yzw;
  // r1.yzw = log2(r1.yzw);
  // r1.yzw = float3(0.159301758,0.159301758,0.159301758) * r1.yzw;
  // r1.yzw = exp2(r1.yzw);
  // r2.yzw = r1.yzw * float3(18.8515625,18.8515625,18.8515625) + float3(0.8359375,0.8359375,0.8359375);
  // r1.yzw = r1.yzw * float3(18.6875,18.6875,18.6875) + float3(1,1,1);
  // r1.yzw = rcp(r1.yzw);
  // r1.yzw = r2.yzw * r1.yzw;
  // r1.yzw = log2(r1.yzw);
  // r1.yzw = float3(78.84375,78.84375,78.84375) * r1.yzw;
  // r1.yzw = exp2(r1.yzw);
  // r1.yzw = renodx::color::pq::EncodeSafe(r1.yzw, 1.f);
  r0.yzw = r0.yzw * r1.xxx + float3(0.00266771927,0.00266771927,0.00266771927);
  r0.yzw = log2(r0.yzw);
  r0.yzw = saturate(r0.yzw * float3(0.0714285746, 0.0714285746, 0.0714285746) + float3(0.610726953, 0.610726953, 0.610726953));
  r0.yzw = r2.xxx ? renodx::color::pq::EncodeSafe(r1.yzw, 1.f) : r0.yzw;

  r0.yzw = r0.yzw * float3(0.96875,0.96875,0.96875) + float3(0.015625,0.015625,0.015625);
  r0.yzw = t3.Sample(s3_s, r0.yzw).xyz;
  r1.xyz = float3(1.04999995,1.04999995,1.04999995) * r0.yzw;
  // o0.w = saturate(dot(r1.xyz, float3(0.298999995,0.587000012,0.114)));
  o0.w = renodx::color::y::from::BT709(r1.xyz);
  r0.x = r0.x * 0.00390625 + -0.001953125;
  r0.xyz = r0.yzw * float3(1.04999995,1.04999995,1.04999995) + r0.xxx;
  r1.xy = cmp(asint(cb0[34].xx) == int2(5,6));
  r0.w = (int)r1.y | (int)r1.x;
  if (r0.w != 0) {
  // if (false) {
    r0.w = cmp(asint(cb0[34].x) == 4);
    r0.w = (int)r1.y | (int)r0.w;
    r1.xyzw = r0.wwww ? float4(2000,0.00499999989,-0.00499999989,25) : float4(1000,9.99999975e-005,-9.99999975e-005,12.5);
    // r2.xyz = log2(r0.xyz);
    // r2.xyz = float3(0.0126833133,0.0126833133,0.0126833133) * r2.xyz;
    // r2.xyz = exp2(r2.xyz);
    // r3.xyz = float3(-0.8359375,-0.8359375,-0.8359375) + r2.xyz;
    // r3.xyz = max(float3(0,0,0), r3.xyz);
    // r2.xyz = -r2.xyz * float3(18.6875,18.6875,18.6875) + float3(18.8515625,18.8515625,18.8515625);
    // r2.xyz = r3.xyz / r2.xyz;
    // r2.xyz = log2(r2.xyz);
    // r2.xyz = float3(6.27739477,6.27739477,6.27739477) * r2.xyz;
    // r2.xyz = exp2(r2.xyz);
    // r2.xyz = float3(10000,10000,10000) * r2.xyz;
    r2.xyz = renodx::color::pq::DecodeSafe(r0.xyz, 1.f);
    r2.xyz = max(r2.xyz, r1.yyy);
    r2.xyz = min(r2.xyz, r1.xxx);
    r2.xyz = r2.xyz + r1.zzz;
    r0.w = r1.x + r1.z;
    r1.xyz = r2.xyz / r0.www;
    r2.x = dot(float3(1.73125386,-0.604043067,-0.0801077113), r1.xyz);
    r2.y = dot(float3(-0.131618932,1.13484156,-0.00867943279), r1.xyz);
    r2.z = dot(float3(-0.0245682523,-0.125750408,1.06563699), r1.xyz);
    o0.xyz = r2.xyz * r1.www;
  } else {
    if (RENODX_TONE_MAP_TYPE == 0.f) {
      o0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
    }
    else {
      o0.xyz = renodx::draw::ToneMapPass(r0.xyz);
    }
    o0.rgb = renodx::draw::RenderIntermediatePass(o0.rgb);
    
  }
  return;
}