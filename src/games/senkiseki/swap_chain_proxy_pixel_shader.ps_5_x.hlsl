#include "./shared.h"
#include "./cs4/common.hlsl"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
    : SV_TARGET {
  return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
  float4 o0 = t0.Sample(s0, uv);

  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 color = o0.rgb;

  color = renodx::color::srgb::DecodeSafe(color);

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = GammaCorrectHuePreserving(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = GammaCorrectHuePreserving(color, 2.4f);
  }

  color *= config.swap_chain_scaling_nits;

  [branch]
  if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT709D93(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::BT601NTSCU(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
    color = renodx::color::bt709::from::ARIBTRB9(color);
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  }

  color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos


  color = renodx::color::bt2020::from::BT709(color);
  color = max(0.f, color);

  if (RENODX_SWAP_CHAIN_ENCODING == 4.f) {
    color = renodx::color::pq::EncodeSafe(color, 1.f);
  } else if (RENODX_SWAP_CHAIN_ENCODING == 5.f) {
    color = renodx::color::bt709::from::BT2020(color);
    color = color / 80.f;
  }

  return o0;
}
