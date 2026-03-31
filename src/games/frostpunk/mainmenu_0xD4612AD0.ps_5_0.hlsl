// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:24:14 2025
#include "./shared.h"
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[3];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[14];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(cb1[1].z != 0.000000);
  if (r0.x != 0) {
    o0.xyz = v2.xyz;
    o0.w = 1;
    return;
  }
  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.x = cmp(0 < cb1[1].x);
  if (r1.x != 0) {
    r1.x = -cb1[1].x * 2 + 3;
    r1.y = -1 + cb1[1].x;
    r1.zw = cb0[7].xy * v0.xy;
    r1.zw = r1.zw * cb0[13].ww + cb0[8].xy;
    r1.z = t2.Sample(s2_s, r1.zw).w;
    r1.x = r1.z * r1.x + r1.y;
    r1.y = v2.w * r1.x;
    r1.x = v2.w * r1.x + -0.00100000005;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  } else {
    r1.y = v2.w;
  }
  r1.x = cmp(cb1[1].w == 0.000000);
  if (r1.x != 0) {

    r0.xyz = renodx::color::srgb::DecodeSafe(r0.xyz);
    o0.xyz = v2.xyz * r2.xyz;
    
    o0.w = r2.w * r1.y;
    o0 = r2;
    o0 = r0;
    o0.w = r0.w * r1.y;
    return;
  }
  t0.GetDimensions(0, uiDest.x, uiDest.y, uiDest.z);
  r1.xz = uiDest.xy;
  r1.xz = (uint2)r1.xz;
  r1.xz = v1.xy * r1.xz;
  r2.xy = ddx_coarse(r1.xz);
  r1.xz = ddy_coarse(r1.xz);
  r0.w = min(r0.x, r0.y);
  r0.x = max(r0.x, r0.y);
  r0.x = min(r0.x, r0.z);
  r0.x = max(r0.w, r0.x);
  r0.x = -0.5 + r0.x;
  r3.x = ddx_coarse(r0.x);
  r3.y = ddy_coarse(r0.x);
  r0.y = dot(r3.xy, r3.xy);
  r0.y = sqrt(r0.y);
  r0.z = cmp(0 < r0.y);
  r0.y = 1 / r0.y;
  r0.y = r0.z ? r0.y : 0;
  r0.yz = r3.xy * r0.yy;
  r0.zw = r0.zz * r1.xz;
  r0.yz = r0.yy * r2.xy + r0.zw;
  r0.y = dot(r0.yz, r0.yz);
  r0.y = sqrt(r0.y);
  r0.y = 0.0883883461 * r0.y;
  r0.y = min(0.5, r0.y);
  r0.z = cb1[1].y * 0.0179999992 + r0.y;
  r0.w = r0.y + r0.y;
  r0.y = r0.x + r0.y;
  r0.w = 1 / r0.w;
  r0.y = saturate(r0.y * r0.w);
  r0.w = r0.y * -2 + 3;
  r0.y = r0.y * r0.y;
  r2.y = r0.w * r0.y;
  r0.y = cmp(0 < cb1[1].y);
  r0.x = r0.x + r0.z;
  r0.z = 1 / r0.z;
  r0.x = saturate(r0.x * r0.z);
  r0.z = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  r0.x = r0.z * r0.x;
  r0.x = cb1[2].x * r0.x;
  r0.x = min(1, r0.x);
  r3.xyzw = -cb1[0].xyzw + v2.xyzw;
  r3.xyzw = r2.yyyy * r3.xyzw + cb1[0].xyzw;
  r4.y = max(r2.y, r0.x);
  o0.xyz = r0.yyy ? r3.xyz : v2.xyz;
  r4.x = r3.w;
  r2.x = v2.w;
  r0.xy = r0.yy ? r4.xy : r2.xy;
  r0.y = r0.y * r1.y;
  o0.w = r0.x * r0.y;

  return;
}