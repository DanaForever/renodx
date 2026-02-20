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

  if (shader_injection.processing_path == 0.f) {
    return color;
  }

  color.rgb = renodx::color::srgb::DecodeSafe(color.rgb);
  color.rgb = CustomSwapchainPass(color.rgb);

  return color;
}
