// ---- Created with 3Dmigoto v1.3.16 on Tue May 27 23:29:21 2025
#include "./shared.h"
cbuffer _Globals : register(b0)
{
  float vATest : packoffset(c0);
}

SamplerState smp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = -vATest + v1.w;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.xyzw = tex.Sample(smp_s, v2.xy).xyzw;
  o0.xyz = v1.xyz * r0.xyz;
  o0.w = v1.w;

  // float3 sdr = o0.rgb;
  if (shader_injection.toneMapType != 0.f) {
    float peakNits = min(400.f, shader_injection.toneMapPeakNits);
    float videoPeak =
        peakNits / (shader_injection.toneMapGameNits / 203.f);
    // o0.rgb = renodx::color::gamma::Decode(o0.rgb, 2.4f);  // 2.4 for BT2446a
    o0.rgb = renodx::tonemap::inverse::bt2446a::BT709(o0.rgb, 100.f, videoPeak);
    o0.rgb /= videoPeak;                                    // Normalize to 1.0f = peak;
    o0.rgb *= peakNits /
                shader_injection.toneMapGameNits;  // 1.f = game nits
  }

  float3 color = o0.rgb;
  color.rgb = renodx::color::correct::GammaSafe(color.rgb);
  color.rgb *= RENODX_GAME_NITS / RENODX_UI_NITS;
  color.rgb = renodx::color::correct::GammaSafe(color.rgb, true);
  o0.rgb = color;

  return;
}