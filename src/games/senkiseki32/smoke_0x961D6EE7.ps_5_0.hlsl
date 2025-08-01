// ---- Created with 3Dmigoto v1.3.16 on Sat Jul 26 18:35:24 2025

cbuffer _Globals : register(b0)
{
  bool PhyreContextSwitches : packoffset(c0);
  bool PhyreMaterialSwitches : packoffset(c0.y);
  float3 scene_EyePosition : packoffset(c1);
  float4x4 scene_View : packoffset(c2);
  float4x4 scene_ViewProjection : packoffset(c6);
  float3 scene_GlobalAmbientColor : packoffset(c10);
  float scene_GlobalTexcoordFactor : packoffset(c10.w);
  float3 scene_FakeRimLightDir : packoffset(c11);
  float4 scene_MiscParameters2 : packoffset(c12);
  float scene_AdditionalShadowOffset : packoffset(c13);
  float4 scene_cameraNearFarParameters : packoffset(c14);
  float4x4 World : packoffset(c15);
  float PerMaterialMainLightClampFactor : packoffset(c19) = {1.5};
  float GlobalMainLightClampFactor : packoffset(c19.y) = {1.5};
  float ReflectionIntensity : packoffset(c19.z) = {0.75};

  struct
  {
    float3 m_direction;
    float3 m_colorIntensity;
  } Light0 : packoffset(c20);


  struct
  {
    float4x4 m_split0Transform;
    float4x4 m_split1Transform;
    float4 m_splitDistances;
  } LightShadow0 : packoffset(c22);

  float GameMaterialID : packoffset(c31) = {0};
  float4 GameMaterialDiffuse : packoffset(c32) = {1,1,1,1};
  float3 GameMaterialEmission : packoffset(c33) = {0,0,0};
  float4 GameMaterialTexcoord : packoffset(c34) = {0,0,1,1};
  float4 UVaMUvColor : packoffset(c35) = {1,1,1,1};
  float4 UVaProjTexcoord : packoffset(c36) = {0,0,1,1};
  float4 UVaMUvTexcoord : packoffset(c37) = {0,0,1,1};
  float4 UVaMUv2Texcoord : packoffset(c38) = {0,0,1,1};
  float4 UVaDuDvTexcoord : packoffset(c39) = {0,0,1,1};
  float AlphaThreshold : packoffset(c40) = {0.5};
  float3 ShadowColorShift : packoffset(c40.y) = {0.100000001,0.0199999996,0.0199999996};
  float Shininess : packoffset(c41) = {0.5};
  float SpecularPower : packoffset(c41.y) = {50};
  float3 SpecularColor : packoffset(c42) = {1,1,1};
  float3 RimLitColor : packoffset(c43) = {1,1,1};
  float RimLitIntensity : packoffset(c43.w) = {4};
  float RimLitPower : packoffset(c44) = {2};
  float2 TexCoordOffset : packoffset(c44.y) = {0,0};
  float2 TexCoordOffset2 : packoffset(c45) = {0,0};
  float2 TexCoordOffset3 : packoffset(c45.z) = {0,0};
  float SphereMapIntensity : packoffset(c46) = {1};
  float CubeFresnelPower : packoffset(c46.y) = {0};
  float2 ProjectionScale : packoffset(c46.z) = {1,1};
  float2 ProjectionScroll : packoffset(c47) = {0,0};
  float2 DuDvMapImageSize : packoffset(c47.z) = {256,256};
  float2 DuDvScroll : packoffset(c48) = {1,1};
  float2 DuDvScale : packoffset(c48.z) = {4,4};
  float2 WindyGrassDirection : packoffset(c49) = {0,0};
  float WindyGrassSpeed : packoffset(c49.z) = {2};
  float WindyGrassHomogenity : packoffset(c49.w) = {2};
  float WindyGrassScale : packoffset(c50) = {1};
  float GlareIntensity : packoffset(c50.y) = {1};
  uint4 DuranteSettings : packoffset(c51);
}

SamplerState DiffuseMapSamplerS_s : register(s0);
SamplerState NormalMapSamplerS_s : register(s1);
Texture2D<float4> DiffuseMapSampler : register(t0);
Texture2D<float4> NormalMapSampler : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float4 v2 : COLOR1,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD4,
  float3 v6 : TEXCOORD6,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = DiffuseMapSampler.Sample(DiffuseMapSamplerS_s, v3.xy).xyzw;
  r0.w = v1.w * r0.w;
  r1.xyzw = GameMaterialDiffuse.xyzw * r0.xyzw;
  r0.x = r0.w * GameMaterialDiffuse.w + -0.00400000019;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.x = dot(v6.xyz, v6.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v6.xyz * r0.xxx;
  r0.w = dot(v5.xyz, v5.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = v5.xyz * r0.www;
  r3.xyz = r2.zxy * r0.yzx;
  r3.xyz = r2.yzx * r0.zxy + -r3.xyz;
  r4.xyz = NormalMapSampler.Sample(NormalMapSamplerS_s, v3.xy).xyz;
  r4.xyz = r4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r3.xyz = r4.yyy * r3.xyz;
  r0.w = cmp(v3.x < 0);
  r0.w = r0.w ? -1 : 1;
  r0.w = r4.x * r0.w;
  r0.xyz = r0.www * r0.xyz + r3.xyz;
  r0.xyz = r4.zzz * r2.xyz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = scene_EyePosition.xyz + -v4.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.x = dot(r0.xyz, r2.xyz);
  r0.y = cmp(r0.x < 0);
  r0.x = r0.y ? -r0.x : r0.x;
  r0.x = 1 + -abs(r0.x);
  r0.x = log2(r0.x);
  r0.x = RimLitPower * r0.x;
  r0.x = exp2(r0.x);
  r0.x = -r0.x * RimLitIntensity + 1;
  o0.w = r1.w * r0.x;
  r0.x = max(Light0.m_colorIntensity.x, Light0.m_colorIntensity.y);
  r0.y = max(0.00100000005, Light0.m_colorIntensity.z);
  r0.x = max(r0.x, r0.y);
  r0.xyz = Light0.m_colorIntensity.xyz / r0.xxx;
  r0.xyz = min(GlobalMainLightClampFactor, r0.xyz);
  r0.xyz = GameMaterialEmission.xyz + r0.xyz;
  r2.xyz = min(float3(1,1,1), r0.xyz);
  r2.xyz = float3(1,1,1) + -r2.xyz;
  r2.xyz = ShadowColorShift.xyz * r2.xyz;
  r3.xyz = Light0.m_colorIntensity.xyz + Light0.m_colorIntensity.xyz;
  r3.xyz = max(float3(1,1,1), r3.xyz);
  r0.xyz = r2.xyz * r3.xyz + r0.xyz;
  r0.xyz = v1.xyz * r0.xyz;
  o0.xyz = r1.xyz * r0.xyz;

  o0.w = max(0.f, o0.w);
  return;
}