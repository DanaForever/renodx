#include "./shared.h"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
    : SV_TARGET {
  // return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
  float4 color_pq = t0.Sample(s0, uv);

  float3 color_rgb = renodx::color::pq::DecodeSafe(color_pq.xyz, RENODX_DIFFUSE_WHITE_NITS);
  color_rgb = renodx::color::bt709::from::BT2020(color_rgb);

  float max_ratio = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  float max_channel = max(max(color_rgb.r, color_rgb.g), color_rgb.b);

  if (max_channel > max_ratio) {

    color_rgb = renodx::tonemap::neutwo::MaxChannel(color_rgb, max_ratio);
  }
  
  color_rgb = renodx::color::bt2020::from::BT709(color_rgb);
  color_pq.rgb = renodx::color::pq::EncodeSafe(color_rgb, RENODX_DIFFUSE_WHITE_NITS);

  return color_pq;
}
