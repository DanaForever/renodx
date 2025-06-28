#include "./shared.h"

Texture2D<float4> sceneTexture : register(t0);
Texture2D<float4> lut : register(t1);
SamplerState s0_s : register(s0);
SamplerState s1_s : register(s1);

Texture2D<float4> bloomTexture : register(t50);
SamplerState bloomSampler : register(s14);

Texture2D<float4> improvedLut : register(t51);
SamplerState improvedLutSampler : register(s15);


// 3Dmigoto declarations
#define cmp -


// Pumbo black magic
// Sample that allows to go beyond the 0-1 coordinates range through extrapolation.
// It finds the rate of change (acceleration) of the LUT color around the requested clamped coordinates, and guesses what color the sampling would have with the out of range coordinates.
// Extrapolating LUT by re-apply the rate of change has the benefit of consistency. If the LUT has the same color at (e.g.) uv 0.9 0.9 and 1.0 1.0, thus clipping to white or black, the extrapolation will also stay clipped.
// Additionally, if the LUT had inverted colors or highly fluctuating colors, extrapolation would work a lot better than a raw LUT out of range extraction with a luminance multiplier.
//
// This function does not acknowledge the LUT transfer function nor any specific LUT properties.
// This function allows your to pick whether you want to extrapolate diagonal, horizontal or veretical coordinates.
// Note that this function might return "invalid colors", they could have negative values etc etc, so make sure to clamp them after if you need to.
// This version is for a 2D float4 texture with a single gradient (not a 3D map reprojected in 2D with horizontal/vertical slices), but the logic applies to 3D textures too.
//
// "unclampedUV" is expected to have been remapped within the range that excludes that last half texels at the edges.
// "extrapolationDirection" 0 is both hor and ver. 1 is hor only. 2 is ver only.
float4 sampleLUTWithExtrapolation(Texture2D<float4> lut, SamplerState samplerState, float2 unclampedUV, bool remapped = false, const int extrapolationDirection = 0) {
  // LUT size in texels
  float lutWidth;
  float lutHeight;
  lut.GetDimensions(lutWidth, lutHeight);
  const float2 lutSize = float2(lutWidth, lutHeight);
  const float2 lutMax = lutSize - 1.0;
  const float2 uvScale = lutMax / lutSize;        // Also "1-(1/lutSize)"
  const float2 uvOffset = 1.0 / (2.0 * lutSize);  // Also "(1/lutSize)/2"
  // The uv distance between the center of one texel and the next one
  const float2 lutTexelRange = 1.0 / lutMax;

  // Remap the input coords to also include the last half texels at the edges, essentually working in full 0-1 range,
  // we will re-map them out when sampling, this is essential for proper extrapolation math.
  if (remapped)
  {
    if (lutMax.x != 0)
      unclampedUV.x = (unclampedUV.x - uvOffset.x) / uvScale.x;
    if (lutMax.y != 0)
      unclampedUV.y = (unclampedUV.y - uvOffset.y) / uvScale.y;
  }

  const float2 clampedUV = saturate(unclampedUV);
  const float distanceFromUnclampedToClamped = length(unclampedUV - clampedUV);
  const bool uvOutOfRange = distanceFromUnclampedToClamped > renodx::math::FLT_MIN;  // Some threshold is needed to avoid divisions by tiny numbers

  const float4 clampedSample = lut.Sample(samplerState, (clampedUV * uvScale) + uvOffset).xyzw;  // Use "clampedUV" instead of "unclampedUV" as we don't know what kind of sampler was in use here

  if (uvOutOfRange && extrapolationDirection >= 0) {
    float2 centeredUV;
    // Diagonal
    if (extrapolationDirection == 0) {
      // Find the direction between the clamped and unclamped coordinates, flip it, and use it to determine
      // where more centered texel for extrapolation is.
      centeredUV = clampedUV - (normalize(unclampedUV - clampedUV) * (1.0 - lutTexelRange));
    }
    // Horizontal or Vertical (use Diagonal if you want both Horizontal and Vertical at the same time)
    else {
      const bool extrapolateHorizontalCoordinates = extrapolationDirection == 0 || extrapolationDirection == 1;
      const bool extrapolateVerticalCoordinates = extrapolationDirection == 0 || extrapolationDirection == 2;
      centeredUV = float2(clampedUV.x >= 0.5 ? max(clampedUV.x - lutTexelRange.x, 0.5) : min(clampedUV.x + lutTexelRange.x, 0.5), clampedUV.y >= 0.5 ? max(clampedUV.y - lutTexelRange.y, 0.5) : min(clampedUV.y + lutTexelRange.y, 0.5));
      centeredUV = float2(extrapolateHorizontalCoordinates ? centeredUV.x : unclampedUV.x, extrapolateVerticalCoordinates ? centeredUV.y : unclampedUV.y);
    }

    const float4 centeredSample = lut.Sample(samplerState, (centeredUV * uvScale) + uvOffset).xyzw;
    // Note: if we are only doing "Horizontal" or "Vertical" extrapolation, we could replace this "length()" calculation with a simple subtraction
    const float distanceFromClampedToCentered = length(clampedUV - centeredUV);
    const float extrapolationRatio = distanceFromClampedToCentered == 0.0 ? 0.0 : (distanceFromUnclampedToClamped / distanceFromClampedToCentered);
#if 1  // Lerp in gamma space, this seems to look better for this game (the whole rendering is in gamma space, never linearized), and the "extrapolationRatio" is in gamma space too
    const float4 extrapolatedSample = lerp(centeredSample, clampedSample, 1.0 + extrapolationRatio);
#else  // Lerp in linear space to make it more "accurate"
    const float4 extrapolatedSample = lerp(pow(centeredSample, 2.2), pow(clampedSample, 2.2), 1.0 + extrapolationRatio);
    extrapolatedSample = pow(abs(extrapolatedSample), 1.0 / 2.2) * sign(extrapolatedSample);
#endif
    return extrapolatedSample;
  }
  return clampedSample;
}


// LUTXClippingPoint is the first LUT horizontal texel (from left to right) to have a "clipped" value of 1
float3 SampleClippedLUT(Texture2D<float4> lut, SamplerState samplerState, float3 color, uint LUTXSize, uint LUTXClippingPoint)
{
   float2 UVRed = float2(color.r, 0.5f);
   float2 UVGrn = float2(color.g, 0.5f);
   float2 UVBlu = float2(color.b, 0.5f);

   float UVClippingPoint = LUTXClippingPoint / (float)LUTXSize;
   // If we are trying to sample a coordinate beyond the clipping point, extrapolate it
   //TODO: add LUT half texels bias to the math
   if (UVRed.x > UVClippingPoint || UVGrn.x > UVClippingPoint || UVBlu.x > UVClippingPoint)
   {
      float3 ClippedColor = lut.Sample(samplerState, float2(UVClippingPoint, 0.5f)).rgb; // Should be 1 anyway?
      // Sample the color 25% backwards of the clipped color
      float3 BackwardsColor = lut.Sample(samplerState, float2(((LUTXClippingPoint / 4.f) * 3.f) / (float)LUTXSize, 0.5f)).rgb;
      // Find the velocity by dividing by the number of texels we travelled backwards of
      float3 Velocity = (ClippedColor - BackwardsColor) / 0.25f;

      // Add back the velocity with the new "time"
      float3 OutColor = ClippedColor;
      if (UVRed.x > UVClippingPoint) {
         OutColor.r += Velocity.r * max((((UVRed.x * LUTXSize) / LUTXClippingPoint) - 1.f), 0.f);
      } else {
         OutColor.r = lut.Sample(samplerState, UVRed).r;
      }
      if (UVGrn.x > UVClippingPoint) {
         OutColor.g += Velocity.g * max((((UVGrn.x * LUTXSize) / LUTXClippingPoint) - 1.f), 0.f);
      } else {
         OutColor.g = lut.Sample(samplerState, UVGrn).g;
      }
      if (UVBlu.x > UVClippingPoint) {
         OutColor.b += Velocity.b * max((((UVBlu.x * LUTXSize) / LUTXClippingPoint) - 1.f), 0.f);
      } else {
         OutColor.b = lut.Sample(samplerState, UVBlu).b;
      }
      return OutColor;
   }

   float3 OutColor;
   OutColor.r = lut.Sample(samplerState, UVRed).r;
   OutColor.g = lut.Sample(samplerState, UVGrn).g;
   OutColor.b = lut.Sample(samplerState, UVBlu).b;
   return OutColor;
}

// from Musa
float3 extendGamut(float3 color, float extendGamutAmount)
{
  float3 colorOKLab = renodx::color::oklab::from::BT709(color);

  // Extract L, C, h from OKLab
  float L = colorOKLab[0];
  float a = colorOKLab[1];
  float b = colorOKLab[2];
  float C = sqrt(a * a + b * b);
  float h = atan2(b, a);

  // Calculate the exponential weighting factor based on luminance and chroma
  float chromaWeight = 1.0f - exp(-4.0f * C);
  float luminanceWeight = 1.0f - exp(-4.0f * L * L);
  float weight = chromaWeight * luminanceWeight * extendGamutAmount;

  // Apply the expansion factor
  C *= (1.0f + weight);

  // Convert back to OKLab with adjusted chroma
  a = C * cos(h);
  b = C * sin(h);
  float3 adjustedOKLab = float3(L, a, b);

  float3 adjustedColor = renodx::color::bt709::from::OkLab(adjustedOKLab);
  float3 colorAP1 = renodx::color::ap1::from::BT709(adjustedColor);
  colorAP1 = max(0, colorAP1); // Clamp to AP1
  return renodx::color::bt709::from::AP1(colorAP1);
}

float FindLUTEnd(Texture2D<float4> lut, SamplerState samplerState, float lutWidth)
{
    // find the real end of the lut
  float lutEnd = lutWidth;

  while (lutEnd >= 1.0) {
    float3 col = lut.Sample(samplerState, float2(lutEnd / lutWidth, 0.5f)).rgb;
    float3 nextCol = lut.Sample(samplerState, float2((lutEnd - 1.0f) / lutWidth, 0.5f)).rgb;
    if (any(col - nextCol)) {
      break;
    }
    lutEnd = lutEnd - 1.0;
  }

  return lutEnd;
}

float3 FindLUTEnds(Texture2D<float4> lut, SamplerState samplerState, float lutWidth)
{
    // find the real end of the lut
  float3 lutEnds = lutWidth;
  
  while (lutEnds.r >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.r / lutWidth, 0.5f)).r;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.r - 1.0f) / lutWidth, 0.5f)).r;
    if (col != nextCol) {
      break;
    }
    lutEnds.r = lutEnds.r - 1.0;
  }

  while (lutEnds.g >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.g / lutWidth, 0.5f)).g;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.g - 1.0f) / lutWidth, 0.5f)).g;
    if (col != nextCol) {
      break;
    }
    lutEnds.g = lutEnds.g - 1.0;
  }

  while (lutEnds.b >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.b / lutWidth, 0.5f)).b;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.b - 1.0f) / lutWidth, 0.5f)).b;
    if (col != nextCol) {
      break;
    }
    lutEnds.b = lutEnds.b - 1.0;
  }

  return lutEnds;
}

void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD8,
  float4 v2 : COLOR0,
  float4 v3 : COLOR1,
  float4 v4 : TEXCOORD9,
  float4 v5 : TEXCOORD0,
  float4 v6 : TEXCOORD1,
  float4 v7 : TEXCOORD2,
  float4 v8 : TEXCOORD3,
  float4 v9 : TEXCOORD4,
  float4 v10 : TEXCOORD5,
  float4 v11 : TEXCOORD6,
  float4 v12 : TEXCOORD7,
  out float4 o0 : SV_TARGET0)
{
  float3 sceneColor = sceneTexture.Sample(s0_s, v5.xy).xyz;
  float4 color;
  color.rgb = sceneColor.rgb;
  color.a = 1;

  if (injectedData.improvedBloom) {
    // sample and upscale bloom one last time
    float x = injectedData.bloomRadius;
    float y = injectedData.bloomRadius;

    float3 a = bloomTexture.Sample(s0_s, float2(v5.x - x, v5.y + y)).rgb;
    float3 b = bloomTexture.Sample(s0_s, float2(v5.x,     v5.y + y)).rgb;
    float3 c = bloomTexture.Sample(s0_s, float2(v5.x + x, v5.y + y)).rgb;

    float3 d = bloomTexture.Sample(s0_s, float2(v5.x - x, v5.y)).rgb;
    float3 e = bloomTexture.Sample(s0_s, float2(v5.x,     v5.y)).rgb;
    float3 f = bloomTexture.Sample(s0_s, float2(v5.x + x, v5.y)).rgb;

    float3 g = bloomTexture.Sample(s0_s, float2(v5.x - x, v5.y - y)).rgb;
    float3 h = bloomTexture.Sample(s0_s, float2(v5.x,     v5.y - y)).rgb;
    float3 i = bloomTexture.Sample(s0_s, float2(v5.x + x, v5.y - y)).rgb;
    
    float3 bloom = e*4.0;
    bloom += (b+d+f+h)*2.0;
    bloom += (a+c+g+i);
    bloom *= 1.0 / 16.0;

    // blend it with the scene color    
    color.rgb = lerp(color.rgb, bloom.rgb, saturate(injectedData.bloomBlend));
    color.rgb += bloom.rgb * injectedData.bloomStrength;
  }

  if (injectedData.toneMapType == 0) {
    color.rgb = saturate(color.rgb);
  }
    
  float3 colorGraded = color.rgb;
  colorGraded.r = dot(color.xyzw, v6.xyzw);
  colorGraded.g = dot(color.xyzw, v7.xyzw);
  colorGraded.b = dot(color.xyzw, v8.xyzw);
  color.rgb = lerp(color.rgb, colorGraded, injectedData.gameColorGradingStrength);

  float3 sampledLut = color.rgb;
  if (injectedData.improvedLUT > 0) {
    if (injectedData.toneMapType > 0) {
      sampledLut.r = sampleLUTWithExtrapolation(improvedLut, improvedLutSampler, float2(color.r, 0.5f), false, 1).r;
      sampledLut.g = sampleLUTWithExtrapolation(improvedLut, improvedLutSampler, float2(color.g, 0.5f), false, 1).g;
      sampledLut.b = sampleLUTWithExtrapolation(improvedLut, improvedLutSampler, float2(color.b, 0.5f), false, 1).b;

      // float lutWidth;
      // float lutHeight;
      // improvedLut.GetDimensions(lutWidth, lutHeight);

      // float lutEnd = lutWidth;
      // sampledLut = SampleClippedLUT(improvedLut, improvedLutSampler, color.rgb, lutWidth, lutEnd);
    } else {    
      sampledLut.r = improvedLut.Sample(improvedLutSampler, float2(color.r, 0.5f)).r;
      sampledLut.g = improvedLut.Sample(improvedLutSampler, float2(color.g, 0.5f)).g;
      sampledLut.b = improvedLut.Sample(improvedLutSampler, float2(color.b, 0.5f)).b;
    }
  } else {
    if (injectedData.toneMapType > 0) {
      float lutWidth;
      float lutHeight;
      lut.GetDimensions(lutWidth, lutHeight);

      float lutEnd = lutWidth;
      lutEnd = FindLUTEnd(lut, s1_s, lutWidth);

      sampledLut = SampleClippedLUT(lut, s1_s, color.rgb, lutWidth, lutEnd);
    } else {    
      sampledLut.r = lut.Sample(s1_s, float2(color.r, 0.5f)).r;
      sampledLut.g = lut.Sample(s1_s, float2(color.g, 0.5f)).g;
      sampledLut.b = lut.Sample(s1_s, float2(color.b, 0.5f)).b;
    }
  }

  // debug output lut on screen
  //color.rgb = improvedLut.Sample(s1_s, v5.xy).rgb; o0 = color; return;
  
  color.rgb = lerp(color.rgb, sampledLut, injectedData.lutStrength);  

  if (injectedData.toneMapType > 0) {
    // linearize
    color.rgb = renodx::math::PowSafe(color.rgb, 2.2f);

    //float3 untonemapped = color.rgb;

    // additional renodx color grading
    color.rgb = renodx::color::grade::UserColorGrading(
      color.rgb,
      injectedData.colorGradeExposure, 
      injectedData.colorGradeHighlights, 
      injectedData.colorGradeShadows, 
      injectedData.colorGradeContrast,
      injectedData.colorGradeSaturation, 
      injectedData.colorGradeBlowout,
      0.f);
    
    // tonemap to display peak
    float peak = injectedData.toneMapPeakNits / injectedData.toneMapGameNits;
    color.rgb = renodx::tonemap::ReinhardScalable(color.rgb, peak);

    // color correct
    color.rgb = renodx::color::correct::Hue(color.rgb, renodx::tonemap::Reinhard(color.rgb), injectedData.hueCorrectionStrength);
    
    // extend gamut
    color.rgb = extendGamut(color.rgb, injectedData.gamutExpansion);

    // clamp to bt2020
    color.rgb = renodx::color::bt709::clamp::BT2020(color.rgb);

    // apply inverse UI brightness (ui brightness is re-applied in the final shader)
    color.rgb *= injectedData.toneMapGameNits / injectedData.toneMapUINits;
    
    // back to gamma space
    color.rgb = renodx::math::PowSafe(color.rgb, 1.f / 2.2f);
  }

  o0 = color;

  if (injectedData.toneMapType == 0) {
    o0 = saturate(o0);
  }
  return;
}