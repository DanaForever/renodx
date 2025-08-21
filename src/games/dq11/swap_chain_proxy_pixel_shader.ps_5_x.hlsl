#include "./shared.h"
#include "./common.hlsl"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
    : SV_TARGET {
  return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
  float4 o0 = t0.Sample(s0, uv);

  renodx::draw::Config config = renodx::draw::BuildConfig();

  o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);

  o0.rgb = GammaCorrectHuePreserving(o0.rgb, 2.4f);

  o0.rgb *= RENODX_GRAPHICS_WHITE_NITS;
  float3 color = o0.rgb;

  [branch]
  if (config.swap_chain_clamp_color_space == renodx::color::convert::COLOR_SPACE_UNKNOWN) {
    color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
  } else {
    [branch]
    if (config.swap_chain_clamp_color_space == config.swap_chain_encoding_color_space) {
      color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
      color = max(0, color);
    } else {
      if (config.swap_chain_clamp_color_space != config.swap_chain_decoding_color_space) {
        color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_clamp_color_space);
      }
      color = max(0, color);
      color = renodx::color::convert::ColorSpaces(color, config.swap_chain_clamp_color_space, config.swap_chain_encoding_color_space);

    }
  }

  o0.rgb = color;
  o0.rgb = renodx::draw::EncodeColor(o0.rgb, config.swap_chain_encoding);

  return o0;
}
