// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:53:13 2025
Texture2D<float4> t10 : register(t10);

SamplerState s10_s : register(s10);

cbuffer cb0 : register(b0)
{
  float4 cb0[10];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb2[1].yw + -cb2[1].xz;
  r0.xy = float2(1,1) / r0.xy;
  r0.z = t10.Sample(s10_s, v1.xy).x;
  r0.z = r0.z * cb0[9].z + cb0[9].w;
  r0.z = 1 / r0.z;
  r1.xy = -cb2[1].xz + r0.zz;
  r0.xy = saturate(r1.xy * r0.xy);
  r1.xy = r0.xy * float2(-2,-2) + float2(3,3);
  r0.xy = r0.xy * r0.xy;
  r0.y = r1.y * r0.y;
  r0.x = -r1.x * r0.x + 1;
  r0.x = cb2[2].x * -r0.x;
  r0.y = cb2[2].y * r0.y;
  r0.w = cmp(cb2[1].z < r0.z);
  r0.z = cmp(r0.z < cb2[1].y);
  r0.y = r0.w ? r0.y : 0;
  r0.x = r0.z ? r0.x : r0.y;
  r0.x = max(-1, r0.x);
  o0.w = min(1, r0.x);
  o0.xyz = float3(0,0,0);
  return;
}