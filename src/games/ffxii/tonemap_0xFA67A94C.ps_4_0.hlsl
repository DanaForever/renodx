// ---- Created with 3Dmigoto v1.3.16 on Sat May 31 21:05:20 2025
#include "./shared.h"
#include "common.hlsl"
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[209];
}

float3 toneMap(float3 color, float3 r1) {
  float3 r0, r2;

  r0 = color;

  r0.xyz = cb0[154].xxx * r0.xyz;

  r0.xyz = max(float3(5.96046448e-008, 5.96046448e-008, 5.96046448e-008), r0.xyz);
  r0.xyz = cb0[208].xxx * -r0.xyz;

  r0.xyz = float3(1.44269502, 1.44269502, 1.44269502) * r0.xyz;
  r0.xyz = exp2(r0.xyz);  // exp(-kL)

  r2.xyz = -r0.xyz * cb0[208].yyy + float3(1, 1, 1);
  r0.xyz = float3(1, 1, 1) + -r0.xyz;

  r2.xyz = r2.xyz * r2.xyz;
  r0.xyz = (r2.xyz * r0.xyz);
  r2.xyz = float3(1, 1, 1) + -r0.xyz;  // (1 - (1 - ax)^2 (1 -x))
  r0.xyz = r2.xyz * r1.xyz + r0.xyz;   // lerp

  return r0;

}


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float2 v4 : TEXCOORD4,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t2.Sample(s2_s, v3.xy).xyzw;

 
  r1.xyz = r0.xyz * cb0[186].xxx + cb0[186].yyy;
  r0.xyz = r0.xyz * cb0[188].xxx + cb0[188].yyy;
  r0.w = dot(r1.xyz, float3(0.333333343,0.333333343,0.333333343)); // average
  r1.xyz = r1.xyz + -r0.www;
  r1.xyz = (cb0[187].xxx * r1.xyz + r0.www);
  r1.xyz = r1.xyz * cb0[186].zzz + cb0[186].www;
  r0.w = dot(r0.xyz, float3(0.333333343,0.333333343,0.333333343)); // average
  r1.xyz = r1.xyz + -r0.www;
  r0.xyz = r0.xyz + -r0.www;
  r0.xyz = cb0[189].xxx * r0.xyz + r0.www;
  r0.xyz = r0.xyz * cb0[188].zzz + cb0[188].www;
  r2.xyzw = t1.Sample(s1_s, v1.xy, int2(0, 0)).xyzw;
  
  r1.xyz = r2.xyz * r0.xyz + r1.xyz;
  r1.xyz = (cb0[154].yyy * r1.xyz);
  r2.xyzw = t0.Sample(s0_s, v0.xy, int2(0, 0)).xyzw;  // sample the untonemapped

  r0.xyz = r2.xyz * r0.xyz;

  r0.w = dot(r2.xyzw, cb0[155].xyzw);
  o0.w = (cb0[154].w + r0.w);

  float3 untonemapped = renodx::color::srgb::DecodeSafe(r0.rgb);

  // r0.xyz = cb0[154].xxx * r0.xyz;

  // r0.xyz = max(float3(5.96046448e-008,5.96046448e-008,5.96046448e-008), r0.xyz);
  // r0.xyz = cb0[208].xxx * -r0.xyz;

  // r0.xyz = float3(1.44269502, 1.44269502, 1.44269502) * r0.xyz;  
  // r0.xyz = exp2(r0.xyz);                                         // exp(-kL)

  // r2.xyz = -r0.xyz * cb0[208].yyy + float3(1,1,1);
  // r0.xyz = float3(1,1,1) + -r0.xyz;
  
  // r2.xyz = r2.xyz * r2.xyz;
  // r0.xyz = (r2.xyz * r0.xyz);
  // r2.xyz = float3(1,1,1) + -r0.xyz;  // (1 - (1 - ax)^2 (1 -x))
  // o0.xyz = r2.xyz * r1.xyz + r0.xyz; // lerp

  o0.xyz = toneMap(r0.rgb, r1.rgb);
  o0.xyz = renodx::color::srgb::DecodeSafe(o0.xyz);

  if (RENODX_TONE_MAP_TYPE > 0.f) {

    // based on their color grading code
    float mid_gray = renodx::color::srgb::Decode(0.5f);
    untonemapped = untonemapped * mid_gray / 0.18f;
    // o0.rgb = renodx::draw::ToneMapPass(untonemapped, o0.xyz);
    if (CUSTOM_TONEMAP_UPGRADE_TYPE == 0.f) {
      o0.rgb = renodx::draw::ToneMapPass(untonemapped, o0.xyz);
    } else {
      o0.rgb = CustomUpgradeToneMapPerChannel(untonemapped, o0.rgb);
      o0.rgb = renodx::draw::ToneMapPass(o0.rgb);
    }
  }
  return;
}