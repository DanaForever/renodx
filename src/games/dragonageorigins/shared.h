#ifndef SRC_TEMPLATE_SHARED_H_
#define SRC_TEMPLATE_SHARED_H_

#ifndef __cplusplus
#include "../../shaders/renodx.hlsl"
#endif

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  float toneMapType;
  float toneMapPeakNits;
  float toneMapGameNits;
  float toneMapUINits;
  float colorGradeExposure;
  float colorGradeHighlights;
  float colorGradeShadows;
  float colorGradeContrast;
  float colorGradeSaturation;
  float colorGradeBlowout;
  float hueCorrectionStrength;
  float gamutExpansion;
  float gameColorGradingStrength;
  float lutStrength;
  float improvedLUT;
  float clampBloom;
  float improvedBloom;
  float bloomBlend;
  float bloomStrength;
  float bloomThreshold;
  float bloomThresholdKnee;
  float bloomContrast;
  float bloomRadius;
  float circleOpacity;
  float vignetteStrength;

  float internalBloomSrcTexelSizeX;
  float internalBloomSrcTexelSizeY;
  float internalBloomFilterRadiusX;
  float internalBloomFilterRadiusY;
};

#ifndef __cplusplus
cbuffer cb13 : register(b13) {
  ShaderInjectData injectedData : packoffset(c0);
}
#endif

#endif  // SRC_TEMPLATE_SHARED_H_
