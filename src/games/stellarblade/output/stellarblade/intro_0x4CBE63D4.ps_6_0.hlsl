#include "../output.hlsl"

Texture2D<float4> t0 : register(t0);

cbuffer cb0 : register(b0) {
  float4 Globals_000 : packoffset(c000.x);
  float4 Globals_016 : packoffset(c001.x);
  float4 Globals_032 : packoffset(c002.x);
};

SamplerState s0 : register(s0);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float4 COLOR : COLOR,
  linear float4 ORIGINAL_POSITION : ORIGINAL_POSITION,
  linear float2 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target;
  float4 _14 = t0.Sample(s0, float2((TEXCOORD_1.z * TEXCOORD_1.x), (TEXCOORD_1.w * TEXCOORD_1.y)));
  float _19 = _14.x * COLOR.x;
  float _20 = _14.y * COLOR.y;
  float _21 = _14.z * COLOR.z;
  float _22 = _14.w * COLOR.w;
  float _40;
  float _41;
  float _42;
  float _66;
  float _77;
  float _88;
  float _89;
  float _90;
  [branch]
  if (!((Globals_000.w) == 1.0f)) {
    _40 = (((Globals_000.w) * (_19 + -0.25f)) + 0.25f);
    _41 = (((Globals_000.w) * (_20 + -0.25f)) + 0.25f);
    _42 = (((Globals_000.w) * (_21 + -0.25f)) + 0.25f);
  } else {
    _40 = _19;
    _41 = _20;
    _42 = _21;
  }
  [branch]
  if (!((Globals_000.y) == 1.0f)) {
    // float _53 = exp2(log2(_40) * (Globals_000.x));
    // float _54 = exp2(log2(_41) * (Globals_000.x));
    // float _55 = exp2(log2(_42) * (Globals_000.x));

    float3 output = float3(_40, _41, _42);
    output = renodx::math::SafePow(output, Globals_000.x);

    if (RENODX_TONE_MAP_TYPE > 2.f) {
      float videoPeak = 400.f;
      float peak = videoPeak / (RENODX_DIFFUSE_WHITE_NITS / 203.f);
      // output = renodx::color::gamma::DecodeSafe(output, 2.4f);  // 2.4 for BT2446a
      // output = GammaCorrection(output, 2.4f);
      output = renodx::tonemap::inverse::bt2446a::BT709(output, 100.f, videoPeak);
      output /= videoPeak;                              // Normalize to 1.0f = peak;
      output *= videoPeak /
              RENODX_DIFFUSE_WHITE_NITS;  // 1.f = game nits

      output = LMS_Vibrancy(output, shader_injection.tone_map_saturation, shader_injection.tone_map_contrast);

      // [branch]
      // if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
      //   output = renodx::color::correct::GammaSafe(output, false, 2.2f);
      // } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
      //   output = renodx::color::correct::GammaSafe(output, false, 2.4f);
      // }

      output *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;

    }

    output = renodx::color::srgb::EncodeSafe(output);

    _88 = output.r;
    _89 = output.g;     
    _90 = output.b;
    // do {
    //   if (_53 < 0.0031306699384003878f) {
    //     _66 = (_53 * 12.920000076293945f);
    //   } else {
    //     _66 = (((pow(_53, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f);
    //   }
    //   do {
    //     if (_54 < 0.0031306699384003878f) {
    //       _77 = (_54 * 12.920000076293945f);
    //     } else {
    //       _77 = (((pow(_54, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f);
    //     }
    //     if (_55 < 0.0031306699384003878f) {
    //       _88 = _66;
    //       _89 = _77;
    //       _90 = (_55 * 12.920000076293945f);
    //     } else {
    //       _88 = _66;
    //       _89 = _77;
    //       _90 = (((pow(_55, 0.4166666567325592f)) * 1.0549999475479126f) + -0.054999999701976776f);
    //     }
    //   } while (false);
    // } while (false);
  } else {
    _88 = _40;
    _89 = _41;
    _90 = _42;
  }
  SV_Target.x = _88;
  SV_Target.y = _89;
  SV_Target.z = _90;
  SV_Target.w = (((Globals_000.z) * ((_22 * -2.0f) + 1.0f)) + _22);
  return SV_Target;
}
