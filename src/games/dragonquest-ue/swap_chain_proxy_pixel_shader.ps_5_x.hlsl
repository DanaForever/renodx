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
  if (shader_injection.processing_path == 0.f ) {
    // by default the game outputs in scrgb

    if (shader_injection.swap_chain_encoding ==4.f) { {}
    
      color.rgb = color.rgb * 80.f;  // scrgb -> nits
      color.rgb = renodx::color::bt2020::from::BT709(color.rgb);
      color.rgb = renodx::color::pq::EncodeSafe(color.rgb, 1.f);
    }

    return color;

  }

  // only for the SDR upgrade path
  color.rgb = renodx::color::srgb::DecodeSafe(color.rgb);
  color.rgb = CustomSwapchainPass(color.rgb);

  return color;
}
