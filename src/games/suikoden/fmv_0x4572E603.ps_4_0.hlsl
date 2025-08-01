#include "./common.hlsl"
#include "./shared.h"


// ---- Created with 3Dmigoto v1.3.16 on Sun May 18 12:37:49 2025
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[6];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).wxyz;
  r1.xyzw = t1.Sample(s1_s, w1.xy).xyzw;
  r0.y = r1.w;
  r1.xyzw = t2.Sample(s2_s, w1.xy).xyzw;
  r0.z = r1.w;
  // r0.xyz = float3(-0.0627499968,-0.50195998,-0.50195998) + r0.xyz;
  // o0.x = dot(float2(1.16437995,1.59603), r0.xz);
  // o0.y = dot(float3(1.16437995,-0.391759992,-0.812969983), r0.xyz);
  // o0.z = dot(float2(1.16437995,2.01723003), r0.xy);

  // Offset remains the same:
  r0.xyz = r0.xyz + float3(-0.0627451, -0.5019608, -0.5019608);

  // BT.709 matrix
  o0.x = dot(float2(1.164383, 1.792741), r0.xz);               // R
  o0.y = dot(float3(1.164383, -0.213249, -0.532909), r0.xyz);  // G
  o0.z = dot(float2(1.164383, 2.112402), r0.xy);               // B
  o0.w = 1 + -cb0[5].x;

  if (shader_injection.tone_map_type != 0.f) {
    // float3 saturated = saturate(r0.rgb);
    float3 inverse;
    float3 saturated = o0.rgb;

    float videoPeak =
        400.f;
    inverse = renodx::color::gamma::Decode(saturated, 2.4f);  // 2.4 for BT2446a
    inverse = renodx::tonemap::inverse::bt2446a::BT709(inverse, 100.f, videoPeak);
    inverse /= videoPeak;                                        // Normalize to 1.0f = peak;
    inverse *= videoPeak /
        shader_injection.diffuse_white_nits;  // 1.f = game nits

    o0.rgb = PostToneMapScale(inverse);  // Gamma Correct
  }

  return;
}