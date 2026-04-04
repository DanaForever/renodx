#include "../output.hlsl"

Texture2D<float4> t0 : register(t0);

cbuffer cb0 : register(b0) {
  float2 $Globals_000 : packoffset(c000.x);
  float2 $Globals_008 : packoffset(c000.z);
  float2 $Globals_016 : packoffset(c001.x);
  float2 $Globals_024 : packoffset(c001.z);
  int2 $Globals_032 : packoffset(c002.x);
  int2 $Globals_040 : packoffset(c002.z);
  float2 $Globals_048 : packoffset(c003.x);
  float2 $Globals_056 : packoffset(c003.z);
  float2 $Globals_064 : packoffset(c004.x);
  float2 $Globals_072 : packoffset(c004.z);
  float2 $Globals_080 : packoffset(c005.x);
  float2 $Globals_088 : packoffset(c005.z);
  float2 $Globals_096 : packoffset(c006.x);
  float2 $Globals_104 : packoffset(c006.z);
  float2 $Globals_112 : packoffset(c007.x);
  float2 $Globals_120 : packoffset(c007.z);
  float2 $Globals_128 : packoffset(c008.x);
  float2 $Globals_136 : packoffset(c008.z);
  int2 $Globals_144 : packoffset(c009.x);
  int2 $Globals_152 : packoffset(c009.z);
  float2 $Globals_160 : packoffset(c010.x);
  float2 $Globals_168 : packoffset(c010.z);
  float2 $Globals_176 : packoffset(c011.x);
  float2 $Globals_184 : packoffset(c011.z);
  float2 $Globals_192 : packoffset(c012.x);
  float2 $Globals_200 : packoffset(c012.z);
  float2 $Globals_208 : packoffset(c013.x);
  float2 $Globals_216 : packoffset(c013.z);
  float2 $Globals_224 : packoffset(c014.x);
  float2 $Globals_232 : packoffset(c014.z);
  float2 $Globals_240 : packoffset(c015.x);
  float2 $Globals_248 : packoffset(c015.z);
  int2 $Globals_256 : packoffset(c016.x);
  int2 $Globals_264 : packoffset(c016.z);
  float2 $Globals_272 : packoffset(c017.x);
  float2 $Globals_280 : packoffset(c017.z);
  float2 $Globals_288 : packoffset(c018.x);
  float2 $Globals_296 : packoffset(c018.z);
  float2 $Globals_304 : packoffset(c019.x);
  float2 $Globals_312 : packoffset(c019.z);
  float2 $Globals_320 : packoffset(c020.x);
  float2 $Globals_328 : packoffset(c020.z);
  float2 $Globals_336 : packoffset(c021.x);
  float2 $Globals_344 : packoffset(c021.z);
  float2 $Globals_352 : packoffset(c022.x);
  float2 $Globals_360 : packoffset(c022.z);
  int2 $Globals_368 : packoffset(c023.x);
  int2 $Globals_376 : packoffset(c023.z);
  float2 $Globals_384 : packoffset(c024.x);
  float2 $Globals_392 : packoffset(c024.z);
  float2 $Globals_400 : packoffset(c025.x);
  float2 $Globals_408 : packoffset(c025.z);
  float2 $Globals_416 : packoffset(c026.x);
  float2 $Globals_424 : packoffset(c026.z);
  float2 $Globals_432 : packoffset(c027.x);
  float2 $Globals_440 : packoffset(c027.z);
  float2 $Globals_448 : packoffset(c028.x);
  float2 $Globals_456 : packoffset(c028.z);
  float2 $Globals_464 : packoffset(c029.x);
  float2 $Globals_472 : packoffset(c029.z);
  int2 $Globals_480 : packoffset(c030.x);
  int2 $Globals_488 : packoffset(c030.z);
  float2 $Globals_496 : packoffset(c031.x);
  float2 $Globals_504 : packoffset(c031.z);
  float2 $Globals_512 : packoffset(c032.x);
  float2 $Globals_520 : packoffset(c032.z);
  float2 $Globals_528 : packoffset(c033.x);
  float2 $Globals_536 : packoffset(c033.z);
  float2 $Globals_544 : packoffset(c034.x);
  float2 $Globals_552 : packoffset(c034.z);
  float2 $Globals_560 : packoffset(c035.x);
  float2 $Globals_568 : packoffset(c035.z);
  float2 $Globals_576 : packoffset(c036.x);
  float2 $Globals_584 : packoffset(c036.z);
  int2 $Globals_592 : packoffset(c037.x);
  int2 $Globals_600 : packoffset(c037.z);
  float2 $Globals_608 : packoffset(c038.x);
  float2 $Globals_616 : packoffset(c038.z);
  float2 $Globals_624 : packoffset(c039.x);
  float2 $Globals_632 : packoffset(c039.z);
  float2 $Globals_640 : packoffset(c040.x);
  float2 $Globals_648 : packoffset(c040.z);
  float2 $Globals_656 : packoffset(c041.x);
  float2 $Globals_664 : packoffset(c041.z);
  float4 $Globals_672 : packoffset(c042.x);
};

cbuffer cb1 : register(b1) {
  float4 Material_000[2] : packoffset(c000.x);
  float4 Material_032[1] : packoffset(c002.x);
};

SamplerState s0 : register(s0);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float4 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target;
  float _17 = (SV_Position.x - float((uint)((int)($Globals_592.x)))) * ($Globals_616.x);
  float _18 = (SV_Position.y - float((uint)((int)($Globals_592.y)))) * ($Globals_616.y);
  float4 _38 = t0.Sample(s0, float2(min(max(((_17 * ($Globals_080.x)) + ($Globals_064.x)), ($Globals_096.x)), ($Globals_104.x)), min(max(((_18 * ($Globals_080.y)) + ($Globals_064.y)), ($Globals_096.y)), ($Globals_104.y))));
  _38.rgb = PQtoSRGB(_38.rgb);

  float4 _62 = t0.Sample(s0, float2(min(max(((($Globals_080.x) * _17) + ($Globals_064.x)), ($Globals_096.x)), ($Globals_104.x)), min(max(((($Globals_080.y) * (_18 + 0.0010000000474974513f)) + ($Globals_064.y)), ($Globals_096.y)), ($Globals_104.y))));
  _62.rgb = PQtoSRGB(_62.rgb);

  float4 _86 = t0.Sample(s0, float2(min(max(((($Globals_080.x) * _17) + ($Globals_064.x)), ($Globals_096.x)), ($Globals_104.x)), min(max(((($Globals_080.y) * (_18 + -0.0010000000474974513f)) + ($Globals_064.y)), ($Globals_096.y)), ($Globals_104.y))));
  _86.rgb = PQtoSRGB(_86.rgb);

  float4 _110 = t0.Sample(s0, float2(min(max(((($Globals_080.x) * (_17 + 0.0010000000474974513f)) + ($Globals_064.x)), ($Globals_096.x)), ($Globals_104.x)), min(max(((($Globals_080.y) * _18) + ($Globals_064.y)), ($Globals_096.y)), ($Globals_104.y))));
  _110.rgb = PQtoSRGB(_110.rgb);

  float4 _134 = t0.Sample(s0, float2(min(max(((($Globals_080.x) * (_17 + -0.0010000000474974513f)) + ($Globals_064.x)), ($Globals_096.x)), ($Globals_104.x)), min(max(((($Globals_080.y) * _18) + ($Globals_064.y)), ($Globals_096.y)), ($Globals_104.y))));
  _134.rgb = PQtoSRGB(_134.rgb);

  // float3 average_color = float3(((_38.x - ((((_86.x + _62.x) + _110.x) + _134.x) * 0.25f)) * 0.30000001192092896f), ((_38.y - ((((_86.y + _62.y) + _110.y) + _134.y) * 0.25f)) * 0.30000001192092896f), ((_38.z - ((((_86.z + _62.z) + _110.z) + _134.z) * 0.25f)) * 0.30000001192092896f));

  // float y = renodx::color::y::from::AP1(average_color);

  float _156 = dot(float3(((_38.x - ((((_86.x + _62.x) + _110.x) + _134.x) * 0.25f)) * 0.30000001192092896f), ((_38.y - ((((_86.y + _62.y) + _110.y) + _134.y) * 0.25f)) * 0.30000001192092896f), ((_38.z - ((((_86.z + _62.z) + _110.z) + _134.z) * 0.25f)) * 0.30000001192092896f)), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
  float _157 = _156 + _38.x;
  float _158 = _156 + _38.y;
  float _159 = _156 + _38.z;
  // SV_Target.x = max(((((Material_000[1].x) - _157) * (Material_032[0].x)) + _157), 0.0f);
  // SV_Target.y = max(((((Material_000[1].y) - _158) * (Material_032[0].x)) + _158), 0.0f);
  // SV_Target.z = max(((((Material_000[1].z) - _159) * (Material_032[0].x)) + _159), 0.0f);
  SV_Target.x = ((((Material_000[1].x) - _157) * (Material_032[0].x)) + _157);
  SV_Target.y = ((((Material_000[1].y) - _158) * (Material_032[0].x)) + _158);
  SV_Target.z = ((((Material_000[1].z) - _159) * (Material_032[0].x)) + _159);

  if (shader_injection.processing_path == 0.f) {
    // instead of disabling this shader, we match the luminance of the output color to the original color
    float4 output = t0.Sample(s0, float2(_17, _18));
    float4 output_pq = output;
    output.rgb = PQtoSRGB(output.rgb);

    SV_Target.rgb = renodx::color::srgb::DecodeSafe(output.rgb);
    output.rgb = renodx::color::srgb::DecodeSafe(output.rgb);

    SV_Target.rgb = renodx::color::correct::Luminance(SV_Target.rgb, output.rgb);
    SV_Target.rgb = renodx::color::srgb::EncodeSafe(SV_Target.rgb);
    SV_Target.rgb = SRGBtoPQ(SV_Target.rgb);
  }

  SV_Target.w = 1.0f;
  return SV_Target;
}
