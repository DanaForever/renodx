#include "./common.hlsli"

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

  // HDR rendering path
  

  // float3 nit_scale = renodx::color::pq::DecodeSafe(color.rgb, 1.f);
  // nit_scale = renodx::color::bt709::from::BT2020(nit_scale);
  // float nits = min(min(nit_scale.r, nit_scale.g), nit_scale.b);

  // if (nits > RENODX_PEAK_WHITE_NITS) {
  //   color.rgb = renodx::color::pq::DecodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);
  //   color.rgb = renodx::color::bt709::from::BT2020(color.rgb);

  //   float peak = RENODX_PEAK_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  //   color.rgb = NeutwoBT709WhiteForEnergy(color.rgb, peak);

  //   color.rgb = renodx::color::bt2020::from::BT709(color.rgb);
  //   color.rgb = renodx::color::pq::EncodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);
  // }
  float peak_pq = renodx::color::pq::Encode(RENODX_PEAK_WHITE_NITS, 1.f);

  color.rgb = renodx::color::pq::DecodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);
  color.rgb = renodx::color::bt709::from::BT2020(color.rgb);

  float peak = RENODX_PEAK_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

  float y = renodx::color::y::from::BT709(color.rgb);
  if (y > peak_pq) 
    color.rgb = NeutwoBT709WhiteForEnergy(color.rgb, peak);

  color.rgb = renodx::color::bt2020::from::BT709(color.rgb);
  color.rgb = renodx::color::pq::EncodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);

  return color;
}
