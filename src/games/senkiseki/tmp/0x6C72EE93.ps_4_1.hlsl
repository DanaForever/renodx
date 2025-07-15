// ---- Created with 3Dmigoto v1.3.16 on Mon Jul 14 23:43:52 2025

cbuffer _Globals : register(b0)
{

  struct
  {
    float3 EyePosition;
    float3 EyeDirection;
    float4x4 View;
    float4x4 Projection;
    float4x4 ViewProjection;
    float4x4 ViewInverse;
    float4x4 ProjectionInverse;
    float4x4 ViewProjectionPrev;
    float2 cameraNearFar;
    float cameraNearTimesFar;
    float cameraFarMinusNear;
    float cameraFarMinusNearInv;
    float2 ViewportWidthHeight;
    float2 screenWidthHeightInv;
    float3 GlobalAmbientColor;
    float Time;
    float3 FakeRimLightDir;
    float3 FogColor;
    float4 FogRangeParameters;
    float3 MiscParameters1;
    float4 MiscParameters2;
    float3 MonotoneMul;
    float3 MonotoneAdd;
    float3 UserClipPlane2;
    float4 UserClipPlane;
    float4 MiscParameters3;
    float AdditionalShadowOffset;
    float AlphaTestDirection;
    float4 MiscParameters4;
    float3 MiscParameters5;
    float4 MiscParameters6;
    float3 MiscParameters7;
    float3 light2_colorIntensity;
    float4 light2_attenuation;
    uint4 DuranteSettings;
  } scene : packoffset(c0);

  float MaskEps : packoffset(c48);
  bool PhyreContextSwitches : packoffset(c48.y);
  float4x4 World : packoffset(c49);
}

SamplerState PointClampSamplerState_s : register(s0);
Texture2D<float4> MovieTexture : register(t0);
Texture2D<float4> MovieTexture2 : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.xy / scene.ViewportWidthHeight.xy;
  r0.xy = v0.ww * r0.xy;
  r0.xy = r0.xy / v0.ww;
  r1.xyzw = MovieTexture2.SampleLevel(PointClampSamplerState_s, r0.xy, 0).xyzw;
  r0.z = r1.z * 0.00390625 + r1.y;
  r2.z = r0.z * 0.00390625 + r1.x;
  r2.xy = r0.xy * float2(2,-2) + float2(-1,1);
  r2.w = 1;
  r3.x = dot(r2.xyzw, scene.ProjectionInverse._m00_m10_m20_m30);
  r3.y = dot(r2.xyzw, scene.ProjectionInverse._m01_m11_m21_m31);
  r3.z = dot(r2.xyzw, scene.ProjectionInverse._m02_m12_m22_m32);
  r3.w = dot(r2.xyzw, scene.ProjectionInverse._m03_m13_m23_m33);
  r1.x = dot(r3.xyzw, scene.ViewInverse._m00_m10_m20_m30);
  r1.y = dot(r3.xyzw, scene.ViewInverse._m01_m11_m21_m31);
  r1.z = dot(r3.xyzw, scene.ViewInverse._m02_m12_m22_m32);
  r0.z = dot(r3.xyzw, scene.ViewInverse._m03_m13_m23_m33);
  r1.xyz = r1.xyz / r0.zzz;
  r1.xyz = v1.xyz + -r1.xyz;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.w = v1.w * v1.w;
  r0.w = cmp(r0.w < r0.z);
  if (r0.w != 0) discard;
  r0.xyw = MovieTexture.SampleLevel(PointClampSamplerState_s, r0.xy, 0).xyz;
  r1.w = 255.000015 * r1.w;
  r1.w = (uint)r1.w;
  r2.xyz = (int3)r1.www & int3(1,4,8);
  r3.xyz = r2.xxx ? float3(1,0,0.5) : float3(0,2.80259693e-045,1);
  r1.w = 255.000015 * v2.w;
  r1.w = (uint)r1.w;
  r2.x = (int)r3.y + (int)r3.x;
  r1.w = (int)r1.w & (int)r2.x;
  r1.w = min(1, (uint)r1.w);
  r1.w = (uint)r1.w;
  r1.w = r3.z * r1.w;
  r1.w = r2.z ? 0 : r1.w;
  r1.w = r2.y ? 0 : r1.w;
  r0.z = max(9.99999997e-007, r0.z);
  r0.z = sqrt(r0.z);
  r1.xyz = r1.xyz / r0.zzz;
  r0.z = r0.z / v1.w;
  r0.z = min(1, r0.z);
  r0.z = -r0.z * r0.z + 1;
  r0.xyw = r0.xyw * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = dot(r0.xyw, r1.xyz);
  r0.x = r0.x * 0.5 + 0.5;
  r0.x = r0.x * r0.x;
  r0.x = r0.z * r0.x;
  o0.w = r0.x * r1.w;
  o0.xyz = v2.xyz;
  return;
}