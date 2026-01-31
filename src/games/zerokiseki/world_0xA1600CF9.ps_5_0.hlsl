// ---- Created with 3Dmigoto v1.3.16 on Sat Jan 31 10:42:05 2026

cbuffer CAlTest : register(b0)
{
  float altest : packoffset(c0);
  float useshadow : packoffset(c0.y);
  float mulblend : packoffset(c0.z);
  float noalpha : packoffset(c0.w);
  float input_zoom : packoffset(c1);
}

cbuffer CShadowColor : register(b1)
{
  float4 shadowcolor : packoffset(c0);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float4 v7 : TEXCOORD5,
  float4 v8 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = tex.Sample(samp_s, v0.xy).xyzw;
  r1.x = v1.w * r0.w;
  r1.y = cmp(0 != noalpha);
  r1.y = ~(int)r1.y;
  r1.z = cmp(r1.x < altest);
  r1.y = r1.z ? r1.y : 0;
  if (r1.y != 0) discard;
  r0.xyz = r0.xyz * v1.xyz + v2.xyz;
  r1.y = max(0, v2.w);
  r2.xyz = float3(-1,-1,-1) + shadowcolor.xyz;
  r1.yzw = r1.yyy * r2.xyz + float3(1,1,1);
  r0.xyz = r1.yzw * r0.xyz;
  r0.xyz = r0.xyz * v3.www + v3.xyz;
  r1.y = cmp(0 != mulblend);
  r0.w = -r0.w * v1.w + 1;
  r2.xyz = float3(1,1,1) + -r0.xyz;
  r2.xyz = r0.www * r2.xyz + r0.xyz;
  o0.xyz = r1.yyy ? r2.xyz : r0.xyz;
  o0.w = r1.x;
  return;
}