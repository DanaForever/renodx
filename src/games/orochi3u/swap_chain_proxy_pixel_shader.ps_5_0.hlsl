#include "./common.hlsl"
#include "shared.h"

// Texture2D t0 : register(t0);
// SamplerState s0 : register(s0);
// float4 main(float4 vpos : SV_POSITION, float2 uv : TEXCOORD0)
//     : SV_TARGET {
//   return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
// }

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0) : SV_TARGET {
  float4 color = t0.Sample(s0, uv);

  color.rgb = renodx::color::correct::GammaSafe(color.rgb);  // The game is linear

  if (RENODX_COLOR_GRADE_SPACE == 1.f) {
    color.rgb = renodx::color::bt709::from::BT709D93(color.rgb);
  }

  color.rgb *= RENODX_UI_NITS;  // Scale paper white

  color.rgb /= RENODX_DIFFUSE_WHITE_NITS;
  float peak_nits = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  color.rgb = renodx::tonemap::ExponentialRollOff(color.rgb, min(1.f, peak_nits * 0.5f), peak_nits);
  color.rgb *= RENODX_DIFFUSE_WHITE_NITS;

  color.rgb /= 80.f;
  

  color.rgb = renodx::color::bt709::clamp::BT2020(color.rgb);  // clamp to bt2020

  color.a = 1.f;

  return color;
}

// #include "./shared.h"

// Texture2D t0 : register(t0);
// SamplerState s0 : register(s0);
// float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
//     : SV_TARGET {
//   return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
// }
