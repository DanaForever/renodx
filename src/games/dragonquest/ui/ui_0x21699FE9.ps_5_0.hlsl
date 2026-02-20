// ---- Created with 3Dmigoto v1.3.16 on Fri Feb 20 01:57:13 2026
#include "uicommon.hlsli"

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[2];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[131];
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

  r0.x = 0.000138888892 * cb1[130].z;
  r0.y = cmp(r0.x >= -r0.x);
  r0.x = frac(abs(r0.x));
  r0.x = r0.y ? r0.x : -r0.x;
  r0.x = 14400 * r0.x;
  r0.x = frac(r0.x);
  r0.xy = float2(16,4) * r0.xx;
  r0.xy = floor(r0.xy);
  r0.xy = float2(0.25,0.25) * r0.xy;
  r0.zw = v4.xy * v4.zw;
  r0.xy = r0.zw * float2(0.25,0.25) + r0.xy;
  r0.xyzw = t0.SampleBias(s0_s, r0.xy, 0).xyzw;
  r1.xyz = cb2[1].xyz + r0.xyz;
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

  float hdr = r1.w;
  
  o0.xyz = r1.www ? r1.xyz : r0.xyz;
  o0.w = r0.w;

  if (hdr == 0) {
    o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);

    if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
      o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.2f);
    } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
      o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.4f);
    }
    o0.rgb *= RENODX_GRAPHICS_WHITE_NITS / 80.f;
  }
  return;
}