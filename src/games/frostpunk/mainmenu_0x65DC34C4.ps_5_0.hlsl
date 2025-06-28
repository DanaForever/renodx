// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 20:21:23 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb5 : register(b5)
{
  float4 cb5[222];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[17];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.xyzw = v2.wxyz * r0.wxyz;
  r0.x = r1.x * cb5[216].y + cb5[216].z;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.x = 1 + -v2.w;
  r0.y = r0.w + -r0.x;
  r0.y = cmp(r0.y < 0);
  r0.z = cmp(0 < cb5[221].x);
  r0.y = r0.z ? r0.y : 0;
  if (r0.y != 0) discard;
  r0.y = saturate(cb5[221].y + r0.x);
  r0.y = min(r0.w, r0.y);
  r0.x = r0.y + -r0.x;
  r0.x = r0.x / cb5[221].y;
  r0.y = cmp(0.000000 == cb5[221].y);
  r0.x = r0.y ? 1 : r0.x;
  o0.w = r0.z ? r0.x : r1.x;
  r0.x = max(0.00999999978, cb0[14].y);
  r0.x = min(0.150000006, r0.x);
  r0.x = -0.00999999978 + r0.x;
  r0.x = 7.14285707 * r0.x;
  r0.x = r0.x * r0.x;
  r0.yzw = cb5[218].xyz * cb5[218].www;
  r0.yzw = v5.xxx * r0.yzw;
  r2.xyz = cb0[16].xxx * cb0[15].xyz;
  r0.xyz = r2.xyz * r0.xxx + r0.yzw;
  r0.xyz = v5.zzz * r0.xyz;
  r0.xyz = r1.yzw * r0.xyz + v4.xyz;
  r0.xyz = -cb0[10].xyz * cb0[16].zzz + r0.xyz;
  r0.w = max(cb0[10].w, v6.y);
  r0.w = saturate(min(v7.w, r0.w));
  r1.xyz = cb0[16].zzz * cb0[10].xyz;
  r0.xyz = r0.www * r0.xyz + r1.xyz;
  o0.xyz = float3(0.0009765625,0.0009765625,0.0009765625) * r0.xyz;
  return;
}