
#include "./shared.h"

float3 PostToneMapScale(float3 color) {
  if (shader_injection.gamma_correction == 2.f) {
    color = renodx::color::srgb::EncodeSafe(color);
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else if (shader_injection.gamma_correction == 1.f) {
    color = renodx::color::srgb::EncodeSafe(color);
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else {
    color *= shader_injection.diffuse_white_nits / shader_injection.graphics_white_nits;
    color = renodx::color::srgb::EncodeSafe(color);
  }
  return color;
}

float3 RestoreHighlightSaturation(float3 color) {
  if (RENODX_TONE_MAP_TYPE != 0.f && DISPLAY_MAP_TYPE != 0.f) {
    if (DISPLAY_MAP_TYPE == 1.f) {  // Dice

      float dicePeak = DISPLAY_MAP_PEAK;          // 2.f default
      float diceShoulder = DISPLAY_MAP_SHOULDER;  // 0.5f default
      color = renodx::tonemap::dice::BT709(color, dicePeak, diceShoulder);

    } else if (DISPLAY_MAP_TYPE == 2.f) {  // Frostbite

      float frostbitePeak = DISPLAY_MAP_PEAK;     // 2.f default
      float diceShoulder = DISPLAY_MAP_SHOULDER;  // 0.5f default
      float diceSaturation = 1.f;                 // Hardcode to 1.f
      color = renodx::tonemap::frostbite::BT709(color, frostbitePeak, diceShoulder, diceSaturation);
      // color = RenoDRTSmoothClamp(color, 10000.f, 100.f, 5.f); // Testing smoothclamp
    } else if (DISPLAY_MAP_TYPE == 3.f) {
      float3 neutral_sdr_color = renodx::tonemap::renodrt::NeutralSDR(color);
      float color_y = renodx::color::y::from::BT709(color);
      // Lerp color and NeutralSDR(color) based on luminance
      // Normally using NeutralSDR alone messes up midtones
      // But the lerp makes sure it only gets applied to highlights
      color = lerp(color, neutral_sdr_color, saturate(color_y));
    }
  } else {
    // We dont want to Display Map if the tonemapper is vanilla/preset off or display map is none
    color = color;
  }

  return color;
}

float3 ToneMapPass(float3 untonemapped, float3 graded_sdr, float mid_gray) {
  renodx::draw::Config draw_config = renodx::draw::BuildConfig();
  draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
  // draw_config.tone_map_pass_autocorrection = 0.5;
  float3 color = renodx::draw::ComputeUntonemappedGraded(
      untonemapped,
      graded_sdr,
      draw_config);

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

  tone_map_config.mid_gray_value = mid_gray;
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

  tone_map_config.hue_correction_strength = draw_config.tone_map_hue_correction;

  if (draw_config.tone_map_hue_shift != 0.f) {
    tone_map_config.hue_correction_type = renodx::tonemap::config::hue_correction_type::CUSTOM;

    float3 hue_shifted_color;
    if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_CLIP) {
      hue_shifted_color = saturate(color);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_SDR_MODIFIED) {
      renodx::tonemap::renodrt::Config renodrt_config = renodx::tonemap::renodrt::config::Create();
      renodrt_config.nits_peak = 100.f;
      renodrt_config.mid_gray_value = 0.18f;
      renodrt_config.mid_gray_nits = 18.f;
      renodrt_config.exposure = 1.f;
      renodrt_config.highlights = 1.f;
      renodrt_config.shadows = 1.f;
      renodrt_config.contrast = 1.0f;
      renodrt_config.saturation = draw_config.tone_map_hue_shift_modifier;
      renodrt_config.dechroma = 0.f;
      renodrt_config.flare = 0.f;
      renodrt_config.per_channel = false;
      renodrt_config.tone_map_method = 1u;
      renodrt_config.white_clip = 1.f;
      renodrt_config.hue_correction_strength = 0.f;
      renodrt_config.working_color_space = 0u;
      renodrt_config.clamp_color_space = 0u;
      hue_shifted_color = renodx::tonemap::renodrt::BT709(color, renodrt_config);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_AP1_ROLL_OFF) {
      float3 incorrect_hue_ap1 = renodx::color::ap1::from::BT709(color * tone_map_config.mid_gray_value / 0.18f);
      hue_shifted_color = renodx::color::bt709::from::AP1(renodx::tonemap::ExponentialRollOff(incorrect_hue_ap1, tone_map_config.mid_gray_value, 2.f));
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_ACES_FITTED_BT709) {
      hue_shifted_color = renodx::tonemap::ACESFittedBT709(color);
    } else if (draw_config.tone_map_hue_shift_method == renodx::draw::HUE_SHIFT_METHOD_ACES_FITTED_AP1) {
      hue_shifted_color = renodx::tonemap::ACESFittedAP1(color);
    }
    tone_map_config.hue_correction_color = lerp(
        color,
        hue_shifted_color,
        draw_config.tone_map_hue_shift);
  }

  float3 tonemapped = renodx::tonemap::config::Apply(color, tone_map_config);

  return tonemapped;
}

float UpgradeToneMapRatio(float ap1_color_hdr, float ap1_color_sdr, float ap1_post_process_color) {
  if (ap1_color_hdr < ap1_color_sdr) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    return ap1_color_hdr / ap1_color_sdr;
  } else {
    float ap1_delta = ap1_color_hdr - ap1_color_sdr;
    ap1_delta = max(0, ap1_delta);  // Cleans up NaN
    const float ap1_new = ap1_post_process_color + ap1_delta;

    const bool ap1_valid = (ap1_post_process_color > 0);  // Cleans up NaN and ignore black
    return ap1_valid ? (ap1_new / ap1_post_process_color) : 0;
  }
}
float3 UpgradeToneMapPerChannel(float3 color_hdr, float3 color_sdr, float3 post_process_color, float post_process_strength) {
  float3 ap1_hdr = max(0, renodx::color::ap1::from::BT709(color_hdr));
  float3 ap1_sdr = max(0, renodx::color::ap1::from::BT709(color_sdr));
  float3 ap1_post_process = max(0, renodx::color::ap1::from::BT709(post_process_color));

  float3 ratio = float3(
      UpgradeToneMapRatio(ap1_hdr.r, ap1_sdr.r, ap1_post_process.r),
      UpgradeToneMapRatio(ap1_hdr.g, ap1_sdr.g, ap1_post_process.g),
      UpgradeToneMapRatio(ap1_hdr.b, ap1_sdr.b, ap1_post_process.b));

  float3 color_scaled = max(0, ap1_post_process * ratio);
  color_scaled = renodx::color::bt709::from::AP1(color_scaled);
  float peak_correction = saturate(1.f - renodx::color::y::from::AP1(ap1_post_process));
  color_scaled = renodx::color::correct::Hue(color_scaled, post_process_color, peak_correction);
  return lerp(color_hdr, color_scaled, post_process_strength);
}

float3 UpgradeToneMapByLuminance(float3 color_hdr, float3 color_sdr, float3 post_process_color, float post_process_strength) {
  float3 bt2020_hdr = max(0, renodx::color::bt2020::from::BT709(color_hdr));
  float3 bt2020_sdr = max(0, renodx::color::bt2020::from::BT709(color_sdr));
  float3 bt2020_post_process = max(0, renodx::color::bt2020::from::BT709(post_process_color));

  float ratio = UpgradeToneMapRatio(
      renodx::color::y::from::BT2020(bt2020_hdr),
      renodx::color::y::from::BT2020(bt2020_sdr),
      renodx::color::y::from::BT2020(bt2020_post_process));

  float3 color_scaled = max(0, bt2020_post_process * ratio);
  color_scaled = renodx::color::bt709::from::BT2020(color_scaled);
  color_scaled = renodx::color::correct::Hue(color_scaled, post_process_color);
  return lerp(color_hdr, color_scaled, post_process_strength);
}

///////////////////////////////////////////////////////////////////////////
////////// CUSTOM TONEMAPPASS//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

/// Applies Exponential Roll-Off tonemapping using the maximum channel.
/// Used to fit the color into a 0–output_max range for SDR LUT compatibility.
float3 ToneMapMaxCLL(float3 color, float rolloff_start = 0.375f, float output_max = 1.f) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return color;
  }
  color = min(color, 100.f);
  float peak = max(color.r, max(color.g, color.b));
  peak = min(peak, 100.f);
  float log_peak = log2(peak);

  // Apply exponential shoulder in log space
  float log_mapped = renodx::tonemap::ExponentialRollOff(log_peak, log2(rolloff_start), log2(output_max));
  float scale = exp2(log_mapped - log_peak);  // How much to compress all channels

  return min(output_max, color * scale);
}

float3 UpgradeToneMap(
    float3 color_untonemapped,
    float3 color_tonemapped,
    float3 color_tonemapped_graded,
    float post_process_strength = 1.f,
    float auto_correction = 0.f) {
  float ratio = 1.f;

  float y_untonemapped = renodx::color::y::from::BT709(abs(color_untonemapped));
  float y_tonemapped = renodx::color::y::from::BT709(abs(color_tonemapped));
  float y_tonemapped_graded = renodx::color::y::from::BT709(abs(color_tonemapped_graded));

  if (y_untonemapped < y_tonemapped) {
    // If substracting (user contrast or paperwhite) scale down instead
    // Should only apply on mismatched HDR
    ratio = y_untonemapped / y_tonemapped;
  } else {
    float y_delta = y_untonemapped - y_tonemapped;
    y_delta = max(0, y_delta);  // Cleans up NaN
    const float y_new = y_tonemapped_graded + y_delta;

    const bool y_valid = (y_tonemapped_graded > 0);  // Cleans up NaN and ignore black
    ratio = y_valid ? (y_new / y_tonemapped_graded) : 0;
  }
  float auto_correct_ratio = lerp(1.f, ratio, saturate(y_untonemapped));
  ratio = lerp(ratio, auto_correct_ratio, auto_correction);

  float3 color_scaled = color_tonemapped_graded * ratio;
  // Match hue
  color_scaled = renodx::color::correct::Hue(color_scaled, color_tonemapped_graded, RENODX_TONE_MAP_HUE_PROCESSOR);
  return lerp(color_untonemapped, color_scaled, post_process_strength);
}

float3 ToneMap(float3 color) {
  renodx::draw::Config draw_config = renodx::draw::BuildConfig();
  // draw_config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
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

float3 CustomToneMapPass(float3 untonemapped, 
  float3 tonemapped_bt709, 
  float mid_gray) {
  if (RENODX_TONE_MAP_TYPE == 0) {
    return tonemapped_bt709;
  }
  else {
    float mid_gray_scale = mid_gray / 0.18f;
    float3 untonemapped_midgray = untonemapped * mid_gray_scale;
    // float3 hdr_color;
    float3 outputColor;
    tonemapped_bt709 = renodx::draw::ApplyPerChannelCorrection(
        untonemapped_midgray,
        tonemapped_bt709,
        RENODX_PER_CHANNEL_BLOWOUT_RESTORATION,
        RENODX_PER_CHANNEL_HUE_CORRECTION,
        RENODX_PER_CHANNEL_CHROMINANCE_CORRECTION,
        RENODX_TONE_MAP_HUE_SHIFT);


    outputColor = UpgradeToneMap(untonemapped_midgray,
                                 //  renodx::tonemap::renodrt::NeutralSDR(untonemapped_midgray),
                                 ToneMapMaxCLL(untonemapped_midgray),
                                 tonemapped_bt709,
                                 RENODX_COLOR_GRADE_STRENGTH);

    outputColor = ToneMap(outputColor);
    
    return outputColor;
  }
}
