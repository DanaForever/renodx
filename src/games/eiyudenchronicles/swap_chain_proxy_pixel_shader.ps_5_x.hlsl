#include "./shared.h"
#include "./common.hlsl"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);
float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0)
    : SV_TARGET {
  return SwapChainPass(t0.Sample(s0, uv));
  // return t0.Sample(s0, uv);
}
