#ifndef SRC_ORI2_SHARED_H_
#define SRC_ORI2_SHARED_H_

#ifndef __cplusplus


#define RENODX_RENO_DRT_NEUTRAL_SDR_TONE_MAP_METHOD 2.f

#include "../../shaders/renodx.hlsl"
#endif

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  float toneMapType;
  float toneMapPeakNits;
  float toneMapGameNits;
  float toneMapHueCorrection;
  float toneMapHDRBlendFactor;
  float colorGradeStrength;

  float swap_chain_encoding;
  float swap_chain_encoding_color_space;
};

#ifndef __cplusplus
cbuffer cb11 : register(b11) {
  ShaderInjectData injectedData : packoffset(c0);
}

#define RENODX_SWAP_CHAIN_ENCODING             shader_injection.swap_chain_encoding
#define RENODX_SWAP_CHAIN_ENCODING_COLOR_SPACE shader_injection.swap_chain_encoding_color_space


// #include "../../shaders/renodx.hlsl"

#endif

#endif  // SRC_ORI2_SHARED_H_
