// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 03 23:11:56 2025
#include "common.hlsl"
#include "shared.h"
#include "so6utils.hlsl"

float getMidGray(Texture3D<float4> lut_texture,
                 SamplerState lut_sampler,
                 float paper_white) {
  float3 mid = (0.18f, 0.18f, 0.18f);
  float3 lutInputColor = LinearToPQ(mid, paper_white, true);

  float3 lutResult = renodx::lut::Sample(lut_texture,
                                         lut_sampler,
                                         lutInputColor,
                                         32u);
  float3 lutOutputColor_bt2020 = renodx::color::pq::DecodeSafe(lutResult, 1.f);
  lutOutputColor_bt2020 /= paper_white;

  return renodx::color::y::from::BT2020(lutOutputColor_bt2020);
}

cbuffer cb_gp : register(b2)
{
  float4 cvConst_0 : packoffset(c0);
  float4 cvConst_1 : packoffset(c1);
  float4 cvConst_2 : packoffset(c2);
  float4 cvConst_3 : packoffset(c3);
  float4 cvConst_4 : packoffset(c4);
  float4 cvConst_5 : packoffset(c5);
  float4 cvConst_6 : packoffset(c6);
  float4 cvConst_7 : packoffset(c7);
  float4 cvConst_8 : packoffset(c8);
  float4 cvConst_9 : packoffset(c9);
  float4 cvConst_10 : packoffset(c10);
  float4 cvConst_11 : packoffset(c11);
  float4 cvConst_12 : packoffset(c12);
  float4 cvConst_13 : packoffset(c13);
  float4 cvConst_14 : packoffset(c14);
  float4 cvConst_15 : packoffset(c15);
  float4 cvConst_16 : packoffset(c16);
  float4 cvConst_17 : packoffset(c17);
  float4 cvConst_18 : packoffset(c18);
  float4 cvConst_19 : packoffset(c19);
  float4 cvConst_20 : packoffset(c20);
  float4 cvConst_21 : packoffset(c21);
  float4 cvConst_22 : packoffset(c22);
  float4 cvConst_23 : packoffset(c23);
  float4 cvConst_24 : packoffset(c24);
  float4 cvUVOffsetTBR[5] : packoffset(c27);
  float4 cvConst_48 : packoffset(c48);
  float4 cvConst_95 : packoffset(c95);
}

SamplerState asTexSamp_0__s : register(s0);
SamplerState asTexSamp_1__s : register(s1);
SamplerState asTexSamp_2__s : register(s2);
SamplerState asTexSamp_3__s : register(s3);
SamplerState asTexSamp_4__s : register(s4);
SamplerState asTexSamp_7__s : register(s7);
SamplerState asTexSamp_8__s : register(s8);
SamplerState asTexSamp_10__s : register(s10);
Texture2D<float4> asTexObject_0_ : register(t0);
Texture2D<float4> asTexObject_1_ : register(t1);
Texture2D<float4> asTexObject_2_ : register(t2);
Texture3D<float4> asTexObject3D_3_ : register(t3);
Texture2D<float4> asTexObject_4_ : register(t4);
Texture2D<float4> asTexObject_7_ : register(t7);
Texture2D<float4> asTexObject_8_ : register(t8);
Texture2D<float4> asTexObject_10_ : register(t10);


// 3Dmigoto declarations
#define cmp -

float getMidGray(Texture3D<float4> lut_texture,
                 SamplerState lut_sampler,
                 float3 paper_white) {
  float3 lutInputColor = saturate(renodx::color::pq::Encode(0.18f * paper_white, 1.f));

  // renodx::lut::Sample(asTexObject3D_3_, asTexSamp_3__s, r0.xyz, 32u);
  // float3 lutResult = renodx::lut::Sample(asTexObject3D_3_,
  //                                        asTexSamp_3__s,
  //                                        lutInputColor,
  //                                        32u);
  float3 lutResult = renodx::lut::Sample(lut_texture,
                                         lut_sampler,
                                         lutInputColor,
                                         32u);
  float3 lutOutputColor_bt2020 = renodx::color::pq::DecodeSafe(lutResult, 1.f);
  lutOutputColor_bt2020 /= paper_white;

  return renodx::color::y::from::BT2020(lutOutputColor_bt2020);
}

void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  uint v3 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0,
  out float oDepth : SV_DEPTH)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = asTexObject_1_.Sample(asTexSamp_1__s, v1.xy).x;
  r0.x = -cvConst_7.x + r0.x;
  r0.x = saturate(cvConst_7.y * r0.x);
  r0.y = 0;
  r0.x = asTexObject_8_.Sample(asTexSamp_8__s, r0.xy).x;
  r1.xyzw = asTexObject_7_.Sample(asTexSamp_7__s, v1.xy).xyzw;
  r0.x = max(r1.w, r0.x);
  r2.xy = float2(-0.5,-0.5) + v1.yx;
  r2.z = cvConst_3.x * r2.x;
  r0.y = dot(r2.yz, r2.yz);
  r0.y = sqrt(r0.y);
  r0.y = cvConst_3.y * r0.y;
  r0.y = asTexObject_10_.Sample(asTexSamp_10__s, r0.yy).x;
  r2.xyzw = asTexObject_0_.Sample(asTexSamp_0__s, v1.xy).xyzw;
  r3.xyz = r2.xyz * r0.yyy;
  r0.yzw = -r2.xyz * r0.yyy + r1.xyz;
  o0.w = r2.w;
  r0.xyz = r0.xxx * r0.yzw + r3.xyz;
  r1.xyz = asTexObject_4_.Sample(asTexSamp_4__s, v1.xy).xyz;
  r1.xyz = cvConst_1.yyy * r1.xyz;
  r0.xyz = r0.xyz * cvConst_1.xxx + r1.xyz;
  r0.w = 1;
  r1.x = dot(cvConst_8.xyzw, r0.xyzw);
  r1.y = dot(cvConst_9.xyzw, r0.xyzw);
  r1.z = dot(cvConst_10.xyzw, r0.xyzw);
  r0.xyz = max(cvConst_13.zzz, r1.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = saturate(r0.xyz * cvConst_13.xxx + cvConst_13.www);
  // r0.xyz = (r0.xyz * cvConst_13.xxx + cvConst_13.www);

  // untonemapped in PQ
  float white = 203.f;
  float3 untonemapped = PQtoLinear(r0.rgb, white);

  // r0.xyz = asTexObject3D_3_.Sample(asTexSamp_3__s, r0.xyz).xyz;
  // r0.xyz = renodx::lut::Sample(asTexObject3D_3_, asTexSamp_3__s, r0.xyz, 32u);
  r0.xyz = renodx::lut::SampleTetrahedral(asTexObject3D_3_, r0.xyz, 32u);

  if (shader_injection.dithering == 0.f) {
    r1.xyz = asTexObject_2_.Sample(asTexSamp_2__s, v1.zw).xyz;
    r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
    o0.xyz = r1.xyz * cvConst_0.yyy + r0.xyz;
  } else {
    o0.xyz = r0.xyz;
  }

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    // post-LUT output
    float3 graded = PQtoLinear(o0.rgb, white, true);

    float midGray = getMidGray(asTexObject3D_3_, asTexSamp_3__s, white);

    o0.rgb = ToneMapPass(untonemapped, renodx::tonemap::renodrt::NeutralSDR(graded), midGray);
    float color_y = renodx::color::y::from::BT709(o0.rgb);

    // random number for perception
    float bias = 2.4;
    float weight = saturate(pow(color_y, bias));

    // lerp in oklab: keep the sdr colors from SE, and hdr colors from tonemapped
    float3 hdr_graded_oklab = renodx::color::oklab::from::BT709(graded);
    float3 hdr_saturated_oklab = renodx::color::oklab::from::BT709(o0.rgb);
    hdr_graded_oklab = lerp(hdr_graded_oklab, hdr_saturated_oklab, weight);

    o0.rgb = renodx::color::bt709::from::OkLab(hdr_graded_oklab);

    o0.rgb = renodx::color::grade::UserColorGrading(
        o0.rgb,
        RENODX_TONE_MAP_EXPOSURE,
        RENODX_TONE_MAP_HIGHLIGHTS,
        RENODX_TONE_MAP_SHADOWS,
        RENODX_TONE_MAP_CONTRAST,
        RENODX_TONE_MAP_SATURATION,
        RENODX_TONE_MAP_BLOWOUT,
        0.f,
        graded);

    float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
    o0.rgb *= RENODX_DIFFUSE_WHITE_NITS;
    o0.rgb = convertColorSpace(o0.rgb);
    o0.rgb = min(o0.rgb, RENODX_PEAK_WHITE_NITS);

    o0.rgb /= RENODX_DIFFUSE_WHITE_NITS;

    // game has 2.4 gamma correction
    o0.rgb = LinearToPQ(o0.rgb, RENODX_DIFFUSE_WHITE_NITS, true);
  }

  oDepth = 0;
  return;
}