// ---- Created with 3Dmigoto v1.3.16 on Tue May 27 18:58:17 2025
#include "./shared.h"
#include "./common.hlsl"
SamplerState __smpsStage0_s : register(s0);
Texture2D<float4> sStage0 : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_ClipDistance0,
  float4 v1 : SV_Position0,
  float4 v2 : TEXCOORD0,
  float3 v3 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = sStage0.Sample(__smpsStage0_s, v3.xy).xyzw;
  r0.xyzw = v2.xyzw * r0.xyzw;
  o0.xyz = v3.zzz * r0.xyz;
  o0.w = r0.w;

  float3 color = o0.rgb;

  color = applyDice(color);
  color.rgb = renodx::color::correct::GammaSafe(color.rgb);
  color.rgb *= RENODX_GAME_NITS / RENODX_UI_NITS;
  color.rgb = renodx::color::correct::GammaSafe(color.rgb, true);
  o0.rgb = color;


  return;
}