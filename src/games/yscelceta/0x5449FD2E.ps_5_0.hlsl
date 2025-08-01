// ---- Created with 3Dmigoto v1.3.16 on Tue Jul 15 22:55:41 2025

cbuffer CAlTest : register(b0)
{
  float altest : packoffset(c0);
  float mulblend : packoffset(c0.y);
  float noalpha : packoffset(c0.z);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(samp_s, v0.xy).xyzw;
  r0.xyzw = v1.xyzw * r0.xyzw;
  r1.x = cmp(r0.w < altest);
  if (r1.x != 0) {
    if (-1 != 0) discard;
  }
  r1.x = cmp(0 != mulblend);
  if (r1.x != 0) {
    r1.x = -r0.w;
    r1.x = 1 + r1.x;
    r1.yzw = -r0.xyz;
    r1.yzw = float3(1,1,1) + r1.yzw;
    r1.xyz = r1.xxx * r1.yzw;
    r0.xyz = r1.xyz + r0.xyz;
  }
  r0.xyz = r0.xyz;
  r0.w = r0.w;
  r1.x = cmp(0 != noalpha);
  if (r1.x != 0) {
    r0.w = 1;
  }
  o0.xyzw = r0.xyzw;
  return;
}