// ---- Created with 3Dmigoto v1.3.16 on Mon Feb 23 22:45:54 2026
#include "./output.hlsli"
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
  float4 cb1[167];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[36];
}




// 3Dmigoto declarations
#define cmp -


void main(
  linear noperspective float4 v0 : TEXCOORD0,
  linear noperspective float4 v1 : TEXCOORD1,
  linear noperspective float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb0[32].xx * v1.yz;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = 1 + r0.x;
  r0.x = rcp(r0.x);
  r0.x = r0.x * r0.x;
  r0.yz = -cb1[114].xy + v5.xy;
  r0.yz = cb1[115].zw * r0.yz;
  r0.yzw = t0.Sample(s0_s, r0.yz).xyz;
  r0.yzw = r0.yzw * cb2[0].xyz + cb0[30].xyz;
  r1.xyz = t2.Sample(s2_s, v0.xy).xyz;
  r0.yzw = r1.xyz * r0.yzw;
  r1.xyzw = t1.Sample(s1_s, v0.xy).xyzw;
  r1.xyz = r1.xyz * cb0[29].xyz + r0.yzw;
  r0.yzw = cmp(cb0[32].zzz < r0.yzw);
  r1.xyz = v1.xxx * r1.xyz;
  r1.xyz = r1.xyz * r0.xxx;
  r2.xyz = float3(9.99999975e-005,9.99999975e-005,9.99999975e-005) * r1.xyz;
  r1.xyz = log2(r1.xyz);
  r1.xyz = saturate(r1.xyz * float3(0.0714285746,0.0714285746,0.0714285746) + float3(0.610726953,0.610726953,0.610726953));
  r2.xyz = log2(r2.xyz);
  r2.xyz = float3(0.159301758,0.159301758,0.159301758) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r3.xyz = r2.xyz * float3(18.6875,18.6875,18.6875) + float3(1,1,1);
  r2.xyz = r2.xyz * float3(18.8515625,18.8515625,18.8515625) + float3(0.8359375,0.8359375,0.8359375);
  r3.xyz = rcp(r3.xyz);
  r2.xyz = r3.xyz * r2.xyz;
  r2.xyz = log2(r2.xyz);
  r2.xyz = float3(78.84375,78.84375,78.84375) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r0.x = cmp(asuint(cb0[35].z) >= 3);
  r1.xyz = r0.xxx ? r2.xyz : r1.xyz;
  r1.xyz = r1.xyz * float3(0.96875,0.96875,0.96875) + float3(0.015625,0.015625,0.015625);
  // r1.xyz = t3.Sample(s3_s, r1.xyz).xyz;
  r1.xyz = renodx::lut::SampleTetrahedral(t3, r1.xyz, 32u);
  r2.xyz = float3(1.04999995, 1.04999995, 1.04999995) * r1.xyz;
  r2.rgb = renodx::color::pq::DecodeSafe(r2.rgb);
  // r0.x = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
  r0.x = saturate(renodx::color::y::from::BT709(r2.rgb));
  r0.y = (int)r0.z | (int)r0.y;
  r0.y = (int)r0.w | (int)r0.y;
  r0.y = r0.y ? 1 : r1.w;
  r0.z = cmp(cb1[166].w == 0.000000);
  o0.w = saturate(r0.z ? r0.x : r0.y);
  r0.x = v2.w * 543.309998 + v2.z;
  r0.x = sin(r0.x);
  r0.x = 493013 * r0.x;
  r0.x = frac(r0.x);
  r0.x = r0.x * 0.00390625 + -0.001953125;
  o0.xyz = r1.xyz * float3(1.04999995,1.04999995,1.04999995) + r0.xxx;
  o0.xyz = r2.xyz + r0.xxx;

  o0.rgb = DisplayMap(o0.rgb);
  return;
}