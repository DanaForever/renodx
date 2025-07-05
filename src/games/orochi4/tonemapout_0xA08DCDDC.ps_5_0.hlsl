// ---- Created with 3Dmigoto v1.3.16 on Wed May 14 11:39:13 2025
#include "./common.hlsl"
#include "./shared.h"
#include "./rcas.hlsl"

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[7];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = v2.xyzw * cb0[0].zwzw + cb0[0].xyxy;
  r1.xyz = t2.Sample(s2_s, r0.xy).xyz;
  r0.xyz = t2.Sample(s2_s, r0.zw).xyz;

  // r1.xyz = ApplyRCAS(r1.xyz, r0.xy, t2, s2_s);
  // r0.xyz = ApplyRCAS(r0.xyz, r0.zw, t2, s2_s);
  
  r0.xyz = max(float3(0,0,0), r0.xyz);
  // r0.w = dot(r0.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.w = dot(r0.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r1.xyz = max(float3(0,0,0), r1.xyz);
  // r0.z = dot(r1.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.z = dot(r1.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r1.xyzw = v3.xyzw * cb0[0].zwzw + cb0[0].xyxy;
  r2.xyz = t2.Sample(s2_s, r1.xy).xyz;
  r1.xyz = t2.Sample(s2_s, r1.zw).xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  // r0.x = dot(r1.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.x = dot(r1.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r1.xyz = max(float3(0,0,0), r2.xyz);
  // r0.y = dot(r1.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.y = dot(r1.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r1.xyzw = r0.yzzw + r0.xwyx;
  r1.xy = r1.xz + -r1.yw;
  r1.z = min(abs(r1.x), abs(r1.y));
  r1.z = r1.z * cb0[1].x + 0.00100000005;
  r1.zw = r1.xy / r1.zz;
  r2.xy = cb0[2].zw * r1.xy;
  r1.xy = max(-cb0[1].yy, r1.zw);
  r1.xy = min(cb0[1].yy, r1.xy);
  r1.zw = cb0[2].xy * cb0[1].yy;
  r2.zw = r1.xy * r1.zw;
  r1.xyzw = v1.xyxy * cb0[0].zwzw + cb0[0].xyxy;
  r3.xyzw = r1.zwzw + -r2.xyzw;
  r2.xyzw = r1.xyzw + r2.xyzw;
  r1.xyzw = t2.Sample(s2_s, r1.zw).xyzw;
  r4.xyz = t2.Sample(s2_s, r3.zw).xyz;
  r3.xyz = t2.Sample(s2_s, r3.xy).xyz;
  r3.xyz = max(float3(0,0,0), r3.xyz);
  r4.xyz = max(float3(0,0,0), r4.xyz);
  r5.xyz = t2.Sample(s2_s, r2.zw).xyz;
  r2.xyz = t2.Sample(s2_s, r2.xy).xyz;

  r2.xyz = max(float3(0,0,0), r2.xyz);
  r2.xyz = r3.xyz + r2.xyz;
  r3.xyz = max(float3(0,0,0), r5.xyz);
  r3.xyz = r4.xyz + r3.xyz;
  r3.xyz = float3(0.25,0.25,0.25) * r3.xyz;
  r3.xyz = r2.xyz * float3(0.25,0.25,0.25) + r3.xyz;
  r2.xyz = float3(0.5,0.5,0.5) * r2.xyz;
  // r2.w = dot(r3.xyz, float3(0.298999995, 0.587000012, 0.114));
  r2.w = dot(r3.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r4.xy = min(r0.zy, r0.wx);
  r0.xy = max(r0.zy, r0.wx);
  r0.x = max(r0.x, r0.y);
  r0.y = min(r4.x, r4.y);
  r4.xyz = max(float3(0,0,0), r1.xyz);
  // r0.z = dot(r4.xyz, float3(0.298999995, 0.587000012, 0.114));
  r0.z = dot(r4.xyz, float3(0.2126390059f, 0.7151686788f, 0.0721923154f));
  r0.y = min(r0.z, r0.y);
  r0.x = max(r0.z, r0.x);
  r0.x = cmp(r0.x < r2.w);
  r0.y = cmp(r2.w < r0.y);
  r0.x = (int)r0.x | (int)r0.y;
  r0.xyz = r0.xxx ? r2.xyz : r3.xyz;

  r1.xyz = cb0[3].xxx * r0.xyz;
  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;

  r2.x = cb0[3].y / cb0[3].z;
  r0.xyzw = r2.xxxx * r0.xyzw;
  r0.xyzw = r0.xyzw * float4(0.5,0.5,0.5,0.5) + r1.xyzw;
  r1.xyzw = t1.Sample(s1_s, v1.xy).xyzw;
  r0.xyzw = r1.xyzw * cb0[3].wwww + r0.xyzw;

  r0.xyz = cb0[4].xyz * r0.xyz;
  o0.w = r0.w;
  
  float3 untonemapped = r0.xyz;
  r0.xyz = RestoreHighlightSaturation(untonemapped);

  r1.xyz = cb0[4].www * r0.xyz + cb0[5].xxx;
  r1.xyz = r0.xyz * r1.xyz + cb0[5].yyy;
  r2.xyz = cb0[4].www * r0.xyz + cb0[5].zzz;
  r0.xyz = r0.xyz * r2.xyz + cb0[5].www;
  r0.xyz = r1.xyz / r0.xyz;
  r0.xyz = -cb0[6].xxx + r0.xyz;
  r0.xyz = cb0[6].yyy * r0.xyz;
  
  // gamma slider
  // r0.xyz = renodx::math::SignPow(r0.xyz, cb0[6].z);

  if (shader_injection.tone_map_type == 0.f) {
    // Gamma Encoding for SDR
    r0.xyz = renodx::math::SignPow(r0.xyz, cb0[6].z);
    o0.xyz = r0.xyz;
  } else {
    float3 sdr = r0.xyz;
    // tonemap (0.18) to find mid gray
    r0.xyz = float3(0.18f, 0.18f, 0.18f);
    r1.xyz = cb0[4].www * r0.xyz + cb0[5].xxx;
    r1.xyz = r0.xyz * r1.xyz + cb0[5].yyy;
    r2.xyz = cb0[4].www * r0.xyz + cb0[5].zzz;
    r0.xyz = r0.xyz * r2.xyz + cb0[5].www;
    r0.xyz = r1.xyz / r0.xyz;
    r0.xyz = -cb0[6].xxx + r0.xyz;
    r0.xyz = cb0[6].yyy * r0.xyz;

    float mid_gray = renodx::color::y::from::BT709(r0.xyz);
    // untonemapped *= mid_gray / 0.18f;

    // o0.rgb = renodx::draw::ToneMapPass(untonemapped, sdr);
    
    // untonemapped *= mid_gray / 0.18f;

    o0.rgb = CustomToneMapPass(untonemapped, sdr, mid_gray);
    // o0.rgb = CustomToneMapPass(untonemapped, sdr, mid_gray);

    // float3 tonemapped_bt709;
    // float3 ungraded_bt709 = untonemapped;
    // // float3 graded_untonemapped_bt709 = UpgradeToneMapByLuminance(ungraded_bt709,
    // //                                                              renodx::tonemap::renodrt::NeutralSDR(untonemapped),
    // //                                                             sdr, 1.f);

    // // float3 graded_untonemapped_bt709 = UpgradeToneMapPerChannel(ungraded_bt709,
    // //                                                              renodx::tonemap::renodrt::NeutralSDR(untonemapped),
    // //                                                              sdr, 1.f);

    // tonemapped_bt709 = CustomToneMapPass(untonemapped, sdr, mid_gray);
    // // tonemapped_bt709 = ToneMap(graded_untonemapped_bt709);
    // o0.rgb = tonemapped_bt709; 
    o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);
    

  }

  o0.rgb = renodx::draw::RenderIntermediatePass(o0.rgb);

  return;
}