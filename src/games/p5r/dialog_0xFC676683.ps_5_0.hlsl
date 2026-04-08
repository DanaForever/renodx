// ---- Created with 3Dmigoto v1.3.16 on Thu Apr 09 01:08:05 2026

cbuffer GFD_PSCONST_MATERIAL : register(b1)
{
  float4 matAmbient : packoffset(c0);
  float4 matDiffuse : packoffset(c1);
  float4 matSpecular : packoffset(c2);
  float4 matEmissive : packoffset(c3);
  float matReflectivity : packoffset(c4);
  float matOutlineIndex : packoffset(c4.y);
  float shadowDisable : packoffset(c4.z);
  float fogDisable : packoffset(c4.w);
}

cbuffer GFD_PSCONST_ENV_COLORS : register(b5)
{
  float4 fogColor : packoffset(c0);
  float4 heightFogColor : packoffset(c1);
  float3 lmapAmbient : packoffset(c2);
  float atestRef : packoffset(c2.w);
}

SamplerState diffuseSampler_s : register(s0);
Texture2D<float4> diffuseTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : NORMAL0,
  float4 v2 : COLOR0,
  float2 v3 : TEXCOORD0,
  float4 v4 : COLOR1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = diffuseTexture.Sample(diffuseSampler_s, v3.xy).xyz;
  r0.xyz = r0.xyz;
  r0.w = heightFogColor.w * v1.w;
  r1.x = -fogDisable;
  r1.x = 1 + r1.x;
  r0.w = r1.x * r0.w;
  r0.w = max(0, r0.w);
  r0.w = min(1, r0.w);
  r1.xyz = matDiffuse.xyz + matAmbient.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.xyz = v2.xyz * r0.xyz;
  r1.xyz = -r0.xyz;
  r1.xyz = heightFogColor.xyz + r1.xyz;
  r1.xyz = r1.xyz * r0.www;
  r0.xyz = r1.xyz + r0.xyz;
  r0.w = -v4.x;
  r0.w = 1 + r0.w;
  r0.w = fogColor.w * r0.w;
  r1.x = -fogDisable;
  r1.x = 1 + r1.x;
  r0.w = r1.x * r0.w;
  r1.xyz = -r0.xyz;
  r1.xyz = fogColor.xyz + r1.xyz;
  r1.xyz = r1.xyz * r0.www;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.w = 1;
  o0.xyz = r0.xyz;
  o0.w = r0.w;

  o0.rgb = clamp(o0.rgb, 0, 0.5f);
  // o0 = saturate(o0);
  // o0 *= 4;
  return;
}