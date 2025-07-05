// ---- Created with 3Dmigoto v1.3.16 on Thu Jul 03 16:53:09 2025

cbuffer _Globals : register(b0)
{
  uint4 DuranteSettings : packoffset(c0);

  struct
  {
    float3 EyePosition;
    float4x4 View;
    float4x4 Projection;
    float4x4 ViewProjection;
    float4x4 ViewInverse;
    float4x4 ProjectionInverse;
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
    float4 light1_attenuation;
    float3 light2_position;
    float3 light2_colorIntensity;
    float4 light2_attenuation;
  } scene : packoffset(c1);

  bool PhyreContextSwitches : packoffset(c43);
  float4x4 World : packoffset(c44);
  float4x4 WorldView : packoffset(c48);
  float4x4 WorldViewProjection : packoffset(c52);
  float4x4 WorldViewInverse : packoffset(c56);
  float4x4 WorldViewProjectionInverse : packoffset(c60);
  float4x4 WorldInverse : packoffset(c64);
  float CameraAspectRatio : packoffset(c68);
  float4 inputColor : packoffset(c69) = {1,1,1,1};
  float3 inputSpecular : packoffset(c70) = {0,0,0};
  float inputAlphaThreshold : packoffset(c70.w) = {0};
  float4 inputCenter : packoffset(c71) = {0,0,0,0};
  float4 inputUVShift : packoffset(c72) = {1,1,0,0};
  float4 inputUVShift1 : packoffset(c73) = {1,1,0,0};
  float4 inputUVShift2 : packoffset(c74) = {1,1,0,0};
  float2 inputUVtraspose : packoffset(c75) = {1,0};
  float2 inputUVtraspose1 : packoffset(c75.z) = {1,0};
  float2 inputUVtraspose2 : packoffset(c76) = {1,0};
  float4 inputShaderParam : packoffset(c77) = {0,0,0,0};
  float2 inputDUDVParam1 : packoffset(c78) = {1,1};
  float2 inputScreenOffset : packoffset(c78.z) = {0,0};
  float inputDepth : packoffset(c79) = {0};
  float2 inputSoftCheckDepthParam : packoffset(c79.y) = {10,0};
  float3 inputNearFadeClip : packoffset(c80) = {0,0,1};
  float inputDownscaleFactor : packoffset(c80.w) = {1};
  float2 inputDepthBufferSize : packoffset(c81) = {960,544};
  float2 inputDistortion : packoffset(c81.z) = {0,0};
  float3 inputBlurParam : packoffset(c82) = {0,0,0};
  float4 inputMonotoneMul : packoffset(c83) = {1,1,1,1};
  float4 inputMonotoneAdd : packoffset(c84) = {0,0,0,0};
  float4 inputInvProjXY : packoffset(c85) = {0,0,0,0};
}

SamplerState VariableSamplerState_s : register(s0);
Texture2D<float4> TextureSampler : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = TextureSampler.Sample(VariableSamplerState_s, v2.xy).xyzw;
  r1.x = r0.w * v1.w + -inputAlphaThreshold;
  r1.x = cmp(r1.x < 0);
  if (r1.x != 0) discard;
  r0.w = v1.w * r0.w;
  o0.xyz = r0.xyz * v1.xyz + inputSpecular.xyz;
  o0.w = r0.w;
  return;
}