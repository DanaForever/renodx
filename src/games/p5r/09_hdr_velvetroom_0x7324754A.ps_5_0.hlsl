// ---- Created with 3Dmigoto v1.3.16 on Sun Apr 12 19:36:51 2026
#include "./common.hlsl"

cbuffer GFD_PSCONST_CORRECT : register(b12)
{
  float3 colorBalance : packoffset(c0);
  float _reserve00 : packoffset(c0.w);
  float3 colorBlend : packoffset(c1);
}

SamplerState sampler0_s : register(s0);
Texture2D<float4> texture0 : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = texture0.Sample(sampler0_s, v1.xy).xyz;
  r0.xyz = r0.xyz;
  r0.w = max(r0.x, r0.y);
  r0.w = max(r0.w, r0.z);
  r1.x = -r0.w;
  r1.x = 1 + r1.x;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;
  r1.yzw = -r1.xxx;
  r0.xyz = r1.yzw + r0.xyz;
  r0.xyz = r0.xyz / r0.www;
  r0.xyz = colorBalance.xyz + r0.xyz;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = r0.xyz + r1.xxx;
  r0.xyz = -r0.xyz;
  r0.xyz = float3(1,1,1) + r0.xyz;

  
  // r0.xyz = r0.xyz / colorBlend.xxx;
  // r0.xyz = -r0.xyz;
  // r0.xyz = float3(1,1,1) + r0.xyz;
  // r0.xyz = r0.xyz / colorBlend.yyy;
  // r0.xyz = -r0.xyz;
  // r0.xyz = float3(1,1,1) + r0.xyz;

  float3 t = r0.rgb;
  float3 ungraded = t;

  float3 t_lin = gammaDecode(t);
  t_lin = max(0.f, t_lin);
  float Y = renodx::color::y::from::BT709(t_lin);

  float bias = 1.0 - 1.0 / colorBlend.y;
  float scale = 1.0 / (colorBlend.x * colorBlend.y);
  float cutoff = colorBlend.x * (1 - colorBlend.y);

  float min_value = gammaEncode(0.01 / 100);
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

  float3 t_aff_fixed = gammaEncode(out_lin);

  if (injectedData.toneMapBlackCorrection > 0.f && injectedData.toneMapType != 0.f) {
    //   t = lerp(t, t_aff, w);
    t = t_aff_fixed;
    // optional: blend only when needed (k>1)
    // float w = saturate((k - 1.0) / (k));  // 0 when k=1, ->1 as k grows
    // t = lerp(t_aff, t_aff_fixed, 1.0);  // usually just use fixed version
  } else {
    t = t * scale + bias;
  }

  o0 = float4(t, 1.0);

  // r0.w = colorBlend.z;
  // r0.xyz = r0.xyz;
  // r0.w = r0.w;
  // o0.xyzw = r0.xyzw;

  // need this fix
  o0.w = saturate(colorBlend.z);
  return;
}