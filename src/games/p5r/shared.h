#ifndef SRC_P5R_SHARED_H_
#define SRC_P5R_SHARED_H_

#define RENODX_PEAK_WHITE_NITS               injectedData.toneMapPeakNits
#define RENODX_DIFFUSE_WHITE_NITS            injectedData.toneMapGameNits
#define RENODX_GRAPHICS_WHITE_NITS           injectedData.toneMapUINits
#define RENODX_TONE_MAP_TYPE                 injectedData.toneMapType
#define RENODX_RENO_DRT_TONE_MAP_METHOD      renodx::tonemap::renodrt::config::tone_map_method::REINHARD
#define RENODX_TONE_MAP_CONTRAST             injectedData.colorGradeContrast
#define RENODX_TONE_MAP_SATURATION           injectedData.colorGradeSaturation
#define RENODX_TONE_MAP_WORKING_COLOR_SPACE  renodx::color::convert::COLOR_SPACE_BT2020
#define RENODX_TONE_MAP_PER_CHANNEL          1.f
#define RENODX_GAMMA_CORRECTION              injectedData.toneMapGammaCorrection
#define RENODX_SWAP_CHAIN_GAMMA_CORRECTION   RENODX_GAMMA_CORRECTION
#define RENODX_SWAP_CHAIN_CLAMP_NITS         10000.f
#define RENODX_SWAP_CHAIN_CLAMP_COLOR_SPACE  renodx::color::convert::COLOR_SPACE_BT2020
#define RENODX_INTERMEDIATE_ENCODING         0.f
#define RENODX_SWAP_CHAIN_DECODING           0.f

#define CLAMP_STATE__NONE      0.f
#define CLAMP_STATE__OUTPUT    1.f
#define CLAMP_STATE__MIN_ALPHA 2.f
#define CLAMP_STATE__MAX_ALPHA 3.f

#define COLOR_SPACE__NONE   0.f
#define COLOR_SPACE__BT709  1.f
#define COLOR_SPACE__BT2020 2.f
#define COLOR_SPACE__AP1    3.f

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  float toneMapType;
  float toneMapPeakNits;
  float toneMapGameNits;
  float toneMapUINits;
  float toneMapGammaCorrection;
  float toneMapBlackCorrection;
  float colorGradeExposure;
  float colorGradeHighlights;
  float colorGradeShadows;
  float colorGradeContrast;
  float colorGradeSaturation;
  float colorGradeDechroma;
  float colorGradeLUTStrength;
  float colorGradeLUTScaling;
  float colorGradeColorSpace;
  float fxBloom;
  float clampState;
};

#ifndef __cplusplus
cbuffer cb7 : register(b7) {
  ShaderInjectData injectedData : packoffset(c0);
}
#include "../../shaders/renodx.hlsl"

#endif

#endif  // SRC_P5R_SHARED_H_