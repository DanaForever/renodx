// #include "./lutbuildercommon.hlsli"
#include "./filmiclutbuilder.hlsli"

// #include "../common.hlsli"

float3 PostProcess(float3 bt709_tonemapped, UECbufferConfig cb_config, bool hdr = false) {

  if (hdr)  {
    float scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(bt709_tonemapped);

    bt709_tonemapped *= scale;
    bt709_tonemapped = (((cb_config.ue_mappingpolynomial.y + (cb_config.ue_mappingpolynomial.x * bt709_tonemapped)) * bt709_tonemapped) + cb_config.ue_mappingpolynomial.z);
    bt709_tonemapped /= scale;
  } else {
    bt709_tonemapped = (((cb_config.ue_mappingpolynomial.y + (cb_config.ue_mappingpolynomial.x * bt709_tonemapped)) * bt709_tonemapped) + cb_config.ue_mappingpolynomial.z);
  }

  // post processing like usual
  float3 scaled = cb_config.ue_colorscale.xyz * bt709_tonemapped;
  float3 output = ((cb_config.ue_overlaycolor.xyz - scaled) * cb_config.ue_overlaycolor.w) + scaled;
  output = renodx::math::SafePow(output, cb_config.ue_gamma);

  return output;
}


float3 PostProcess(float3 bt709_tonemapped, UECbufferConfig cb_config, SamplerState lut_sampler, Texture2D<float4> lut_texture, bool hdr = false) {

  float scale = 1.f;
  bt709_tonemapped *= scale;
  if (hdr)  {
    scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(bt709_tonemapped);
  }
  float3 lut_output;

  bt709_tonemapped = SampleLUTSRGBInSRGBOut(lut_texture, lut_sampler, bt709_tonemapped, cb_config);
  bt709_tonemapped = (((cb_config.ue_mappingpolynomial.y + (cb_config.ue_mappingpolynomial.x * bt709_tonemapped)) * bt709_tonemapped) + cb_config.ue_mappingpolynomial.z);
  bt709_tonemapped /= scale;

  // post processing like usual
  float3 scaled = cb_config.ue_colorscale.xyz * bt709_tonemapped;
  float3 output = ((cb_config.ue_overlaycolor.xyz - scaled) * cb_config.ue_overlaycolor.w) + scaled;
  output = renodx::math::SafePow(output, cb_config.ue_gamma);

  return output;
}


float3 PostProcess_2SDRLUT(float3 bt709_tonemapped, UECbufferConfig cb_config, SamplerState lut_sampler_0, Texture2D<float4> lut_texture_0, 
SamplerState lut_sampler_1, Texture2D<float4> lut_texture_1, bool hdr = false) {

  float scale = 1.f;
  bt709_tonemapped *= scale;
  if (hdr)  {
    scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(bt709_tonemapped);
  }
  float3 lut_output;

  bt709_tonemapped = Sample2LUTSRGBInSRGBOut(lut_texture_0, lut_texture_1, lut_sampler_0, lut_sampler_1, bt709_tonemapped, cb_config);
  bt709_tonemapped = (((cb_config.ue_mappingpolynomial.y + (cb_config.ue_mappingpolynomial.x * bt709_tonemapped)) * bt709_tonemapped) + cb_config.ue_mappingpolynomial.z);
  bt709_tonemapped /= scale;

  // post processing like usual
  float3 scaled = cb_config.ue_colorscale.xyz * bt709_tonemapped;
  float3 output = ((cb_config.ue_overlaycolor.xyz - scaled) * cb_config.ue_overlaycolor.w) + scaled;
  output = renodx::math::SafePow(output, cb_config.ue_gamma);

  return output;
}



struct LegacyTonemapResult
{
  float3 graded_untonemapped;
  float3 graded_tonemapped;
};

LegacyTonemapResult LegacyFilmicPostProcess(float3 linear_color, LegacyFilmicConfig legacy_config) {
  LegacyTonemapResult result;

  float3 matrix_color;

  matrix_color.x = dot(linear_color, legacy_config.ColorMatrixR_ColorCurveCd1.rgb);
  matrix_color.y = dot(linear_color, legacy_config.ColorMatrixG_ColorCurveCd3Cm3.rgb);
  matrix_color.z = dot(linear_color, legacy_config.ColorMatrixB_ColorCurveCm2.rgb);

  // shadow tint
  float3 tint;
  tint = legacy_config.ColorShadow_Tint1.rgb + legacy_config.ColorShadow_Tint2.rgb * rcp(dot(linear_color, legacy_config.ColorShadow_Luma.rgb) + 1.0); 
  matrix_color *= tint;

  // Required to insure saturation doesn't create negative colors!
  matrix_color = max(0.f, matrix_color);

  result.graded_untonemapped = matrix_color;

  // Apply Curve
  result.graded_tonemapped = unrealengine::filmtonemap::ApplyMobileTonemap(matrix_color, legacy_config);

  return result;
}

float4 createLegacyLUT(float3 untonemapped_ap1, float3 untonemapped_bt709,
                       UECbufferConfig cb_config, uint outputdevice) {

  // float3 untonemapped_bt709 = renodx::color::bt709::from::AP1(untonemapped_ap1);
  float4 output;
  output.w = 0;

  LegacyFilmicConfig legacy_config = CreateLegacy(
      cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3,  // ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3
      cb_config.ColorCurve_Ch1_Ch2,  // ColorCurve_Ch1_Ch2
      cb_config.ColorMatrixR_ColorCurveCd1,  // ColorMatrixR_ColorCurveCd1
      cb_config.ColorMatrixG_ColorCurveCd3Cm3,  // ColorMatrixG_ColorCurveCd3Cm3
      cb_config.ColorMatrixB_ColorCurveCm2,  // ColorMatrixB_ColorCurveCm2
      cb_config.ColorShadow_Luma,  // ColorShadow_Luma,
      cb_config.ColorShadow_Tint1,  // Tint
      cb_config.ColorShadow_Tint2  // Tint
  );

  LegacyTonemapResult legacy_output = LegacyFilmicPostProcess(untonemapped_bt709, legacy_config);
  float3 legacy_sdr = legacy_output.graded_tonemapped;

  output.rgb = PostProcess(legacy_sdr, cb_config);

  // final output
  float gamma = 1.f / cb_config.ue_inv_gamma;

  // correct gamma - this is important for SDR
  if (outputdevice == 0u)  {
    output.rgb = renodx::color::srgb::EncodeSafe(output.rgb);
  }
  else if (outputdevice == 2u) {
    output.rgb = renodx::color::gamma::EncodeSafe(output.rgb, gamma);
  } 
  // lut output encoding
  output.rgb = float3(0.952381015, 0.952381015, 0.952381015) * output.rgb;
  output.w = 0;

  return output;
}


float3 CreateStellarBladeOutput(float3 untonemapped_ap1, float3 untonemapped_bt709,
                       UECbufferConfig cb_config, uint outputdevice) {

  float3 output;
  float3 org_input = untonemapped_bt709;

  // luma in AP1
  float y = renodx::color::y::from::AP1(untonemapped_ap1);

  // desaturation
  untonemapped_ap1 = lerp(y.xxx, untonemapped_ap1, 0.959999979f);

  float3 untonemapped_graded_ap1;
  float3 tonemapped_graded_ap1;
  float3 tonemapped_graded_bt709;

  // Blue Correction Pre

  const float3x3 BlueCorrect =
      {
        0.9404372683, -0.0183068787, 0.0778696104,
        0.0083786969, 0.8286599939, 0.1629613092,
        0.0005471261, -0.0008833746, 1.0003362486
      };

  const float3x3 BlueCorrectAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrect, renodx::color::AP1_TO_AP0_MAT));

  untonemapped_graded_ap1 = lerp(untonemapped_ap1, mul(BlueCorrectAP1, untonemapped_ap1), shader_injection.unreal_blue_correction);

  // float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));
  float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));

  float3 vanilla = unrealengine::filmtonemap::ApplyToneCurve(untonemapped_graded_rrt_ap1, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);

  // if (RENODX_TONE_MAP_TYPE == 1.f) {  // SDR 
  //   tonemapped_graded_ap1 = vanilla;  
  // } else if (RENODX_TONE_MAP_TYPE == 3.f) { // HDR
  tonemapped_graded_ap1 = vanilla;
  // tonemapped_graded_ap1 = ApplyToneCurveExtended(untonemapped_graded_rrt_ap1, vanilla, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);
  // }

  // PostToneMapDesaturation
  float grayscale = renodx::color::y::from::AP1(tonemapped_graded_ap1);
  tonemapped_graded_ap1 = max(0.f, lerp(grayscale, tonemapped_graded_ap1, 0.93f));

  // Tonecurve Amount
  tonemapped_graded_ap1 = lerp(untonemapped_graded_ap1, tonemapped_graded_ap1, cb_config.ue_tonecurveammount);

  const float3x3 BlueCorrectInv =
      {
        1.06318, 0.0233956, -0.0865726,
        -0.0106337, 1.20632, -0.19569,
        -0.000590887, 0.00105248, 0.999538
      };

  const float3x3 BlueCorrectInvAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrectInv, renodx::color::AP1_TO_AP0_MAT));

  // Uncorrect blue to maintain white point
  tonemapped_graded_ap1 = lerp(tonemapped_graded_ap1, mul(BlueCorrectInvAP1, tonemapped_graded_ap1), shader_injection.unreal_blue_correction);

  // AP1 -> BT709

  tonemapped_graded_bt709 = renodx::color::bt709::from::AP1(tonemapped_graded_ap1);

  float3 filmic = tonemapped_graded_bt709;

  float3 graded_filmic = filmic;

  // graded_filmic = PostProcess(filmic, cb_config, true);
  graded_filmic = PostProcess(filmic, cb_config);
  
  output.rgb = graded_filmic;


  return output;
}


float4 CreateUnrealLUT(float3 untonemapped_ap1, float3 untonemapped_bt709,
                       UECbufferConfig cb_config, uint outputdevice) {

  float4 output;
  output.w = 0;
  float3 org_input = untonemapped_bt709;

  LegacyFilmicConfig legacy_config = CreateLegacy(
      cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3,  // ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3
      cb_config.ColorCurve_Ch1_Ch2,  // ColorCurve_Ch1_Ch2
      cb_config.ColorMatrixR_ColorCurveCd1,  // ColorMatrixR_ColorCurveCd1
      cb_config.ColorMatrixG_ColorCurveCd3Cm3,  // ColorMatrixG_ColorCurveCd3Cm3
      cb_config.ColorMatrixB_ColorCurveCm2,  // ColorMatrixB_ColorCurveCm2
      cb_config.ColorShadow_Luma,  // ColorShadow_Luma,
      cb_config.ColorShadow_Tint1,  // Tint
      cb_config.ColorShadow_Tint2  // Tint
  );

  LegacyTonemapResult legacy_output = LegacyFilmicPostProcess(untonemapped_bt709, legacy_config);
  float3 legacy_sdr = legacy_output.graded_tonemapped;
  float3 legacy_untonemapped = legacy_output.graded_untonemapped;
  
  if (RENODX_TONE_MAP_TYPE == 0.f || RENODX_TONE_MAP_TYPE == 2.f) {

    if (RENODX_TONE_MAP_TYPE == 2.f) {
      float3 legacy_hdr = unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_output.graded_untonemapped, legacy_config);
      output.rgb = PostProcess(legacy_hdr, cb_config, true);
    } else {
      output.rgb = PostProcess(legacy_sdr, cb_config);
    }

  } else {
    
    // to be used for hue-shifting
    float3 postprocessed_legacy_sdr = PostProcess(legacy_sdr, cb_config);
    
    // luma in AP1
    float y = renodx::color::y::from::AP1(untonemapped_ap1);

    // desaturation
    untonemapped_ap1 = lerp(y.xxx, untonemapped_ap1, 0.959999979f);
  
    float3 untonemapped_graded_ap1;
    float3 tonemapped_graded_ap1;
    float3 tonemapped_graded_bt709;

    // Blue Correction Pre

    const float3x3 BlueCorrect =
        {
          0.9404372683, -0.0183068787, 0.0778696104,
          0.0083786969, 0.8286599939, 0.1629613092,
          0.0005471261, -0.0008833746, 1.0003362486
        };

    const float3x3 BlueCorrectAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrect, renodx::color::AP1_TO_AP0_MAT));

    untonemapped_graded_ap1 = lerp(untonemapped_ap1, mul(BlueCorrectAP1, untonemapped_ap1), shader_injection.unreal_blue_correction);

    // float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));
    float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));

    float3 vanilla = unrealengine::filmtonemap::ApplyToneCurve(untonemapped_graded_rrt_ap1, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);

    if (RENODX_TONE_MAP_TYPE == 1.f) {  // SDR 
      tonemapped_graded_ap1 = vanilla;  
    } else if (RENODX_TONE_MAP_TYPE == 3.f) { // HDR
      tonemapped_graded_ap1 = ApplyToneCurveExtended(untonemapped_graded_rrt_ap1, vanilla, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);
    }

    // PostToneMapDesaturation
    float grayscale = renodx::color::y::from::AP1(tonemapped_graded_ap1);
    tonemapped_graded_ap1 = max(0.f, lerp(grayscale, tonemapped_graded_ap1, 0.93f));

    // Tonecurve Amount
    tonemapped_graded_ap1 = lerp(untonemapped_graded_ap1, tonemapped_graded_ap1, cb_config.ue_tonecurveammount);

    const float3x3 BlueCorrectInv =
        {
          1.06318, 0.0233956, -0.0865726,
          -0.0106337, 1.20632, -0.19569,
          -0.000590887, 0.00105248, 0.999538
        };

    const float3x3 BlueCorrectInvAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrectInv, renodx::color::AP1_TO_AP0_MAT));

    // Uncorrect blue to maintain white point
    tonemapped_graded_ap1 = lerp(tonemapped_graded_ap1, mul(BlueCorrectInvAP1, tonemapped_graded_ap1), shader_injection.unreal_blue_correction);

    // AP1 -> BT709

    tonemapped_graded_bt709 = renodx::color::bt709::from::AP1(tonemapped_graded_ap1);

    float3 filmic = tonemapped_graded_bt709;

    float3 graded_sdr = postprocessed_legacy_sdr;
    float3 graded_filmic = filmic;
    float3 graded_color = graded_sdr;

    if (RENODX_TONE_MAP_TYPE == 1.f) {
      graded_filmic = PostProcess(filmic, cb_config);
      graded_color = graded_sdr;
    } else if (RENODX_TONE_MAP_TYPE == 3.f) {
      // graded_filmic = PostProcess(filmic, cb_config, true);
      graded_filmic = PostProcess(filmic, cb_config, true);
      graded_color = PostProcess(unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_untonemapped, legacy_config), cb_config, true);
    }

    float3 hue_shifted_graded_filmic = CorrectHueAndPurity(graded_filmic, graded_color, RENODX_TONE_MAP_HUE_SHIFT);
    
    output.rgb = hue_shifted_graded_filmic;
  }

  // final output
  float gamma = 1.f / cb_config.ue_inv_gamma;

  // correct gamma - this is important for SDR
  if (shader_injection.unreal_lut_gamma_correction == 1 && outputdevice == 2u)  {
    output.rgb = CorrectGammaHuePreservingSRGB(output.rgb, gamma);
  }

  // lut output encoding
  output.rgb = DisplayMap(output.rgb, outputdevice);

  output.rgb = float3(0.952381015, 0.952381015, 0.952381015) * output.rgb;
  output.w = 0;

  return output;
}


// 1 SDR LUT
float4 CreateUnrealLUT(float3 untonemapped_ap1, float3 untonemapped_bt709,
                       SamplerState lut_sampler, Texture2D<float4> lut_texture, 
                       UECbufferConfig cb_config, uint outputdevice) {

  float4 output;
  output.w = 0;
  float3 org_input = untonemapped_bt709;

  LegacyFilmicConfig legacy_config = CreateLegacy(
      cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3,  // ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3
      cb_config.ColorCurve_Ch1_Ch2,  // ColorCurve_Ch1_Ch2
      cb_config.ColorMatrixR_ColorCurveCd1,  // ColorMatrixR_ColorCurveCd1
      cb_config.ColorMatrixG_ColorCurveCd3Cm3,  // ColorMatrixG_ColorCurveCd3Cm3
      cb_config.ColorMatrixB_ColorCurveCm2,  // ColorMatrixB_ColorCurveCm2
      cb_config.ColorShadow_Luma,  // ColorShadow_Luma,
      cb_config.ColorShadow_Tint1,  // Tint
      cb_config.ColorShadow_Tint2  // Tint
  );

  LegacyTonemapResult legacy_output = LegacyFilmicPostProcess(untonemapped_bt709, legacy_config);
  float3 legacy_sdr = legacy_output.graded_tonemapped;
  float3 legacy_untonemapped = legacy_output.graded_untonemapped;
  
  if (RENODX_TONE_MAP_TYPE == 0.f || RENODX_TONE_MAP_TYPE == 2.f) {

    if (RENODX_TONE_MAP_TYPE == 2.f) {
      float3 legacy_hdr = unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_output.graded_untonemapped, legacy_config);
      output.rgb = PostProcess(legacy_hdr, cb_config, lut_sampler, lut_texture, true);
    } else {
      output.rgb = PostProcess(legacy_sdr, cb_config, lut_sampler, lut_texture);
    }

  } else {
    
    // to be used for hue-shifting
    float3 postprocessed_legacy_sdr = PostProcess(legacy_sdr, cb_config, lut_sampler, lut_texture);
    
    // luma in AP1
    float y = renodx::color::y::from::AP1(untonemapped_ap1);

    // desaturation
    untonemapped_ap1 = lerp(y.xxx, untonemapped_ap1, 0.959999979f);
  
    float3 untonemapped_graded_ap1;
    float3 tonemapped_graded_ap1;
    float3 tonemapped_graded_bt709;

    // Blue Correction Pre

    const float3x3 BlueCorrect =
        {
          0.9404372683, -0.0183068787, 0.0778696104,
          0.0083786969, 0.8286599939, 0.1629613092,
          0.0005471261, -0.0008833746, 1.0003362486
        };

    const float3x3 BlueCorrectAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrect, renodx::color::AP1_TO_AP0_MAT));

    untonemapped_graded_ap1 = lerp(untonemapped_ap1, mul(BlueCorrectAP1, untonemapped_ap1), shader_injection.unreal_blue_correction);

    float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));

    float3 vanilla = unrealengine::filmtonemap::ApplyToneCurve(untonemapped_graded_rrt_ap1, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);

    if (RENODX_TONE_MAP_TYPE == 1.f) {  // SDR 
      tonemapped_graded_ap1 = vanilla;  
    } else if (RENODX_TONE_MAP_TYPE == 3.f) { // HDR
      tonemapped_graded_ap1 = ApplyToneCurveExtended(untonemapped_graded_rrt_ap1, vanilla, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);
    }

    // PostToneMapDesaturation
    float grayscale = renodx::color::y::from::AP1(tonemapped_graded_ap1);
    tonemapped_graded_ap1 = max(0.f, lerp(grayscale, tonemapped_graded_ap1, 0.93f));

    // Tonecurve Amount
    tonemapped_graded_ap1 = lerp(untonemapped_graded_ap1, tonemapped_graded_ap1, cb_config.ue_tonecurveammount);

    const float3x3 BlueCorrectInv =
        {
          1.06318, 0.0233956, -0.0865726,
          -0.0106337, 1.20632, -0.19569,
          -0.000590887, 0.00105248, 0.999538
        };

    const float3x3 BlueCorrectInvAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrectInv, renodx::color::AP1_TO_AP0_MAT));

    // Uncorrect blue to maintain white point
    tonemapped_graded_ap1 = lerp(tonemapped_graded_ap1, mul(BlueCorrectInvAP1, tonemapped_graded_ap1), shader_injection.unreal_blue_correction);

    // AP1 -> BT709

    tonemapped_graded_bt709 = renodx::color::bt709::from::AP1(tonemapped_graded_ap1);

    float3 filmic = tonemapped_graded_bt709;

    float3 graded_sdr = postprocessed_legacy_sdr;
    float3 graded_filmic = filmic;
    float3 graded_color = graded_sdr;

    if (RENODX_TONE_MAP_TYPE == 1.f) {
      graded_filmic = PostProcess(filmic, cb_config, lut_sampler, lut_texture);
      graded_color = graded_sdr;
    } else if (RENODX_TONE_MAP_TYPE == 3.f) {
      graded_filmic = PostProcess(filmic, cb_config, lut_sampler, lut_texture, true);
      graded_color = PostProcess(unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_untonemapped, legacy_config), cb_config, lut_sampler, lut_texture, true);
    }

    float3 hue_shifted_graded_filmic = CorrectHueAndPurity(graded_filmic, graded_color, RENODX_TONE_MAP_HUE_SHIFT);
    
    output.rgb = hue_shifted_graded_filmic;
  }

  // final output
  float gamma = 1.f / cb_config.ue_inv_gamma;

  // correct gamma - this is important for SDR
  if (shader_injection.unreal_lut_gamma_correction == 1 && outputdevice == 2u) {
    output.rgb = CorrectGammaHuePreservingSRGB(output.rgb, gamma);
  }

  // lut output encoding
  output.rgb = DisplayMap(output.rgb, outputdevice);

  output.rgb = float3(0.952381015, 0.952381015, 0.952381015) * output.rgb;
  output.w = 0;

  return output;
}


// 2 SDR LUT
float4 CreateUnrealLUT(float3 untonemapped_ap1, float3 untonemapped_bt709,
                       SamplerState lut_sampler_0, Texture2D<float4> lut_texture_0, 
                       SamplerState lut_sampler_1, Texture2D<float4> lut_texture_1, 
                       UECbufferConfig cb_config, uint outputdevice) {

  float4 output;
  output.w = 0;
  float3 org_input = untonemapped_bt709;

  LegacyFilmicConfig legacy_config = CreateLegacy(
      cb_config.ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3,  // ColorCurve_Cm0Cd0_Cd2_Ch0Cm1_Ch3
      cb_config.ColorCurve_Ch1_Ch2,  // ColorCurve_Ch1_Ch2
      cb_config.ColorMatrixR_ColorCurveCd1,  // ColorMatrixR_ColorCurveCd1
      cb_config.ColorMatrixG_ColorCurveCd3Cm3,  // ColorMatrixG_ColorCurveCd3Cm3
      cb_config.ColorMatrixB_ColorCurveCm2,  // ColorMatrixB_ColorCurveCm2
      cb_config.ColorShadow_Luma,  // ColorShadow_Luma,
      cb_config.ColorShadow_Tint1,  // Tint
      cb_config.ColorShadow_Tint2  // Tint
  );

  LegacyTonemapResult legacy_output = LegacyFilmicPostProcess(untonemapped_bt709, legacy_config);
  float3 legacy_sdr = legacy_output.graded_tonemapped;
  float3 legacy_untonemapped = legacy_output.graded_untonemapped;
  
  if (RENODX_TONE_MAP_TYPE == 0.f || RENODX_TONE_MAP_TYPE == 2.f) {

    if (RENODX_TONE_MAP_TYPE == 2.f) {
      float3 legacy_hdr = unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_output.graded_untonemapped, legacy_config);
      output.rgb = PostProcess_2SDRLUT(legacy_hdr, cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1, true);
    } else {
      output.rgb = PostProcess_2SDRLUT(legacy_sdr, cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1);
    }

  } else {
    
    // to be used for hue-shifting
    float3 postprocessed_legacy_sdr = PostProcess_2SDRLUT(legacy_sdr, cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1);
    
    // luma in AP1
    float y = renodx::color::y::from::AP1(untonemapped_ap1);

    // desaturation
    untonemapped_ap1 = lerp(y.xxx, untonemapped_ap1, 0.959999979f);
  
    float3 untonemapped_graded_ap1;
    float3 tonemapped_graded_ap1;
    float3 tonemapped_graded_bt709;

    // Blue Correction Pre

    const float3x3 BlueCorrect =
        {
          0.9404372683, -0.0183068787, 0.0778696104,
          0.0083786969, 0.8286599939, 0.1629613092,
          0.0005471261, -0.0008833746, 1.0003362486
        };

    const float3x3 BlueCorrectAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrect, renodx::color::AP1_TO_AP0_MAT));

    untonemapped_graded_ap1 = lerp(untonemapped_ap1, mul(BlueCorrectAP1, untonemapped_ap1), shader_injection.unreal_blue_correction);

    float3 untonemapped_graded_rrt_ap1 = renodx::tonemap::aces::RRT(mul(renodx::color::AP1_TO_AP0_MAT, untonemapped_graded_ap1));

    float3 vanilla = unrealengine::filmtonemap::ApplyToneCurve(untonemapped_graded_rrt_ap1, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);

    if (RENODX_TONE_MAP_TYPE == 1.f) {  // SDR 
      tonemapped_graded_ap1 = vanilla;  
    } else if (RENODX_TONE_MAP_TYPE == 3.f) { // HDR
      tonemapped_graded_ap1 = ApplyToneCurveExtended(untonemapped_graded_rrt_ap1, vanilla, cb_config.ue_filmslope, cb_config.ue_filmtoe, cb_config.ue_filmshoulder, cb_config.ue_filmblackclip, cb_config.ue_filmwhiteclip);
    }

    // PostToneMapDesaturation
    float grayscale = renodx::color::y::from::AP1(tonemapped_graded_ap1);
    tonemapped_graded_ap1 = max(0.f, lerp(grayscale, tonemapped_graded_ap1, 0.93f));

    // Tonecurve Amount
    tonemapped_graded_ap1 = lerp(untonemapped_graded_ap1, tonemapped_graded_ap1, cb_config.ue_tonecurveammount);

    const float3x3 BlueCorrectInv =
        {
          1.06318, 0.0233956, -0.0865726,
          -0.0106337, 1.20632, -0.19569,
          -0.000590887, 0.00105248, 0.999538
        };

    const float3x3 BlueCorrectInvAP1 = mul(renodx::color::AP0_TO_AP1_MAT, mul(BlueCorrectInv, renodx::color::AP1_TO_AP0_MAT));

    // Uncorrect blue to maintain white point
    tonemapped_graded_ap1 = lerp(tonemapped_graded_ap1, mul(BlueCorrectInvAP1, tonemapped_graded_ap1), shader_injection.unreal_blue_correction);

    // AP1 -> BT709

    tonemapped_graded_bt709 = renodx::color::bt709::from::AP1(tonemapped_graded_ap1);

    float3 filmic = tonemapped_graded_bt709;

    float3 graded_sdr = postprocessed_legacy_sdr;
    float3 graded_filmic = filmic;
    float3 graded_color = graded_sdr;

    if (RENODX_TONE_MAP_TYPE == 1.f) {
      graded_filmic = PostProcess_2SDRLUT(filmic, cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1);
      graded_color = graded_sdr;
    } else if (RENODX_TONE_MAP_TYPE == 3.f) {
      graded_filmic = PostProcess_2SDRLUT(filmic, cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1, true);
      graded_color = PostProcess_2SDRLUT(unrealengine::filmtonemap::extended::ApplyContrastExtended(legacy_untonemapped, legacy_config), cb_config, lut_sampler_0, lut_texture_0, lut_sampler_1, lut_texture_1, true);
    }

    float3 hue_shifted_graded_filmic = CorrectHueAndPurity(graded_filmic, graded_color, RENODX_TONE_MAP_HUE_SHIFT);
    
    output.rgb = hue_shifted_graded_filmic;
  }

  // final output
  float gamma = 1.f / cb_config.ue_inv_gamma;

  // correct gamma - this is important for SDR
  if (shader_injection.unreal_lut_gamma_correction == 1 && outputdevice == 2u) {
    output.rgb = CorrectGammaHuePreservingSRGB(output.rgb, gamma);
  }

  // lut output encoding
  output.rgb = DisplayMap(output.rgb, outputdevice);

  output.rgb = float3(0.952381015, 0.952381015, 0.952381015) * output.rgb;
  output.w = 0;

  return output;
}
