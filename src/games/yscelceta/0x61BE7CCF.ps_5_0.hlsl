// ---- Created with 3Dmigoto v1.3.16 on Tue Jul 15 22:55:41 2025

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex.Sample(samp_s, v0.xy).xyz;
  r0.xyz = r0.xyz;
  r0.w = 1;
  o0.xyz = r0.xyz;
  o0.w = r0.w;
  return;
}