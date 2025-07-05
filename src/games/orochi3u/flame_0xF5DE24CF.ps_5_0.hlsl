// ---- Created with 3Dmigoto v1.3.16 on Tue May 27 18:58:17 2025
#include "./common.hlsl"
#include "./shared.h"
cbuffer _Globals : register(b0)
{
  float4 vDDot : packoffset(c10);
}

SamplerState __smpsStage0_s : register(s0);
SamplerState __smpsDepth_s : register(s1);
Texture2D<float4> sStage0 : register(t0);
Texture2D<float4> sDepth : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_ClipDistance0,
  float4 v1 : SV_Position0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float3 v4 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v3.xy / v3.zz;
  r0.x = sDepth.Sample(__smpsDepth_s, r0.xy).x;
  r0.x = r0.x * vDDot.x + vDDot.w;
  r0.x = max(9.99999984e-018, r0.x);
  r0.x = 1 / r0.x;
  r0.x = -v3.z + r0.x;
  r0.x = saturate(r0.x * v3.w + 0.5);
  r1.xyzw = sStage0.Sample(__smpsStage0_s, v4.xy).xyzw;
  r0.y = saturate(-v2.w * r1.w + 1.00100005);
  r1.xyz = v2.xyz * r1.xyz;
  o0.xyz = v4.zzz * r1.xyz;
  // r0.y = log2(r0.y);
  // r0.x = r0.y * r0.x;
  // r0.x = exp2(r0.x);

  r0.x = renodx::math::SignPow(r0.y, r0.x);
  o0.w = 1 + -r0.x;

  float3 color = o0.rgb;
  // color = applyDice(color);
  // color.rgb = renodx::color::correct::GammaSafe(color.rgb);
  // color.rgb *= RENODX_GAME_NITS / RENODX_UI_NITS;
  // color.rgb = renodx::color::correct::GammaSafe(color.rgb, true);
  o0.rgb = color;
  return;
}