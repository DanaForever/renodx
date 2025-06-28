// ---- Created with 3Dmigoto v1.3.16 on Sat May 31 12:33:56 2025
#include "./shared.h"
cbuffer Constants : register(b2)
{

  struct
  {
    float4 AverageLuminanceHalfTexelSize;
    float4 BrightnessContrastSaturationColorLUTEnable;
    float4 MaskParams_MaskColor_InputGammaCorrection;
  } PerDrawCall : packoffset(c0);

}

SamplerState InputTextureSampler_s : register(s0);
SamplerState ColorLUTTextureSampler_s : register(s12);
SamplerState ColorLUTMaskSampler_s : register(s13);
SamplerState ParametersMaskSampler_s : register(s14);
Texture2D<float4> InputTexture : register(t0);
Texture3D<float4> ColorLUTTexture : register(t12);
Texture2D<float4> ColorLUTMask : register(t13);
Texture2D<float4> ParametersMask : register(t14);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = InputTexture.Sample(InputTextureSampler_s, v1.xy).xyzw;

  r1.x = cmp(0 < PerDrawCall.MaskParams_MaskColor_InputGammaCorrection.z);
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    r2.xyzw = log2(abs(r0.xyzw));
    r2.xyzw = float4(2.20000005,2.20000005,2.20000005,2.20000005) * r2.xyzw;
    r2.xyzw = exp2(r2.xyzw);
    r0.xyzw = r1.xxxx ? r2.xyzw : r0.xyzw;
  }

  // r1.x = cmp(0 < PerDrawCall.BrightnessContrastSaturationColorLUTEnable.w);
  // if (r1.x != 0) {
  //   r1.x = cmp(0 < PerDrawCall.MaskParams_MaskColor_InputGammaCorrection.y);
  //   if (r1.x != 0) {
  //     r1.x = ColorLUTMask.Sample(ColorLUTMaskSampler_s, w1.xy).w;
  //   } else {
  //     r1.x = 1;
  //   }
  //   r1.yzw = PerDrawCall.AverageLuminanceHalfTexelSize.www + r0.xyz;
  //   r1.yzw = ColorLUTTexture.Sample(ColorLUTTextureSampler_s, r1.yzw).xyz;
  //   r1.yzw = r1.yzw + -r0.xyz;
  //   r0.xyz = r1.xxx * r1.yzw + r0.xyz;
  // }

  r1.x = cmp(PerDrawCall.MaskParams_MaskColor_InputGammaCorrection.x >= 0);
  if (r1.x != 0) {
    r1.x = ParametersMask.Sample(ParametersMaskSampler_s, w1.xy).w;
    r1.x = PerDrawCall.MaskParams_MaskColor_InputGammaCorrection.x * r1.x;
  } else {
    r1.x = 1;
  }
  r1.yzw = PerDrawCall.BrightnessContrastSaturationColorLUTEnable.xxx * r0.xyz;
  r1.y = dot(r1.yzw, float3(0.212599993,0.715200007,0.0722000003));
  r2.xyz = r0.xyz * PerDrawCall.BrightnessContrastSaturationColorLUTEnable.xxx + -r1.yyy;
  r1.yzw = PerDrawCall.BrightnessContrastSaturationColorLUTEnable.zzz * r2.xyz + r1.yyy;
  r1.yzw = -PerDrawCall.AverageLuminanceHalfTexelSize.xyz + r1.yzw;
  r1.yzw = PerDrawCall.BrightnessContrastSaturationColorLUTEnable.yyy * r1.yzw + PerDrawCall.AverageLuminanceHalfTexelSize.xyz;
  r1.yzw = r1.yzw + -r0.xyz;
  o0.xyz = r1.xxx * r1.yzw + r0.xyz;

  o0.w = r0.w;
  o0.rgb = renodx::color::bt709::clamp::BT2020(o0.rgb);
  return;
}