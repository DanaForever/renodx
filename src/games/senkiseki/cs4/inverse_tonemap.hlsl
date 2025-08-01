#include "../shared.h"

#include "./common.hlsl"

static const float3x3 Wide_2_XYZ_MAT = float3x3(
    0.5441691, 0.2395926, 0.1666943,
    0.2394656, 0.7021530, 0.0583814,
    -0.0023439, 0.0361834, 1.0552183);

static const float3 AP1_RGB2Y = float3(
    0.2722287168,  // AP1_2_XYZ_MAT[0][1],
    0.6740817658,  // AP1_2_XYZ_MAT[1][1],
    0.0536895174   // AP1_2_XYZ_MAT[2][1]
);

float inv_tonemap_ReinhardPerComponent(float L, float L_white) {
  const float L2 = L * L;
  const float LW2 = L_white * L_white;
  const float LP1 = (0.5f * ((L * LW2) - LW2));
  // It shouldn't be possible for this to be negative (but if it was, put a max() with 0)
  const float LP2P1 = LW2 * ((L2 * LW2) - (2.0f * L * LW2) + (4.0f * L) + LW2);
  const float LP2 = (0.5f * sqrt(LP2P1));

  // The results can both be negative for some reason (especially on pitch black pixels), so we max against 0.
  const float LA = LP1 + LP2;
  L = max(LA, 0.0f);

  return L;
}

float3 inv_tonemap_ReinhardPerComponent(float3 L, float L_white) {
  const float3 L2 = L * L;
  const float LW2 = L_white * L_white;
  const float3 LP1 = (0.5f * ((L * LW2) - LW2));
  // It shouldn't be possible for this to be negative (but if it was, put a max() with 0)
  const float3 LP2P1 = LW2 * ((L2 * LW2) - (2.0f * L * LW2) + (4.0f * L) + LW2);
  const float3 LP2 = (0.5f * sqrt(LP2P1));

  // The results can both be negative for some reason (especially on pitch black pixels), so we max against 0.
  const float3 LA = LP1 + LP2;
  L = max(LA, 0.0f);

  return L;
}

float3 RestoreHue(float3 targetColor, float3 sourceColor, float amount = 0.5)
{
  float3 oklch = renodx::color::oklch::from::BT709(sourceColor);
  float3 rgb = sourceColor;

  // Invalid or black colors fail oklab conversions or ab blending so early out
  float y = renodx::color::y::from::BT709(targetColor);
  float bloom_y = renodx::color::y::from::BT709(targetColor);

  if (bloom_y < FLT_MIN)
  {
    // Optionally we could blend the target towards the source, or towards black, but there's no need until proven otherwise
    return targetColor;
  }

  const float3 targetOklab = renodx::color::oklab::from::BT709(targetColor);
  const float3 targetOklch = renodx::color::oklch::from::OkLab(targetOklab);
  const float3 sourceOklab = renodx::color::oklab::from::BT709(sourceColor);

  // First correct both hue and chrominance at the same time (oklab a and b determine both, they are the color xy coordinates basically).
  // As long as we don't restore the hue to a 100% (which should be avoided), this will always work perfectly even if the source color is pure white (or black, any "hueless" and "chromaless" color).
  // This method also works on white source colors because the center of the oklab ab diagram is a "white hue", thus we'd simply blend towards white (but never flipping beyond it (e.g. from positive to negative coordinates)),
  // and then restore the original chrominance later (white still conserving the original hue direction, so likely spitting out the same color as the original, or one very close to it).
  float3 correctedTargetOklab = float3(targetOklab.x, lerp(targetOklab.yz, sourceOklab.yz, amount));

  // Then restore chrominance
  float3 correctedTargetOklch = renodx::color::oklch::from::OkLab(correctedTargetOklab);
  correctedTargetOklch.y = targetOklch.y;

  return renodx::color::bt709::from::OkLCh(correctedTargetOklch);
}

float3 saturation(float3 color, float saturation)
{
  float luminance = renodx::color::y::from::BT709(color);
  return lerp(luminance, color, saturation);
}

float3 expandGamut(float3 vHDRColor, float fExpandGamut /*= 1.0f*/)
{
  // const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
  // const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));
  // const float3x3 Wide_2_AP1 = mul(XYZ_2_AP1_MAT, Wide_2_XYZ_MAT);
  // const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  const float3x3 sRGB_2_AP1 = renodx::color::BT709_TO_AP1_MAT;
  const float3x3 AP1_2_sRGB = renodx::color::AP1_TO_BT709_MAT;
  const float3x3 Wide_2_AP1 = mul(renodx::color::XYZ_TO_AP1_MAT, Wide_2_XYZ_MAT);
  const float3x3 ExpandMat = mul(Wide_2_AP1, AP1_2_sRGB);

  // float3 ColorAP1 = mul(sRGB_2_AP1, vHDRColor);
  float3 ColorAP1 = renodx::color::ap1::from::BT709(vHDRColor);
  float LumaAP1 = renodx::color::y::from::AP1(ColorAP1);

  // float LumaAP1 = dot(ColorAP1, AP1_RGB2Y);
  if (LumaAP1 <= 0.f)
    {
    return vHDRColor;
  }
  float3 ChromaAP1 = ColorAP1 / LumaAP1;

  float ChromaDistSqr = dot(ChromaAP1 - 1, ChromaAP1 - 1);
  float ExpandAmount = (1 - exp2(-4 * ChromaDistSqr)) * (1 - exp2(-4 * fExpandGamut * LumaAP1 * LumaAP1));

  float3 ColorExpand = mul(ExpandMat, ColorAP1);
  ColorAP1 = lerp(ColorAP1, ColorExpand, ExpandAmount);

  vHDRColor = mul(AP1_2_sRGB, ColorAP1);
  return vHDRColor;
}

float average(float3 vColor)
{
  return dot(vColor, float3(1.f / 3.f, 1.f / 3.f, 1.f / 3.f));
}

bool IsNAN(const float input)
{
  if (isnan(input) || isinf(input))
    return true;
  else
    return false;
}

float fixNAN(const float input)
{
  if (IsNAN(input))
    return 0.f;
  else
    return input;
}

float3 fixNAN(float3 input)
{
  if (IsNAN(input.r))
    input.r = 0.f;
  else if (IsNAN(input.g))
    input.g = 0.f;
  else if (IsNAN(input.b))
    input.b = 0.f;

  return input;
}

float3 PumboInverseTonemap(float3 color) {
  float3 originalColor = color;
  float3 fineTunedColor = color;
  float3 mid_gray = 0.18f;
  // float3 inverse_luminance = color;

  if (INVERSE_TONEMAP_WHITE_LEVEL == 0) {
    return color;
  }
  float PreTonemapLuminance = renodx::color::y::from::BT709(color);

  bool per_channel = RENODX_TONE_MAP_PER_CHANNEL;

  if (per_channel) {
    color = inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL);

    color *= mid_gray / average(inv_tonemap_ReinhardPerComponent(mid_gray, INVERSE_TONEMAP_WHITE_LEVEL));

  } else {
    float PostTonemapLuminance = renodx::color::y::from::BT709(inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL));
    // float PostTonemapLuminance = inv_tonemap_ReinhardPerComponent(color, INVERSE_TONEMAP_WHITE_LEVEL).r;

    // likely to eliminate NaN.
    float scale = max(1.f, PostTonemapLuminance / PreTonemapLuminance);
    color *= scale;

    color = renodx::color::bt709::clamp::AP1(color);
  }

  if (INVERSE_TONEMAP_COLOR_CONSERVATION != 0.f)
    // Restore part of the original color "saturation" and "hue", but keep the new luminance
    color = RestoreHue(color, fineTunedColor, INVERSE_TONEMAP_COLOR_CONSERVATION);

  // // return color;
  fineTunedColor = color;

  if (INVERSE_TONEMAP_HIGHLIGHT_SATURATION != 1.f)
    {
    const float OklabLightness = renodx::color::oklab::from::BT709(fineTunedColor)[0];
    const float highlightSaturationRatio = max((OklabLightness - (2.f / 3.f)) / (1.f / 3.f), 0.f);
    fineTunedColor = saturation(fineTunedColor, lerp(1.f, INVERSE_TONEMAP_HIGHLIGHT_SATURATION, highlightSaturationRatio));
  }

  float3 displayMappedColor = fineTunedColor;

  // return displayMappedColor;
  displayMappedColor = fixNAN(displayMappedColor);

  float weight;
  if (RENODX_GAMMA_CORRECTION == 0.f)
    weight = saturate(pow(PreTonemapLuminance, 1.f));
  else if (RENODX_GAMMA_CORRECTION == 1.f)
    weight = saturate(pow(PreTonemapLuminance, 2.2));
  else if (RENODX_GAMMA_CORRECTION == 2.f)
    weight = saturate(pow(PreTonemapLuminance, 2.4));

  float3 finalColor = lerp(originalColor, displayMappedColor, weight);

  return finalColor;
}