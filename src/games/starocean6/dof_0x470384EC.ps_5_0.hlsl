// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 03 23:11:56 2025
#include "shared.h"
cbuffer _Globals : register(b0)
{
  float4 cavDOF[2] : packoffset(c0);
  float4 cvVig : packoffset(c3);
}

SamplerState s0_samp_s : register(s0);
SamplerState s1_samp_s : register(s1);
SamplerState s3_samp_s : register(s3);
SamplerState s4_samp_s : register(s4);
SamplerState s5_samp_s : register(s5);
Texture2D<float4> s0_tex : register(t0);
Texture2D<float4> s1_tex : register(t1);
Texture2D<float4> s3_tex : register(t3);
Texture2D<float4> s4_tex : register(t4);
Texture2D<float4> s5_tex : register(t5);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (shader_injection.depthoffield == 1.f) {
    r2.xyzw = s0_tex.Sample(s0_samp_s, v1.xy).xyzw;
    o0 = r2;
    return;
  }

  r0.xy = float2(-0.5,-0.5) + v1.yx;
  r0.z = cvVig.x * r0.x;
  r0.x = dot(r0.yz, r0.yz);
  r0.x = sqrt(r0.x);
  r0.x = cvVig.y * r0.x;
  r0.y = 0;
  r0.x = s5_tex.Sample(s5_samp_s, r0.xy).x;
  r0.yzw = s0_tex.Sample(s0_samp_s, v1.xy).xyz;
  r1.xyz = s1_tex.Sample(s1_samp_s, v1.xy).xzw;
  r2.xyzw = v1.zwzw * float4(0.5,1.5,1.5,-0.5) + v1.xyxy;
  r3.xyz = s1_tex.Sample(s1_samp_s, r2.xy).xzw;
  r2.xyz = s1_tex.Sample(s1_samp_s, r2.zw).xzw;
  r1.xzw = r1.zxx * float3(0.25,0.25,0.25) + r3.zxx;
  r1.y = max(r3.y, r1.y);
  r1.y = max(r1.y, r2.y);
  r1.xzw = r1.xzw + r2.zxx;
  r2.xyzw = v1.zwzw * float4(-1.5,0.5,-0.5,-1.5) + v1.xyxy;
  r3.xyz = s1_tex.Sample(s1_samp_s, r2.zw).xzw;
  r2.xyz = s1_tex.Sample(s1_samp_s, r2.xy).xzw;
  r1.xzw = r3.zxx + r1.xzw;
  r1.y = max(r3.y, r1.y);
  r1.y = max(r1.y, r2.y);
  r1.xzw = r1.xzw + r2.zxx;
  r2.xy = r1.zw * float2(-0.0470588244,0.164705887) + float2(0.5,0.5);
  r1.x = 0.235294119 * r1.x;
  r1.zw = r2.xy * cavDOF[0].zw + v1.xy;
  r3.xyz = s0_tex.Sample(s0_samp_s, r1.zw).xyz;
  r0.yzw = r0.yzw * float3(0.5,0.5,0.5) + r3.xyz;
  r2.zw = -r2.xy;
  r3.xyzw = r2.yzwx * cavDOF[0].zwzw + v1.xyxy;
  r1.zw = -r2.xy * cavDOF[0].zw + v1.xy;
  r2.xyz = s0_tex.Sample(s0_samp_s, r1.zw).xyz;
  r4.xyz = s0_tex.Sample(s0_samp_s, r3.xy).xyz;
  r3.xyz = s0_tex.Sample(s0_samp_s, r3.zw).xyz;
  r0.yzw = r4.xyz + r0.yzw;
  r0.yzw = r0.yzw + r2.xyz;
  r0.yzw = r0.yzw + r3.xyz;
  r2.xyz = s3_tex.Sample(s3_samp_s, v1.xy).xyz;
  r2.xyz = -r0.yzw * float3(0.222222224,0.222222224,0.222222224) + r2.xyz;
  r0.yzw = float3(0.222222224,0.222222224,0.222222224) * r0.yzw;
  r0.yzw = r1.xxx * r2.xyz + r0.yzw;
  r2.xyzw = s4_tex.Sample(s4_samp_s, v1.xy).xyzw;
  r1.xzw = r2.xyz + -r0.yzw;
  r0.yzw = r2.www * r1.xzw + r0.yzw;
  o0.w = max(r2.w, r1.y);
  o0.xyz = r0.yzw * r0.xxx;
  return;
}