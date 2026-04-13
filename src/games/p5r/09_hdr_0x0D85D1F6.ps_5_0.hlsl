#include "./common.hlsl"

// cbuffer GFD_PSCONST_CORRECT : register(b12) {
//   float3 colorBalance : packoffset(c0);  // 0,0,0
//   float _reserve00 : packoffset(c0.w);   // 0
//   float2 colorBlend : packoffset(c1);    // 0.8, 0.9
// }

// cbuffer GFD_PSCONST_HDR : register(b11) {
//   float middleGray : packoffset(c0.x);  // 0.06
//   float adaptedLum : packoffset(c0.y);  // 0.0003
//   float bloomScale : packoffset(c0.z);  // 1.15
//   float starScale : packoffset(c0.w);   // 0
// }

// SamplerState opaueSampler_s : register(s0);
// SamplerState bloomSampler_s : register(s1);
// SamplerState brightSampler_s : register(s2);
// Texture2D<float4> opaueTexture : register(t0);
// Texture2D<float4> bloomTexture : register(t1);
// Texture2D<float4> brightTexture : register(t2);



// // 3Dmigoto declarations
// #define cmp -

// void main(float4 v0: SV_POSITION0, float2 v1: TEXCOORD0, out float4 o0: SV_TARGET0) {
//   // ---------------------------
//   // 1) Sample inputs (gamma/sRGB domain in your capture)
//   // ---------------------------

//   float2 uv = v1;
//   // float3 bloom = bloomTexture.Sample(bloomSampler_s, uv).rgb * bloomScale;
//   float3 bloom = sample_bicubic(bloomTexture, bloomSampler_s, uv).rgb * bloomScale;
//   float3 bright = brightTexture.Sample(brightSampler_s, uv).rgb * bloomScale;
//   float3 base = opaueTexture.Sample(opaueSampler_s, uv).rgb;

//   // ---------------------------
//   // 2) Bloom compositing
//   // ---------------------------
//   // The code does two "screen" blends:
//   // screen(a,b) = a + b - a*b

//   // screen(bright, bloom)
//   float3 screenBrightBloom = bright + bloom - (bright * bloom);

//   // baseMinusBright = max(base - bright, 0)
//   float3 baseMinusBright = max(base - bright, 0.0);

//   // screen(baseMinusBright, screenBrightBloom)
//   float3 screen2 = baseMinusBright + screenBrightBloom - (baseMinusBright * screenBrightBloom);

//   // Lighten against base: max(base, screen2)
//   float3 untonemapped = max(base, screen2);

//   // ---------------------------
//   // 3) "Tonemap"/grade block (still in gamma space)
//   // ---------------------------

//   // max channel
//   float maxCh = max(untonemapped.r, max(untonemapped.g, untonemapped.b));

//   // oneMinusMax = 1 - maxCh  (this is r2.x in the original)
//   float oneMinusMax = 1.0 - maxCh;

//   // The original does:
//   //   tmp = (1 - untonemapped) - oneMinusMax;
//   //   tmp = tmp / maxCh;
//   //
//   // which simplifies to:
//   //   tmp = 1 - untonemapped/maxCh
//   //
//   // We'll keep it in the same conceptual steps for clarity:
//   float3 t = 1.0 - untonemapped;  // (float3(1)-untonemapped)
//   t = t - oneMinusMax;            // remove (1-maxCh)
//   t = renodx::math::DivideSafe(t, maxCh, 0.f);                  // normalize by max channel  (no guard: original assumes maxCh>0)

//   // Add balance
//   t = t + colorBalance;

//   // Original:
//   //   t = t * maxCh;
//   //   t = t + oneMinusMax;
//   //   t = 1 - t;
//   //
//   // i.e. t = 1 - (t*maxCh + (1-maxCh))
//   t = t * maxCh;
//   t = t + oneMinusMax;
//   t = 1.0 - t;

//   float3 ungraded = t.rgb;

//   // Two more invert/divide stages:
//   //   t = 1 - (t / colorBlend.x)
//   //   t = 1 - (t / colorBlend.y)
//   // t = 1.0 - (t / colorBlend.x);
//   // t = 1.0 - (t / colorBlend.y);

//   float bias = 1.0 - 1.0 / colorBlend.y;
//   float scale = 1.0 / (colorBlend.x * colorBlend.y);


//   if (injectedData.toneMapBlackCorrection > 0.f) {
//     // Shadow crush fix: multiplicative lift in linear space.
//     // t0_srgb = -bias/scale is the sRGB input that maps exactly to 0 after the affine.
//     // k smoothly blends from 1 (no correction, above 2*t0_lin) to t0_lin/m (full correction)
//     // using smoothstep to avoid the C1 discontinuity that causes banding.
//     float t0_srgb = -bias / scale;  // = colorBlend.x * (1 - colorBlend.y)
//     float t0_lin  = gammaDecode(float3(t0_srgb, t0_srgb, t0_srgb)).r;

//     float3 t_lin = gammaDecode(t);
//     float  y     = max(renodx::color::y::from::BT709(t_lin), 1e-6f);
//     // float3 y_lms = renodx::color::lms::from::BT709(t_lin);

//     float k = max(t0_lin / y, 1.f);
//     k            = isfinite(k) ? k : 1.0;
//     float inv_k  = 1.0 / k;

//     float3 t_safe_srgb = gammaEncode(t_lin * k);
//     float3 t_aff       = t_safe_srgb * scale + bias;
//     float3 out_lin     = gammaDecode(t_aff) * inv_k;
//     t = gammaEncode(out_lin);
//   } else {
//     // OLD: original game affine applied directly in sRGB (crushes shadows below t0_srgb to black)
//     t = t * scale + bias;
//   }

//   float3 ungraded_linear = gammaDecode(ungraded);
//   float3 t_linear = gammaDecode(t);

//   t_linear = renodx::color::bt709::clamp::BT2020(t_linear);

//   t = gammaEncode(t_linear);

//   float3 tOut = t;

//   // Final invert to output (original does: r1 = 1 + (-t) = 1 - t)
//   float3 outRGB = tOut;

//   outRGB = gammaDecode(outRGB);
//   ungraded = gammaDecode(ungraded);

//   outRGB = lerp(ungraded, outRGB, injectedData.colorGradeLUTStrength);
  
//   outRGB = gammaEncode(outRGB);
  
//   o0 = float4(outRGB, 1.0);

//   return;
// }

// ---- Created with 3Dmigoto v1.3.16 on Wed Apr 08 10:36:36 2026

cbuffer GFD_PSCONST_CORRECT : register(b12)
{
  float3 colorBalance : packoffset(c0);
  float _reserve00 : packoffset(c0.w);
  float2 colorBlend : packoffset(c1);
}

cbuffer GFD_PSCONST_HDR : register(b11)
{
  float middleGray : packoffset(c0);
  float adaptedLum : packoffset(c0.y);
  float bloomScale : packoffset(c0.z);
  float starScale : packoffset(c0.w);
}

SamplerState opaueSampler_s : register(s0);
SamplerState bloomSampler_s : register(s1);
SamplerState brightSampler_s : register(s2);
Texture2D<float4> opaueTexture : register(t0);
Texture2D<float4> bloomTexture : register(t1);
Texture2D<float4> brightTexture : register(t2);

// 3Dmigoto declarations
#define cmp -

void main(
    float4 v0: SV_POSITION0,
    float2 v1: TEXCOORD0,
    out float4 o0: SV_TARGET0)
{
  float4 r0, r1, r2, r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = bloomTexture.Sample(bloomSampler_s, v1.xy).xyz;
  r0.xyz = bloomScale * r0.xyz;
  r1.xyz = brightTexture.Sample(brightSampler_s, v1.xy).xyz;
  r1.xyz = bloomScale * r1.xyz;
  r2.xyz = opaueTexture.Sample(opaueSampler_s, v1.xy).xyz;
  r2.xyz = r2.xyz;
  r3.xyz = r1.xyz + r0.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.xyz = -r0.xyz;
  r0.xyz = r3.xyz + r0.xyz;
  r1.xyz = -r1.xyz;
  r1.xyz = r2.xyz + r1.xyz;
  r3.xyz = int3(0, 0, 0);
  r1.xyz = max(r3.xyz, r1.xyz);
  r3.xyz = r1.xyz + r0.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.xyz = -r0.xyz;
  r0.xyz = r3.xyz + r0.xyz;
  r0.xyz = max(r2.xyz, r0.xyz);
  r1.w = 1;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r2.x = -r0.w;
  r2.x = 1 + r2.x;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1, 1, 1) + r0.xyz;
  r2.yzw = -r2.xxx;
  r0.xyz = r2.yzw + r0.xyz;
  r0.xyz = r0.xyz / r0.www;
  r0.xyz = colorBalance.xyz + r0.xyz;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = r0.xyz + r2.xxx;

  // float3 t = r0.rgb;

  r0.xyz = -r0.xyz;
  r0.xyz = float3(1, 1, 1) + r0.xyz;
  float3 t = r0.rgb;
  float3 ungraded = t;
  // r0.xyz = r0.xyz / colorBlend.xxx;
  // r0.xyz = -r0.xyz;
  // r0.xyz = float3(1, 1, 1) + r0.xyz;
  // r0.xyz = r0.xyz / colorBlend.yyy;
  // r0.xyz = -r0.xyz;
  // r1.xyz = float3(1, 1, 1) + r0.xyz;
  // r1.xyz = r1.xyz;
  // r1.w = r1.w;
  // o0.xyzw = r1.xyzw;

  float3 t_lin = gammaDecode(t);
  t_lin = max(0.f, t_lin);

  float bias = 1.0 - 1.0 / colorBlend.y;
  float scale = 1.0 / (colorBlend.x * colorBlend.y);
  float cutoff = colorBlend.x * (1 - colorBlend.y);

  float min_ap1 = 0.f;
  float min_bt709 = renodx::color::bt709::from::AP1(float3(min_ap1, min_ap1, min_ap1)).r;
  float min_value = gammaEncode(min_bt709);

  min_value = 0.01 / 100.f;
  // compute the danger threshold in *linear*
  float t0_srgb = (min_value - bias) / scale;  // where srgb affine crosses 0
  float t0_lin = gammaDecode(float3(t0_srgb, t0_srgb, t0_srgb)).r;

  float m = min(t_lin.r, min(t_lin.g, t_lin.b));
  m = max(m, 0.0);  // prevent negative
  float m_safe = max(m, 1e-6);

  float eps = 1e-6;
  // k grows only when we're in the danger zone (m < t0)
  // multiplicative “make-safe” factor based on linear luma
  // float k = max(1.0, t0_lin / (m + 1e-6));
  float k = max(1.0, t0_lin / m_safe);
  k = min(k, 4.0);  // optional clamp (tune this)
  k = isfinite(k) ? k : 1.0;
  float inv_k = 1.0 / max(k, 1e-6);

  // apply safety lift in linear, then convert back to srgb for the game’s affine
  float3 t_safe_srgb = gammaEncode(t_lin * k);

  // game affine (still in srgb, preserving its look)
  float3 t_aff = t_safe_srgb * scale + bias;

  // undo the lift back in linear so HDR energy is preserved
  float3 out_lin = gammaDecode(t_aff) * inv_k;

  // float3 t_aff_fixed = gammaEncode(out_lin);

  if (injectedData.toneMapBlackCorrection > 0.f && injectedData.toneMapType != 0.f) {
    //   t = lerp(t, t_aff, w);
    float3 t_aff_fixed = gammaEncode(out_lin);
    t = t_aff_fixed;
    // optional: blend only when needed (k>1)
    // float w = saturate((k - 1.0) / (k));  // 0 when k=1, ->1 as k grows
    // t = lerp(t_aff, t_aff_fixed, 1.0);  // usually just use fixed version
  } else {
    t = ungraded * scale + bias;
  }


  o0 = float4(t, 1.0);
  o0.w = r1.w;

  return;
}