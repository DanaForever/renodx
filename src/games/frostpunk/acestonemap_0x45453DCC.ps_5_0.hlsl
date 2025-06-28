// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 18:29:54 2025
#include "shared.h"
#include "common.hlsl"
Texture2D<float4> t11 : register(t11);
Texture1D<float4> t4 : register(t4);
Texture1D<float4> t3 : register(t3);
Texture2D<float4> t1 : register(t1);
Texture2D<float4> t0 : register(t0);

SamplerState s11_s : register(s11);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s1_s : register(s1);

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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb2[6].xy + v1.xy;
  r0.xyz = t0.Sample(s0_s, r0.xy).xyz;
  
  r0.xyz = cb0[16].yyy * r0.xyz;

  static const float ACES_MID_GRAY = 0.10f;
  static const float ACES_MIN = 0.0001f;
  const float mid_gray_scale = (0.1f / ACES_MID_GRAY);

  float aces_min = ACES_MIN / RENODX_DIFFUSE_WHITE_NITS;
  float aces_max = (RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS);

  aces_max /= mid_gray_scale;
  aces_min /= mid_gray_scale;

  if (RENODX_TONE_MAP_TYPE == 2) {
    r0.rgb = renodx::tonemap::aces::RGCAndRRTAndODT(r0.rgb, aces_min * 48.f, aces_max * 48.f);
    r0.rgb /= 48.f;
    r0.rgb *= mid_gray_scale;
  } else 
    r0.xyz = renodx::tonemap::ACESFittedBT709(r0.xyz / 0.6f);
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;         // // fetch main buffer
  r1.xyz = float3(1024, 1024, 1024) * r1.xyz;  // scale to HDR space

  // cb2[2].w = 1.
  r2.xy = cb2[2].ww * v1.xy;
  r2.xyzw = t11.Sample(s11_s, r2.xy).xyzw;
  r2.xyz = r2.xyz * float3(1024,1024,1024) + -r1.xyz;
  r1.xyz = r2.www * r2.xyz + r1.xyz;
  
  r2.xyz = t1.Sample(s1_s, v1.zw).xyz;

  // cb2[0] = 0.5
  r2.xyz = cb2[0].xyz * r2.xyz;

  // this changes rapidly between 0-1
  r1.xyz = r1.xyz * cb2[9].xyz + r2.xyz;
  
  // this is 0.001129
  r1.xyz = cb0[16].yyy * r1.xyz;

  
  float3 untonemapped = r1.xyz;

  if (RENODX_TONE_MAP_TYPE == 2) {
    r1.rgb = renodx::tonemap::aces::RGCAndRRTAndODT(r1.rgb, aces_min * 48.f, aces_max * 48.f);
    r1.rgb /= 48.f;
    r1.rgb *= mid_gray_scale;
  } else
    r1.xyz = renodx::tonemap::ACESFittedBT709(r1.xyz / 0.6f);

  r0.xyz = lerp(r1.xyz, r0.xyz, cb2[6].z);

  float3 sdr_ungraded = r0.xyz;

  r1.x = t4.Sample(s4_s, r0.x).x;
  r1.y = t4.Sample(s4_s, r0.y).y;
  r1.z = t4.Sample(s4_s, r0.z).z;
  r0.xyz = cb2[8].xyz * r1.xyz;
  r2.xyz = sqrt(r0.xyz);
  r0.w = renodx::color::y::from::BT709(r2.xyz);
  r0.w = min(1, r0.w);

  r3.xyzw = t3.Sample(s3_s, r0.w).xyzw;
  r1.xyz = -r1.xyz * cb2[8].xyz + r3.xyz;
  r3.xyz = cb2[3].xyz + -r2.xyz;
  r2.xyz = cb2[4].xyz + -r2.xyz;
  r2.y = dot(r2.xyz, r2.xyz);
  r2.x = dot(r3.xyz, r3.xyz);
  r2.xy = saturate(r2.xy * cb2[5].xy + cb2[5].zw);
  r0.w = r3.w * r2.x;
  r0.w = saturate(r0.w * r2.y);
  r0.xyz = r0.www * r1.xyz + r0.xyz;

  r0.w = renodx::color::y::from::BT709(r0.xyz);
  r0.xyz = r0.xyz + -r0.www;
  r0.xyz = cb2[1].zzz * r0.xyz + r0.www;
  r0.xyz = r0.xyz + r0.xyz;

  // cb2[1].w is 1.0
  r0.xyz = renodx::math::SafePow(r0.xyz, cb2[1].w);

  r0.xyz = float3(0.5,0.5,0.5) * r0.xyz;

  if (RENODX_TONE_MAP_TYPE == 0.f)
    r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.xyz = v3.xyz * r0.xyz;
  r0.w = dot(v2.xy, v2.xy);
  r0.w = saturate(r0.w * cb2[1].x + cb2[1].y);
  r0.w = r0.w * r0.w;
  r0.xyz = r0.xyz * r0.www;
  r0.w = renodx::color::y::from::BT709(r0.xyz);
  o0.xyz = r0.xyz;

  float midgrey = renodx::color::y::from::BT709(renodx::tonemap::ACESFittedBT709(0.18f));
  if (RENODX_TONE_MAP_TYPE >= 3.f) {
    untonemapped = untonemapped * 0.18f / midgrey;
    o0.xyz = renodx::draw::ToneMapPass(untonemapped,
                                       //  sdr_ungraded,
                                       //  renodx::color::gamma::Decode(o0.xyz, 1 / cb2[1].w)
                                       o0.xyz
                                      //  o0.xyz
    );

  } else {
    // o0.xyz = renodx::color::gamma::Decode(o0.xyz, 1 / cb2[1].w);
  }

  o0.w = r0.w;

  if (RENODX_TONE_MAP_TYPE >= 3.f)
    o0.xyz = renodx::color::srgb::DecodeSafe(o0.xyz);
  o0.xyz = renodx::draw::RenderIntermediatePass(o0.xyz);
  return;
}