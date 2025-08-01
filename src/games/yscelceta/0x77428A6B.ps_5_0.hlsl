// ---- Created with 3Dmigoto v1.3.16 on Tue Jul 15 22:55:41 2025

cbuffer CBuf0 : register(b0)
{
  float4 gaussmul : packoffset(c0);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float2 v1 : TEXCOORD2,
  float2 w1 : TEXCOORD3,
  float2 v2 : TEXCOORD4,
  float2 w2 : TEXCOORD5,
  float2 v3 : TEXCOORD6,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex.Sample(samp_s, v0.xy).xyz;
  r1.xyz = tex.Sample(samp_s, w0.xy).xyz;
  r2.xyz = tex.Sample(samp_s, v1.xy).xyz;
  r3.xyz = tex.Sample(samp_s, w1.xy).xyz;
  r4.xyz = tex.Sample(samp_s, v2.xy).xyz;
  r5.xyz = tex.Sample(samp_s, w2.xy).xyz;
  r6.xyz = tex.Sample(samp_s, v3.xy).xyz;
  r1.xyz = gaussmul.xxx * r1.xyz;
  r2.xyz = gaussmul.yyy * r2.xyz;
  r3.xyz = gaussmul.zzz * r3.xyz;
  r4.xyz = gaussmul.zzz * r4.xyz;
  r5.xyz = gaussmul.yyy * r5.xyz;
  r6.xyz = gaussmul.xxx * r6.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyz = r3.xyz + r2.xyz;
  r2.xyz = r5.xyz + r4.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyz = r2.xyz + r6.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  o0.xyz = r0.xyz / float3(3,3,3);
  o0.w = 1;
  return;
}