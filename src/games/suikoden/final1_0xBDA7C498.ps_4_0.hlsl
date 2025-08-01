// ---- Created with 3Dmigoto v1.3.16 on Sun May 18 11:50:33 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[9];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(-0.5,-0.5) + v1.xy;
  r0.x = dot(r0.xy, r0.xy);
  r0.x = sqrt(r0.x);
  r0.x = -cb0[4].x + r0.x;
  r0.x = 1 + -r0.x;
  r0.x = min(0, r0.x);
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r0.xyz = r1.xyz + r0.xxx;
  o0.w = r1.w;
  r1.xyz = cb0[7].xyz * v1.yyy;

  o0.xyz = r1.xyz * cb0[8].xxx + r0.xyz;
  // o0.xyz = saturate(r1.xyz * cb0[8].xxx + r0.xyz);
  

  return;
}