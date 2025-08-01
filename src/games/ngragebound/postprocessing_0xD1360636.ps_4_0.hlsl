// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 10 16:59:53 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[4];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = 1 << asint(cb0[3].x);
  r0.x = (int)r0.x;
  r0.x = 1 / r0.x;
  r0.yz = cb0[2].zw * v0.xy;
  r0.yz = r0.yz * r0.xx;
  r0.xw = cb0[2].zw * r0.xx;
  r0.yz = round(r0.yz);
  r0.w = trunc(r0.w);
  r1.x = 1 / r0.x;
  r1.y = 1 / r0.w;
  r0.xy = r0.yz * r1.xy + -v0.xy;
  r0.z = asint(cb0[3].x);
  r0.z = cmp(r0.z >= 2);
  r0.z = r0.z ? 1.000000 : 0;
  r0.xy = r0.zz * r0.xy + v0.xy;
  o0.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  return;
}