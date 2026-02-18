// ---- Created with 3Dmigoto v1.3.16 on Wed Feb 18 12:12:02 2026
#include "output.hlsli"
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[2];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[3];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float3 v2 : ORIGINAL_POSITION0,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v4.xy * v4.zw;
  r0.xyz = t0.Sample(s0_s, r0.xy).xyz;
  r0.xyz = cb1[1].xyz + r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = v1.xyz * r0.xyz;
  r1.xyz = log2(r0.xyz);
  r1.xyz = cb0[2].xxx * r1.xyz;
  r2.xyz = float3(0.416666657,0.416666657,0.416666657) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = exp2(r2.xyz);
  r2.xyz = r2.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r3.xyz = float3(12.9200001,12.9200001,12.9200001) * r1.xyz;
  r1.xyz = cmp(r1.xyz >= float3(0.00313066994,0.00313066994,0.00313066994));
  r1.xyz = r1.xyz ? r2.xyz : r3.xyz;
  r0.w = cmp(cb0[2].y != 1.000000);
  o0.xyz = r0.www ? r1.xyz : r0.xyz;

  // // o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    float videoPeak = RENODX_FMV_PEAK_WHITE_NITS;

    float peak = videoPeak / (RENODX_DIFFUSE_WHITE_NITS / 203.f);

    o0.rgb = renodx::color::gamma::DecodeSafe(o0.rgb, 2.4f);  // 2.4 for BT2446a
    // o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);  // 2.4 for BT2446a
    o0.rgb = renodx::tonemap::inverse::bt2446a::BT709(o0.rgb, 100.f, videoPeak);
    o0.rgb /= videoPeak;                              // Normalize to 1.0f = peak;
    o0.rgb *= videoPeak /
                  RENODX_DIFFUSE_WHITE_NITS;  // 1.f = game nits

    // Inverse AutoHDR?
  } else {
    o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
  }

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.4f);
  }

  // o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  // o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);


  o0.rgb *= RENODX_DIFFUSE_WHITE_NITS / 80.f;
  o0.w = v1.w;
  return;
}