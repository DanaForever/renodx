// ---- Created with 3Dmigoto v1.3.16 on Tue Sep 09 14:18:11 2025

cbuffer cb_local : register(b2)
{
  float4 offsetsAndWeights[15] : packoffset(c0);
}

SamplerState samLinear_s : register(s0);
Texture2D<float4> colorTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = float4(0,0,0,0);
  while (true) {
    r1.x = cmp((uint)r0.w >= 15);
    if (r1.x != 0) break;
    r1.xy = offsetsAndWeights[r0.w].xy + v1.xy;
    r1.xyz = colorTexture.SampleLevel(samLinear_s, r1.xy, 0).xyz;
    r0.xyz = r1.xyz * offsetsAndWeights[r0.w].zzw + r0.xyz;
    r0.w = (int)r0.w + 1;
  }
  o0.xyz = r0.xyz;
  o0.w = 0;
  return;
}