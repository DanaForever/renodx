#include "./shared.h"

//-----EFFECTS-----//
float3 applyFilmGrain(float3 outputColor, float2 screen) {
  float3 grainedColor = renodx::effects::ApplyFilmGrain(
        outputColor,
        screen,
        injectedData.random,
        injectedData.fxFilmGrain * 0.03f,
        1.f);
  return grainedColor;
}

//-----SCALING-----//
float3 PostToneMapScale(float3 color) {
  if (injectedData.toneMapGammaCorrection == 2.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
    color *= injectedData.toneMapGameNits / injectedData.toneMapUINits;
    color = renodx::color::correct::GammaSafe(color, true, 2.4f);
  } else if (injectedData.toneMapGammaCorrection == 1.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
    color *= injectedData.toneMapGameNits / injectedData.toneMapUINits;
    color = renodx::color::correct::GammaSafe(color, true, 2.2f);
  } else {
    color *= injectedData.toneMapGameNits / injectedData.toneMapUINits;
  }
  return color;
}

float3 FinalizeOutput(float3 color) {
  if (injectedData.toneMapGammaCorrection == 2.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  } else if (injectedData.toneMapGammaCorrection == 1.f) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  }
  color *= injectedData.toneMapUINits;
  if (injectedData.toneMapType == 0.f) {
    color = renodx::color::bt709::clamp::BT709(color);
  } else {
    color = renodx::color::bt709::clamp::BT2020(color);
  }
  color /= 80.f;
  return color;
}

float3 InverseToneMapBT2446a(float3 color) {
  if (injectedData.toneMapType != 0.f && injectedData.hasLoadedTitleMenu == true) {
  color = renodx::color::srgb::Encode(color);
	float scaling = injectedData.toneMapPeakNits / injectedData.toneMapGameNits;
	float videoPeak = scaling * renodx::color::bt2408::REFERENCE_WHITE;
    videoPeak = renodx::color::correct::Gamma(videoPeak, false, 2.4f);
    scaling = renodx::color::correct::Gamma(scaling, false, 2.4f);
      if(injectedData.toneMapGammaCorrection == 2.f){
    videoPeak = renodx::color::correct::Gamma(videoPeak, true, 2.4f);
    scaling = renodx::color::correct::Gamma(scaling, true, 2.4f);
    } else if(injectedData.toneMapGammaCorrection == 1.f){
    videoPeak = renodx::color::correct::Gamma(videoPeak, true, 2.2f);
    scaling = renodx::color::correct::Gamma(scaling, true, 2.2f);
    }
  color = renodx::color::gamma::Decode(color, 2.4f);
  color = renodx::tonemap::inverse::bt2446a::BT709(color, renodx::color::bt709::REFERENCE_WHITE, videoPeak);
	color /= videoPeak;
	color *= scaling;
  color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  color = renodx::color::srgb::DecodeSafe(color);
  } else {}
	return color;
}

//-----TONEMAP-----//
float3 vanillaTonemap(float3 color, float4 params){
float A = 0.22f * params.x;  // Shoulder Strength
float B = 0.3f * params.y;  // Linear Strength
static const float C = 0.1;  // Linear Angle
static const float D = 0.2;  // Toe Strength
float E = 0.01f * params.z;  // Toe Numerator
static const float F = 0.3f;  // Toe Denominator
 return renodx::tonemap::ApplyCurve(color, A, B, C, D, E, F) / renodx::tonemap::ApplyCurve(params.w, A, B, C, D, E, F);
}

float3 uncharted2Inverse(float3 x, float linear_white) {
  // all parameters are tweakable
  static const float A = 0.22 * 1.30;  // Shoulder Strength
  static const float B = 0.30 * 0.95;  // Linear Strength
  static const float C = 0.10;  // Linear Angle
  static const float D = 0.20;  // Toe Strength
  static const float E = 0.01 * 1.20;  // Toe Numerator
  static const float F = 0.30;  // Toe Denominator
  float W = linear_white;       // Linear White
  static const float exposure = 1.0;         // SHOULD ONLY BE 1.0 OR 2.0 (pre-tonemap adjustment)
  // ITM_max = (W / exposure) * 203;    // (theoretical target peak in nits)
  x *= renodx::tonemap::ApplyCurve(W, A, B, C, D, E, F);

  float3 part1 = renodx::math::DivideSafe(
    (B * C * F) - (B * E) - (B * F * x),
    exposure * 2.f * A * (E + F * x - F));

  float3 part2 = renodx::math::DivideSafe(
  renodx::math::SignSqrt((- (exposure * B * C * F) + (exposure * B * E) + (exposure * B * F * x)) * (- (exposure * B * C * F) + (exposure * B * E) + (exposure * B * F * x)) - (4.f * D * F * F * x * ((pow(exposure,exposure) * A * E) + (pow(exposure,exposure) * A * F * x) - (pow(exposure,exposure) * A * F)))),
  pow(exposure, exposure) * 2.f * A * (E + F * x - F));

  return part1 - part2;
}

float3 applyUserTonemap(float3 untonemapped, Texture3D lutTexture, SamplerState lutSampler, float4 params) {
  float3 outputColor;
  float3 hueCorrectionColor = vanillaTonemap(untonemapped, params);
  float midGray = vanillaTonemap(float3(0.18f,0.18f,0.18f), params).x;
  renodx::tonemap::Config config = renodx::tonemap::config::Create();
  config.type = min(3, injectedData.toneMapType);
  config.peak_nits = injectedData.toneMapPeakNits;
  config.game_nits = injectedData.toneMapGameNits;
  config.gamma_correction = injectedData.toneMapGammaCorrection;
  config.exposure = injectedData.colorGradeExposure;
  config.highlights = injectedData.colorGradeHighlights;
  config.shadows = injectedData.colorGradeShadows;
  config.contrast = injectedData.colorGradeContrast;
  config.saturation = injectedData.colorGradeSaturation;
  config.mid_gray_value = midGray;
  config.mid_gray_nits = midGray * 100;
  config.reno_drt_contrast = 1.18f;
  config.reno_drt_dechroma = injectedData.colorGradeDechroma;
  config.reno_drt_flare = 0.10f * pow(injectedData.colorGradeFlare, 10.f);
  config.hue_correction_type = injectedData.toneMapPerChannel != 0.f
                                   ? renodx::tonemap::config::hue_correction_type::INPUT
                                   : renodx::tonemap::config::hue_correction_type::CUSTOM;
  config.hue_correction_strength = injectedData.toneMapHueCorrection;
  config.hue_correction_color = lerp(untonemapped, hueCorrectionColor, injectedData.toneMapHueShift);
  config.reno_drt_tone_map_method = injectedData.toneMapType == 4.f ? renodx::tonemap::renodrt::config::tone_map_method::REINHARD
                                                                    : renodx::tonemap::renodrt::config::tone_map_method::DANIELE;
  config.reno_drt_hue_correction_method = (int)injectedData.toneMapHueProcessor;
  config.reno_drt_per_channel = injectedData.toneMapPerChannel != 0.f;
  config.reno_drt_blowout = injectedData.colorGradeBlowout;
  config.reno_drt_white_clip = injectedData.colorGradeClip == 0.f ? params.w : injectedData.colorGradeClip;
  renodx::lut::Config lut_config = renodx::lut::config::Create();
  lut_config.lut_sampler = lutSampler;
  lut_config.strength = injectedData.colorGradeLUTStrength;
  lut_config.scaling = injectedData.colorGradeLUTScaling;
  lut_config.type_input = renodx::lut::config::type::GAMMA_2_0;
  lut_config.type_output = renodx::lut::config::type::GAMMA_2_0;
  lut_config.size = 16;
  lut_config.tetrahedral = injectedData.colorGradeLUTSampling != 0.f;
  if (injectedData.toneMapType == 0.f) {
    outputColor = saturate(hueCorrectionColor);
  } else {
    outputColor = untonemapped;
  }
return renodx::tonemap::config::Apply(outputColor, config, lut_config, lutTexture);
}

float3 applyVideoTonemap(float3 untonemapped, float linear_white){
  float3 outputColor;
  float midGray = renodx::tonemap::uncharted2::BT709(float3(0.18f,0.18f,0.18f), linear_white).x;
  float3 hueCorrectionColor = renodx::tonemap::uncharted2::BT709(untonemapped, linear_white);
  bool perChannel = injectedData.toneMapPerChannel != 0.f;
    renodx::tonemap::Config config = renodx::tonemap::config::Create();
    config.type = injectedData.toneMapType > 1.f ? 3.f : injectedData.toneMapType;
    config.peak_nits = injectedData.toneMapPeakNits;
    config.game_nits = injectedData.toneMapGameNits;
    config.gamma_correction = injectedData.toneMapGammaCorrection;
    config.mid_gray_value = midGray;
    config.mid_gray_nits = midGray * 100;
    config.reno_drt_contrast = 1.18f;
    config.reno_drt_saturation = perChannel ? 1.f : 1.6f;
    config.reno_drt_dechroma = perChannel ? 0.f : 0.8f;
    config.hue_correction_type = perChannel ? renodx::tonemap::config::hue_correction_type::INPUT
                                     : renodx::tonemap::config::hue_correction_type::CUSTOM;
    config.hue_correction_strength = perChannel ? 0.f : 1.f;
    config.hue_correction_color = lerp(untonemapped, hueCorrectionColor, injectedData.toneMapHueShift);
    config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
    config.reno_drt_hue_correction_method = (int)injectedData.toneMapHueProcessor;
    config.reno_drt_per_channel = perChannel;
    config.reno_drt_white_clip = linear_white;
    config.reno_drt_blowout = perChannel ? -0.01f : 0.f;
      if(injectedData.toneMapType == 0.f){
    outputColor = saturate(hueCorrectionColor);
    } else {
    outputColor = untonemapped;
    }
return renodx::tonemap::config::Apply(outputColor, config);
}

float3 InverseToneMapCustom(float3 color, float linear_white) {
  color = renodx::color::correct::Gamma(color, true, 2.2f);
  if (linear_white == 0.f || injectedData.hasLoadedTitleMenu == false) {return color;}
  float3 untonemapped = uncharted2Inverse(color, linear_white);
  return applyVideoTonemap(untonemapped, linear_white);
}