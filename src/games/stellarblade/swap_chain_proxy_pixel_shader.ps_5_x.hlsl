#include "./common.hlsl"

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

  

  // SDR rendering path (fallback) (TODO)

  if (shader_injection.processing_path == 0.f) {
    return color;

    // HDR rendering path

    // color.rgb = renodx::color::pq::DecodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);
    // color.rgb = renodx::color::bt709::from::BT2020(color.rgb);

    // float peak = RENODX_PEAK_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    // float peak_y = renodx::color::y::from::BT709(float3(peak, peak, peak));

    // float y = renodx::color::y::from::BT709(color.rgb);
    // if (y > peak_y)
    //   // color.rgb = NeutwoBT709WhiteForEnergy(color.rgb, peak);
    //   color.rgb = renodx::tonemap::neutwo::MaxChannel(color.rgb, peak);

    // color.rgb = renodx::color::bt2020::from::BT709(color.rgb);
    // color.rgb = renodx::color::pq::EncodeSafe(color.rgb, RENODX_GRAPHICS_WHITE_NITS);
  }

  // only for the SDR upgrade path
  color.rgb = renodx::color::srgb::DecodeSafe(color.rgb);
  color.rgb = CustomSwapchainPass(color.rgb);

  return color;
}
