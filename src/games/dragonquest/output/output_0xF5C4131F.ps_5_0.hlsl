// ---- Created with 3Dmigoto v1.3.16 on Sat Feb 21 00:34:16 2026
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
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v2.w * 543.309998 + v2.z;
  r0.x = sin(r0.x);
  r0.x = 493013 * r0.x;
  r0.x = frac(r0.x);
  r0.y = -r0.x * r0.x + 1;
  r0.y = cb0[34].z * r0.y;
  r0.zw = v2.xy + -v0.xy;
  r0.yz = r0.yy * r0.zw + v0.xy;
  r1.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, 0)).xyz;
  r2.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(1, 0)).xyz;
  r1.xyzw = r2.yxyz + r1.yxyz;
  r2.xyzw = t1.Sample(s1_s, r0.yz).xyzw;
  r0.w = r2.y * 2 + -r1.x;
  r3.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, -1)).xyz;
  r4.xyz = t1.SampleLevel(s1_s, r0.yz, 0, int2(-1, 1)).xyz;
  r0.y = r4.y + r3.y;
  r1.xyz = r3.xyz + r1.yzw;
  r1.xyz = r1.xyz + r4.xyz;
  r1.xyz = -r2.xyz * float3(4,4,4) + r1.xyz;
  r0.y = r2.y * 2 + -r0.y;
  r0.y = max(abs(r0.w), abs(r0.y));
  r0.y = saturate(-v1.x * r0.y + 1);
  r0.y = cb0[32].y * -r0.y;
  r0.yzw = r1.xyz * r0.yyy + r2.xyz;
  r1.xy = -cb1[114].xy + v5.xy;
  r1.xy = cb1[115].zw * r1.xy;
  r1.xyz = t0.Sample(s0_s, r1.xy).xyz;
  r1.xyz = r1.xyz * cb2[0].xyz + cb0[30].xyz;
  r2.xyz = t2.Sample(s2_s, v0.xy).xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r0.yzw = r0.yzw * cb0[29].xyz + r1.xyz;
  r1.xyz = cmp(cb0[32].zzz < r1.xyz);
  r0.yzw = v1.xxx * r0.yzw;
  r2.xy = cb0[32].xx * v1.yz;
  r1.w = dot(r2.xy, r2.xy);
  r1.w = 1 + r1.w;
  r1.w = rcp(r1.w);
  r1.w = r1.w * r1.w;
  r0.yzw = r1.www * r0.yzw;
  r1.w = r0.x * cb0[34].x + cb0[34].y;
  r0.x = r0.x * 0.00390625 + -0.001953125;
  r0.yzw = r1.www * r0.yzw;
  r2.xyz = float3(9.99999975e-005,9.99999975e-005,9.99999975e-005) * r0.yzw;
  r0.yzw = log2(r0.yzw);
  r0.yzw = saturate(r0.yzw * float3(0.0714285746,0.0714285746,0.0714285746) + float3(0.610726953,0.610726953,0.610726953));
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
  r1.w = cmp(asuint(cb0[35].z) >= 3);
  r0.yzw = r1.www ? r2.xyz : r0.yzw;
  r0.yzw = r0.yzw * float3(0.96875,0.96875,0.96875) + float3(0.015625,0.015625,0.015625);

  //
  // r0.yzw = t3.Sample(s3_s, r0.yzw).xyz;
  r0.yzw = renodx::lut::SampleTetrahedral(t3, r0.yzw, 32u);

  r2.xyz = float3(1.04999995, 1.04999995, 1.04999995) * r0.yzw;
  r2.rgb = renodx::color::pq::DecodeSafe(r2.rgb);
  o0.xyz = r2.xyz + r0.xxx;

  // r0.x = saturate(dot(r2.xyz, float3(0.298999995,0.587000012,0.114)));
  r0.x = saturate(renodx::color::y::from::BT709(r2.rgb));
  r0.y = cmp(cb1[166].w == 0.000000);
  r0.z = (int)r1.y | (int)r1.x;
  r0.z = (int)r1.z | (int)r0.z;
  r0.z = r0.z ? 1 : r2.w;
  o0.w = saturate(r0.y ? r0.x : r0.z);

  o0.rgb = DisplayMap(o0.rgb);

  return;
}