// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 10 16:59:53 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);




// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  o0.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  return;
}