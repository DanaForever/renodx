#include "./common.hlsl"
#include "shared.h"
Texture2D<float4> t7 : register(t7);
Texture2D<float4> t6 : register(t6);
Texture2D<float4> t5 : register(t5);
Texture2D<float4> t4 : register(t4);
Texture2D<float4> t3 : register(t3);
Texture2D<float4> t2 : register(t2);
Texture2D<float4> t1 : register(t1);
Texture2D<float4> t0 : register(t0);
SamplerState s0_s : register(s0);
cbuffer cb0 : register(b0){
  float4 cb0[144];
}

#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  // static const ParamsLogC LogC =
  //     {
  //       0.011361,  // cut
  //       5.555556,  // a
  //       0.047996,  // b
  //       0.244161,  // c
  //       0.386036,  // d
  //       5.301883,  // e
  //       0.092819   // f
  //     };

  //  GetLutStripValue
  r0.yz = -cb0[128].yz + v1.xy;
  r1.x = cb0[128].x * r0.y;
  r0.x = frac(r1.x);
  r1.x = r0.x / cb0[128].x;
  r0.w = -r1.x + r0.y;
  r0.xyz = cb0[128].www * r0.xzw;

  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    r0.xyz = lutShaper(r0.xyz, true);
  }

  // RGB to LMS
  r1.x = dot(float3(0.390404999,0.549941003,0.00892631989), r0.xyz);
  r1.y = dot(float3(0.070841603,0.963172019,0.00135775004), r0.xyz);
  r1.z = dot(float3(0.0231081992,0.128021002,0.936245024), r0.xyz);

  // _ColorBalance
  r0.xyz = cb0[129].xyz * r1.xyz;

  // LMSToLinear
  r1.x = dot(float3(2.85846996,-1.62879002,-0.0248910002), r0.xyz);
  r1.y = dot(float3(-0.210181996,1.15820003,0.000324280991), r0.xyz);
  r1.z = dot(float3(-0.0418119989,-0.118169002,1.06867003), r0.xyz);

  // LogC.a * x + LogC.b
  r0.xyz = r1.xyz * float3(5.55555582,5.55555582,5.55555582) + float3(0.0479959995,0.0479959995,0.0479959995);

  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = r0.xyz * float3(0.0734997839,0.0734997839,0.0734997839) + float3(-0.0275523961,-0.0275523961,-0.0275523961);
  r0.xyz = r0.xyz * cb0[134].zzz + float3(0.0275523961, 0.0275523961, 0.0275523961);  // Contrast scaling?
  r0.xyz = float3(13.6054821, 13.6054821, 13.6054821) * r0.xyz;
  r0.xyz = exp2(r0.xyz);  // Rescale to linear again
  r0.xyz = float3(-0.0479959995, -0.0479959995, -0.0479959995) + r0.xyz;
  r0.xyz = float3(0.179999992, 0.179999992, 0.179999992) * r0.xyz;  // middle gray

  r0.xyz = cb0[130].xyz * r0.xyz;  // Color filter is just an unclipped multiplier

  // r0.xyz = max(float3(0, 0, 0), r0.xyz);
  float3 signs = sign(r0.xyz);
  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    r0.xyz = max(float3(0, 0, 0), r0.xyz);
  } else {
    r0.xyz = abs(r0.xyz);
  }

  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454545468, 0.454545468, 0.454545468) * r0.xyz;
  r0.xyz = exp2(r0.xyz);

  // Split toning
  r1.xyz = r0.xyz + r0.xyz;
  r2.xyz = r0.xyz * r0.xyz;
  r3.xyz = min(float3(1,1,1), r0.xyz);
  r0.xyz = sqrt(r0.xyz);

  // get luminance?
  r0.w = dot(r3.xyz, float3(0.212672904,0.715152204,0.0721750036));
  r0.w = saturate(cb0[142].w + r0.w);
  r1.w = 1 + -r0.w;
  r3.xyz = float3(-0.5,-0.5,-0.5) + cb0[142].xyz;
  r3.xyz = r1.www * r3.xyz + float3(0.5,0.5,0.5);
  r4.xyz = -r3.xyz * float3(2,2,2) + float3(1,1,1);
  r2.xyz = r4.xyz * r2.xyz;
  r2.xyz = r1.xyz * r3.xyz + r2.xyz;
  r4.xyz = cmp(r3.xyz >= float3(0.5,0.5,0.5));
  r5.xyz = r4.xyz ? float3(0,0,0) : float3(1,1,1);
  r4.xyz = r4.xyz ? float3(1,1,1) : 0;
  r2.xyz = r5.xyz * r2.xyz;
  r5.xyz = float3(1,1,1) + -r3.xyz;
  r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyz = r5.xyz * r1.xyz;
  r0.xyz = r0.xyz * r3.xyz + r1.xyz;
  r0.xyz = r0.xyz * r4.xyz + r2.xyz;
  r1.xyz = r0.xyz + r0.xyz;
  r2.xyz = r0.xyz * r0.xyz;
  r0.xyz = sqrt(r0.xyz);
  r3.xyz = float3(-0.5,-0.5,-0.5) + cb0[143].xyz;
  r3.xyz = r0.www * r3.xyz + float3(0.5,0.5,0.5);
  r4.xyz = -r3.xyz * float3(2,2,2) + float3(1,1,1);
  r2.xyz = r4.xyz * r2.xyz;
  r2.xyz = r1.xyz * r3.xyz + r2.xyz;

  // lerp
  r4.xyz = cmp(r3.xyz >= float3(0.5,0.5,0.5));
  r5.xyz = r4.xyz ? float3(0,0,0) : float3(1,1,1);
  r4.xyz = r4.xyz ? float3(1,1,1) : 0;
  r2.xyz = r5.xyz * r2.xyz;
  r5.xyz = float3(1,1,1) + -r3.xyz;
  r3.xyz = r3.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyz = r5.xyz * r1.xyz;
  r0.xyz = r0.xyz * r3.xyz + r1.xyz;
  r0.xyz = r0.xyz * r4.xyz + r2.xyz;

  // 2.2 Decoding
  // r0.xyz = max(float3(0, 0, 0), r0.xyz);
  r0.xyz = renodx::color::gamma::Decode((r0.xyz), 2.2f);
  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    r0.xyz *= signs;
  }

  // Channel mixing (Adobe style)
  r1.x = dot(r0.xyz, cb0[131].xyz);
  r1.y = dot(r0.xyz, cb0[132].xyz);
  r1.z = dot(r0.xyz, cb0[133].xyz);

  // Shadows, midtones, highlights
  r0.xyz = cb0[139].xyz * r1.xyz;
  r0.w = dot(r1.xyz, float3(0.212672904,0.715152204,0.0721750036));
  r2.xy = -cb0[141].xz + r0.ww;
  r2.zw = cb0[141].yw + -cb0[141].xz;
  r2.zw = float2(1,1) / r2.zw;
  r2.xy = saturate(r2.xy * r2.zw);
  r2.zw = r2.xy * float2(-2,-2) + float2(3,3);
  r2.xy = r2.xy * r2.xy;
  r0.w = -r2.z * r2.x + 1;
  r1.w = 1 + -r0.w;
  r1.w = -r2.w * r2.y + r1.w;
  r2.x = r2.w * r2.y;
  r0.xyz = r1.www * r0.xyz;
  r2.yzw = cb0[138].xyz * r1.xyz;
  r1.xyz = cb0[140].xyz * r1.xyz;
  r0.xyz = r2.yzw * r0.www + r0.xyz;
  r0.xyz = r1.xyz * r2.xxx + r0.xyz;

  // Lift, gamma, gain
  r0.xyz = r0.xyz * cb0[137].xyz + cb0[135].xyz; // * gain + lift
  r1.xyz = cmp(float3(0,0,0) < r0.xyz); // sign mask
  r2.xyz = cmp(r0.xyz < float3(0,0,0)); // sign mask
  r0.xyz = log2(abs(r0.xyz));
  r0.xyz = cb0[136].xyz * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r1.xyz = (int3)-r1.xyz + (int3)r2.xyz;
  r1.xyz = (int3)r1.xyz;
  r2.xyz = r1.xyz * r0.xyz;

  // HSV operations
  r3.xy = r2.zy;
  r0.xy = r1.yz * r0.yz + -r3.xy;
  r1.x = cmp(r3.y >= r2.z);
  r1.x = r1.x ? 1.000000 : 0;
  r3.zw = float2(-1,0.666666687);
  r0.zw = float2(1,-1);
  r0.xyzw = r1.xxxx * r0.xywz + r3.xywz;
  r1.x = cmp(r2.x >= r0.x);
  r1.x = r1.x ? 1.000000 : 0;
  r3.z = r0.w;
  r0.w = r2.x;
  r2.x = dot(r2.xyz, float3(0.212672904,0.715152204,0.0721750036));
  r3.xyw = r0.wyx;
  r3.xyzw = r3.xyzw + -r0.xyzw;
  r0.xyzw = r1.xxxx * r3.xyzw + r0.xyzw;
  r1.x = min(r0.w, r0.y);
  r1.x = -r1.x + r0.x;
  r1.y = r1.x * 6 + 9.99999975e-05;
  r0.y = r0.w + -r0.y;
  r0.y = r0.y / r1.y;
  r0.y = r0.z + r0.y;
  r3.x = abs(r0.y);
  r2.z = cb0[134].x + r3.x;
  r2.yw = float2(0,0);
  r4.xyzw = t4.SampleBias(s0_s, r2.zw, cb0[19].x).xyzw;
  r5.xyzw = t7.SampleBias(s0_s, r2.xy, cb0[19].x).xyzw;
  r5.x = saturate(r5.x);
  r0.y = r5.x + r5.x;
  r4.x = saturate(r4.x);
  r0.z = -0.5 + r4.x;
  r0.z = r2.z + r0.z;
  r0.w = cmp(1 < r0.z);
  r1.yz = float2(1,-1) + r0.zz;
  r0.w = r0.w ? r1.z : r0.z;
  r0.z = cmp(r0.z < 0);
  r0.z = r0.z ? r1.y : r0.w;
  r1.yzw = float3(1,0.666666687,0.333333343) + r0.zzz;
  r1.yzw = frac(r1.yzw);
  r1.yzw = r1.yzw * float3(6,6,6) + float3(-3,-3,-3);
  r1.yzw = saturate(float3(-1,-1,-1) + abs(r1.yzw));
  r1.yzw = float3(-1,-1,-1) + r1.yzw;
  r0.z = 9.99999975e-05 + r0.x;
  r3.z = r1.x / r0.z;
  r1.xyz = r3.zzz * r1.yzw + float3(1,1,1);
  r2.xyz = r1.xyz * r0.xxx;
  r0.z = dot(r2.xyz, float3(0.212672904,0.715152204,0.0721750036));
  r1.xyz = r0.xxx * r1.xyz + -r0.zzz;
  r3.yw = float2(0,0);
  r2.xyzw = t5.SampleBias(s0_s, r3.xy, cb0[19].x).xyzw;
  r3.xyzw = t6.SampleBias(s0_s, r3.zw, cb0[19].x).xyzw;
  r3.x = saturate(r3.x);
  r2.x = saturate(r2.x);
  r0.x = r2.x + r2.x;
  r0.x = dot(r3.xx, r0.xx);
  r0.x = r0.x * r0.y;
  r0.x = cb0[134].y * r0.x;
  r0.xyz = r0.xxx * r1.xyz + r0.zzz;

  float3 untonemapped_bt709 = r0.xyz;
  float mpc = max(r0.a, max(r0.b, r0.g));

  float3 sdr_color = r0.xyz;

  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    if (shader_injection.tone_map_neutral == 0.f) {
      float3 untonemapped = untonemapped_bt709;

      // if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      //   untonemapped = renodx::color::bt2020::from::BT709(untonemapped_bt709);
      // } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      //   untonemapped = renodx::color::ap1::from::BT709(untonemapped_bt709);
      // }

      // sdr_color = renodx::tonemap::renodrt::NeutralSDR(untonemapped);
      sdr_color = displayMap(untonemapped);
      r0.xyz = sdr_color;
    } else {
      // fast Reinhard
      // float3 input = renodx::color::bt2020::from::BT709(r0.rgb);
      float3 input = r0.rgb;
      // if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      //   input = renodx::color::bt2020::from::BT709(input);
      // } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      //   input = renodx::color::ap1::from::BT709(input);
      // }
      r0.a = max(input.r, input.g);
      r0.a = max(r0.a, input.b);
      r0.a = 1 + r0.a;
      r0.a = rcp(r0.a); // normalize the color by (1 / (1 + max(r,g,b)))
      r0.rgb = input * r0.aaa;
    }
  }

  // 1/256 kHalfPixel
  r0.xyz = float3(0.00390625,0.00390625,0.00390625) + r0.xyz;
  r0.w = 0;

  // This block samples 3 slices of the LUT (t0) using red, green, and blue channels independently, using .xw, .yw, .zw as UVs.
  r1.xyzw = t0.SampleBias(s0_s, r0.xw, cb0[19].x).xyzw;
  r1.x = saturate(r1.x);
  r2.xyzw = t0.SampleBias(s0_s, r0.yw, cb0[19].x).xyzw;
  r0.xyzw = t0.SampleBias(s0_s, r0.zw, cb0[19].x).xyzw;
  r1.z = saturate(r0.x);
  r1.y = saturate(r2.x);

  // kHalfPixel again
  r0.xyz = float3(0.00390625,0.00390625,0.00390625) + r1.xyz;
  r0.w = 0;

  // This is a second sampling pass—likely part of a 3D LUT emulation or 
  // post-processing step. o0.xyz becomes the final LUT result, remapped through textures t1, t2, t3.
  r1.xyzw = t1.SampleBias(s0_s, r0.xw, cb0[19].x).xyzw;
  o0.x = saturate(r1.x);
  r1.xyzw = t2.SampleBias(s0_s, r0.yw, cb0[19].x).xyzw;
  r0.xyzw = t3.SampleBias(s0_s, r0.zw, cb0[19].x).xyzw;
  o0.z = saturate(r0.x);
  o0.y = saturate(r1.x);
  o0.w = 1;

  // Post-sampling re-expansion
  if (RENODX_TONE_MAP_TYPE != 0.f && shader_injection.tone_map_mode == 0.f) {
    float3 graded_sdr_color = o0.rgb;
    // per channel correction
    
    if (shader_injection.tone_map_neutral == 0.f) {
      // if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
      //   o0.rgb = renodx::color::bt709::from::BT2020(o0.rgb);
      //   sdr_color = renodx::color::bt709::from::BT2020(sdr_color);
      // } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
      //   o0.rgb = renodx::color::bt709::from::AP1(o0.rgb);
      //   sdr_color = renodx::color::bt709::from::AP1(sdr_color);
      // } else {
      //   // BT709
      // }

      graded_sdr_color = o0.rgb;

      if (CUSTOM_TONEMAP_UPGRADE_TYPE == 0.f) {

        if (RENODX_PER_CHANNEL_BLOWOUT_RESTORATION != 0.f
            || RENODX_PER_CHANNEL_HUE_CORRECTION != 0.f
            || RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION != 0.f) {
          graded_sdr_color = renodx::draw::ApplyPerChannelCorrection(
              untonemapped_bt709,
              graded_sdr_color,
              RENODX_PER_CHANNEL_BLOWOUT_RESTORATION,
              RENODX_PER_CHANNEL_HUE_CORRECTION,
              RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION);
        }

        o0.rgb = renodx::tonemap::UpgradeToneMap(untonemapped_bt709,
                                                 sdr_color,
                                                 graded_sdr_color,
                                                 1.f);
      } else {
        o0.rgb = CustomUpgradeToneMapPerChannel(untonemapped_bt709, graded_sdr_color);
      }                                          

      o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);                                         
                                               
    } else {
      // fast inverted Reinhard
      r0.a = max(o0.r, o0.g);
      r0.a = max(r0.a, o0.b);
      r0.a = 1 + -r0.a;
      r0.a = rcp(r0.a);
      r0.rgb = o0.rgb * r0.aaa;
      o0.rgb = r0.rgb;

      if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 1) {
        o0.rgb = renodx::color::bt709::from::BT2020(o0.rgb);
      } else if (RENODX_TONE_MAP_WORKING_COLOR_SPACE == 2) {
        o0.rgb = renodx::color::bt709::from::AP1(o0.rgb);
      }
    }

  }
  return;
}