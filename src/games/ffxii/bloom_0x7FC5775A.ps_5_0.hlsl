// ---- Created with 3Dmigoto v1.3.16 on Sun Jun 01 02:12:25 2025

cbuffer _Globals : register(b0)
{
  bool PhyreMaterialSwitches : packoffset(c0);
  float4x4 World : packoffset(c1);
  float4x4 WorldView : packoffset(c5);
  float4x4 WorldInverse : packoffset(c9);
  float4x4 WorldViewProjection : packoffset(c13);
  float4x4 WorldViewInverse : packoffset(c17);
  float4 MaterialColour : packoffset(c21) = {1,1,1,1};
  float MaterialDiffuse : packoffset(c22) = {1};
  float MaterialEmissiveness : packoffset(c22.y) = {0};
  int iDebugMode : packoffset(c22.z);
  int mSpecialShadowFlag : packoffset(c22.w);
  float sssBlur : packoffset(c23);
  float2 dir : packoffset(c23.y);
  float2 SingleStepOffset : packoffset(c24);
  float blendAmount : packoffset(c24.z);
  int useBigKernel : packoffset(c24.w);
  float AlphaThreshold : packoffset(c25) = {0};
  float FarPlane : packoffset(c25.y) = {1000};
  float3 PS2ZBias : packoffset(c26) = {0,1024,16776191};
  float2 UvOffset : packoffset(c27) = {0,0};
  float4 PS2PLPos : packoffset(c28);
  float4x4 PS2MatLight : packoffset(c29);
  float4x4 PS2PLColor : packoffset(c33);
  float4x4 TextureMatrix : packoffset(c37);
  float3 SphereVec : packoffset(c41);
  int ObjectType : packoffset(c41.w) = {0};
  int EnableFog : packoffset(c42) = {0};
  float4 PS2FogVec : packoffset(c43);
  float3 FogColor : packoffset(c44);
  float4x4 PS2WHSMatrix : packoffset(c45);
  int EnableIndexedTex : packoffset(c49) = {0};
  int debugTextureDensity : packoffset(c49.y) = {0};
  float specularIntensity : packoffset(c49.z) = {0.300000012};
  float cubemapIntensity : packoffset(c49.w) = {0.600000024};
  float cubemapFactor : packoffset(c50) = {0.400000006};
  int drawDebug : packoffset(c50.y) = {0};
  float isBgNpc : packoffset(c50.z);
  float waterUFactor : packoffset(c50.w) = {1};
  float waterVFactor : packoffset(c51) = {1};
  int EnableNormalMap : packoffset(c51.y) = {0};
  int EnableSpecularMap : packoffset(c51.z) = {0};
  int EnableCubeMap : packoffset(c51.w) = {0};
  float CubeMapWeight0 : packoffset(c52);
  float CubeMapWeight1 : packoffset(c52.y);
  float CubeMapWeight2 : packoffset(c52.z);
  float CubeMapWeight3 : packoffset(c52.w);
  int EnableProceduralTexture : packoffset(c53) = {0};
  float ProceduralTilingOffsetU : packoffset(c53.y) = {0};
  float ProceduralTilingOffsetV : packoffset(c53.z) = {0};
  float ProceduralTilingRatioU : packoffset(c53.w) = {1};
  float ProceduralTilingRatioV : packoffset(c54) = {1};
  float ProceduralNormalBlendingRatio : packoffset(c54.y) = {0.5};
  float ProceduralRotation : packoffset(c54.z) = {0};
  float3 vDLDir : packoffset(c55) = {1,1,1};
  float3 vDLColor : packoffset(c56) = {1,1,1};
  float4 shadowVertexBlendLimit : packoffset(c57);
}

cbuffer SceneWideParameterConstantBuffer : register(b1)
{
  float4x4 ViewProjection : packoffset(c0);
  float4x4 View : packoffset(c4);
  float4x4 Projection : packoffset(c8);
  float4x4 ViewInverse : packoffset(c12);
  float4x4 ProjInverse : packoffset(c16);
  float3 EyePosition : packoffset(c20);
  float cameraNearTimesFar : packoffset(c20.w);
  float3 GlobalAmbientColor : packoffset(c21);
  float cameraFarMinusNear : packoffset(c21.w);
  float2 cameraNearFar : packoffset(c22);
  float2 ViewportWidthHeight : packoffset(c22.z);
  float2 screenWidthHeightInv : packoffset(c23);
  float2 screenWidthHeight : packoffset(c23.z);
  float time : packoffset(c24);
  int mapFresnelRefEnabled : packoffset(c24.y);
  float mapFresnelSpecularIntensity : packoffset(c24.z);
  float mapFresnelSpecularPower : packoffset(c24.w);
  float mapFresnelSpecularClampValue : packoffset(c25);
  float mapFresnelSpecularSkinIntensity : packoffset(c25.y);
  int eMapCameraLightEnabled : packoffset(c25.z);
  float eMapSpecularPowerModifier : packoffset(c25.w);
  float eMapSpecularPowerEyeCameraDistanceFactor : packoffset(c26);
  float eMapSpeIntenBefClpModifier : packoffset(c26.y);
  float eMapSpeIntenBefClpEyeCameraDistanceFactor : packoffset(c26.z);
  float eMapSpeIntenAftClpModifier : packoffset(c26.w);
  float eMapSpeIntenAftClpEyeCameraDistanceFactor : packoffset(c27);
  float eMapCubeMapIntensityModifier : packoffset(c27.y);
  float eMapSpculrBlndMdifir : packoffset(c27.z);
  float eMapCameraLightXModifier : packoffset(c27.w);
  float eMapCameraLightYModifier : packoffset(c28);
  float eMapCameraLightZModifier : packoffset(c28.y);
  float eMapShdwMdifir : packoffset(c28.z);
  float eMapAmbientMdifir : packoffset(c28.w);
  float eMapAmbientBnd : packoffset(c29);
  float hMapCmrLghtXMdifir : packoffset(c29.y);
  float hMapCmrLghtYMdifir : packoffset(c29.z);
  float hMapCmrLghtZMdifir : packoffset(c29.w);
  float hMapSpculrPwrMdifir : packoffset(c30);
  float hMapSpculrPwryCmrDistncFctr : packoffset(c30.y);
  float hMapSpIntnBfClpMdifir : packoffset(c30.z);
  float hMapSpIntnBfClpyCmrDistncFctr : packoffset(c30.w);
  float hMapSpIntnAftClpMdifir : packoffset(c31);
  float hMapSpIntnAftClpyCmrDistncFctr : packoffset(c31.y);
  float mapRefractionFactor : packoffset(c31.z) = {2};
  float mapWaterSpecFactor : packoffset(c31.w) = {3.58999991};
  float mapWaterTexBlendFactor : packoffset(c32) = {1};
  float mapWaterExtraFactorTwo : packoffset(c32.y) = {1};
  float mapWaterCubemapFactor : packoffset(c32.z) = {0.879999995};
  float mapWaterRoughnessFactor : packoffset(c32.w) = {1};
  float mapWaterParallaxFactor : packoffset(c33) = {0.100000001};
  float mapWaterFresnelFactor : packoffset(c33.y) = {3.80999994};
  float mapWaterBias : packoffset(c33.z) = {0.00100000005};
  int mapParallaxEnabled : packoffset(c33.w) = {1};
  float4 vMapAmbientColor : packoffset(c34) = {1,1,1,1};
  float vMapAmbColorCutPercent : packoffset(c35) = {0.300000012};
  float mapIrrCubeMapIntensity : packoffset(c35.y);
  float chrFresnelSpecularIntensity : packoffset(c35.z);
  float chrFresnelSpecularPower : packoffset(c35.w);
  float chrFresnelSpecularClampValue : packoffset(c36);
  float chrFresnelSpecularSkinIntensity : packoffset(c36.y);
  float hChrCmrLghtXMdifir : packoffset(c36.z);
  float hChrCmrLghtYMdifir : packoffset(c36.w);
  float hChrCmrLghtZMdifir : packoffset(c37);
  float hChrSpculrPwrMdifir : packoffset(c37.y);
  float hChrSpculrPwryCmrDistncFctr : packoffset(c37.z);
  float hChrSpIntnBfClpMdifir : packoffset(c37.w);
  float hChrSpIntnBfClpyCmrDistncFctr : packoffset(c38);
  float hChrSpIntnAftClpMdifir : packoffset(c38.y);
  float hChrSpIntnAftClpyCmrDistncFctr : packoffset(c38.z);
  float eChrCubeMapIntensityModifier : packoffset(c38.w);
  float eChrSpculrBlndMdifir : packoffset(c39);
  float eChrAmbientMdifir : packoffset(c39.y);
  float eChrAmbientBnd : packoffset(c39.z);
  float eChrShdwMdifir : packoffset(c39.w);
  float xChrCmrLghtXMdifir : packoffset(c40);
  float xChrCmrLghtYMdifir : packoffset(c40.y);
  float xChrCmrLghtZMdifir : packoffset(c40.z);
  float xChrSpculrPwrMdifir : packoffset(c40.w);
  float xChrSpculrPwryCmrDistncFctr : packoffset(c41);
  float xChrSpIntnBfClpMdifir : packoffset(c41.y);
  float xChrSpIntnBfClpyCmrDistncFctr : packoffset(c41.z);
  float xChrSpIntnAftClpMdifir : packoffset(c41.w);
  float xChrSpIntnAftClpyCmrDistncFctr : packoffset(c42);
  float yChrCmrLghtXMdifir : packoffset(c42.y);
  float yChrCmrLghtYMdifir : packoffset(c42.z);
  float yChrCmrLghtZMdifir : packoffset(c42.w);
  float yChrSpculrPwrMdifir : packoffset(c43);
  float yChrSpculrPwryCmrDistncFctr : packoffset(c43.y);
  float yChrSpIntnBfClpMdifir : packoffset(c43.z);
  float yChrSpIntnBfClpyCmrDistncFctr : packoffset(c43.w);
  float yChrSpIntnAftClpMdifir : packoffset(c44);
  float yChrSpIntnAftClpyCmrDistncFctr : packoffset(c44.y);
  float chrDiffuseIntensity : packoffset(c44.z);
  float chrSpecularIntensity : packoffset(c44.w);
  float chrCubemapIntensity : packoffset(c45);
  int chrDebugCubemap : packoffset(c45.y) = {0};
  float chrCubeMapFactor : packoffset(c45.z);
  float chrIrrCubeMapIntensity : packoffset(c45.w);
  int drawNormal : packoffset(c46);
  int chrDebugTextureDensity : packoffset(c46.y);
  int chrUseVertexColor : packoffset(c46.z);
  int iShadowCascadesUseCount : packoffset(c46.w);
  float4x4 mShadowCascadeProjection0 : packoffset(c47);
  float4x4 mShadowCascadeProjection1 : packoffset(c51);
  float4x4 mShadowCascadeProjection2 : packoffset(c55);
  float4x4 mShadowCascadeProjection3 : packoffset(c59);
  float4x4 mShadowCascadeProjection4 : packoffset(c63);
  float4x4 mShadowCascadeProjection5 : packoffset(c67);
  float4x4 mShadowCascadeProjection6 : packoffset(c71);
  float4x4 mShadowCascadeProjection7 : packoffset(c75);
  float4 m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_1 : packoffset(c79);
  float4 m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_2 : packoffset(c80);
  float4 m_shadowLightDir : packoffset(c81);
  float4 mShadowColor : packoffset(c82);
  float4 mSpecialShadowColor : packoffset(c83);
  float m_fShadowMinBorderPadding : packoffset(c84);
  float m_fShadowMaxBorderPadding : packoffset(c84.y);
  float m_fShadowCascadeBlendArea : packoffset(c84.z);
  float m_fShadowBiasFromGUI : packoffset(c84.w);
  float m_fShadowPartitionSize : packoffset(c85);
  float m_fShadowTexelSize : packoffset(c85.y);
  float m_fShadowNativeTexelSizeInX : packoffset(c85.z);
  float mShadowDecayDistance : packoffset(c85.w);
  int mShadowEnableDecay : packoffset(c86);
  int shadowLevel : packoffset(c86.y);
  int iShadowCascade_selection : packoffset(c86.z);
  int iShadowBlend_between_cascade : packoffset(c86.w);
  int m_iShadowVisualizeCascades : packoffset(c87);
  int mMSAACount : packoffset(c87.y);
  float mapIrrCubeMapFactor : packoffset(c87.z);
  float mapSoftParticleFactor : packoffset(c87.w);
  float rtWidth : packoffset(c88) = {1920};
  float rtHeight : packoffset(c88.y) = {1080};
  float chrIrrCubeMapFactor : packoffset(c88.z);
  float sssWidthInternal : packoffset(c88.w);
  float3 ssssb : packoffset(c89);
  float sssFarPlane : packoffset(c89.w);
  int sssEnable : packoffset(c90);
  float m_objMaxHeight : packoffset(c90.y);
  int m_iMapPCFBlurForLoopStart : packoffset(c90.z);
  int m_iMapPCFBlurForLoopEnd : packoffset(c90.w);
  int m_iChrPCFBlurForLoopStart : packoffset(c91);
  int m_iChrPCFBlurForLoopEnd : packoffset(c91.y);
  int mMapEnableHeightFade : packoffset(c91.z);
  int mChrEnableHeightFade : packoffset(c91.w);
  float mMapShadowValueLerpMin : packoffset(c92);
  float mChrShadowValueLerpMin : packoffset(c92.y);
  float m_objHeight : packoffset(c92.z);
  float m_objFlyingHeight : packoffset(c92.w);
  float mShadowFadeSpeed : packoffset(c93);
  float mShadowFlyingFadeSpeed : packoffset(c93.y);
  float mShadowFadeRange : packoffset(c93.z);
  float mShadowFlyingFadeRange : packoffset(c93.w);
  float m_mapFadeHeight : packoffset(c94);
}

SamplerState TextureSamplerSampler_s : register(s0);
SamplerState g_ChrAlphaSampler_s : register(s2);
SamplerState LinearSamplerShadow_s : register(s3);
SamplerState NormalSpecSamplerSampler_s : register(s4);
SamplerState CubeMapSampler_s : register(s5);
SamplerState ProceduralNormalSampler_s : register(s6);
SamplerState PalletTexSamplerState_s : register(s7);
SamplerComparisonState g_samShadow_s : register(s1);
Texture2D<float4> TextureSampler : register(t0);
Texture2D<float> g_txShadow : register(t1);
Texture2D<float4> g_txChrAlpha : register(t2);
Texture2D<float4> PalletTexture : register(t3);
Texture2D<float> IndexTexture : register(t4);
Texture2D<float4> NormalMap : register(t5);
Texture2D<float4> SpecularMap : register(t6);
TextureCube<float4> CubeMap0 : register(t7);
TextureCube<float4> CubeMap1 : register(t8);
TextureCube<float4> CubeMap2 : register(t9);
TextureCube<float4> CubeMap3 : register(t10);
TextureCube<float4> IrrCubeMap0 : register(t11);
TextureCube<float4> IrrCubeMap1 : register(t12);
TextureCube<float4> IrrCubeMap2 : register(t13);
TextureCube<float4> IrrCubeMap3 : register(t14);
Texture2D<float4> ProceduralNormalTexture : register(t15);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : COLOR0,
  float3 v1 : COLOR1,
  float4 v2 : SV_POSITION0,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  float4 v5 : TEXCOORD2,
  float4 v6 : TEXCOORD3,
  float4 v7 : TEXCOORD4,
  float4 v8 : TEXCOORD5,
  float4 v9 : TEXCOORD6,
  float4 v10 : TEXCOORD7,
  float4 v11 : TEXCOORD8,
  float3 v12 : TEXCOORD9,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000},
                              { 1, 0.706334, -0.316203, 0},
                              { 4, -0.621560, 0.744969, 0},
                              { 7, -1.093365, -0.835738, 0},
                              { 1, 0.727999, 0.817255, 0},
                              { 4, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 1, 0, 0, 0},
                              { 7, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 13, 0, 0, 0},
                              { 4, 0, 0, 0},
                              { 7, 0.970434, -1.218860, 0},
                              { 13, 1.723564, 0.899942, 0},
                              { 0, -1.394010, 1.141620, 0},
                              { 0, -0.800471, -1.641304, 0},
                              { 0, -1.195371, -0.238957, 0},
                              { 0, 0.120446, 1.782226, 0},
                              { 0, 0.156671, 0.084856, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { 0, 0, 0, 0},
                              { -1, 0, 0, -1},
                              { -1, 0, 0, 1},
                              { 1, 2.729044, 1.001841, -1},
                              { 1, 1.200427, -2.210806, 1},
                              { 0, -2.878679, -0.096898, 0},
                              { 0, -0.231437, 2.371948, 0},
                              { 0, -0.076521, -1.246591, 0},
                              { 0, 2.460634, -0.625002, 0},
                              { 0, -1.072969, -2.459462, 0},
                              { -2, -1.708283, -0.763927, -2},
                              { -2, 1.518943, 0.972988, 0},
                              { -2, 0.448011, -0.161030, 2},
                              { 0, -2.219038, 1.159811, -2},
                              { 0, -0.798701, 0.973673, 0},
                              { 0, 1.116809, 2.122032, 2},
                              { 2, 0, 0, -2},
                              { 2, 0, 0, 0},
                              { 2, 0, 0, 2},
                              { 1.500000, 0, 0, 1.000000},
                              { 0, 1.500000, 0, 1.000000},
                              { 0, 0, 5.500000, 1.000000},
                              { 1.500000, 0, 5.500000, 1.000000},
                              { 1.500000, 1.500000, 0, 1.000000},
                              { 1.000000, 1.000000, 1.000000, 1.000000},
                              { 0, 1.000000, 5.500000, 1.000000},
                              { 0.500000, 3.500000, 0.750000, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = FarPlane + v9.z;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.x = cmp(drawDebug == 2);
  r0.yzw = (v0.xyz);
  r0.yzw = r0.yzw + r0.yzw;
  r0.xyz = r0.xxx ? float3(1,1,1) : r0.yzw;
  if (EnableIndexedTex == 0) {
    r1.xy = UvOffset.xy + v3.xy;
    r1.xyzw = TextureSampler.Sample(TextureSamplerSampler_s, r1.xy).xyzw;
  } else {
    r2.xy = UvOffset.xy + v3.xy;
    IndexTexture.GetDimensions(0, fDest.x, fDest.y, fDest.z);
    r3.xy = fDest.xy;
    r4.xy = float2(1,1) / r3.xy;
    r2.z = 1 + -r2.y;
    r2.xy = r3.xy * r2.xz + float2(-0.5,-0.5);
    r2.zw = floor(r2.xy);
    r2.zw = float2(0.400000006,0.400000006) + r2.zw;
    r3.xy = r2.zw * r4.xy;
    r2.xy = frac(r2.xy);
    r3.x = IndexTexture.Sample(PalletTexSamplerState_s, r3.xy).x;
    r3.x = 255 * r3.x;
    r3.x = (uint)r3.x;
    r4.z = 0;
    r5.xyzw = r2.zwzw * r4.xyxy + r4.xzzy;
    r4.z = IndexTexture.Sample(PalletTexSamplerState_s, r5.xy).x;
    r4.z = 255 * r4.z;
    r6.x = (uint)r4.z;
    r4.z = IndexTexture.Sample(PalletTexSamplerState_s, r5.zw).x;
    r4.z = 255 * r4.z;
    r5.x = (uint)r4.z;
    r2.zw = r2.zw * r4.xy + r4.xy;
    r2.z = IndexTexture.Sample(PalletTexSamplerState_s, r2.zw).x;
    r2.z = 255 * r2.z;
    r4.x = (uint)r2.z;
    r3.yzw = float3(0,0,0);
    r3.xyzw = PalletTexture.Load(r3.xyz).xyzw;
    r6.yzw = float3(0,0,0);
    r6.xyzw = PalletTexture.Load(r6.xyz).xyzw;
    r5.yzw = float3(0,0,0);
    r5.xyzw = PalletTexture.Load(r5.xyz).xyzw;
    r4.yzw = float3(0,0,0);
    r4.xyzw = PalletTexture.Load(r4.xyz).xyzw;
    r2.zw = float2(1,1) + -r2.yx;
    r7.x = r2.w * r2.z;
    r2.zw = r2.xy * r2.zw;
    r6.xyzw = r6.xyzw * r2.zzzz;
    r3.xyzw = r3.xyzw * r7.xxxx + r6.xyzw;
    r3.xyzw = r5.xyzw * r2.wwww + r3.xyzw;
    r2.x = r2.x * r2.y;
    r1.xyzw = r4.xyzw * r2.xxxx + r3.xyzw;
  }
  r0.w = 2 * v0.w;
  r2.xyzw = r1.xyzw * r0.xyzw;
  if (debugTextureDensity != 0) {
    if (EnableIndexedTex != 0) {
      IndexTexture.GetDimensions(0, fDest.x, fDest.y, fDest.z);
      r0.xy = fDest.xy;
    } else {
      TextureSampler.GetDimensions(0, fDest.x, fDest.y, fDest.z);
      r0.xy = fDest.xy;
    }
    r0.xy = v3.yx * r0.yx;
    r0.xy = float2(0.0625,0.0625) * r0.xy;
    r0.xy = frac(r0.xy);
    r1.xy = cmp(float2(0.5,0.5) < r0.yx);
    r0.xy = cmp(float2(0.5,0.5) >= r0.xy);
    r0.xy = r0.xy ? r1.xy : 0;
    r0.x = (int)r0.y | (int)r0.x;
    r2.xyz = r0.xxx ? float3(1,1,1) : 0;
  }
  r0.x = r0.w * r1.w + -0.00196078443;
  r0.x = cmp(r0.x < 0);
  if (r0.x != 0) discard;
  r0.x = dot(v4.xyz, v4.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = v4.xyz * r0.xxx;
  r0.w = PS2FogVec.z * PS2FogVec.w;
  r0.w = v8.w * -PS2FogVec.z + r0.w;
  r0.w = saturate(max(PS2FogVec.x, r0.w));
  r1.x = -0.300000012 + r0.w;
  r1.x = saturate(5 * r1.x);
  r1.y = EnableFog;
  r1.x = -1 + r1.x;
  r1.x = r1.y * r1.x + 1;
  r3.xyzw = vMapAmbientColor.xyzw * r2.xyzw;
  r1.y = cmp(drawDebug != 1);
  r1.z = cmp(r1.x >= 0.0500000007);
  r4.xy = UvOffset.xy + v3.xy;
  r4.zw = NormalMap.Sample(NormalSpecSamplerSampler_s, r4.xy).xy;
  r1.w = cmp(EnableProceduralTexture == 3);
  r5.xyz = r1.www ? v11.yzx : v7.yzx;
  r6.xyz = ddx_coarse(r5.yzx);
  r7.xyz = ddy_coarse(r5.xyz);
  r8.x = ProceduralTilingRatioU;
  r8.y = ProceduralTilingRatioV;
  r9.xyzw = r5.xyyz * r8.xyxy + ProceduralTilingOffsetU;
  r5.xy = r5.zx * r8.xy + ProceduralTilingOffsetU;
  r5.zw = ProceduralNormalTexture.Sample(ProceduralNormalSampler_s, r9.xy).xy;
  r8.xy = ProceduralNormalTexture.Sample(ProceduralNormalSampler_s, r9.zw).xy;
  r5.xy = ProceduralNormalTexture.Sample(ProceduralNormalSampler_s, r5.xy).xy;
  r9.xyzw = SpecularMap.Sample(NormalSpecSamplerSampler_s, r4.xy).zxyw;
  if (r1.z != 0) {
    if (EnableNormalMap != 0) {
      r1.z = dot(-vDLDir.xyz, r0.xyz);
      r4.xy = r4.zw * float2(2,2) + float2(-1,-1);
      r1.w = -r4.x * r4.x + 1;
      r1.w = -r4.y * r4.y + r1.w;
      r1.w = max(0, r1.w);
      r4.z = sqrt(r1.w);
      r1.w = dot(r4.xyz, r4.xyz);
      r1.w = rsqrt(r1.w);
      r4.xyz = r4.xyz * r1.www;
      r1.w = dot(v5.xyz, v5.xyz);
      r1.w = rsqrt(r1.w);
      r10.xyz = v5.xyz * r1.www;
      r1.w = dot(v6.xyz, v6.xyz);
      r1.w = rsqrt(r1.w);
      r11.xyz = v6.xyz * r1.www;
      r10.xyz = r10.xyz * r4.yyy;
      r4.xyw = r4.xxx * r11.xyz + r10.xyz;
      r4.xyz = r4.zzz * r0.xyz + r4.xyw;
      if (EnableProceduralTexture != 0) {
        r10.xyz = r7.xyz * r6.xyz;
        r6.xyz = r6.zxy * r7.yzx + -r10.xyz;
        r1.w = dot(r6.xyz, r6.xyz);
        r1.w = rsqrt(r1.w);
        r6.xyz = r6.xyz * r1.www;
        r6.xyz = abs(r6.xyz) * float3(7,7,7) + float3(-3.5,-3.5,-3.5);
        r6.xyz = max(float3(0,0,0), r6.xyz);
        r1.w = r6.x + r6.y;
        r1.w = r1.w + r6.z;
        r6.xyz = r6.xyz / r1.www;
        r7.xyz = cmp(float3(0,0,0) < r6.xyz);
        r5.xyzw = r6.zzxx * r5.xyzw;
        r6.xy = r8.xy * r6.yy;
        r6.xy = r7.yy ? r6.xy : 0;
        r5.xyzw = r7.zzxx ? r5.xyzw : 0;
        r5.zw = r5.zw + r6.xy;
        r5.xy = r5.zw + r5.xy;
        r5.xy = r5.xy * float2(2,2) + float2(-1,-1);
        r1.w = -r5.x * r5.x + 1;
        r1.w = -r5.y * r5.y + r1.w;
        r1.w = max(0, r1.w);
        r6.z = sqrt(r1.w);
        r6.xy = ProceduralNormalBlendingRatio * r5.xy;
        r1.w = dot(r6.xyz, r6.xyz);
        r1.w = rsqrt(r1.w);
        r5.xyz = r6.xyz * r1.www;
        r5.w = 1 + r4.z;
        r4.w = 1 + r4.z;
        r6.z = dot(r4.xyw, r5.xyz);
        r5.w = r6.z / r5.w;
        r5.xyz = r4.xyw * r5.www + -r5.xyz;
        r4.w = dot(r5.xyz, r5.xyz);
        r4.w = rsqrt(r4.w);
        r5.xyz = r5.xyz * r4.www;
        r4.xy = -r6.xy * r1.ww + r4.xy;
        r1.w = dot(r4.xyz, r4.xyz);
        r1.w = rsqrt(r1.w);
        r4.w = saturate(r0.y * 10 + 10);
        r6.xyz = r4.xyz * r1.www + -r5.xyz;
        r5.xyz = r4.www * r6.xyz + r5.xyz;
        r1.w = dot(r5.xyz, r5.xyz);
        r1.w = rsqrt(r1.w);
        r4.xyz = r5.xyz * r1.www;
      }
      r1.w = dot(-vDLDir.xyz, r4.xyz);
    } else {
      r4.xyz = r0.xyz;
      r1.zw = float2(0,0);
    }
    r4.w = dot(r4.xyz, r4.xyz);
    r4.w = rsqrt(r4.w);
    r4.xyz = r4.xyz * r4.www;
    if (r1.y != 0) {
      r1.z = -vMapAmbColorCutPercent * r1.z + 1;
      r5.xyz = vMapAmbientColor.xyz * r1.zzz;
      r6.xyz = vDLColor.xyz * r1.www;
      r5.xyz = r5.xyz * v1.xyz + r6.xyz;
      r5.w = vMapAmbientColor.w;
      r6.xyzw = r5.xyzw * r2.xyzw;
      if (EnableSpecularMap != 0) {
        r7.xyz = -EyePosition.xyz + v7.xyz;
        r1.z = dot(r7.xyz, r7.xyz);
        r1.z = rsqrt(r1.z);
        r7.xyz = r7.xyz * r1.zzz;
        r1.z = 1 + -r9.z;
        r1.z = max(0.00999999978, r1.z);
        r1.z = min(1, r1.z);
        r1.w = dot(-r7.xyz, r4.xyz);
        r4.w = max(0, r1.w);
        r5.w = min(1, r4.w);
        r8.xyzw = r1.zzzz * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
        r7.w = r8.x * r8.x;
        r5.w = -9.27999973 * r5.w;
        r5.w = exp2(r5.w);
        r7.w = min(r7.w, r5.w);
        r7.w = r7.w * r8.x + r8.y;
        r8.xy = r7.ww * float2(-1.03999996,1.03999996) + r8.zw;
        if (EnableCubeMap != 0) {
          r7.w = dot(r7.xyz, r4.xyz);
          r7.w = r7.w + r7.w;
          r10.xyz = r4.xyz * -r7.www + r7.xyz;
          r7.w = log2(r1.z);
          r7.w = cubemapFactor * r7.w;
          r7.w = exp2(r7.w);
          r7.w = 6 * r7.w;
          r11.xyzw = cmp(float4(0,0,0,0) < CubeMapWeight0);
          r10.xyz = -r10.xyz;
          r12.xyz = CubeMap0.SampleLevel(CubeMapSampler_s, r10.xyz, r7.w).xyz;
          r12.xyz = CubeMapWeight0 * r12.xyz;
          r12.xyz = r11.xxx ? r12.xyz : 0;
          r13.xyz = CubeMap1.SampleLevel(CubeMapSampler_s, r10.xyz, r7.w).xyz;
          r13.xyz = CubeMapWeight1 * r13.xyz;
          r13.xyz = r11.yyy ? r13.xyz : 0;
          r12.xyz = r13.xyz + r12.xyz;
          r13.xyz = CubeMap2.SampleLevel(CubeMapSampler_s, r10.xyz, r7.w).xyz;
          r13.xyz = CubeMapWeight2 * r13.xyz;
          r11.xyz = r11.zzz ? r13.xyz : 0;
          r11.xyz = r12.xyz + r11.xyz;
          r10.xyz = CubeMap3.SampleLevel(CubeMapSampler_s, r10.xyz, r7.w).xyz;
          r10.xyz = CubeMapWeight3 * r10.xyz;
          r10.xyz = r11.www ? r10.xyz : 0;
          r10.xyz = r11.xyz + r10.xyz;
          r7.w = r9.y * r8.x + r8.y;
          r10.xyz = (r10.xyz * r7.www);
        } else {
          r10.xyz = float3(0,0,0);
        }
        r7.w = cmp(r9.w < 0.501960814);
        r8.z = cmp(0.5 < isBgNpc);
        r8.w = cmp(eMapCameraLightEnabled != 0);
        r8.w = r8.w ? r8.z : 0;
        if (r8.w != 0) {
          r11.xyz = EyePosition.xyz + -v7.xyz;
          r8.w = dot(r11.xyz, r11.xyz);
          r8.w = sqrt(r8.w);
          r9.z = cmp(r9.x < 0.501960814);
          r10.w = saturate(r9.x * -2 + 1);
          r11.x = r1.w + r1.w;
          r11.xyz = r11.xxx * r4.xyz + r7.xyz;
          r12.xyz = v0.xyz * float3(0.300000012,0.300000012,0.300000012) + float3(0.699999988,0.699999988,0.699999988);
          r11.w = r2.x + r2.y;
          r11.w = r11.w + r2.z;
          r12.w = 0.333333343 * r11.w;
          r11.w = r11.w * 0.333333343 + -0.5;
          r13.xyz = saturate(-r11.www + r2.xyz);
          r14.xyz = hMapCmrLghtXMdifir + View._m02_m12_m22;
          r11.w = dot(r14.xyz, r14.xyz);
          r11.w = rsqrt(r11.w);
          r14.xyz = r14.xyz * r11.www;
          r11.w = cmp(0 < mapIrrCubeMapFactor);
          if (r11.w != 0) {
            r15.xyzw = cmp(float4(0,0,0,0) < CubeMapWeight0);
            r16.xyz = IrrCubeMap0.SampleLevel(CubeMapSampler_s, r14.xyz, 0).xyz;
            r16.xyz = CubeMapWeight0 * r16.xyz;
            r16.xyz = r15.xxx ? r16.xyz : 0;
            r17.xyz = IrrCubeMap1.SampleLevel(CubeMapSampler_s, r14.xyz, 0).xyz;
            r17.xyz = CubeMapWeight1 * r17.xyz;
            r17.xyz = r15.yyy ? r17.xyz : 0;
            r16.xyz = r17.xyz + r16.xyz;
            r17.xyz = IrrCubeMap2.SampleLevel(CubeMapSampler_s, r14.xyz, 0).xyz;
            r17.xyz = CubeMapWeight2 * r17.xyz;
            r15.xyz = r15.zzz ? r17.xyz : 0;
            r15.xyz = r16.xyz + r15.xyz;
            r16.xyz = IrrCubeMap3.SampleLevel(CubeMapSampler_s, r14.xyz, 0).xyz;
            r16.xyz = CubeMapWeight3 * r16.xyz;
            r16.xyz = r15.www ? r16.xyz : 0;
            r15.xyz = r16.xyz + r15.xyz;
            r15.xyz = r15.xyz * mapIrrCubeMapIntensity + float3(-1,-1,-1);
            r15.xyz = mapIrrCubeMapFactor * r15.xyz + float3(1,1,1);
          } else {
            r15.xyz = float3(1,1,1);
          }
          r13.w = vDLColor.x + vDLColor.y;
          r13.w = vDLColor.z + r13.w;
          r13.w = r13.w * 0.333333343 + -0.5;
          r16.xyz = (vDLColor.xyz + -r13.www);
          r17.x = eMapCameraLightXModifier + View._m02;
          r17.yz = eMapCameraLightYModifier + View._m12_m22;
          r13.w = dot(r17.xyz, r17.xyz);
          r13.w = rsqrt(r13.w);
          r17.xyz = r17.xyz * r13.www;
          if (r11.w != 0) {
            r18.xyzw = cmp(float4(0,0,0,0) < CubeMapWeight0);
            r19.xyz = IrrCubeMap0.SampleLevel(CubeMapSampler_s, r17.xyz, 0).xyz;
            r19.xyz = CubeMapWeight0 * r19.xyz;
            r19.xyz = r18.xxx ? r19.xyz : 0;
            r20.xyz = IrrCubeMap1.SampleLevel(CubeMapSampler_s, r17.xyz, 0).xyz;
            r20.xyz = CubeMapWeight1 * r20.xyz;
            r20.xyz = r18.yyy ? r20.xyz : 0;
            r19.xyz = r20.xyz + r19.xyz;
            r20.xyz = IrrCubeMap2.SampleLevel(CubeMapSampler_s, r17.xyz, 0).xyz;
            r20.xyz = CubeMapWeight2 * r20.xyz;
            r18.xyz = r18.zzz ? r20.xyz : 0;
            r18.xyz = r19.xyz + r18.xyz;
            r19.xyz = IrrCubeMap3.SampleLevel(CubeMapSampler_s, r17.xyz, 0).xyz;
            r19.xyz = CubeMapWeight3 * r19.xyz;
            r19.xyz = r18.www ? r19.xyz : 0;
            r18.xyz = r19.xyz + r18.xyz;
            r18.xyz = r18.xyz * mapIrrCubeMapIntensity + float3(-1,-1,-1);
            r18.xyz = mapIrrCubeMapFactor * r18.xyz + float3(1,1,1);
          } else {
            r18.xyz = float3(1,1,1);
          }
          if (r7.w == 0) {
            r11.w = dot(r11.xyz, -vDLDir.xyz);
            r13.w = r1.z * r1.z;
            r13.w = r13.w * r13.w;
            r13.w = rcp(r13.w);
            r14.w = r13.w * 0.721347511 + 0.396741122;
            r11.w = r14.w * r11.w + -r14.w;
            r11.w = exp2(r11.w);
            r11.w = r13.w * r11.w;
            r13.w = r9.y * r8.x + r8.y;
            r11.w = r13.w * r11.w;
            r19.xyz = (vDLColor.xyz * r11.www);
            r20.xyz = cubemapIntensity * r10.xyz;
            r19.xyz = r19.xyz * specularIntensity + r20.xyz;
            r11.w = hMapSpculrPwryCmrDistncFctr * r8.w;
            r11.w = r1.z * hMapSpculrPwrMdifir + r11.w;
            r13.w = dot(-r7.xyz, -r7.xyz);
            r13.w = rsqrt(r13.w);
            r21.xyz = r13.www * -r7.xyz;
            r13.w = (dot(r21.xyz, r4.xyz));
            r21.xyzw = r11.wwww * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
            r14.w = r21.x * r21.x;
            r13.w = -9.27999973 * r13.w;
            r13.w = exp2(r13.w);
            r13.w = min(r14.w, r13.w);
            r13.w = r13.w * r21.x + r21.y;
            r21.xy = r13.ww * float2(-1.03999996,1.03999996) + r21.zw;
            r13.w = r15.x + r15.y;
            r13.w = r13.w + r15.z;
            r13.w = r13.w * 0.333333343 + -0.5;
            r15.xyz = (r15.xyz + -r13.www);
            r21.zw = r16.xy * r15.xy;
            r13.w = r21.z + r21.w;
            r13.w = r16.z * r15.z + r13.w;
            r13.w = r13.w * 0.333333343 + -0.5;
            r15.xyz = (r16.xyz * r15.xyz + -r13.www);
            r13.w = dot(r11.xyz, r14.xyz);
            r11.w = r11.w * r11.w;
            r11.w = r11.w * r11.w;
            r11.w = rcp(r11.w);
            r14.x = r11.w * 0.721347511 + 0.396741122;
            r14.yzw = r15.xyz * r13.xyz;
            r13.w = r14.x * r13.w + -r14.x;
            r13.w = exp2(r13.w);
            r11.w = r13.w * r11.w;
            r13.w = r9.y * r21.x + r21.y;
            r11.w = r13.w * r11.w;
            r14.xyz = r14.yzw * r11.www;
            r11.w = r8.w * hMapSpIntnBfClpyCmrDistncFctr + hMapSpIntnBfClpMdifir;
            r14.xyz = (r14.xyz * r11.www);
            r11.w = r8.w * hMapSpIntnAftClpyCmrDistncFctr + hMapSpIntnAftClpMdifir;
            r14.xyz = r14.xyz * r11.www;
            r14.xyz = r14.xyz * specularIntensity + r20.xyz;
            r14.xyz = r14.xyz * r12.xyz;
            r14.xyz = r9.zzz ? r14.xyz : 0;
            r15.xyz = r19.xyz * r12.xyz + r6.xyz;
            r5.xyz = r5.xyz * r2.xyz + r14.xyz;
            r11.w = 1 + -r10.w;
            r11.w = r9.z ? r11.w : 1;
            r14.xyz = r15.xyz * r11.www;
            r6.xyz = r5.xyz * r10.www + r14.xyz;
          } else {
            r5.x = saturate(r9.w * -2 + 1);
            r5.y = eMapSpecularPowerEyeCameraDistanceFactor * r8.w;
            r5.y = r1.z * eMapSpecularPowerModifier + r5.y;
            r14.xyzw = r5.yyyy * float4(-1,-0.0274999999,-0.572000027,0.0219999999) + float4(1,0.0425000004,1.03999996,-0.0399999991);
            r5.z = r14.x * r14.x;
            r5.z = min(r5.z, r5.w);
            r5.z = r5.z * r14.x + r14.y;
            r5.zw = r5.zz * float2(-1.03999996,1.03999996) + r14.zw;
            r9.w = r18.x + r18.y;
            r9.w = r9.w + r18.z;
            r9.w = r9.w * 0.333333343 + -0.5;
            r14.xyz = (r18.xyz + -r9.www);
            r15.xy = r16.xy * r14.xy;
            r9.w = r15.x + r15.y;
            r9.w = r16.z * r14.z + r9.w;
            r9.w = r9.w * 0.333333343 + -0.5;
            r14.xyz = (r16.xyz * r14.xyz + -r9.www);
            r9.w = dot(r11.xyz, r17.xyz);
            r5.y = r5.y * r5.y;
            r5.y = r5.y * r5.y;
            r5.y = rcp(r5.y);
            r11.x = r5.y * 0.721347511 + 0.396741122;
            r11.yzw = r14.xyz * r13.xyz;
            r9.w = r11.x * r9.w + -r11.x;
            r9.w = exp2(r9.w);
            r5.y = r9.w * r5.y;
            r5.z = r9.y * r5.z + r5.w;
            r5.y = r5.y * r5.z;
            r11.xyz = r11.yzw * r5.yyy;
            r5.z = r11.x + r11.y;
            r5.y = r11.w * r5.y + r5.z;
            r5.y = -r5.y * 0.333333343 + r12.w;
            r5.yzw = (-r5.yyy + r2.xyz);
            r5.yzw = r11.xyz * r5.yzw;
            r9.w = r8.w * eMapSpeIntenBefClpEyeCameraDistanceFactor + eMapSpeIntenBefClpModifier;
            r5.yzw = (r9.www * r5.yzw);
            r8.w = r8.w * eMapSpeIntenAftClpEyeCameraDistanceFactor + eMapSpeIntenAftClpModifier;
            r5.yzw = r8.www * r5.yzw;
            r8.w = eMapCubeMapIntensityModifier * r5.x;
            r10.xyz = r10.xyz * r8.www;
            r8.w = 1 + -r5.x;
            r8.w = r9.z ? 0 : r8.w;
            r11.xyz = cubemapIntensity * r10.xyz;
            r5.yzw = r5.yzw * specularIntensity + r11.xyz;
            r5.yzw = r5.yzw * r12.xyz;
            r9.z = vMapAmbientColor.x + vMapAmbientColor.y;
            r9.z = vMapAmbientColor.z + r9.z;
            r9.z = 0.333333343 * r9.z;
            r9.w = cmp(eMapAmbientBnd >= r9.z);
            r11.x = 1 + -eMapAmbientMdifir;
            r11.x = r11.x / eMapAmbientBnd;
            r9.z = r9.z * r11.x + eMapAmbientMdifir;
            r9.z = r9.w ? r9.z : 1;
            r5.yzw = r9.zzz * r5.yzw;
            r11.xyz = eMapShdwMdifir * r6.xyz;
            r12.xyz = log2(r5.yzw);
            r12.xyz = eMapSpculrBlndMdifir * r12.xyz;
            r12.xyz = exp2(r12.xyz);
            r12.xyz = min(float3(1,1,1), r12.xyz);
            r13.xyz = float3(1,1,1) + -r12.xyz;
            r5.yzw = r12.xyz * r5.yzw;
            r5.yzw = r11.xyz * r13.xyz + r5.yzw;
            r11.xyz = r10.www * r6.xyz;
            r5.xyz = r5.yzw * r5.xxx + r11.xyz;
            r6.xyz = r6.xyz * r8.www + r5.xyz;
          }
        } else {
          r5.x = r1.w + r1.w;
          r5.xyz = r5.xxx * r4.xyz + r7.xyz;
          r5.x = dot(r5.xyz, -vDLDir.xyz);
          r1.z = r1.z * r1.z;
          r1.z = r1.z * r1.z;
          r1.z = rcp(r1.z);
          r5.y = r1.z * 0.721347511 + 0.396741122;
          r5.x = r5.y * r5.x + -r5.y;
          r5.x = exp2(r5.x);
          r1.z = r5.x * r1.z;
          r5.x = r9.y * r8.x + r8.y;
          r1.z = r5.x * r1.z;
          r5.xyz = (vDLColor.xyz * r1.zzz);
          r7.xyz = cubemapIntensity * r10.xyz;
          r5.xyz = r5.xyz * specularIntensity + r7.xyz;
          r7.xyz = v0.xyz * float3(0.300000012,0.300000012,0.300000012) + float3(0.699999988,0.699999988,0.699999988);
          r6.xyz = r5.xyz * r7.xyz + r6.xyz;
        }
        r1.z = cmp(mapFresnelRefEnabled != 0);
        r1.z = r8.z ? r1.z : 0;
        r5.x = cmp((int)r7.w == 0);
        r1.z = r1.z ? r5.x : 0;
        if (r1.z != 0) {
          r1.z = cmp(r1.w >= mapFresnelSpecularClampValue);
          if (r1.z != 0) {
            r1.z = 1 + -r4.w;
            r1.z = max(0, r1.z);
            r1.z = log2(r1.z);
            r1.z = mapFresnelSpecularPower * r1.z;
            r1.z = exp2(r1.z);
            r1.z = r1.z * r9.y;
            r1.z = mapFresnelSpecularIntensity * r1.z;
            r1.w = saturate(-0.501960814 + r9.x);
            r1.w = mapFresnelSpecularSkinIntensity * r1.w;
            r1.w = r1.w * 1.99218738 + 1;
            r5.xyz = r1.zzz * r1.www;
          } else {
            r5.xyz = float3(0,0,0);
          }
          r7.xyz = r5.xyz * r10.xyz;
          r5.xyz = EnableCubeMap ? r7.xyz : r5.xyz;
          r6.xyz = r6.xyz + r5.xyz;
        }
      } else {
        r9.x = 0;
      }
      r1.z = cmp(0 != isBgNpc);
      r1.w = cmp(sssEnable != 0);
      r1.z = r1.w ? r1.z : 0;
      if (r1.z != 0) {
        r1.z = saturate(-0.501960814 + r9.x);
        r1.z = 1.99218738 * r1.z;
        r1.w = 0.346355766 * sssWidthInternal;
        r1.w = -r1.w * r1.w;
        r5.xyzw = float4(225.421097,29.8077488,7.71494675,2.5444355) * r1.wwww;
        r5.xyzw = exp2(r5.xyzw);
        r7.xyz = float3(0.100000001,0.335999995,0.344000012) * r5.yyy;
        r7.xyz = r5.xxx * float3(0.232999995,0.455000013,0.648999989) + r7.xyz;
        r5.xyz = r5.zzz * float3(0.118000001,0.197999999,0) + r7.xyz;
        r5.xyz = r5.www * float3(0.112999998,0.00700000022,0.00700000022) + r5.xyz;
        r7.xy = float2(0.724972367,0.194695681) * r1.ww;
        r7.xy = exp2(r7.xy);
        r5.xyz = r7.xxx * float3(0.35800001,0.00400000019,0) + r5.xyz;
        r5.xyz = r7.yyy * float3(0.0780000016,0,0) + r5.xyz;
        r1.w = dot(ssssb.xyz, -r0.xyz);
        r1.w = saturate(0.300000012 + r1.w);
        r5.xyz = r5.xyz * r1.www;
        r6.xyz = r1.zzz * r5.xyz + r6.xyz;
      }
      r2.xyzw = -vMapAmbientColor.xyzw * r2.xyzw + r6.xyzw;
      r3.xyzw = r1.xxxx * r2.xyzw + r3.xyzw;
    } else {
      r3.xyz = r4.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
    }
  } else {
    r1.xzw = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
    r3.xyz = r1.yyy ? r3.xyz : r1.xzw;
  }
  r1.x = -0.300000012 + r3.w;
  r1.x = saturate(5 * r1.x);
  r0.x = dot(-vDLDir.xyz, r0.xyz);
  r0.x = -shadowVertexBlendLimit.z + r0.x;
  r1.yzw = float3(9.99999975e-005,9.99999975e-005,9.99999975e-005) + MaterialColour.xyz;
  r1.yzw = v0.xyz / r1.yzw;
  r0.y = dot(r1.yzw, float3(0.298999995,0.587000012,0.114));
  r0.y = -shadowVertexBlendLimit.x + r0.y;
  r0.xy = saturate(r0.xy / shadowVertexBlendLimit.wy);
  r0.y = r1.x * r0.y;
  r0.x = r0.y * r0.x;
  r0.y = cmp(0 < r0.x);
  r1.xyz = v7.xyz;
  r1.w = 1;
  r0.z = dot(r1.xyzw, mShadowCascadeProjection0._m00_m10_m20_m30);
  r2.x = dot(r1.xyzw, mShadowCascadeProjection0._m01_m11_m21_m31);
  r2.y = dot(r1.xyzw, mShadowCascadeProjection0._m02_m12_m22_m32);
  r0.z = r0.z * 0.5 + 0.5;
  r2.x = r2.x * -0.5 + 0.5;
  r2.z = cmp(iShadowCascade_selection == 1);
  if (r2.z != 0) {
    r2.w = dot(r1.xyzw, WorldView._m02_m12_m22_m32);
    r4.xyzw = cmp(r2.wwww < m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_1.xyzw);
    r5.x = ~(int)r4.x;
    if (r4.x != 0) {
      r5.yzw = float3(1.5,0,0) * r3.xyz;
    } else {
      r5.yzw = r3.xyz;
    }
    if (r4.y != 0) {
      r6.xyz = float3(0,1.5,0) * r3.xyz;
      r6.w = 1;
    } else {
      r6.xyzw = r5.yzwx;
    }
    r4.y = (int)r4.y | (int)r4.x;
    r4.y = r4.y ? r5.x : 0;
    r4.y = (int)r4.x | (int)r4.y;
    r5.xyz = r4.xxx ? r5.yzw : r6.xyz;
    r4.x = r4.x ? 0 : r6.w;
    if (r4.z != 0) {
      r6.xyz = float3(0,0,5.5) * r3.xyz;
      r5.w = 2;
    } else {
      r6.xyz = r5.xyz;
      r5.w = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyz;
    r4.x = r4.y ? r4.x : r5.w;
    r4.y = (int)r4.z | (int)r4.y;
    if (r4.w != 0) {
      r6.xyz = float3(1.5,0,5.5) * r3.xyz;
      r4.z = 3;
    } else {
      r6.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r4.w | (int)r4.y;
    r6.xyz = cmp(r2.www < m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_2.yzw);
    if (r6.x != 0) {
      r7.xyz = float3(1.5,1.5,0) * r3.xyz;
      r4.z = 4;
    } else {
      r7.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r7.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r4.y | (int)r6.x;
    if (r6.y != 0) {
      r7.xyz = r3.xyz;
      r4.z = 5;
    } else {
      r7.xyz = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r7.xyz;
    r4.x = r4.y ? r4.x : r4.z;
    r4.y = (int)r6.y | (int)r4.y;
    if (r6.z != 0) {
      r6.xyw = float3(0,1,5.5) * r3.xyz;
      r4.z = 6;
    } else {
      r6.xyw = r5.xyz;
      r4.z = r4.x;
    }
    r5.xyz = r4.yyy ? r5.xyz : r6.xyw;
    r6.x = r4.y ? r4.x : r4.z;
    r4.x = (int)r6.z | (int)r4.y;
    r4.y = r0.z;
    r7.y = r2.x;
    r4.z = r2.y;
  } else {
    r8.y = 1;
    r4.y = r0.z;
    r7.y = r2.x;
    r4.z = r2.y;
    r6.xy = float2(-1,0);
    r8.x = 0;
    while (true) {
      r4.w = cmp((int)r8.x < iShadowCascadesUseCount);
      r5.w = cmp((int)r6.y == 0);
      r4.w = r4.w ? r5.w : 0;
      if (r4.w == 0) break;
      r9.xyzw = cmp((int4)r8.xxxx == int4(1,2,3,4));
      r6.zw = cmp((int2)r8.xx == int2(5,6));
      r10.xyzw = r6.wwww ? mShadowCascadeProjection6._m00_m10_m20_m30 : mShadowCascadeProjection7._m00_m10_m20_m30;
      r11.xyzw = r6.wwww ? mShadowCascadeProjection6._m01_m11_m21_m31 : mShadowCascadeProjection7._m01_m11_m21_m31;
      r12.xyzw = r6.wwww ? mShadowCascadeProjection6._m02_m12_m22_m32 : mShadowCascadeProjection7._m02_m12_m22_m32;
      r10.xyzw = r6.zzzz ? mShadowCascadeProjection5._m00_m10_m20_m30 : r10.xyzw;
      r11.xyzw = r6.zzzz ? mShadowCascadeProjection5._m01_m11_m21_m31 : r11.xyzw;
      r12.xyzw = r6.zzzz ? mShadowCascadeProjection5._m02_m12_m22_m32 : r12.xyzw;
      r10.xyzw = r9.wwww ? mShadowCascadeProjection4._m00_m10_m20_m30 : r10.xyzw;
      r11.xyzw = r9.wwww ? mShadowCascadeProjection4._m01_m11_m21_m31 : r11.xyzw;
      r12.xyzw = r9.wwww ? mShadowCascadeProjection4._m02_m12_m22_m32 : r12.xyzw;
      r10.xyzw = r9.zzzz ? mShadowCascadeProjection3._m00_m10_m20_m30 : r10.xyzw;
      r11.xyzw = r9.zzzz ? mShadowCascadeProjection3._m01_m11_m21_m31 : r11.xyzw;
      r12.xyzw = r9.zzzz ? mShadowCascadeProjection3._m02_m12_m22_m32 : r12.xyzw;
      r10.xyzw = r9.yyyy ? mShadowCascadeProjection2._m00_m10_m20_m30 : r10.xyzw;
      r11.xyzw = r9.yyyy ? mShadowCascadeProjection2._m01_m11_m21_m31 : r11.xyzw;
      r12.xyzw = r9.yyyy ? mShadowCascadeProjection2._m02_m12_m22_m32 : r12.xyzw;
      r10.xyzw = r9.xxxx ? mShadowCascadeProjection1._m00_m10_m20_m30 : r10.xyzw;
      r11.xyzw = r9.xxxx ? mShadowCascadeProjection1._m01_m11_m21_m31 : r11.xyzw;
      r9.xyzw = r9.xxxx ? mShadowCascadeProjection1._m02_m12_m22_m32 : r12.xyzw;
      r10.xyzw = r8.xxxx ? r10.xyzw : mShadowCascadeProjection0._m00_m10_m20_m30;
      r11.xyzw = r8.xxxx ? r11.xyzw : mShadowCascadeProjection0._m01_m11_m21_m31;
      r9.xyzw = r8.xxxx ? r9.xyzw : mShadowCascadeProjection0._m02_m12_m22_m32;
      r4.w = dot(r1.xyzw, r10.xyzw);
      r5.w = dot(r1.xyzw, r11.xyzw);
      r4.z = dot(r1.xyzw, r9.xyzw);
      r4.y = r4.w * 0.5 + 0.5;
      r7.y = r5.w * -0.5 + 0.5;
      r4.w = min(r7.y, r4.y);
      r4.w = cmp(m_fShadowMinBorderPadding < r4.w);
      r5.w = max(r7.y, r4.y);
      r5.w = cmp(r5.w < m_fShadowMaxBorderPadding);
      r4.w = r4.w ? r5.w : 0;
      r5.w = cmp(r4.z < 1);
      r4.w = r4.w ? r5.w : 0;
      r6.xy = r4.ww ? r8.xy : r6.xy;
      r8.x = (int)r8.x + 1;
    }
    r5.xyz = r3.xyz;
    r2.w = 1;
    r4.x = 0;
  }
  r0.z = (int)r6.x;
  r0.z = m_fShadowPartitionSize * r0.z;
  r7.x = r4.y * m_fShadowPartitionSize + r0.z;
  r2.xy = g_txChrAlpha.Sample(g_ChrAlphaSampler_s, r7.xy).xy;
  if (r0.y != 0) {
    r0.y = cmp(iDebugMode != 1);
    if (r0.y != 0) {
      if (r4.x == 0) {
        r0.y = cmp((int)r6.x == -1);
        if (r0.y != 0) {
          r5.xyz = r3.xyz;
        }
        if (r0.y == 0) {
          if (r2.z != 0) {
            r0.y = cmp(iShadowBlend_between_cascade != 0);
            r0.z = cmp(1 < iShadowCascadesUseCount);
            r0.y = r0.z ? r0.y : 0;
            if (r0.y != 0) {
              r0.y = cmp((int)r6.x < 4);
              r0.z = dot(m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_1.xyzw, icb[r6.x+0].xyzw);
              r4.xw = (int2)r6.xx + int2(-3,-1);
              r2.z = dot(m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_2.xyzw, icb[r4.x+0].xyzw);
              r0.y = r0.y ? r0.z : r2.z;
              r0.z = min(0, (int)r4.w);
              r0.z = dot(m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_1.xyzw, icb[r0.z+0].xyzw);
              r2.z = r2.w + -r0.z;
              r0.y = r0.y + -r0.z;
              r0.y = rcp(r0.y);
              r0.z = -r2.z * r0.y + 1;
              r2.z = rcp(m_fShadowCascadeBlendArea);
              r0.y = r2.z * r0.z;
            } else {
              r0.yz = float2(1,1);
            }
          } else {
            r2.z = 1 + -r4.y;
            r2.w = 1 + -r7.y;
            r4.x = min(r4.y, r7.y);
            r2.z = min(r2.z, r2.w);
            r4.y = min(r4.x, r2.z);
            r2.z = rcp(m_fShadowCascadeBlendArea);
            r4.x = r4.y * r2.z;
            r0.yz = iShadowBlend_between_cascade ? r4.xy : float2(1,1);
          }
          r2.z = -m_fShadowBiasFromGUI + r4.z;
          r2.w = dot(m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_2.xyzw, icb[r6.x+0].xyzw);
          r4.x = rcp(r2.w);
          r4.x = mShadowDecayDistance * r4.x;
          r4.y = (int)-r6.x + m_iMapPCFBlurForLoopEnd;
          r4.y = max(2, (int)r4.y);
          r4.y = min(4, (int)r4.y);
          r4.z = (int)r4.y + -2;
          r4.w = mad(shadowLevel, 3, (int)r4.z);
          r5.w = cmp(1 == (int)icb[r4.w+4].x);
          if (r5.w != 0) {
            r5.w = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r7.xy, r2.z).x;
            r6.y = mShadowEnableDecay | mMapEnableHeightFade;
            if (r6.y != 0) {
              r8.xyzw = g_txShadow.Gather(LinearSamplerShadow_s, r7.xy).xyzw;
              r9.xyzw = cmp(r8.xyzw >= r2.zzzz);
              r9.xyzw = r9.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
              r6.y = dot(r9.xyzw, float4(1,1,1,1));
              r6.z = dot(r8.xyzw, r9.xyzw);
              r6.w = rcp(r6.y);
              r6.y = cmp(0 < r6.y);
              r6.z = -r6.z * r6.w + r2.z;
              r6.w = rcp(r4.x);
              r6.w = r6.z * r6.w + -1;
              r6.w = saturate(r6.w + r6.w);
              r6.y = r6.y ? r6.w : 0;
              r6.y = mShadowEnableDecay ? r6.y : 0;
              if (mMapEnableHeightFade != 0) {
                r8.xyzw = g_txChrAlpha.Gather(LinearSamplerShadow_s, r7.xy).xyzw;
                r9.xyzw = cmp(r8.xyzw < float4(1,1,1,1));
                r9.xyzw = r9.xyzw ? float4(1,1,1,1) : 0;
                r6.w = dot(r9.xyzw, float4(1,1,1,1));
                r7.z = cmp(0 < r6.w);
                if (r7.z != 0) {
                  r7.z = dot(r8.xyzw, r9.xyzw);
                  r6.w = rcp(r6.w);
                  r7.w = r7.z * r6.w;
                  r6.z = r6.z * r2.w;
                  r6.z = abs(m_shadowLightDir.y) * r6.z;
                  r6.z = 0.5 * r6.z;
                  r8.x = cmp(0.5 < r7.w);
                  r6.w = r7.z * r6.w + -0.5;
                  r6.w = m_objMaxHeight * r6.w;
                  r6.w = dot(r6.ww, mShadowFlyingFadeRange);
                  r6.w = r6.z / r6.w;
                  r6.w = -1 + r6.w;
                  r7.z = m_objMaxHeight * r7.w;
                  r7.z = dot(r7.zz, mShadowFadeRange);
                  r6.z = r6.z / r7.z;
                  r6.z = -1 + r6.z;
                  r6.zw = saturate(mShadowFadeSpeed * r6.zw);
                  r6.z = r8.x ? r6.w : r6.z;
                } else {
                  r6.z = 0;
                }
              } else {
                r6.z = 0;
              }
            } else {
              r6.yz = float2(0,0);
            }
            r6.w = 1 + -r5.w;
            r5.w = r6.y * r6.w + r5.w;
            r5.w = r5.w + r6.z;
            r5.w = min(1, r5.w);
          } else {
            r6.y = (int)r4.z * 13;
            r6.zw = icb[r6.y+4].yz * m_fShadowNativeTexelSizeInX + r7.xy;
            r6.z = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.zw, r2.z).x;
            r7.zw = icb[r6.y+5].yz * m_fShadowNativeTexelSizeInX + r7.xy;
            r6.w = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r7.zw, r2.z).x;
            r6.z = r6.z + r6.w;
            r7.zw = icb[r6.y+6].yz * m_fShadowNativeTexelSizeInX + r7.xy;
            r6.w = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r7.zw, r2.z).x;
            r6.z = r6.z + r6.w;
            r6.yw = icb[r6.y+7].yz * m_fShadowNativeTexelSizeInX + r7.xy;
            r6.y = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.yw, r2.z).x;
            r5.w = r6.z + r6.y;
            r6.y = cmp(3.99959993 < r5.w);
            if (r6.y != 0) {
              r5.w = 1;
            }
            if (r6.y == 0) {
              r6.y = mShadowEnableDecay | mMapEnableHeightFade;
              if (r6.y != 0) {
                r4.y = (int)r4.y + -1;
                r4.y = (int)r4.y * (int)r4.y;
                r6.yzw = float3(0,0,0);
                while (true) {
                  r7.z = cmp((int)r6.w >= (int)r4.y);
                  if (r7.z != 0) break;
                  r7.z = mad((int)r4.z, 9, (int)r6.w);
                  r8.xyzw = g_txShadow.Gather(LinearSamplerShadow_s, r7.xy).xyzw;
                  r9.xyzw = cmp(r8.xyzw >= r2.zzzz);
                  r9.xyzw = r9.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                  r7.z = dot(r9.xyzw, float4(1,1,1,1));
                  r6.y = r7.z + r6.y;
                  r7.z = dot(r8.xyzw, r9.xyzw);
                  r6.z = r7.z + r6.z;
                  r6.w = (int)r6.w + 1;
                }
                r6.w = rcp(r6.y);
                r6.y = cmp(0 < r6.y);
                r6.z = -r6.z * r6.w + r2.z;
                r4.x = rcp(r4.x);
                r4.x = dot(r6.zz, r4.xx);
                r4.x = saturate(-2 + r4.x);
                r4.x = r6.y ? r4.x : 0;
                r8.y = mShadowEnableDecay ? r4.x : 0;
                if (mMapEnableHeightFade != 0) {
                  r6.yw = float2(0,0);
                  r4.x = 0;
                  while (true) {
                    r7.z = cmp((int)r4.x >= (int)r4.y);
                    if (r7.z != 0) break;
                    r7.z = mad((int)r4.z, 9, (int)r4.x);
                    r9.xyzw = g_txChrAlpha.Gather(LinearSamplerShadow_s, r7.xy).xyzw;
                    r10.xyzw = cmp(r9.xyzw < float4(1,1,1,1));
                    r10.xyzw = r10.xyzw ? float4(1,1,1,1) : 0;
                    r7.z = dot(r10.xyzw, float4(1,1,1,1));
                    r6.y = r7.z + r6.y;
                    r7.z = dot(r9.xyzw, r10.xyzw);
                    r6.w = r7.z + r6.w;
                    r4.x = (int)r4.x + 1;
                  }
                  r4.x = cmp(0 < r6.y);
                  if (r4.x != 0) {
                    r4.x = rcp(r6.y);
                    r4.y = r6.w * r4.x;
                    r2.w = r6.z * r2.w;
                    r2.w = abs(m_shadowLightDir.y) * r2.w;
                    r2.w = 0.5 * r2.w;
                    r6.y = cmp(0.5 < r4.y);
                    r4.x = r6.w * r4.x + -0.5;
                    r4.xy = m_objMaxHeight * r4.xy;
                    r4.x = dot(r4.xx, mShadowFlyingFadeRange);
                    r4.x = r2.w / r4.x;
                    r4.x = -1 + r4.x;
                    r4.x = saturate(mShadowFlyingFadeSpeed * r4.x);
                    r4.y = dot(r4.yy, mShadowFadeRange);
                    r2.w = r2.w / r4.y;
                    r2.w = -1 + r2.w;
                    r2.w = saturate(mShadowFadeSpeed * r2.w);
                    r8.x = r6.y ? r4.x : r2.w;
                  } else {
                    r8.x = 0;
                  }
                } else {
                  r8.x = 0;
                }
              } else {
                r8.xy = float2(0,0);
              }
              r2.w = cmp(r5.w < 0.00039999999);
              if (r2.w != 0) {
                r4.x = r8.y + r8.x;
                r5.w = min(1, r4.x);
              }
              if (r2.w == 0) {
                r2.w = r5.w;
                r4.x = 4;
                while (true) {
                  r4.y = cmp((int)r4.x >= (int)icb[r4.w+4].x);
                  if (r4.y != 0) break;
                  r4.y = mad((int)r4.z, 13, (int)r4.x);
                  r6.yz = icb[r4.y+4].yz * m_fShadowNativeTexelSizeInX + r7.xy;
                  r4.y = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.yz, r2.z).x;
                  r2.w = r4.y + r2.w;
                  r4.x = (int)r4.x + 1;
                }
                r2.z = (int)icb[r4.w+4].x;
                r2.z = rcp(r2.z);
                r4.x = r2.w * r2.z;
                r2.z = -r2.w * r2.z + 1;
                r2.z = r8.y * r2.z + r4.x;
                r5.w = saturate(r2.z + r8.x);
              }
            }
          }
          r2.x = saturate(r2.x);
          r2.x = 1 + -r2.x;
          r2.z = cmp(iShadowBlend_between_cascade != 0);
          r2.w = cmp(1 < iShadowCascadesUseCount);
          r2.z = r2.w ? r2.z : 0;
          if (r2.z != 0) {
            r0.z = cmp(r0.z < m_fShadowCascadeBlendArea);
            if (r0.z != 0) {
              r0.z = (int)r6.x + 1;
              r0.z = iShadowBlend_between_cascade ? r0.z : 0;
              if (iShadowCascade_selection == 0) {
                r4.xyzw = cmp((int4)r0.zzzz == int4(1,2,3,4));
                r2.zw = cmp((int2)r0.zz == int2(5,6));
                r7.xyzw = r2.wwww ? mShadowCascadeProjection6._m00_m10_m20_m30 : mShadowCascadeProjection7._m00_m10_m20_m30;
                r8.xyzw = r2.wwww ? mShadowCascadeProjection6._m01_m11_m21_m31 : mShadowCascadeProjection7._m01_m11_m21_m31;
                r9.xyzw = r2.wwww ? mShadowCascadeProjection6._m02_m12_m22_m32 : mShadowCascadeProjection7._m02_m12_m22_m32;
                r7.xyzw = r2.zzzz ? mShadowCascadeProjection5._m00_m10_m20_m30 : r7.xyzw;
                r8.xyzw = r2.zzzz ? mShadowCascadeProjection5._m01_m11_m21_m31 : r8.xyzw;
                r9.xyzw = r2.zzzz ? mShadowCascadeProjection5._m02_m12_m22_m32 : r9.xyzw;
                r7.xyzw = r4.wwww ? mShadowCascadeProjection4._m00_m10_m20_m30 : r7.xyzw;
                r8.xyzw = r4.wwww ? mShadowCascadeProjection4._m01_m11_m21_m31 : r8.xyzw;
                r9.xyzw = r4.wwww ? mShadowCascadeProjection4._m02_m12_m22_m32 : r9.xyzw;
                r7.xyzw = r4.zzzz ? mShadowCascadeProjection3._m00_m10_m20_m30 : r7.xyzw;
                r8.xyzw = r4.zzzz ? mShadowCascadeProjection3._m01_m11_m21_m31 : r8.xyzw;
                r9.xyzw = r4.zzzz ? mShadowCascadeProjection3._m02_m12_m22_m32 : r9.xyzw;
                r7.xyzw = r4.yyyy ? mShadowCascadeProjection2._m00_m10_m20_m30 : r7.xyzw;
                r8.xyzw = r4.yyyy ? mShadowCascadeProjection2._m01_m11_m21_m31 : r8.xyzw;
                r9.xyzw = r4.yyyy ? mShadowCascadeProjection2._m02_m12_m22_m32 : r9.xyzw;
                r7.xyzw = r4.xxxx ? mShadowCascadeProjection1._m00_m10_m20_m30 : r7.xyzw;
                r8.xyzw = r4.xxxx ? mShadowCascadeProjection1._m01_m11_m21_m31 : r8.xyzw;
                r4.xyzw = r4.xxxx ? mShadowCascadeProjection1._m02_m12_m22_m32 : r9.xyzw;
                r7.xyzw = r0.zzzz ? r7.xyzw : mShadowCascadeProjection0._m00_m10_m20_m30;
                r8.xyzw = r0.zzzz ? r8.xyzw : mShadowCascadeProjection0._m01_m11_m21_m31;
                r4.xyzw = r0.zzzz ? r4.xyzw : mShadowCascadeProjection0._m02_m12_m22_m32;
                r2.z = dot(r1.xyzw, r7.xyzw);
                r2.w = dot(r1.xyzw, r8.xyzw);
                r1.x = dot(r1.xyzw, r4.xyzw);
                r1.y = r2.z * 0.5 + 0.5;
                r4.y = r2.w * -0.5 + 0.5;
              } else {
                r4.y = 0;
                r1.xy = float2(0,0);
              }
              r1.z = (int)r0.z;
              r1.z = m_fShadowPartitionSize * r1.z;
              r4.x = r1.y * m_fShadowPartitionSize + r1.z;
              r1.y = cmp((int)r0.z < iShadowCascadesUseCount);
              r1.x = -m_fShadowBiasFromGUI + r1.x;
              r1.z = dot(m_fShadowCascadeFrustumsEyeSpaceDepthsFloat4_2.xyzw, icb[r0.z+0].xyzw);
              r1.w = rcp(r1.z);
              r1.w = mShadowDecayDistance * r1.w;
              r0.z = (int)-r0.z + m_iMapPCFBlurForLoopEnd;
              r0.z = max(2, (int)r0.z);
              r0.z = min(4, (int)r0.z);
              r2.z = (int)r0.z + -2;
              r2.w = mad(shadowLevel, 3, (int)r2.z);
              r4.z = cmp(1 == (int)icb[r2.w+4].x);
              if (r4.z != 0) {
                r4.z = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r4.xy, r1.x).x;
                r4.w = mShadowEnableDecay | mMapEnableHeightFade;
                if (r4.w != 0) {
                  r7.xyzw = g_txShadow.Gather(LinearSamplerShadow_s, r4.xy).xyzw;
                  r8.xyzw = cmp(r7.xyzw >= r1.xxxx);
                  r8.xyzw = r8.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                  r4.w = dot(r8.xyzw, float4(1,1,1,1));
                  r6.y = dot(r7.xyzw, r8.xyzw);
                  r6.z = rcp(r4.w);
                  r4.w = cmp(0 < r4.w);
                  r6.y = -r6.y * r6.z + r1.x;
                  r6.z = rcp(r1.w);
                  r6.z = r6.y * r6.z + -1;
                  r6.z = saturate(r6.z + r6.z);
                  r4.w = r4.w ? r6.z : 0;
                  r4.w = mShadowEnableDecay ? r4.w : 0;
                  if (mMapEnableHeightFade != 0) {
                    r7.xyzw = g_txChrAlpha.Gather(LinearSamplerShadow_s, r4.xy).xyzw;
                    r8.xyzw = cmp(r7.xyzw < float4(1,1,1,1));
                    r8.xyzw = r8.xyzw ? float4(1,1,1,1) : 0;
                    r6.z = dot(r8.xyzw, float4(1,1,1,1));
                    r6.w = cmp(0 < r6.z);
                    if (r6.w != 0) {
                      r6.w = dot(r7.xyzw, r8.xyzw);
                      r6.z = rcp(r6.z);
                      r7.x = r6.w * r6.z;
                      r6.y = r6.y * r1.z;
                      r6.y = abs(m_shadowLightDir.y) * r6.y;
                      r6.y = 0.5 * r6.y;
                      r7.y = cmp(0.5 < r7.x);
                      r6.z = r6.w * r6.z + -0.5;
                      r6.z = m_objMaxHeight * r6.z;
                      r6.z = dot(r6.zz, mShadowFlyingFadeRange);
                      r6.z = r6.y / r6.z;
                      r6.z = -1 + r6.z;
                      r6.w = m_objMaxHeight * r7.x;
                      r6.w = dot(r6.ww, mShadowFadeRange);
                      r6.y = r6.y / r6.w;
                      r6.y = -1 + r6.y;
                      r6.yz = saturate(mShadowFadeSpeed * r6.yz);
                      r6.y = r7.y ? r6.z : r6.y;
                    } else {
                      r6.y = 0;
                    }
                  } else {
                    r6.y = 0;
                  }
                } else {
                  r6.y = 0;
                  r4.w = 0;
                }
                r6.z = 1 + -r4.z;
                r4.z = r4.w * r6.z + r4.z;
                r4.z = r4.z + r6.y;
                r4.z = min(1, r4.z);
              } else {
                r4.w = (int)r2.z * 13;
                r6.yz = icb[r4.w+4].yz * m_fShadowNativeTexelSizeInX + r4.xy;
                r6.y = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.yz, r1.x).x;
                r6.zw = icb[r4.w+5].yz * m_fShadowNativeTexelSizeInX + r4.xy;
                r6.z = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.zw, r1.x).x;
                r6.y = r6.y + r6.z;
                r6.zw = icb[r4.w+6].yz * m_fShadowNativeTexelSizeInX + r4.xy;
                r6.z = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.zw, r1.x).x;
                r6.y = r6.y + r6.z;
                r6.zw = icb[r4.w+7].yz * m_fShadowNativeTexelSizeInX + r4.xy;
                r4.w = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.zw, r1.x).x;
                r4.z = r6.y + r4.w;
                r4.w = cmp(3.99959993 < r4.z);
                if (r4.w != 0) {
                  r4.z = 1;
                }
                if (r4.w == 0) {
                  r4.w = mShadowEnableDecay | mMapEnableHeightFade;
                  if (r4.w != 0) {
                    r0.z = (int)r0.z + -1;
                    r0.z = (int)r0.z * (int)r0.z;
                    r6.yz = float2(0,0);
                    r4.w = 0;
                    while (true) {
                      r6.w = cmp((int)r4.w >= (int)r0.z);
                      if (r6.w != 0) break;
                      r6.w = mad((int)r2.z, 9, (int)r4.w);
                      r7.xyzw = g_txShadow.Gather(LinearSamplerShadow_s, r4.xy).xyzw;
                      r8.xyzw = cmp(r7.xyzw >= r1.xxxx);
                      r8.xyzw = r8.xyzw ? float4(0,0,0,0) : float4(1,1,1,1);
                      r6.w = dot(r8.xyzw, float4(1,1,1,1));
                      r6.y = r6.y + r6.w;
                      r6.w = dot(r7.xyzw, r8.xyzw);
                      r6.z = r6.z + r6.w;
                      r4.w = (int)r4.w + 1;
                    }
                    r4.w = rcp(r6.y);
                    r6.y = cmp(0 < r6.y);
                    r4.w = -r6.z * r4.w + r1.x;
                    r1.w = rcp(r1.w);
                    r1.w = dot(r4.ww, r1.ww);
                    r1.w = saturate(-2 + r1.w);
                    r1.w = r6.y ? r1.w : 0;
                    r7.y = mShadowEnableDecay ? r1.w : 0;
                    if (mMapEnableHeightFade != 0) {
                      r6.yz = float2(0,0);
                      r1.w = 0;
                      while (true) {
                        r6.w = cmp((int)r1.w >= (int)r0.z);
                        if (r6.w != 0) break;
                        r6.w = mad((int)r2.z, 9, (int)r1.w);
                        r8.xyzw = g_txChrAlpha.Gather(LinearSamplerShadow_s, r4.xy).xyzw;
                        r9.xyzw = cmp(r8.xyzw < float4(1,1,1,1));
                        r9.xyzw = r9.xyzw ? float4(1,1,1,1) : 0;
                        r6.w = dot(r9.xyzw, float4(1,1,1,1));
                        r6.y = r6.y + r6.w;
                        r6.w = dot(r8.xyzw, r9.xyzw);
                        r6.z = r6.z + r6.w;
                        r1.w = (int)r1.w + 1;
                      }
                      r0.z = cmp(0 < r6.y);
                      if (r0.z != 0) {
                        r0.z = rcp(r6.y);
                        r1.w = r6.z * r0.z;
                        r1.z = r4.w * r1.z;
                        r1.z = abs(m_shadowLightDir.y) * r1.z;
                        r1.z = 0.5 * r1.z;
                        r4.w = cmp(0.5 < r1.w);
                        r0.z = r6.z * r0.z + -0.5;
                        r0.z = m_objMaxHeight * r0.z;
                        r0.z = dot(r0.zz, mShadowFlyingFadeRange);
                        r0.z = r1.z / r0.z;
                        r0.z = -1 + r0.z;
                        r0.z = saturate(mShadowFlyingFadeSpeed * r0.z);
                        r1.w = m_objMaxHeight * r1.w;
                        r1.w = dot(r1.ww, mShadowFadeRange);
                        r1.z = r1.z / r1.w;
                        r1.z = -1 + r1.z;
                        r1.z = saturate(mShadowFadeSpeed * r1.z);
                        r7.x = r4.w ? r0.z : r1.z;
                      } else {
                        r7.x = 0;
                      }
                    } else {
                      r7.x = 0;
                    }
                  } else {
                    r7.xy = float2(0,0);
                  }
                  r0.z = cmp(r4.z < 0.00039999999);
                  if (r0.z != 0) {
                    r1.z = r7.y + r7.x;
                    r4.z = min(1, r1.z);
                  }
                  if (r0.z == 0) {
                    r0.z = r4.z;
                    r1.z = 4;
                    while (true) {
                      r1.w = cmp((int)r1.z >= (int)icb[r2.w+4].x);
                      if (r1.w != 0) break;
                      r1.w = mad((int)r2.z, 13, (int)r1.z);
                      r6.yz = icb[r1.w+4].yz * m_fShadowNativeTexelSizeInX + r4.xy;
                      r1.w = g_txShadow.SampleCmpLevelZero(g_samShadow_s, r6.yz, r1.x).x;
                      r0.z = r1.w + r0.z;
                      r1.z = (int)r1.z + 1;
                    }
                    r1.x = (int)icb[r2.w+4].x;
                    r1.x = rcp(r1.x);
                    r1.z = r1.x * r0.z;
                    r0.z = -r0.z * r1.x + 1;
                    r0.z = r7.y * r0.z + r1.z;
                    r4.z = saturate(r0.z + r7.x);
                  }
                }
              }
              r0.z = r1.y ? r4.z : 1;
              r1.x = r5.w + -r0.z;
              r5.w = r0.y * r1.x + r0.z;
            }
          }
          r0.y = 1 + -r5.w;
          r0.y = r2.x * r0.y + r5.w;
          r1.xyz = m_iShadowVisualizeCascades ? icb[r6.x+46].xyz : float3(1,1,1);
          r0.z = 1 + -mMapShadowValueLerpMin;
          r0.y = r0.y * r0.z + mMapShadowValueLerpMin;
          r0.z = 1 + -r0.y;
          r2.xzw = mShadowColor.xyz * r0.zzz + r0.yyy;
          r1.xyz = r2.xzw * r1.xyz;
          r1.xyz = r1.xyz * r3.xyz;
          r0.y = cmp(r2.y < 0.5);
          r2.xyz = float3(1,1,1) + -mSpecialShadowColor.xyz;
          r2.xyz = r5.www * r2.xyz + mSpecialShadowColor.xyz;
          r2.xyz = r2.xyz * r1.xyz;
          r5.xyz = r0.yyy ? r2.xyz : r1.xyz;
        }
      }
    } else {
      r5.xyz = r3.xyz;
    }
    r1.xyz = r5.xyz + -r3.xyz;
    r3.xyz = r0.xxx * r1.xyz + r3.xyz;
  }
  r0.xyz = -FogColor.xyz + r3.xyz;
  r0.xyz = r0.www * r0.xyz + FogColor.xyz;
  o0.xyz = EnableFog ? r0.xyz : r3.xyz;
  r0.x = max(0, r3.w);
  o0.w = min(0.999000013, r0.x);
  r0.x = dot(v10.xyz, v10.xyz);
  r0.x = rsqrt(r0.x);
  o1.xy = v10.xy * r0.xx;
  o1.zw = float2(0.300000012,0);
  return;
}