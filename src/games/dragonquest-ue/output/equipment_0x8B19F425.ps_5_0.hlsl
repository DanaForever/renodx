// ---- Created with 3Dmigoto v1.3.16 on Sat Mar 14 17:52:11 2026
#include "output.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[2];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[3];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float3 v2 : ORIGINAL_POSITION0,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v4.xy * v4.zw;
  r1.xyz = t0.Sample(s0_s, r0.xy).xyz;
  r0.w = t1.Sample(s1_s, r0.xy).x;
  r0.w = saturate(r0.w);
  r1.xyz = cb1[1].xyz + r1.xyz;
  r0.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyzw = v1.xyzw * r0.xyzw;
  r1.xyz = log2(r0.xyz);
  r1.xyz = cb0[2].xxx * r1.xyz;
  r2.xyz = float3(0.416666657,0.416666657,0.416666657) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = exp2(r2.xyz);
  r2.xyz = r2.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r3.xyz = float3(12.9200001,12.9200001,12.9200001) * r1.xyz;
  r1.xyz = cmp(r1.xyz >= float3(0.00313066994,0.00313066994,0.00313066994));
  r1.xyz = r1.xyz ? r2.xyz : r3.xyz;
  r1.w = cmp(cb0[2].y != 1.000000);
  o0.xyz = r1.www ? r1.xyz : r0.xyz;

  // o0.rgb  = renodx::color::bt709::from::BT2020(o0.rgb);

  if (shader_injection.processing_path == 0.f)
    o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  o0.w = r0.w;
  return;
}