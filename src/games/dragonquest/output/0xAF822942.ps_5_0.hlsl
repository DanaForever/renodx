// ---- Created with 3Dmigoto v1.3.16 on Wed Feb 18 12:54:49 2026
#include "output.hlsli"

Texture3D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[159];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[71];
}




// 3Dmigoto declarations

#define cmp -


void main(
  linear noperspective float2 v0 : TEXCOORD0,
  linear noperspective float2 w0 : TEXCOORD3,
  linear noperspective float4 v1 : TEXCOORD1,
  linear noperspective float4 v2 : TEXCOORD2,
  float2 v3 : TEXCOORD4,
  float4 v4 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = w0.xyxy * cb0[67].zwzw + cb0[67].xyxy;
  r1.xyzw = cmp(float4(0,0,0,0) < r0.zwzw);
  r2.xyzw = cmp(r0.zwzw < float4(0,0,0,0));
  r1.xyzw = (int4)-r1.xyzw + (int4)r2.xyzw;
  r1.xyzw = (int4)r1.xyzw;
  r2.xyzw = saturate(-cb0[70].zzzz + abs(r0.zwzw));
  r1.xyzw = r2.xyzw * r1.xyzw;
  r0.xyzw = -r1.xyzw * cb0[70].xxyy + r0.xyzw;
  r0.xyzw = r0.xyzw * cb0[68].zwzw + cb0[68].xyxy;
  r0.xyzw = r0.xyzw * cb0[38].zwzw + cb0[39].xyxy;
  r0.xyzw = cb0[38].xyxy * r0.xyzw;
  r0.xyzw = max(cb0[43].zwzw, r0.xyzw);
  r0.xyzw = min(cb0[44].xyxy, r0.xyzw);
  r1.x = t0.Sample(s0_s, r0.xy).x;
  r1.y = t0.Sample(s0_s, r0.zw).y;
  r0.xy = max(cb0[43].zw, v0.xy);
  r0.xy = min(cb0[44].xy, r0.xy);
  r1.z = t0.Sample(s0_s, r0.xy).z;
  r0.xyz = cb1[135].zzz * r1.xyz;
  r1.xy = cb0[58].zw * v0.xy + cb0[59].xy;
  r1.xy = max(cb0[50].zw, r1.xy);
  r1.xy = min(cb0[51].xy, r1.xy);
  r1.xyz = t1.Sample(s1_s, r1.xy).xyz;
  r1.xyz = cb1[135].zzz * r1.xyz;
  r1.xyz = cb0[61].xyz * r1.xyz;
  r0.xyz = r0.xyz * cb0[60].xyz + r1.xyz;
  r1.xy = asuint(cb0[53].zw);
  r1.xy = v4.xy + -r1.xy;
  r1.xy = -r1.xy * cb0[55].xy + float2(0.5,0.5);
  r0.w = dot(cb1[155].xy, r1.xy);
  r1.x = dot(r1.xy, r1.xy);
  r1.x = sqrt(r1.x);
  r1.x = 1 + -r1.x;
  r0.w = -r1.x * 0.25 + r0.w;
  r0.w = 0.25 + r0.w;
  r0.w = max(0, r0.w);
  r0.w = log2(r0.w);
  r0.w = cb1[155].z * r0.w;
  r0.w = exp2(r0.w);
  r1.xyz = cb1[156].xyz * r0.www;
  r0.xyz = r0.xyz * v1.xxx + r1.xyz;
  r1.xy = cb0[62].xx * v1.yz;
  r0.w = dot(r1.xy, r1.xy);
  r0.w = log2(r0.w);
  r0.w = cb1[157].w * r0.w;
  r0.w = exp2(r0.w);
  r0.w = 1 + r0.w;
  r0.w = rcp(r0.w);
  r0.w = r0.w * r0.w;
  r1.xyz = float3(1,1,1) + -cb1[157].xyz;
  r1.xyz = r0.www * r1.xyz + cb1[157].xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r1.xyz = v2.www * float3(127.309998,109.309998,113.309998) + v2.zzz;
  r1.xyz = sin(r1.xyz);
  r1.xyz = float3(493013,493013,493013) * r1.xyz;
  r1.xyz = frac(r1.xyz);
  r1.xyz = r1.xyz * cb0[64].xxx + cb0[64].yyy;
  r0.w = dot(r0.xyz, float3(0.300000012,0.589999974,0.109999999));
  r0.w = sqrt(r0.w);
  r0.w = 1 + -r0.w;
  r0.w = max(0, r0.w);
  r0.w = -1 + r0.w;
  r0.w = cb1[158].x * r0.w + 1;
  r1.xyz = float3(-1,-1,-1) + r1.xyz;
  r1.xyz = r0.www * r1.xyz + float3(1,1,1);
  r0.xyz = r0.xyz * r1.xyz + float3(0.00266771927,0.00266771927,0.00266771927);

  // o0.rgb = renodx::color::srgb::EncodeSafe(r0.rgb);
  // o0.w = 1;
  // return;

  // r0.xyz = log2(r0.xyz);
  // r0.xyz = saturate(r0.xyz * float3(0.0714285746,0.0714285746,0.0714285746) + float3(0.610726953,0.610726953,0.610726953));
  // r0.xyz = r0.xyz * float3(0.96875,0.96875,0.96875) + float3(0.015625,0.015625,0.015625);

  // lut sampling
  r0.xyz = t2.Sample(s2_s, r0.xyz).xyz;
  
  r0.xyz = float3(1.04999995,1.04999995,1.04999995) * r0.xyz;

  o0.w = saturate(dot(r0.xyz, float3(0.298999995,0.587000012,0.114)));
  if (cb0[65].x != 0) {
    r1.xyz = log2(r0.xyz);
    r1.xyz = float3(0.0126833133,0.0126833133,0.0126833133) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r2.xyz = float3(-0.8359375,-0.8359375,-0.8359375) + r1.xyz;
    r2.xyz = max(float3(0,0,0), r2.xyz);
    r1.xyz = -r1.xyz * float3(18.6875,18.6875,18.6875) + float3(18.8515625,18.8515625,18.8515625);
    r1.xyz = r2.xyz / r1.xyz;
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(6.27739477,6.27739477,6.27739477) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r1.xyz = float3(10000,10000,10000) * r1.xyz;
    r1.xyz = r1.xyz / cb0[64].www;
    r1.xyz = max(float3(6.10351999e-005,6.10351999e-005,6.10351999e-005), r1.xyz);
    r2.xyz = float3(12.9200001,12.9200001,12.9200001) * r1.xyz;
    r1.xyz = max(float3(0.00313066994,0.00313066994,0.00313066994), r1.xyz);
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(0.416666657,0.416666657,0.416666657) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r1.xyz = r1.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
    o0.xyz = min(r2.xyz, r1.xyz);
  } else {
    o0.xyz = r0.xyz;
  }

  // o0 *= 10;
  return;
}