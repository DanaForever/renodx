// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 19 17:02:43 2025
#include "common.hlsl"
#include "shared.h"
Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[143];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.SampleBias(s0_s, v1.xy, cb0[19].x).xyzw;
  r1.xyzw = t1.SampleBias(s0_s, v1.xy, cb0[19].x).xyzw;
  r0.w = cmp(0 < cb0[131].x);
  if (r0.w != 0) {
    r2.xyz = r1.xyz * r1.www;
    r1.xyz = float3(8,8,8) * r2.xyz;
  }
  r1.xyz = cb0[130].xxx * r1.xyz;
  r0.xyz = r1.xyz * cb0[130].yzw + r0.xyz;
  r0.w = cmp(0 < cb0[138].z);
  if (r0.w != 0) {
    r1.xy = -cb0[138].xy + v1.xy;
    r1.yz = cb0[138].zz * abs(r1.xy);
    r1.x = cb0[137].w * r1.y;
    r0.w = dot(r1.xz, r1.xz);
    r0.w = 1 + -r0.w;
    r0.w = max(0, r0.w);
    r0.w = log2(r0.w);
    r0.w = cb0[138].w * r0.w;
    r0.w = exp2(r0.w);
    r1.xyz = float3(1,1,1) + -cb0[137].xyz;
    r1.xyz = r0.www * r1.xyz + cb0[137].xyz;
    r0.xyz = r1.xyz * r0.xyz;
  }
  
  r0.xyz = (cb0[128].www * r0.xyz);

  float3 untonemapped = r0.xyz;

  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    // 2D LUT not used
    // PQ Encode for LUT Builder
    // float3 encoded = renodx::color::pq::Encode(untonemapped, shader_injection.lut_white_nits);
    float3 encoded = lutShaper(untonemapped);
    float3 lut_color;
    if (shader_injection.colorGradeLUTSampling == 1.f)
      lut_color = renodx::lut::SampleTetrahedral(t2, encoded, cb0[128].z + 1u);
    else {
      float3 precompute = cb0[128].xyz;
      lut_color = renodx::lut::Sample(t2, s0_s, encoded, precompute);
    }

    r0.rgb = renodx::draw::ToneMapPass(lut_color);
    // post tonemap?
    r1.xy = v1.xy * cb0[142].xy + cb0[142].zw;
    r1.xyzw = t4.SampleBias(s1_s, r1.xy, cb0[19].x).xyzw;
    r0.w = r1.w * 2 + -1;
    r1.x = cmp(r0.w >= 0);
    r1.x = r1.x ? 1 : -1;
    r0.w = 1 + -abs(r0.w);
    r0.w = sqrt(r0.w);
    r0.w = 1 + -r0.w;
    r0.w = r1.x * r0.w;
    r0.xyz = renodx::color::srgb::EncodeSafe(r0.xyz);
    r0.xyz = r0.www * float3(0.00392156886, 0.00392156886, 0.00392156886) + r0.xyz;
    r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
    r0.rgb = renodx::color::bt709::clamp::AP1(r0.rgb);
    o0.rgb = renodx::draw::RenderIntermediatePass(r0.rgb);
    o0.w = 1;
    return;
  } else if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 1.f) {
    // r0.xyz = renodx::tonemap::renodrt::NeutralSDR(untonemapped);
    r0.xyz = RestoreHighlightSaturation(untonemapped);
  } else {
    r0.xyz = saturate(r0.xyz);
  }
  
  r0.w = cmp(0 < cb0[129].w);
  if (r0.w != 0) {
    r1.xyz = renodx::color::srgb::EncodeSafe(r0.xyz);
    r2.xyz = cb0[129].zzz * r1.zxy;
    r0.w = floor(r2.x);
    r2.xw = float2(0.5,0.5) * cb0[129].xy;
    r2.yz = r2.yz * cb0[129].xy + r2.xw;
    r2.x = r0.w * cb0[129].y + r2.y;
    r3.xyzw = t3.SampleLevel(s0_s, r2.xz, 0).xyzw;
    r4.x = cb0[129].y;
    r4.y = 0;
    r2.xy = r4.xy + r2.xz;
    r2.xyzw = t3.SampleLevel(s0_s, r2.xy, 0).xyzw;
    r0.w = r1.z * cb0[129].z + -r0.w;
    r2.xyz = r2.xyz + -r3.xyz;
    r2.xyz = r0.www * r2.xyz + r3.xyz;
    r2.xyz = r2.xyz + -r1.xyz;
    r1.xyz = cb0[129].www * r2.xyz + r1.xyz;

    r0.xyz = renodx::color::srgb::DecodeSafe(r1.xyz);
  }

  if (shader_injection.colorGradeLUTSampling == 0.f) {
    r0.xyw = cb0[128].zzz * r0.xyz;
    r0.w = floor(r0.w);
    r1.xy = float2(0.5,0.5) * cb0[128].xy;
    r1.yz = r0.xy * cb0[128].xy + r1.xy;
    r1.x = r0.w * cb0[128].y + r1.y;
    r2.xyzw = t2.SampleLevel(s0_s, r1.xz, 0).xyzw;
    r0.x = cb0[128].y;
    r0.y = 0;
    r0.xy = r1.xz + r0.xy;
    r1.xyzw = t2.SampleLevel(s0_s, r0.xy, 0).xyzw;
    r0.x = r0.z * cb0[128].z + -r0.w;
    r0.yzw = r1.xyz + -r2.xyz;
    r0.xyz = r0.xxx * r0.yzw + r2.xyz;
  } else {
    r0.xyz = renodx::lut::SampleTetrahedral(t2, r0.xyz, cb0[128].z + 1u);
  }

  r1.xy = v1.xy * cb0[142].xy + cb0[142].zw;
  r1.xyzw = t4.SampleBias(s1_s, r1.xy, cb0[19].x).xyzw;
  r0.w = r1.w * 2 + -1;
  r1.x = cmp(r0.w >= 0);
  r1.x = r1.x ? 1 : -1;
  r0.w = 1 + -abs(r0.w);
  r0.w = sqrt(r0.w);
  r0.w = 1 + -r0.w;
  r0.w = r1.x * r0.w;

  r0.xyz = renodx::color::srgb::EncodeSafe(r0.xyz);
  r0.xyz = r0.www * float3(0.00392156886,0.00392156886,0.00392156886) + r0.xyz;
  r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    o0.xyz = renodx::draw::ToneMapPass(untonemapped, r0.xyz);
  }  
  else
    o0.xyz = max(float3(0,0,0), r0.xyz);

  o0.w = 1;

  o0.rgb = RenderIntermediatePass(o0.rgb);
  o0.w = 1;
  return;
}