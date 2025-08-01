#include "./common.hlsl"

Texture2D<float4> UITexture : register(t0);

Texture2D<float4> SceneTexture : register(t1);

cbuffer $Globals : register(b0) {
  float UILevel : packoffset(c000.x);
  float UILuminance : packoffset(c000.y);
};

SamplerState UISampler : register(s0);

SamplerState SceneSampler : register(s1);

float4 main(
  noperspective float2 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float UILevel = 1.0f;
  float UILuminance = RENODX_GRAPHICS_WHITE_NITS;

  float4 SV_Target;
  float4 _11 = UITexture.Sample(UISampler, float2(TEXCOORD.x, TEXCOORD.y));
  float _16 = max(6.103519990574569e-05f, _11.x);
  float _17 = max(6.103519990574569e-05f, _11.y);
  float _18 = max(6.103519990574569e-05f, _11.z);
  float _40 = select((_16 > 0.040449999272823334f), exp2(log2((_16 * 0.9478672742843628f) + 0.05213269963860512f) * 2.4000000953674316f), (_16 * 0.07739938050508499f));
  float _41 = select((_17 > 0.040449999272823334f), exp2(log2((_17 * 0.9478672742843628f) + 0.05213269963860512f) * 2.4000000953674316f), (_17 * 0.07739938050508499f));
  float _42 = select((_18 > 0.040449999272823334f), exp2(log2((_18 * 0.9478672742843628f) + 0.05213269963860512f) * 2.4000000953674316f), (_18 * 0.07739938050508499f));
  float4 _59 = SceneTexture.Sample(SceneSampler, float2(TEXCOORD.x, TEXCOORD.y));

  if (HandleUICompositing(_11, _59, SV_Target)) {
    return SV_Target;
  }

  float _69 = (pow(_59.x, 0.012683313339948654f));
  float _70 = (pow(_59.y, 0.012683313339948654f));
  float _71 = (pow(_59.z, 0.012683313339948654f));
  float _96 = exp2(log2(max(0.0f, (_69 + -0.8359375f)) / (18.8515625f - (_69 * 18.6875f))) * 6.277394771575928f) * 10000.0f;
  float _97 = exp2(log2(max(0.0f, (_70 + -0.8359375f)) / (18.8515625f - (_70 * 18.6875f))) * 6.277394771575928f) * 10000.0f;
  float _98 = exp2(log2(max(0.0f, (_71 + -0.8359375f)) / (18.8515625f - (_71 * 18.6875f))) * 6.277394771575928f) * 10000.0f;
  float _119;
  float _120;
  float _121;
  if ((bool)(_11.w > 0.0f) && (bool)(_11.w < 1.0f)) {
    float _104 = max(_96, 0.0f);
    float _105 = max(_97, 0.0f);
    float _106 = max(_98, 0.0f);
    float _114 = ((((1.0f / ((dot(float3(_104, _105, _106), float3(0.26269999146461487f, 0.6779999732971191f, 0.059300001710653305f)) / UILevel) + 1.0f)) * UILevel) + -1.0f) * _11.w) + 1.0f;
    _119 = (_114 * _104);
    _120 = (_114 * _105);
    _121 = (_114 * _106);
  } else {
    _119 = _96;
    _120 = _97;
    _121 = _98;
  }
  float _122 = 1.0f - _11.w;
  float _141 = exp2(log2(((_119 * _122) + ((UILuminance * mad(0.043313056230545044f, _42, mad(0.3292830288410187f, _41, (_40 * 0.6274039149284363f)))) * UILevel)) * 9.999999747378752e-05f) * 0.1593017578125f);
  float _142 = exp2(log2(((_120 * _122) + ((UILuminance * mad(0.011362319812178612f, _42, mad(0.919540286064148f, _41, (_40 * 0.06909731030464172f)))) * UILevel)) * 9.999999747378752e-05f) * 0.1593017578125f);
  float _143 = exp2(log2(((_121 * _122) + ((UILuminance * mad(0.8955953121185303f, _42, mad(0.08801331371068954f, _41, (_40 * 0.016391439363360405f)))) * UILevel)) * 9.999999747378752e-05f) * 0.1593017578125f);
  SV_Target.x = exp2(log2((1.0f / ((_141 * 18.6875f) + 1.0f)) * ((_141 * 18.8515625f) + 0.8359375f)) * 78.84375f);
  SV_Target.y = exp2(log2((1.0f / ((_142 * 18.6875f) + 1.0f)) * ((_142 * 18.8515625f) + 0.8359375f)) * 78.84375f);
  SV_Target.z = exp2(log2((1.0f / ((_143 * 18.6875f) + 1.0f)) * ((_143 * 18.8515625f) + 0.8359375f)) * 78.84375f);
  SV_Target.w = 1.0f;
  return SV_Target;
}
