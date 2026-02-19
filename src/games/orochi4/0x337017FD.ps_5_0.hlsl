// ---- Created with 3Dmigoto v1.3.16 on Thu Feb 19 15:03:28 2026

SamplerState smplScene_s : register(s0);
Texture2D<float4> smplScene_Tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  o0.xyzw = smplScene_Tex.Sample(smplScene_s, v1.xy).xyzw;
  return;
}