// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 11 20:50:08 2025
#include "./shared.h"
SamplerState ColorBufferSampler_s : register(s0);
Texture2D<float4> ColorBuffer : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  o0.xyzw = ColorBuffer.Sample(ColorBufferSampler_s, v1.xy).xyzw;

  
  return;
}