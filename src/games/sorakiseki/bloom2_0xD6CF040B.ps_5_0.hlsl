float3 LogMap(float3 c) { return log(1.0 + c); }
float3 LogMapInv(float3 l) { return exp(l) - 1.0; }

// ---- Created with 3Dmigoto v1.3.16 on Thu Aug 21 11:48:23 2025

cbuffer cb_glow : register(b2)
{
  float4 uv_clamp0_g : packoffset(c0);
  float4 uv_clamp1_g : packoffset(c1);
  float2 uv_clamp2_g : packoffset(c2);
  float2 intensityLum_g : packoffset(c2.z);
  float2 chrIntensityLum_g : packoffset(c3);
  float atmosphereFadeBegin_g : packoffset(c3.z);
  float atmosphereFadeRangeInv_g : packoffset(c3.w);
  float atmosphereIntensity_g : packoffset(c4);
}

SamplerState samLinear_s : register(s0);
SamplerState samPoint_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> blurTexture1 : register(t1);
Texture2D<float4> blurTexture2 : register(t2);
Texture2D<float4> blurTexture3 : register(t3);
Texture2D<float4> blurTexture4 : register(t4);
Texture2D<float4> blurTexture5 : register(t5);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = min(uv_clamp0_g.xyzw, v1.xyxy);
  r1.xyz = blurTexture1.SampleLevel(samLinear_s, r0.xy, 0).xyz;
  r0.xyz = blurTexture2.SampleLevel(samLinear_s, r0.zw, 0).xyz;
  
  r0.rgb = LogMap(r0.rgb);
  r1.rgb = LogMap(r1.rgb);
  
  r2.xyzw = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyzw;
  
  r2.rgb = LogMap(r2.rgb);
  
  r3.xyz = float3(1,1,1) + -r2.xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r1.xyz = r1.xyz * r3.xyz + r2.xyz;
  o0.w = r2.w;
  r2.xyz = float3(1,1,1) + -r1.xyz;
  r2.xyz = max(float3(0,0,0), r2.xyz);
  r0.xyz = r0.xyz * r2.xyz + r1.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xyzw = min(uv_clamp1_g.xyzw, v1.xyxy);
  r3.xyz = blurTexture3.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  r2.xyz = blurTexture4.SampleLevel(samLinear_s, r2.zw, 0).xyz;
  
  r3.rgb = LogMap(r3.rgb);
  r2.rgb = LogMap(r2.rgb);
  
  r0.xyz = r3.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyz = r2.xyz * r1.xyz + r0.xyz;
  r1.xyz = float3(1,1,1) + -r0.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r2.xy = min(uv_clamp2_g.xy, v1.xy);
  r2.xyz = blurTexture5.SampleLevel(samLinear_s, r2.xy, 0).xyz;
  
  r2.rgb = LogMap(r2.rgb);
  
  o0.xyz = r2.xyz * r1.xyz + r0.xyz;
  
  o0.rgb = LogMapInv(o0.rgb);
  
  return;
}