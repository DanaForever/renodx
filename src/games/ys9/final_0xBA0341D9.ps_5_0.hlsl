// ---- Created with 3Dmigoto v1.3.16 on Sun Jul 06 23:10:35 2025
#include "shared.h"
#include "common.hlsl"
cbuffer CGamma : register(b1)
{
  float fGamma : packoffset(c0);
}

cbuffer CB2 : register(b2)
{
  int colorTableIndex : packoffset(c0);
}

SamplerState samp_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 x0[12];
  x0[0].xyz = float3(1,0,0);
  x0[1].xyz = float3(0,1,0);
  x0[2].xyz = float3(0,0,1);
  x0[3].xyz = float3(0,2.02343988,-2.52581);
  x0[4].xyz = float3(0,1,0);
  x0[5].xyz = float3(0,0,1);
  x0[6].xyz = float3(1,0,0);
  x0[7].xyz = float3(0.494210005,0,1.24827003);
  x0[8].xyz = float3(0,0,1);
  x0[9].xyz = float3(1,0,0);
  x0[10].xyz = float3(0,1,0);
  x0[11].xyz = float3(-0.395909995,0.801110029,0);
  r0.xyz = tex.Sample(samp_s, v0.xy).yzx;
  if (colorTableIndex != 0) {
    // RGB -> XYZ
    r1.x = dot(r0.zxy, float3(17.8824005,43.5161018,4.11934996));
    r1.y = dot(r0.zxy, float3(3.45565009,27.1553993,3.86714005));
    r1.z = dot(r0.zxy, float3(0.0299565997, 0.184309006, 1.46709001));

    r0.w = colorTableIndex * 3;
    r2.xyz = x0[r0.w+0].xyz;
    r1.w = dot(r2.xyz, r1.xyz);
    r2.xyz = x0[r0.w+1].xyz;
    r2.x = dot(r2.xyz, r1.xyz);
    r2.yzw = x0[r0.w+2].xyz;
    r0.w = dot(r2.yzw, r1.xyz);
    r1.xyz = float3(-0.130504414,0.0540193282,-0.00412161462) * r2.xxx;
    r1.xyz = r1.www * float3(0.0809444487,-0.0102485335,-0.000365296932) + r1.xyz;
    r1.xyz = r0.www * float3(0.116721064,-0.113614708,0.693511426) + r1.xyz;
    r1.xyz = -r1.xyz + r0.zxy;
    r1.xy = r1.xx * float2(0.699999988,0.699999988) + r1.yz;
    r0.xy = r1.xy + r0.xy;
  }
  // r1.x = log2(r0.z);
  // r1.yz = log2(r0.xy);
  // r0.xyz = fGamma * r1.xyz;
  // o0.xyz = exp2(r0.xyz);
  o0.xyz = renodx::math::SafePow(r0.zxy, fGamma);

  // if (shader_injection.hdr_format == 0.f)
  //   o0.rgb = renodx::color::bt2020::from::BT709(o0.rgb);
  // o0.rgb = renodx::color::bt709::from::BT2020(o0.rgb);
  // o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);
  // o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);
  // o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  

  o0.w = 1;
  return;
}