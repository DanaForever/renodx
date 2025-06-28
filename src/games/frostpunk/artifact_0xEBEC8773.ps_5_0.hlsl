// ---- Created with 3Dmigoto v1.3.16 on Thu Jun 12 19:17:06 2025

cbuffer Constants : register(b2)
{

  struct
  {
    float4 Weights;
  } PerDrawCall : packoffset(c0);

}

SamplerState InputTextureSampler_s : register(s0);
Texture2D<float4> InputTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float2 v4 : TEXCOORD3,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v1.zw, 0).xyz;
  r0.xyz = PerDrawCall.Weights.yyy * r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0).xyz;
  r0.xyz = r1.xyz * PerDrawCall.Weights.xxx + r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v2.xy, 0).xyz;
  r0.xyz = r1.xyz * PerDrawCall.Weights.zzz + r0.xyz;
  r1.xyzw = InputTexture.SampleLevel(InputTextureSampler_s, v2.zw, 0).xyzw;
  r0.xyz = r1.xyz * PerDrawCall.Weights.www + r0.xyz;
  o0.w = r1.w;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v3.xy, 0).xyz;
  r0.xyz = r1.xyz * PerDrawCall.Weights.zzz + r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v3.zw, 0).xyz;
  r0.xyz = r1.xyz * PerDrawCall.Weights.yyy + r0.xyz;
  r1.xyz = InputTexture.SampleLevel(InputTextureSampler_s, v4.xy, 0).xyz;
  o0.xyz = r1.xyz * PerDrawCall.Weights.xxx + r0.xyz;

  return;
}