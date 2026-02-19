// ---- Created with 3Dmigoto v1.3.16 on Fri Feb 20 00:48:54 2026

cbuffer CB0 : register(b0)
{
  float2 fparam : packoffset(c0);
}

SamplerState depthmap_samp_s : register(s0);
Texture2D<float4> depthmap_tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = fparam.x * fparam.y;
  r0.y = depthmap_tex.Sample(depthmap_samp_s, v0.xy).x;
  r0.z = fparam.y + -fparam.x;
  r0.y = -r0.z * r0.y + fparam.y;
  r0.x = r0.x / r0.y;
  r0.x = -fparam.x + r0.x;
  r0.x = r0.x / r0.z;
  r0.x = saturate(1 + -r0.x);
  r0.y = 65536 * r0.x;
  r0.y = trunc(r0.y);
  o0.z = r0.x * 65536 + -r0.y;
  r0.x = 0.00390625 * r0.y;
  r0.x = trunc(r0.x);
  o0.y = r0.y * 0.00390625 + -r0.x;
  o0.x = 0.00390625 * r0.x;
  o0.w = 1;
  return;
}