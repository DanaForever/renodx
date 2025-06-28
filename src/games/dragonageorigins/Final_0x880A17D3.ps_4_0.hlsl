#include "./shared.h"

Texture2D<float4> t0 : register(t0);


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float3 uv = float3(v1.x, v1.y, 0);

  float4 color = t0.Load(uv).xyzw;

  // if (injectedData.toneMapType == 0) {
  //   color = saturate(color);
  // }

  // linearize
  // color.rgb = renodx::math::PowSafe(color.rgb, 2.2f);

  // apply ui brightness
  // color.rgb *= 203 / 80.f;

  o0 = color;
}