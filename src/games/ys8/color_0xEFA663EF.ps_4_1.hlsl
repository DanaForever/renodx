// ---- Created with 3Dmigoto v1.3.16 on Sun May 25 17:37:38 2025
#include "shared.h"
#include "common.hlsl"


cbuffer CB0 : register(b0)
{
  float4 fparam : packoffset(c0);
  float4 fparam2 : packoffset(c1);
  float4 fparam3 : packoffset(c2);
}

SamplerState tex_samp_s : register(s0);
SamplerState gradtex_samp_s : register(s1);
SamplerState darktex_samp_s : register(s2);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> gradtex_tex : register(t1);
Texture2D<float4> darktex_tex : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float2 v1 : TEXCOORD1,
  float4 v2 : COLOR0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex_tex.Sample(tex_samp_s, v0.xy).xyz;
  r1.xyz = gradtex_tex.Sample(gradtex_samp_s, v0.zw).xyz;
  r2.xyz = r1.xyz + r0.xyz;
  r0.xyz = -r0.xyz * r1.xyz + r2.xyz;
  r1.xyz = v2.xyz * r0.xyz;
  r2.xyz = r1.xyz * r1.xyz;
  r2.xyz = r2.xyz + r2.xyz;
  r3.xyz = r1.xyz * float3(4,4,4) + -r2.xyz;
  r3.xyz = float3(-1,-1,-1) + r3.xyz;
  r4.xyz = cmp(float3(0.5,0.5,0.5) < r1.xyz);
  r2.xyz = r4.xyz ? r3.xyz : r2.xyz;
  r0.xyz = -r0.xyz * v2.xyz + r2.xyz;

  r0.xyz = fparam.xxx * r0.xyz + r1.xyz;

  r0.w = cmp(0 < fparam.y);
  if (r0.w != 0) {
    r1.xyzw = darktex_tex.Sample(darktex_samp_s, v1.xy).xyzw;
    r0.w = fparam.y * r1.w;
    r1.xyz = r1.xyz + -r0.xyz;
    r0.xyz = r0.www * r1.xyz + r0.xyz;
  }
  r0.w = cmp(0 < fparam3.w);
  r1.xy = float2(-0.5,-0.5) + v1.xy;
  r1.xy = fparam3.ww * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.xy = r1.xy * r1.xy;
  r1.x = max(r1.x, r1.y);
  // BT601 transformation 
  r1.y = dot(r0.xyz, float3(0.298911989,0.586610973,0.114478));
  r1.z = fparam3.w * 0.349999994;
  r2.xyz = r1.yyy + -r0.xyz;
  r1.yzw = r1.zzz * r2.xyz + r0.xyz;
  r2.xyz = fparam3.xyz + -r1.yzw;
  r1.xyz = r1.xxx * r2.xyz + r1.yzw;
  o0.xyz = r0.www ? r1.xyz : r0.xyz;
  o0.w = 1;

  // ToneMapPass here?
  if (RENODX_TONE_MAP_TYPE > 0.f) {
    o0.rgb = renodx::color::gamma::Decode(o0.rgb, 2.2);
    o0.rgb = ToneMap(o0.rgb);
  }

  o0.rgb = renodx::draw::RenderIntermediatePass(o0.rgb);
  
  o0.w = 1;

  return;
}