// ---- Created with 3Dmigoto v1.3.16 on Sun May 18 12:36:22 2025
#include "./shared.h"

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s5_s : register(s5);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[18];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb0[16].xy * cb0[10].zz + cb0[15].zw;
  r0.xy = v2.xy * cb0[15].xy + r0.xy;
  r0.xyzw = t3.Sample(s4_s, r0.xy).xyzw;
  r0.x = -cb0[14].z + r0.x;
  r0.y = cb0[14].w + -cb0[14].z;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.zw = cb0[14].xy * cb0[10].zz + cb0[13].zw;
  r0.zw = v2.xy * cb0[13].xy + r0.zw;
  r0.xy = r0.yy * r0.xx + r0.zw;
  r0.xyzw = t4.Sample(s3_s, r0.xy).xyzw;
  r0.x = -cb0[12].z + r0.x;
  r0.y = cb0[12].w + -cb0[12].z;
  r0.y = 1 / r0.y;
  r0.x = saturate(r0.x * r0.y);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = cb0[10].xy * cb0[10].zz + cb0[9].zw;
  r0.yz = v2.xy * cb0[9].xy + r0.yz;
  r1.xyzw = t1.Sample(s2_s, r0.yz).xyzw;
  r0.y = -cb0[8].x + r1.x;
  r0.z = cb0[8].y + -cb0[8].x;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r1.xy = cb0[12].xy * cb0[10].zz + cb0[11].zw;
  r1.xy = v2.xy * cb0[11].xy + r1.xy;
  r0.yz = r0.zz * r0.yy + r1.xy;
  r1.xyzw = t2.Sample(s1_s, r0.yz).xyzw;
  r0.y = -cb0[7].z + r1.x;
  r0.zw = cb0[7].wy + -cb0[7].zx;
  r0.zw = float2(1,1) / r0.zw;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * cb0[17].xy + cb0[17].zw;
  r1.xyzw = t5.Sample(s5_s, r0.yz).xyzw;
  r0.y = -cb0[16].z + r1.x;
  r0.z = cb0[16].w + -cb0[16].z;
  r0.z = 1 / r0.z;
  r0.y = saturate(r0.y * r0.z);
  r0.z = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r0.y = r0.z * r0.y;
  r0.x = r0.x * r0.y + -cb0[7].x;
  r0.x = saturate(r0.x * r0.w);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.y * r0.x;
  r0.yz = v2.xy * cb0[6].xy + cb0[6].zw;
  r1.xyzw = t0.Sample(s0_s, r0.yz).xyzw;
  r1.xyzw = v1.xyzw * r1.xyzw;
  o0.w = r1.w * r0.x;
  // o0.xyz = cb0[5].xxx * r1.xyz;
  // o0.xyz = r1.xyz * 1.0;

  int targetNits = shader_injection.graphics_white_nits;
  float coef = pow(targetNits / 100.0, 1.0 / 2.104);
  o0.xyz = r1.xyz * coef;

  // o0.xyz = min(max(o0.xyz, 0.0), 1.5);
  return;
}