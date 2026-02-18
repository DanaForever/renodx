// ---- Created with 3Dmigoto v1.3.16 on Wed Feb 18 12:37:35 2026
#include "output.hlsli"

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[15];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[160];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[39];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = asuint(cb0[37].xy);
  r0.xy = v0.xy + -r0.xy;
  r0.zw = cb0[38].zw * r0.xy;
  r0.zw = r0.zw * cb0[5].xy + cb0[4].xy;
  r1.xyz = t0.Sample(s0_s, r0.zw).xyz;
  r0.xy = r0.xy * cb0[38].zw + float2(-0.5,-0.5);
  r0.z = dot(r0.xy, cb2[3].xy);
  r0.z = cb2[11].y + r0.z;
  r0.z = saturate(0.5 + r0.z);
  r0.w = cmp(0 >= r0.z);
  r0.z = log2(r0.z);
  r0.z = cb2[11].z * r0.z;
  r0.z = exp2(r0.z);
  r1.w = 1 + -cb1[159].w;
  r0.z = r1.w * r0.z;
  r0.z = r0.w ? 0 : r0.z;
  r0.w = cmp(cb2[12].x == 0.000000);
  if (r0.w != 0) {
    r2.xyz = r1.xyz;
  }
  r2.w = cmp(cb2[11].w == 0.000000);
  if (r2.w != 0) {
    r3.xyz = cb2[4].xyz * r0.zzz + r1.xyz;
  } else {
    r4.xyz = r1.xyz * cb2[4].xyz + -r1.xyz;
    r4.xyz = r0.zzz * r4.xyz + r1.xyz;
    r5.xy = cmp(cb2[11].ww == float2(1,2));
    r1.xyz = float3(1,1,1) + -r1.xyz;
    r6.xyz = -cb2[4].xyz * r0.zzz + float3(1,1,1);
    r1.xyz = -r1.xyz * r6.xyz + float3(1,1,1);
    r1.xyz = r5.yyy ? r1.xyz : 0;
    r3.xyz = r5.xxx ? r4.xyz : r1.xyz;
  }
  r1.xyz = r0.www ? r2.xyz : r3.xyz;
  r0.x = dot(r0.xy, cb2[7].xy);
  r0.x = cb2[13].z + r0.x;
  r0.x = saturate(0.5 + r0.x);
  r0.y = cmp(0 >= r0.x);
  r0.x = log2(r0.x);
  r0.x = cb2[13].w * r0.x;
  r0.x = exp2(r0.x);
  r0.x = r0.x * r1.w;
  r0.x = r0.y ? 0 : r0.x;
  r0.yz = cmp(cb2[14].yx == float2(0,0));
  if (r0.y != 0) {
    r2.xyz = r1.xyz;
  }
  if (r0.z != 0) {
    r3.xyz = cb2[8].xyz * r0.xxx + r1.xyz;
  } else {
    r4.xyz = r1.xyz * cb2[8].xyz + -r1.xyz;
    r4.xyz = r0.xxx * r4.xyz + r1.xyz;
    r0.zw = cmp(cb2[14].xx == float2(1,2));
    r1.xyz = float3(1,1,1) + -r1.xyz;
    r5.xyz = -cb2[8].xyz * r0.xxx + float3(1,1,1);
    r1.xyz = -r1.xyz * r5.xyz + float3(1,1,1);
    r1.xyz = r0.www ? r1.xyz : 0;
    r3.xyz = r0.zzz ? r4.xyz : r1.xyz;
  }
  r0.xyz = r0.yyy ? r2.xyz : r3.xyz;
  r1.xyz = cb2[9].xyz + -r0.xyz;
  r0.xyz = cb2[14].zzz * r1.xyz + r0.xyz;
  o0.xyz = max(float3(0,0,0), r0.xyz);

  // o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
  // o0.rgb *= 203 / 80.f;
  o0.w = 1;
  return;
}