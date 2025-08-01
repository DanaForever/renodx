// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 10 16:59:53 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[1];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[5];
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

  r0.x = -cb1[0].y * cb0[3].y + v0.y;
  r0.x = cb0[3].x * r0.x;
  r0.x = sin(r0.x);
  r0.y = cb0[3].z / cb0[2].z;
  r0.x = r0.x * r0.y;
  r0.y = -v0.y * cb0[3].w + 1;
  r0.x = r0.x * r0.y;
  r0.y = 0;
  r0.xy = v0.xy + r0.xy;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r1.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  r0.xyzw = -r1.xyzw + r0.xyzw;
  o0.xyzw = cb0[4].xxxx * r0.xyzw + r1.xyzw;
  return;
}