// ---- Created with 3Dmigoto v1.3.16 on Tue May 20 17:31:24 2025
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[132];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t2.SampleBias(s0_s, v1.xy, cb0[19].x).x;
  r0.x = -0.5 + r0.x;
  r0.x = dot(r0.xx, cb0[131].zz);
  r0.x = -cb0[128].w * 2 + r0.x;
  r0.y = cb0[128].w + cb0[128].w;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  // r0.x = r0.x * r0.y;
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.z = r0.y * r0.x;
  r1.xyzw = t1.SampleBias(s0_s, v1.xy, cb0[19].x).xyzw;
  r0.x = r0.y * r0.x + r1.w;
  r0.x = -r0.z * r1.w + r0.x;
  r0.y = max(r1.x, r1.y);
  r1.w = max(r0.y, r1.z);
  r2.xyzw = t0.SampleBias(s0_s, v1.xy, cb0[19].x).xyzw;
  r1.xyzw = -r2.xyzw + r1.xyzw;
  o0.xyzw = r0.xxxx * r1.xyzw + r2.xyzw;
  return;
}