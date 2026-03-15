// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 01:35:19 2025

cbuffer CAlTest : register(b0)
{
  float altest : packoffset(c0);
  float mulblend : packoffset(c0.y);
  float noalpha : packoffset(c0.z);
}



// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(v0.w < altest);
  if (r0.x != 0) discard;
  r0.xy = cmp(float2(0,0) != mulblend);
  r1.xyzw = float4(1,1,1,1) + -v0.wxyz;
  r1.xyz = r1.xxx * r1.yzw + v0.xyz;
  o0.xyz = r0.xxx ? r1.xyz : v0.xyz;

  // o0.rgb *= 
  o0.w = r0.y ? 1 : v0.w;

  return;
}