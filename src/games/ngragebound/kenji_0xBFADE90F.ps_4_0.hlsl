// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 10 16:59:53 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[8];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xyz = r0.xyz * cb0[4].xyz + -r0.xyz;
  r1.xyz = cb0[4].www * r1.xyz + r0.xyz;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = r2.xyz + -r1.xyz;
  r1.xyz = cb0[7].xxx * r2.xyz + r1.xyz;
  r1.xyz = cb0[6].xxx + r1.xyz;
  r2.xyz = cb0[3].xyz + -r1.xyz;
  r1.xyz = cb0[6].yyy * r2.xyz + r1.xyz;
  r2.xyz = r1.xyz * cb0[3].xyz + -r1.xyz;
  r1.xyz = cb0[6].zzz * r2.xyz + r1.xyz;
  r1.w = dot(r1.xyz, float3(0.300000012,0.589999974,0.109999999));
  r2.x = dot(cb0[3].xyz, float3(0.300000012,0.589999974,0.109999999));
  r1.w = -r2.x + r1.w;
  r2.xyz = cb0[3].xyz + r1.www;
  r1.w = min(r2.y, r2.z);
  r1.w = min(r2.x, r1.w);
  r2.w = dot(r2.xyz, float3(0.300000012,0.589999974,0.109999999));
  r3.x = r2.w + -r1.w;
  r1.w = cmp(r1.w < 0);
  r3.x = r2.w / r3.x;
  r3.yzw = r2.xyz + -r2.www;
  r3.xyz = r3.xxx * r3.yzw + r2.www;
  r3.xyz = r1.www ? r3.xyz : r2.xyz;
  r4.xyz = r3.xyz + -r2.www;
  r1.w = max(r2.y, r2.z);
  r1.w = max(r2.x, r1.w);
  r2.x = r1.w + -r2.w;
  r1.w = cmp(1 < r1.w);
  r2.y = 1 + -r2.w;
  r2.x = r2.y / r2.x;
  r2.xyz = r2.xxx * r4.xyz + r2.www;
  r2.xyz = r1.www ? r2.xyz : r3.xyz;
  r2.xyz = r2.xyz + -r1.xyz;
  r0.xyz = cb0[6].www * r2.xyz + r1.xyz;
  o0.xyzw = v1.xyzw * r0.xyzw;
  return;
}