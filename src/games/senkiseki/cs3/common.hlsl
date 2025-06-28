#include "../shared.h"


float3 ToneMap(float3 color) {
    renodx::draw::Config draw_config = renodx::draw::BuildConfig();
    draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::DANIELE;
    // draw_config.tone_map_pass_autocorrection = 0.5;
  
    renodx::tonemap::Config tone_map_config = renodx::tonemap::config::Create();
    tone_map_config.peak_nits = draw_config.peak_white_nits;
    tone_map_config.game_nits = draw_config.diffuse_white_nits;
    tone_map_config.type = draw_config.tone_map_type;
    tone_map_config.gamma_correction = draw_config.gamma_correction;
    tone_map_config.exposure = draw_config.tone_map_exposure;
    tone_map_config.highlights = draw_config.tone_map_highlights;
    tone_map_config.shadows = draw_config.tone_map_shadows;
    tone_map_config.contrast = draw_config.tone_map_contrast;
    tone_map_config.saturation = draw_config.tone_map_saturation;
  
    tone_map_config.mid_gray_value = 0.18f;
    tone_map_config.mid_gray_nits = tone_map_config.mid_gray_value * 100.f;
  
    tone_map_config.reno_drt_highlights = 1.0f;
    tone_map_config.reno_drt_shadows = 1.0f;
    tone_map_config.reno_drt_contrast = 1.0f;
    tone_map_config.reno_drt_saturation = 1.0f;
    tone_map_config.reno_drt_blowout = -1.f * (draw_config.tone_map_highlight_saturation - 1.f);
    tone_map_config.reno_drt_dechroma = draw_config.tone_map_blowout;
    tone_map_config.reno_drt_flare = 0.10f * pow(draw_config.tone_map_flare, 10.f);
    tone_map_config.reno_drt_working_color_space = (uint)draw_config.tone_map_working_color_space;
    tone_map_config.reno_drt_per_channel = draw_config.tone_map_per_channel == 1.f;
    tone_map_config.reno_drt_hue_correction_method = (uint)draw_config.tone_map_hue_processor;
    tone_map_config.reno_drt_clamp_color_space = draw_config.tone_map_clamp_color_space;
    tone_map_config.reno_drt_clamp_peak = draw_config.tone_map_clamp_peak;
    tone_map_config.reno_drt_tone_map_method = (uint)draw_config.reno_drt_tone_map_method;
    tone_map_config.reno_drt_white_clip = draw_config.reno_drt_white_clip;
  
    // removed the code for hue correction
    float3 tonemapped = renodx::tonemap::config::Apply(color, tone_map_config);
  
    return tonemapped;
  }