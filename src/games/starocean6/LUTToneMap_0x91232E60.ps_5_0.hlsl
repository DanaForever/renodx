// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 03 16:56:57 2025
#include "shared.h"
#include "common.hlsl"
#include "so6utils.hlsl"
#include "colorcorrection.hlsl"


float getMidGray(Texture3D<float4> lut_texture,
                 SamplerState lut_sampler,
                 float paper_white) {
  float3 mid = 0.18f;
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
SamplerState asTexSamp_2__s : register(s2);
SamplerState asTexSamp_3__s : register(s3);
SamplerState asTexSamp_4__s : register(s4);
SamplerState asTexSamp_10__s : register(s10);
Texture2D<float4> asTexObject_0_ : register(t0);
Texture2D<float4> asTexObject_2_ : register(t2);
Texture3D<float4> asTexObject3D_3_ : register(t3);
Texture2D<float4> asTexObject_4_ : register(t4);
Texture2D<float4> asTexObject_10_ : register(t10);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  uint v3 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0,
  out float oDepth : SV_DEPTH)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  // vignette sampling

  if (shader_injection.vignette == 0.f) {
    r0.xy = float2(-0.5,-0.5) + v1.yx;
    r0.z = cvConst_3.x * r0.x;
    r0.x = dot(r0.yz, r0.yz);
    r0.x = sqrt(r0.x);
    r0.x = cvConst_3.y * r0.x;
    r0.x = asTexObject_10_.Sample(asTexSamp_10__s, r0.xx).x;  // sample vignette (x = red channel)
  }

  r0.yzw = asTexObject_4_.Sample(asTexSamp_4__s, v1.xy).xyz;  // bloom?
  r0.yzw = cvConst_1.yyy * r0.yzw;  // weighting = 0.2 (this scene), too high = too bright
  r1.xyzw = asTexObject_0_.Sample(asTexSamp_0__s, v1.xy).xyzw; // rendered frame
  
  r0.yzw = r1.xyz * cvConst_1.xxx + r0.yzw; // blend bloom/dof/blur into main image

  o0.w = r1.w;
  if (shader_injection.vignette == 0.f) 
    r0.xyz = r0.yzw * r0.xxx; // vignette
  else
    r0.xyz = r0.yzw; // no vignette
  r0.w = 1;

  // point 1: after vignetting: SUPER BRIGHT picture, definitely not PQ or linear

  // cvConst_8 0.12325, 0.01882, 0.00455, 0.19141 128 float4
  r1.x = dot(cvConst_8.xyzw, r0.xyzw);
  // cvConst_9 0.00857, 0.14715, 0.00455, 0.19141 144 float4
  r1.y = dot(cvConst_9.xyzw, r0.xyzw);
  // cvConst_10 0.00857, 0.01882, 0.1637, 0.19141 160 float4
  r1.z = dot(cvConst_10.xyzw, r0.xyzw);

  // point 2: look like PQ image (display-able on HDR10, but very lifted black)

  // cvConst_13 0.21756, 0.00, 0.19141, 0.53458 208 float4
  r0.xyz = max(cvConst_13.zzz, r1.xyz);
  // r0.xyz = r1.xyz;
  r0.xyz = log2(r0.xyz);
  r0.xyz = (r0.xyz * cvConst_13.xxx + cvConst_13.www);

  // point 3: PQ image (looks similar to the final output, lifted black a bit, about 0.05)

  // untonemapped in PQ
  float white = 203.f;

  float3 untonemapped = PQtoLinear(r0.xyz,  white, true);
// 
  // r0.xyz = asTexObject3D_3_.Sample(asTexSamp_3__s, r0.xyz).xyz; // LUT sampling in PQ
  // r0.xyz = renodx::lut::Sample(asTexObject3D_3_, asTexSamp_3__s, r0.xyz, 32u);
  r0.xyz = renodx::lut::SampleTetrahedral(asTexObject3D_3_, r0.xyz, 32u);
  float3 pq_graded = r0.xyz;

  if (shader_injection.dithering == 0.f) {
    r1.xyz = asTexObject_2_.Sample(asTexSamp_2__s, v1.zw).xyz; // dithering? 
    r1.xyz = r1.xyz * float3(2,2,2) + float3(-1,-1,-1);
    o0.xyz = r1.xyz * cvConst_0.yyy + r0.xyz;
  } else {
    o0.xyz = r0.xyz;
  } 
   
  // point 4: tonemapped to display (SE's display, not mine). Looks plausible but lots of highlights being compressed

  if (RENODX_TONE_MAP_TYPE > 0.f) {
    // post-LUT output
    float3 graded = PQtoLinear(o0.rgb, white, true);

    float midGray = getMidGray(asTexObject3D_3_, asTexSamp_3__s, white);
    float3 graded_tonemapped = ToneMap(graded);
    o0.rgb = ToneMapPass(untonemapped, 
      graded,
      midGray);

    float color_y = renodx::color::y::from::BT709(o0.rgb);
    float graded_y = renodx::color::y::from::BT709(graded_tonemapped);

    // // random number for perception
    // float bias = 2.4;
    // float weight = saturate(pow(color_y, bias));

    // Compute t: more saturated if sat is bright and unsat is dark
    float t = saturate((graded_y - color_y) / max(graded_y, 1e-5));

    float ratio = color_y / (graded_y + 1e-5);
    t = 1 - saturate(ratio);
    t = 1 - saturate(color_y);

    // Optional: boost t when Y_sat is significantly > SDR
    // float t_boost = smoothstep(1.0, RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS, color_y);  // ramp from SDR to HDR
    // t *= t_boost;

    // lerp in oklab: keep the sdr colors from SE, and hdr colors from tonemapped
    // float3 hdr_graded_oklab = renodx::color::oklab::from::BT709(graded_tonemapped);
    // float3 hdr_saturated_oklab = renodx::color::oklab::from::BT709(o0.rgb);
    // hdr_graded_oklab = lerp(hdr_graded_oklab, hdr_saturated_oklab, weight);

    // o0.rgb = renodx::color::bt709::from::OkLab(hdr_graded_oklab);

    o0.rgb = lerp(o0.rgb, graded_tonemapped, t);

    // o0.rgb = graded;

    // o0.rgb = renodx::color::grade::UserColorGrading(
    //     o0.rgb,
    //     RENODX_TONE_MAP_EXPOSURE,
    //     RENODX_TONE_MAP_HIGHLIGHTS,
    //     RENODX_TONE_MAP_SHADOWS,
    //     RENODX_TONE_MAP_CONTRAST,
    //     RENODX_TONE_MAP_SATURATION,
    //     RENODX_TONE_MAP_BLOWOUT,
    //     0.f,
    //     graded);

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