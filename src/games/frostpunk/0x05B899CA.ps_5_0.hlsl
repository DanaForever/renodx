// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:42:15 2025

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
  float4 r0;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = InputTexture.SampleLevel(InputTextureSampler_s, v2.zw, 0).w;
  r0.z = cmp(0 >= r0.x);
  if (r0.z != 0) {
    r0.z = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0).w;
    r0.z = PerDrawCall.Weights.x * r0.z;
    r0.z = r0.x * PerDrawCall.Weights.w + r0.z;
    r0.w = InputTexture.SampleLevel(InputTextureSampler_s, v1.zw, 0).w;
    r0.z = r0.w * PerDrawCall.Weights.y + r0.z;
    r0.w = InputTexture.SampleLevel(InputTextureSampler_s, v2.xy, 0).w;
    r0.z = r0.w * PerDrawCall.Weights.z + r0.z;
    r0.w = InputTexture.SampleLevel(InputTextureSampler_s, v3.xy, 0).w;
    r0.z = r0.w * PerDrawCall.Weights.z + r0.z;
    r0.w = InputTexture.SampleLevel(InputTextureSampler_s, v3.zw, 0).w;
    r0.z = r0.w * PerDrawCall.Weights.y + r0.z;
    r0.w = InputTexture.SampleLevel(InputTextureSampler_s, v4.xy, 0).w;
    r0.x = r0.w * PerDrawCall.Weights.x + r0.z;
  }
  r0.y = 0;
  o0.xyzw = r0.yyyx;
  return;
}