#include "./common.hlsl"

cbuffer GFD_PSCONST_CORRECT : register(b12) {
 float3 colorBalance : packoffset(c0);
 float _reserve00 : packoffset(c0.w);
 float2 colorBlend : packoffset(c1);
}

cbuffer GFD_PSCONST_HDR : register(b11) {
 float middleGray : packoffset(c0.x);
 float adaptedLum : packoffset(c0.y);
 float bloomScale : packoffset(c0.z);
 float starScale : packoffset(c0.w);
}

SamplerState opaueSampler_s : register(s0);
SamplerState bloomSampler_s : register(s1);
Texture2D<float4> opaueTexture : register(t0);
Texture2D<float4> bloomTexture : register(t1);

// 3Dmigoto declarations
#define cmp -

void main(float4 v0 : SV_POSITION0, float2 v1 : TEXCOORD0, out float4 o0 : SV_TARGET0) {
  // ---------------------------
  // 1) Sample inputs (gamma/sRGB domain in your capture)
  // ---------------------------

  float2 uv = v1;
  float3 bloom = bloomTexture.Sample(bloomSampler_s, uv).rgb * bloomScale;
  // float3 bright = brightTexture.Sample(brightSampler_s, uv).rgb * bloomScale;
  float3 base = opaueTexture.Sample(opaueSampler_s, uv).rgb;

  float3 untonemapped =  base + bloom - (base * bloom);

  // ---------------------------
  // 3) "Tonemap"/grade block (still in gamma space)
  // ---------------------------

  // max channel
  float maxCh = max(untonemapped.r, max(untonemapped.g, untonemapped.b));

  // oneMinusMax = 1 - maxCh  (this is r2.x in the original)
  float oneMinusMax = 1.0 - maxCh;

  // The original does:
  //   tmp = (1 - untonemapped) - oneMinusMax;
  //   tmp = tmp / maxCh;
  //
  // which simplifies to:
  //   tmp = 1 - untonemapped/maxCh
  //
  // We'll keep it in the same conceptual steps for clarity:
  float3 t = 1.0 - untonemapped;                // (float3(1)-untonemapped)
  t = t - oneMinusMax;                          // remove (1-maxCh)
  t = renodx::math::DivideSafe(t, maxCh, 0.f);  // normalize by max channel  (no guard: original assumes maxCh>0)

  // Add balance
  t = t + colorBalance;

  // Original:
  //   t = t * maxCh;
  //   t = t + oneMinusMax;
  //   t = 1 - t;
  //
  // i.e. t = 1 - (t*maxCh + (1-maxCh))
  t = t * maxCh;
  t = t + oneMinusMax;
  t = 1.0 - t;

  // untonemapped = t.rgb;
  float3 ungraded = t.rgb;

  // Two more invert/divide stages:
  //   t = 1 - (t / colorBlend.x)
  //   t = 1 - (t / colorBlend.y)
  // t = 1.0 - (t / colorBlend.x);
  // t = 1.0 - (t / colorBlend.y);

  float3 t_lin = renodx::color::srgb::DecodeSafe(t);
  float Y = renodx::color::y::from::BT709(t_lin);

  float bias = 1.0 - 1.0 / colorBlend.y;
  float scale = 1.0 / (colorBlend.x * colorBlend.y);
  float cutoff = colorBlend.x * (1 - colorBlend.y);

  // compute the danger threshold in *linear*
  float t0_srgb = -bias / scale;  // where srgb affine crosses 0
  float t0_lin = renodx::color::srgb::DecodeSafe(float3(t0_srgb, t0_srgb, t0_srgb)).r;

  float m = min(t_lin.r, min(t_lin.g, t_lin.b));
  float eps = 1e-6;
  // k grows only when we're in the danger zone (m < t0)
  // multiplicative “make-safe” factor based on linear luma
  float k = max(1.0, t0_lin / (m + 1e-6));

  // apply safety lift in linear, then convert back to srgb for the game’s affine
  float3 t_safe_srgb = renodx::color::srgb::EncodeSafe(t_lin * k);

  // game affine (still in srgb, preserving its look)
  float3 t_aff = t_safe_srgb * scale + bias;

  // undo the lift back in linear so HDR energy is preserved
  float3 out_lin = renodx::color::srgb::DecodeSafe(t_aff) / k;

  float3 t_aff_fixed = renodx::color::srgb::EncodeSafe(out_lin);

  if (injectedData.toneMapBlackCorrection > 0.f) {
    //   t = lerp(t, t_aff, w);
    t = t_aff_fixed;
    // optional: blend only when needed (k>1)
    // float w = saturate((k - 1.0) / (k));  // 0 when k=1, ->1 as k grows
    // t = lerp(t_aff, t_aff_fixed, 1.0);  // usually just use fixed version
  } else {
    t = t * scale + bias;
  }
  float3 ungraded_linear = renodx::color::srgb::DecodeSafe(ungraded);
  float3 t_linear = renodx::color::srgb::DecodeSafe(t);

  t_linear = renodx::color::bt709::clamp::BT2020(t_linear);

  // t_linear = renodx::color::correct::Luminance(ungraded_linear, t_linear);
  t = renodx::color::srgb::EncodeSafe(t_linear);

  float3 tOut = t;

  // Final invert to output (original does: r1 = 1 + (-t) = 1 - t)
  float3 outRGB = tOut;

  outRGB = renodx::color::srgb::DecodeSafe(outRGB);
  ungraded = renodx::color::srgb::DecodeSafe(ungraded);

  outRGB = lerp(ungraded, outRGB, injectedData.colorGradeLUTStrength);

  outRGB = renodx::color::srgb::EncodeSafe(outRGB);

  o0 = float4(outRGB, 1.0);

  // o0.rgb = UserColorGradeSRGB(o0.rgb);

  return;
}