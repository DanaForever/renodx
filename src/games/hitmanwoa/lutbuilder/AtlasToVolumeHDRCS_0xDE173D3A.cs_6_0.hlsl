#include "../common.hlsl"
Texture2D<float4> t0 : register(t0);

RWTexture3D<float4> u0 : register(u0);

// clang-format off
cbuffer cb5 : register(b5) {
  struct S_cbColorCorrectionResolve {
    float S_cbColorCorrectionResolve_000;
  } _cbColorCorrectionResolve_000: packoffset(c000.x);
};
// clang-format on

SamplerState s4 : register(s4);

[numthreads(4, 4, 4)]
void main(
    uint3 SV_DispatchThreadID: SV_DispatchThreadID,
    uint3 SV_GroupID: SV_GroupID,
    uint3 SV_GroupThreadID: SV_GroupThreadID,
    uint SV_GroupIndex: SV_GroupIndex) {
  float3 color_input = float3(SV_DispatchThreadID.xyz) / 15.f;

  float3 color_srgb;
  if (RENODX_LUT_SAMPLING_TYPE) {  // sRGB input
    color_srgb = color_input;
  } else {  // linear input
    color_srgb = renodx::color::srgb::EncodeSafe(color_input);
  }

  float4 lut_output_srgb = saturate(SampleLUTSRGBInSRGBOut(t0, s4, color_srgb));

  float4 interpolated_output_srgb = lerp(lut_output_srgb, float4(color_srgb, 1.f), _cbColorCorrectionResolve_000.S_cbColorCorrectionResolve_000);

  u0[SV_DispatchThreadID] = interpolated_output_srgb;
}
