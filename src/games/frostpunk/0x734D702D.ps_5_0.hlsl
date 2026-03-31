// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:39:32 2025

cbuffer Constants : register(b2)
{

  struct
  {
    float4 OutlineParams;
  } PerDrawCall : packoffset(c0);

}

SamplerState OutlineTextureSampler_s : register(s2);
Texture2D<float4> OutlineTexture : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD4,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = OutlineTexture.Sample(OutlineTextureSampler_s, v2.xy).xyz;
  r1.xyz = OutlineTexture.Sample(OutlineTextureSampler_s, v2.zw).xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyz = OutlineTexture.Sample(OutlineTextureSampler_s, v3.xy).xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r1.xyz = OutlineTexture.Sample(OutlineTextureSampler_s, v3.zw).xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = PerDrawCall.OutlineParams.yyy * r0.xyz;
  r1.xyz = OutlineTexture.Sample(OutlineTextureSampler_s, v1.xy).xyz;
  r0.xyz = r1.xyz * PerDrawCall.OutlineParams.xxx + r0.xyz;
  o0.w = dot(r0.xyz, float3(0.212599993,0.715200007,0.0722000003));
  o0.xyz = r0.xyz;
  return;
}