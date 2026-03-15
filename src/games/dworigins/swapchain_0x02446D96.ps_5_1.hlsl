// // ---- Created with 3Dmigoto v1.3.16 on Sun Feb 15 17:09:47 2026

// cbuffer _Globals : register(b0)
// {
//   float hdrSaturation : packoffset(c0);
//   float hdrContrast : packoffset(c0.y);
//   float hdrBrightness : packoffset(c0.z);
// }

// Texture2D<float4> tTex : register(t0);


// // 3Dmigoto declarations
// #define cmp -


// void main(
//   float4 v0 : SV_Position0,
//   float4 v1 : COLOR0,
//   float2 v2 : TEXCOORD0,
//   out float4 o0 : SV_Target0)
// {
//   float4 r0,r1,r2,r3,r4,r5;
//   uint4 bitmask, uiDest;
//   float4 fDest;

//   r0.xy = (int2)v0.xy;
//   r0.zw = float2(0,0);
//   r0.xyzw = tTex.Load(r0.xyz).xyzw;
//   r1.x = cmp(r0.x < r0.y);
//   if (r1.x != 0) {
//     r1.xyzw = r0.xyzy + -r0.yxxz;
//     r2.xyz = cmp(float3(0,0,0) < r1.zyw);
//     r3.xyz = float3(60,60,60) * r1.xzz;
//     r3.xyz = r3.xyz / r1.zyw;
//     r3.xyz = float3(240,120,120) + r3.xyz;
//     r4.xy = cmp(r0.yx < r0.zz);
//     r2.xyz = r2.xyz ? r3.xyz : 0;
//     r2.w = r1.y;
//     r3.x = r2.z;
//     r3.z = r1.w;
//     r3.xz = r4.yy ? r2.yw : r3.xz;
//     r1.x = r2.x;
//     r1.y = r0.z;
//     r3.y = r0.y;
//     r1.xyz = r4.xxx ? r1.yzx : r3.yzx;
//   } else {
//     r2.xyzw = r0.zxyx + -r0.yyzz;
//     r3.xyz = cmp(float3(0,0,0) < r2.xyw);
//     r4.xyz = float3(60,60,60) * r2.yzz;
//     r4.xyz = r4.xyz / r2.xyw;
//     r1.w = 240 + r4.x;
//     r5.x = r3.x ? r1.w : 0;
//     r3.xw = cmp(r0.xy < r0.zz);
//     r4.xy = r3.yz ? r4.yz : 0;
//     r4.zw = r2.yw;
//     r4.xz = r3.ww ? r4.xz : r4.yw;
//     r5.y = r0.z;
//     r5.z = r2.x;
//     r4.y = r0.x;
//     r1.xyz = r3.xxx ? r5.yzx : r4.yzx;
//   }
//   r1.w = cmp(r1.x == 0.000000);
//   r1.y = r1.y / r1.x;
//   // r1.y = hdrSaturation * r1.y;
//   r1.y = r1.y;
//   r1.y = r1.w ? 0 : r1.y;
//   // r2.x = hdrBrightness * r1.x;
//   r2.x = r1.x;
//   r1.x = cmp(r1.y == 0.000000);
//   if (r1.x != 0) {
//     r2.z = r2.x;
//     r3.x = r2.x;
//   } else {
//     r1.x = cmp(r1.z < 0);
//     r1.w = cmp(360 < r1.z);
//     r3.zw = float2(360,-360) + r1.zz;
//     r1.z = r1.w ? r3.w : r1.z;
//     r1.x = r1.x ? r3.z : r1.z;
//     r1.x = 0.0166666675 * r1.x;
//     r1.z = (uint)r1.x;
//     r1.z = (uint)r1.z % 6;
//     r1.x = frac(r1.x);
//     r1.w = 1 + -r1.y;
//     r2.z = r2.x * r1.w;
//     r1.w = -r1.x * r1.y + 1;
//     r3.x = r2.x * r1.w;
//     r1.x = 1 + -r1.x;
//     r1.x = -r1.x * r1.y + 1;
//     r1.x = r2.x * r1.x;
//     switch (r1.z) {
//       case 0 :      r3.x = r2.z;
//       r2.z = r1.x;
//       break;
//       case 1 :      r1.y = r3.x;
//       r1.z = r2.x;
//       r3.x = r2.z;
//       r2.xz = r1.yz;
//       break;
//       case 2 :      r1.y = r2.z;
//       r2.z = r2.x;
//       r3.x = r1.x;
//       r2.x = r1.y;
//       break;
//       case 3 :      r1.y = r2.z;
//       r2.z = r3.x;
//       r3.x = r2.x;
//       r2.x = r1.y;
//       break;
//       case 4 :      r3.x = r2.x;
//       r2.x = r1.x;
//       break;
//       case 5 :      break;
//     }
//   }
//   r2.yw = float2(1,1);
//   // r1.xy = hdrContrast * float2(1,-0.5) + float2(0,0.5);
//   r1.xy = float2(1,-0.5) + float2(0,0.5);
//   r4.x = dot(r2.xy, r1.xy);
//   r4.y = dot(r2.zw, r1.xy);
//   r3.y = 1;
//   r4.z = dot(r3.xy, r1.xy);

//   renodx::draw::Config config = renodx::draw::BuildConfig();
//   float3 color = r4.rgb;

//   color = ToneMapLMS(color, 203.f, 1156.f, 1.0f, 1.0f); 

//   color = GammaCorrectHuePreserving(color, 2.2f);

//   color = expandGamut(color, 1.0f);

//   // Gamut Compression
//   color = renodx::color::bt2020::from::BT709(color);
//   float grayscale = renodx::color::y::from::BT2020(color);
//   const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
//   const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
//   const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
//   float encode_gamma = MID_GRAY_GAMMA;
//   float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
//   float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
//   float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
//   color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);
//   color = max(0.f, color);

//   r0.rgb = color * 203;
//   // r0.rgb = color * shader_injection.graphics_white_nits;
//   // r0.rgb = color * RENODX_GRAPHICS_WHITE_NITS;
//   o0.w = r0.w;
//   o0.rgb = renodx::color::pq::Encode(r0.rgb, 1.f);
  
//   // color *= 300;

//   // [branch]
//   // if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_BT709D93) {
//   //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
//   //   color = renodx::color::bt709::from::BT709D93(color);
//   //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
//   // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCU) {
//   //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
//   //   color = renodx::color::bt709::from::BT601NTSCU(color);
//   //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
//   // } else if (config.swap_chain_custom_color_space == renodx::draw::COLOR_SPACE_CUSTOM_NTSCJ) {
//   //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, renodx::color::convert::COLOR_SPACE_BT709);
//   //   color = renodx::color::bt709::from::ARIBTRB9(color);
//   //   config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT709;
//   // }

//   // color = min(color, config.swap_chain_clamp_nits);  // Clamp UI or Videos

//   // [branch]
//   // if (config.swap_chain_clamp_color_space == renodx::color::convert::COLOR_SPACE_UNKNOWN) {
//   //   color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
//   // } else {
//   //   [branch]
//   //   if (config.swap_chain_clamp_color_space == config.swap_chain_encoding_color_space) {
//   //     color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_encoding_color_space);
//   //     color = max(0, color);
//   //   } else {
//   //     if (config.swap_chain_clamp_color_space != config.swap_chain_decoding_color_space) {
//   //       color = renodx::color::convert::ColorSpaces(color, config.swap_chain_decoding_color_space, config.swap_chain_clamp_color_space);
//   //     }
//   //     color = max(0, color);
//   //     color = renodx::color::convert::ColorSpaces(color, config.swap_chain_clamp_color_space, config.swap_chain_encoding_color_space);
//   //   }
//   // }

//   // color = renodx::color::bt2020::from::BT709(color);
//   // color = renodx::color::pq::EncodeSafe(color, 1.f);
//   // o0.rgb = color;
//   // o0.w = r0.w;

  
  
//   return;
// }

#include "common.hlsl"

cbuffer cb0_buf : register(b0)
{
  float4 cb0_m : packoffset(c0);
};

Texture2D<float4> tTex : register(t0);

static float4 gl_FragCoord;
static float4 SV_Target;

struct SPIRV_Cross_Input
{
  float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
  float4 SV_Target : SV_Target0;
};

int cvt_f32_i32(float v)
{
  return isnan(v) ? 0 : ((v < (-2147483648.0f)) ? int(0x80000000) : ((v > 2147483520.0f) ? 2147483647 : int(v)));
}

uint cvt_f32_u32(float v)
{
  return (v > 4294967040.0f) ? 4294967295u : uint(max(v, 0.0f));
}

float dp2_f32(float2 a, float2 b)
{
  precise float _83 = a.x * b.x;
  return mad(a.y, b.y, _83);
}

float dp3_f32(float3 a, float3 b)
{
  precise float _67 = a.x * b.x;
  return mad(a.z, b.z, mad(a.y, b.y, _67));
}

void frag_main()
{
  float4 _122 = tTex.Load(int3(uint2(uint(cvt_f32_i32(gl_FragCoord.x)), uint(cvt_f32_i32(gl_FragCoord.y))), 0u));
  float _123 = _122.x;
  float _124 = _122.y;
  float _125 = _122.z;
  float _179;
  float _180;
  float _181;
  if (_123 < _124)
    {
    float _132 = _124 - _123;
    float _133 = _125 - _123;
    float _134 = _124 - _125;
    float _139 = _133 * 60.0f;
    bool _146 = _124 < _125;
    bool _147 = _123 < _125;
    _179 = _146 ? ((_133 > 0.0f) ? ((((_123 - _124) * 60.0f) / _133) + 240.0f) : 0.0f) : (_147 ? ((_132 > 0.0f) ? ((_139 / _132) + 120.0f) : 0.0f) : ((_134 > 0.0f) ? ((_139 / _134) + 120.0f) : 0.0f));
    _180 = _146 ? _133 : (_147 ? _132 : _134);
    _181 = _146 ? _125 : _124;
  }
    else
    {
    float _156 = _125 - _124;
    float _157 = _123 - _124;
    float _159 = _123 - _125;
    float _164 = (_124 - _125) * 60.0f;
    bool _170 = _123 < _125;
    bool _171 = _124 < _125;
    _179 = _170 ? ((_156 > 0.0f) ? (((_157 * 60.0f) / _156) + 240.0f) : 0.0f) : (_171 ? ((_157 > 0.0f) ? (_164 / _157) : 0.0f) : ((_159 > 0.0f) ? (_164 / _159) : 0.0f));
    _180 = _170 ? _156 : (_171 ? _157 : _159);
    _181 = _170 ? _125 : _123;
  }
  float _189 = (_181 == 0.0f) ? 0.0f : ((_180 / _181) * cb0_m.x);
  // float _192 = cb0_m.z * _181;
  float _192 = _181;
  float _225;
  float _226;
  float _227;
  if (_189 == 0.0f)
    {
    _225 = _192;
    _226 = _192;
    _227 = _192;
  }
    else
    {
    float _203 = ((_179 < 0.0f) ? (_179 + 360.0f) : ((_179 > 360.0f) ? (_179 - 360.0f) : _179)) * 0.01666666753590106964111328125f;
    float _206 = frac(_203);
    float _208 = _192 * (1.0f - _189);
    float _211 = _192 * mad(-_206, _189, 1.0f);
    float _214 = _192 * mad(_206 - 1.0f, _189, 1.0f);
    float _222;
    float _223;
    float _224;
    switch (cvt_f32_u32(_203) % 6u)
        {
      case 0u:
            {
        _222 = _208;
        _223 = _214;
        _224 = _192;
        break;
      }
      case 1u:
            {
        _222 = _208;
        _223 = _192;
        _224 = _211;
        break;
      }
      case 2u:
            {
        _222 = _214;
        _223 = _192;
        _224 = _208;
        break;
      }
      case 3u:
            {
        _222 = _192;
        _223 = _211;
        _224 = _208;
        break;
      }
      case 4u:
            {
        _222 = _192;
        _223 = _208;
        _224 = _214;
        break;
      }
      case 5u:
            {
        _222 = _211;
        _223 = _208;
        _224 = _192;
        break;
      }
      default:
            {
        _222 = _211;
        _223 = _208;
        _224 = _192;
        break;
      }
    }
    _225 = _222;
    _226 = _223;
    _227 = _224;
  }
  // float2 _233 = float2(mad(cb0_m.y, 1.0f, 0.0f), mad(cb0_m.y, -0.5f, 0.5f));
  // float3 _239 = float3(dp2_f32(float2(_227, 1.0f), _233), dp2_f32(float2(_226, 1.0f), _233), dp2_f32(float2(_225, 1.0f), _233));
  float3 _239 = float3(_227, _226, _225);
  renodx::draw::Config config = renodx::draw::BuildConfig();
  float3 color = _239.rgb;

  if (RENODX_TONE_MAP_TYPE > 0.f)
    color = ToneMapLMS(color, RENODX_GRAPHICS_WHITE_NITS, RENODX_PEAK_WHITE_NITS);

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  }


  // Gamut Compression
  color = renodx::color::bt2020::from::BT709(color);
  float grayscale = renodx::color::y::from::BT2020(color);
  const float MID_GRAY_LINEAR = 1 / (pow(10, 0.75));                          // ~0.18f
  const float MID_GRAY_PERCENT = 0.5f;                                        // 50%
  const float MID_GRAY_GAMMA = log(MID_GRAY_LINEAR) / log(MID_GRAY_PERCENT);  // ~2.49f
  float encode_gamma = MID_GRAY_GAMMA;
  float3 encoded = renodx::color::gamma::EncodeSafe(color, encode_gamma);
  float encoded_gray = renodx::color::gamma::Encode(grayscale, encode_gamma);
  float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
  color = renodx::color::gamma::DecodeSafe(compressed, encode_gamma);
  color = max(0.f, color);

  // SV_Target.rgb = renodx::color::pq::Encode(color, 203.f);
  SV_Target.rgb = renodx::color::pq::Encode(color, RENODX_GRAPHICS_WHITE_NITS);

  SV_Target.w = _122.w * 0.00999999977648258209228515625f;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
  gl_FragCoord = stage_input.gl_FragCoord;
  gl_FragCoord.w = 1.0 / gl_FragCoord.w;
  frag_main();
  SPIRV_Cross_Output stage_output;
  stage_output.SV_Target = SV_Target;
  return stage_output;
}
