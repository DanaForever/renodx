// #include "./shared.h"
#include "./common.hlsl"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
    : SV_TARGET {
  // return SwapChainPass(t0.Sample(s0, uv));

  float4 r0 = t0.Sample(s0, uv);

  r0.rgb = renodx::color::srgb::DecodeSafe(r0.rgb);

  // todo: tonemap with Hermite Spline
  // r0.rgb = expandGamut(r0.rgb, shader_injection.inverse_tonemap_extra_hdr_saturation);

  // r0.rgb = ToneMap(r0.rgb);

  // Swapchain Pass

  renodx::draw::Config config = renodx::draw::BuildConfig();

  // if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
  //   r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.2f);
  //   // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.2f);
  // } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
  //   r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.4f);
  //   // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.4f);
  // } else if (RENODX_GAMMA_CORRECTION == 3.f) {
  //   r0.rgb = GammaCorrectHuePreserving(r0.rgb, 2.3f);
  //   // r0.rgb = renodx::color::correct::GammaSafe(r0.rgb, false, 2.3f);
  // }

  float4 o0 = r0;

  float3 color = o0.rgb;

  // [branch]
  // if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT709D93(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::BT601NTSCU(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
  //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
  //   color = renodx::color::bt709::from::ARIBTRB9(color);
  //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
  // }
  o0.rgb = color;

  // o0.rgb = renodx::color::bt709::clamp::AP1(o0.rgb);

  o0.rgb *= RENODX_GRAPHICS_WHITE_NITS / 80.f;

  o0.w = r0.w;

  return o0;
}
