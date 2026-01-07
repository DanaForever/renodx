// ---- Created with 3Dmigoto v1.3.16 on Sun Jan 04 12:02:07 2026
#include "./common.hlsl"
SamplerState colorSampler_s : register(s0);
SamplerState blurSampler_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = colorTexture.Sample(colorSampler_s, v1.xy).xyzw;

  o0 = r0;
  return; 
  r1.xyzw = blurTexture.Sample(blurSampler_s, v1.xy).xyzw;
  r2.xyz = -r0.xyz;
  r1.xyz = r2.xyz + r1.xyz;
  r1.xyz = r1.www * r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.w = r0.w;
  o0.xyz = r0.xyz;
  o0.w = r0.w;

  return;
}