Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

cbuffer cb0 : register(b0) {
  float4 $Globals_000 : packoffset(c000.x);
  float4 $Globals_016 : packoffset(c001.x);
  float4 $Globals_032 : packoffset(c002.x);
  float4 $Globals_048 : packoffset(c003.x);
  float4 $Globals_064 : packoffset(c004.x);
  float4 $Globals_080 : packoffset(c005.x);
  float4 $Globals_096 : packoffset(c006.x);
  float4 $Globals_112 : packoffset(c007.x);
  float4 $Globals_128 : packoffset(c008.x);
  float4 $Globals_144 : packoffset(c009.x);
};

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

SamplerState s2 : register(s2);

float4 main(
  noperspective float4 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target;
  float4 _12 = t0.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _14 = t1.Sample(s1, float2(TEXCOORD.z, TEXCOORD.w));
  float4 _16 = t2.Sample(s2, float2(TEXCOORD.z, TEXCOORD.w));
  float _67 = ((((($Globals_016.x) * _14.x) + (($Globals_064.x) * _12.x)) + (($Globals_032.x) * _16.x)) + ($Globals_048.x)) * ($Globals_000.x);
  float _68 = ((((($Globals_016.y) * _14.x) + (($Globals_064.y) * _12.x)) + (($Globals_032.y) * _16.x)) + ($Globals_048.y)) * ($Globals_000.y);
  float _69 = ((((($Globals_016.z) * _14.x) + (($Globals_064.z) * _12.x)) + (($Globals_032.z) * _16.x)) + ($Globals_048.z)) * ($Globals_000.z);
  SV_Target.x = (((((_67 * 0.30530601739883423f) + 0.682171106338501f) * _67) + 0.012522878125309944f) * _67);
  SV_Target.y = (((((_68 * 0.30530601739883423f) + 0.682171106338501f) * _68) + 0.012522878125309944f) * _68);
  SV_Target.z = (((((_69 * 0.30530601739883423f) + 0.682171106338501f) * _69) + 0.012522878125309944f) * _69);
  SV_Target.w = (((((($Globals_016.w) * _14.x) + (($Globals_064.w) * _12.x)) + (($Globals_032.w) * _16.x)) + ($Globals_048.w)) * ($Globals_000.w));
  return SV_Target;
}
