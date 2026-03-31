// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 20:24:54 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[17];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.x = r0.w * cb1[3].x + cb1[3].y;
  r0.xyzw = v2.xyzw * r0.xyzw;
  r1.x = cmp(r1.x < 0);
  if (r1.x != 0) discard;
  r0.xyz = cb0[16].zzz * r0.xyz;
  o0.w = r0.w;
  o0.xyz = float3(0.0009765625,0.0009765625,0.0009765625) * r0.xyz;
  return;
}