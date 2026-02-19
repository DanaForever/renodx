// ---- Created with 3Dmigoto v1.3.16 on Fri Feb 20 01:59:26 2026
#include "uicommon.hlsli"
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
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

  r0.x = v4.x * v4.z + -0.0659246594;
  r0.x = r0.x / cb1[3].w;
  r0.x = r0.x * 0.302226037 + 0.0659246594;
  r0.yz = v4.xx * v4.zz + -cb1[3].yx;
  r0.z = 0.368150681 + r0.z;
  r0.y = r0.y / cb1[3].z;
  r0.y = r0.y * 0.560787678 + 0.404109597;
  r1.yz = v4.xy * v4.zw;
  r2.xy = cmp(r1.yy >= float2(0.964897275,0.0659246594));
  r0.y = r2.x ? r1.y : r0.y;
  r2.xz = cmp(r1.yy >= cb1[3].yx);
  r0.y = r2.x ? r0.y : r0.z;
  r0.x = r2.z ? r0.y : r0.x;
  r1.x = r2.y ? r0.x : r1.y;
  r0.xyzw = t0.Sample(s0_s, r1.xz).xyzw;
  r1.xyz = cb1[1].xyz + r0.xyz;
  r0.w = saturate(r0.w);
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

  o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.4f);
  }
  o0.rgb *= RENODX_GRAPHICS_WHITE_NITS / 80.f;
  o0.w = r0.w;
  return;
}