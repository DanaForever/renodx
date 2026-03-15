// ---- Created with 3Dmigoto v1.3.16 on Sun Jun 01 18:20:08 2025
#include "shared.h"
#include "so6utils.hlsl"
SamplerState sTexStage0_s : register(s0);
Texture2D<float4> sTexStage0 : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  o0.xyzw = sTexStage0.Sample(sTexStage0_s, v1.xy).xyzw;

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    float white = 203.f;

    // float3 peak = RENODX_PEAK_WHITE_NITS;

    // float3 pq_peak = renodx::color::pq::EncodeSafe(peak, RENODX_DIFFUSE_WHITE_NITS);

    // o0.rgb = min(o0.rgb, pq_peak);
    // float peak_per_channel = max(o0.r, max(o0.g, o0.b));

    // if (peak_per_channel > pq_peak.x) {
    //   o0.rgb *= (pq_peak / peak_per_channel);
    // }

    // o0.rgb = PQtoLinear(o0.rgb, 1.f, false);

    // o0.rgb = min(o0.rgb, RENODX_PEAK_WHITE_NITS);

    // o0.rgb = LinearToPQ(o0.rgb, 1.f, false);
    // o0.rgb = renodx::color::pq::DecodeSafe(o0.rgb);
    // o0.rgb = renodx::color::bt709::from::BT2020(o0.rgb);

    // o0.rgb *= RENODX_GRAPHICS_WHITE_NITS;
    // o0.rgb = convertColorSpace(o0.rgb);
    // o0.rgb = min(o0.rgb, RENODX_PEAK_WHITE_NITS);

    // o0.rgb = renodx::color::bt2020::from::BT709(o0.rgb);
    // o0.rgb = renodx::color::pq::EncodeSafe(o0.rgb);
  }


  return;
}