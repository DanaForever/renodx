// ---- Created with 3Dmigoto v1.3.16 on Tue Jul 15 22:55:41 2025

cbuffer CBuf0 : register(b0)
{
  float4 lummul : packoffset(c0);
  float lum : packoffset(c1);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(samp_s, v0.xy).xyzw;
  r1.xyz = lummul.xyz * r0.xyz;
  r1.x = r1.x + r1.y;
  r1.x = r1.x + r1.z;
  r1.y = r1.x / lum;
  r1.y = r1.y * r1.y;
  r1.z = cmp(r1.x >= lum);
  r1.z = r1.z ? 0.000000 : 0;
  r1.z = (int)r1.z;
  r1.x = cmp(r1.x < lum);
  r1.x = r1.x ? 0.000000 : 0;
  r1.x = (int)r1.x;
  r1.x = r1.x * r1.y;
  r1.x = r1.x * r1.y;
  r1.x = r1.z + r1.x;
  r0.xyz = r1.xxx * r0.xyz;
  o0.xyz = r0.xyz;
  o0.w = r0.w;
  return;
}