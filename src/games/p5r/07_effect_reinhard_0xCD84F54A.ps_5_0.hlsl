#include "./shared.h"

cbuffer GFD_PSCONST_HDR : register(b11) {
  float middleGray : packoffset(c0);
  float adaptedLum : packoffset(c0.y);
  float bloomScale : packoffset(c0.z);
  float starScale : packoffset(c0.w);
  float3 gradeColor : packoffset(c1);
  float elapsedTime : packoffset(c1.w);
  float threshold : packoffset(c2);
  float exposure1 : packoffset(c2.y);
  float exposure2 : packoffset(c2.z);
}

SamplerState sampler0_s : register(s0);
Texture2D<float4> texture0 : register(t0);

// 3Dmigoto declarations
#define cmp -

void main(float4 v0 : SV_POSITION0, float2 v1 : TEXCOORD0, out float4 o0 : SV_TARGET0) {
  float4 r0, r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = texture0.Sample(sampler0_s, v1.xy).xyzw;
  r0.w = cmp(0.999000013 >= r0.w);
  r0.w = r0.w ? 1 : 0;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = gradeColor.xyz * r0.xyz;
  r0.w = 1;
  r0.xyz = exposure1 * r0.xyz;
  r1.xyz = -threshold;
  r0.xyz = r1.xyz + r0.xyz;
  r0.w = max(0, r0.w);

  r0.rgb = max(0.f, r0.rgb);
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    r0.rgb = renodx::tonemap::Reinhard(r0.rgb);
  } else {

    const float pivot_x = 0.18f;
    const float pivot_y = pivot_x / (1.f + pivot_x);          // Reinhard at pivot
    const float slope   = 1.f / ((1.f + pivot_x) * (1.f + pivot_x));  // dReinhard/dx at pivot
    float3 base     = renodx::tonemap::Reinhard(r0.rgb);
    float3 extended = pivot_y + slope * (r0.rgb - pivot_x);
    r0.rgb = lerp(base, extended, step(pivot_x, r0.rgb));
  }
  
  o0.xyz = r0.xyz;
  o0.w = r0.w;
  return;
}