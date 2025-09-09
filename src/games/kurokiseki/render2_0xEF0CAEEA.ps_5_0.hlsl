// ---- Created with 3Dmigoto v1.3.16 on Tue Sep 09 14:15:01 2025

cbuffer cb_scene : register(b0)
{
  float4x4 view_g : packoffset(c0);
  float4x4 viewInv_g : packoffset(c4);
  float4x4 proj_g : packoffset(c8);
  float4x4 projInv_g : packoffset(c12);
  float4x4 viewProj_g : packoffset(c16);
  float4x4 viewProjInv_g : packoffset(c20);
  float2 vpSize_g : packoffset(c24);
  float2 invVPSize_g : packoffset(c24.z);
  float3 lightColor_g : packoffset(c25);
  float ldotvXZ_g : packoffset(c25.w);
  float3 lightDirection_g : packoffset(c26);
  float shadowSplitDistance_g : packoffset(c26.w);
  float4x4 shadowMtx_g[2] : packoffset(c27);
  float2 invShadowSize_g : packoffset(c35);
  float shadowFadeNear_g : packoffset(c35.z);
  float shadowFadeRangeInv_g : packoffset(c35.w);
  float3 sceneShadowColor_g : packoffset(c36);
  float gameTime_g : packoffset(c36.w);
  float3 windDirection_g : packoffset(c37);
  uint collisionCount_g : packoffset(c37.w);
  float lightTileWidthInv_g : packoffset(c38);
  float lightTileHeightInv_g : packoffset(c38.y);
  float fogNearDistance_g : packoffset(c38.z);
  float fogFadeRangeInv_g : packoffset(c38.w);
  float3 fogColor_g : packoffset(c39);
  float fogIntensity_g : packoffset(c39.w);
  float fogHeight_g : packoffset(c40);
  float fogHeightRangeInv_g : packoffset(c40.y);
  float windWaveTime_g : packoffset(c40.z);
  float windWaveFrequency_g : packoffset(c40.w);
  uint localLightProbeCount_g : packoffset(c41);
  float lightSpecularGlossiness_g : packoffset(c41.y);
  float lightSpecularIntensity_g : packoffset(c41.z);
  uint pointLightCount_g : packoffset(c41.w);
  float4x4 ditherMtx_g : packoffset(c42);
  float4 lightProbe_g[9] : packoffset(c46);
  float4x4 farShadowMtx_g : packoffset(c55);
  float3 chrLightDir_g : packoffset(c59);
  float shadowDistance_g : packoffset(c59.w);
  float resolutionScaling_g : packoffset(c60);
  float sceneTime_g : packoffset(c60.y);
  float windForce_g : packoffset(c60.z);
  float disableMapObjNearFade_g : packoffset(c60.w);
  float4 mapColor_g : packoffset(c61);
  float4 clipPlane_g : packoffset(c62);
  float shadowZeroCascadeUVMult_g : packoffset(c63);
}

cbuffer cb_local : register(b2)
{
  uint maxRayCount_g : packoffset(c0);
  float rayLength_g : packoffset(c0.y);
}

SamplerState samPoint_s : register(s1);
Texture2D<float4> colorTexture : register(t0);
Texture2D<float4> depthTexture : register(t1);
Texture2D<uint4> mrtTexture : register(t2);
Texture2D<float4> prevSSRTexture : register(t3);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  mrtTexture.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r0.xy = fDest.xy;
  r0.zw = v1.xy * r0.xy;
  r1.xy = (int2)r0.zw;
  r1.zw = float2(0,0);
  r1.xyz = mrtTexture.Load(r1.xyz).xyz;
  r2.xyz = colorTexture.SampleLevel(samPoint_s, v1.xy, 0).xyz;
  r0.z = (uint)r1.z >> 24;
  r0.z = (int)r0.z & 2;
  if (r0.z == 0) {
    o0.xyz = r2.xyz;
    o0.w = 0;
    return;
  }
  r3.xyz = prevSSRTexture.SampleLevel(samPoint_s, v1.xy, 0).xyz;
  r4.z = depthTexture.SampleLevel(samPoint_s, v1.xy, 0).x;
  r4.xy = v1.zw * float2(2,-2) + float2(-1,1);
  r4.w = 1;
  r5.x = dot(r4.xyzw, projInv_g._m00_m10_m20_m30);
  r5.y = dot(r4.xyzw, projInv_g._m01_m11_m21_m31);
  r5.z = dot(r4.xyzw, projInv_g._m02_m12_m22_m32);
  r0.z = dot(r4.xyzw, projInv_g._m03_m13_m23_m33);
  r4.xyz = r5.xyz / r0.zzz;
  r5.y = (uint)r1.x >> 16;
  r5.x = r1.x;
  r0.zw = (int2)r5.xy & int2(0xffff,0xffff);
  r0.zw = (uint2)r0.zw;
  r5.xy = float2(1.52590219e-005,1.52590219e-005) * r0.zw;
  r0.z = (int)r1.y & 0x0000ffff;
  r0.z = (uint)r0.z;
  r5.z = 1.52590219e-005 * r0.z;
  r1.xzw = float3(-0.5,-0.5,-0.5) + r5.xyz;
  r1.xzw = r1.xzw + r1.xzw;
  r0.z = dot(r1.xzw, r1.xzw);
  r0.z = rsqrt(r0.z);
  r1.xzw = r1.xzw * r0.zzz;
  r5.x = dot(r1.xzw, view_g._m00_m10_m20);
  r5.y = dot(r1.xzw, view_g._m01_m11_m21);
  r5.z = dot(r1.xzw, view_g._m02_m12_m22);
  r0.z = dot(r4.xyz, r4.xyz);
  r0.z = rsqrt(r0.z);
  r1.xzw = r4.xyz * r0.zzz;
  r0.z = dot(r1.xzw, r5.xyz);
  r0.z = r0.z + r0.z;
  r1.xzw = r5.xyz * -r0.zzz + r1.xzw;
  r0.z = dot(-r4.xyz, -r4.xyz);
  r0.z = rsqrt(r0.z);
  r6.xyz = -r4.xyz * r0.zzz;
  r0.z = dot(r6.xyz, r5.xyz);
  if (8 == 0) r5.x = 0; else if (8+16 < 32) {   r5.x = (uint)r1.y << (32-(8 + 16)); r5.x = (uint)r5.x >> (32-8);  } else r5.x = (uint)r1.y >> 16;
  if (8 == 0) r5.y = 0; else if (8+24 < 32) {   r5.y = (uint)r1.y << (32-(8 + 24)); r5.y = (uint)r5.y >> (32-8);  } else r5.y = (uint)r1.y >> 24;
  r5.xy = (uint2)r5.xy;
  r5.yz = float2(3.92156887,0.392156899) * r5.xy;
  r0.w = maxRayCount_g;
  r0.w = r5.y / r0.w;
  r6.xyz = r1.xzw * r0.www;
  r7.xyz = sceneTime_g * r4.xyz;
  r1.y = dot(r7.xyz, float3(12.9898005,78.2330017,56.7869987));
  r1.y = sin(r1.y);
  r1.y = 43758.5469 * r1.y;
  r1.y = frac(r1.y);
  r1.y = r1.y * 0.00999999978 + r0.w;
  r7.xyz = r1.xzw * r1.yyy + r4.xyz;
  r0.z = 1 + -abs(r0.z);
  r0.z = r0.z * r0.z;
  r0.z = r0.z * r0.z;
  r0.z = r0.z * r0.z;
  r0.z = -r4.z * r0.z;
  r0.z = 0.0199999996 * r0.z;
  r7.xyz = r1.xzw * r0.zzz + r7.xyz;
  r8.w = 1;
  r9.x = resolutionScaling_g;
  r9.yw = float2(1,1);
  r5.yw = float2(0,0);
  r1.y = 0;
  r10.xyz = r7.xyz;
  r2.w = 0;
  while (true) {
    r3.w = cmp((uint)r2.w >= maxRayCount_g);
    if (r3.w != 0) break;
    r8.xyz = r10.xyz;
    r11.x = dot(r8.xyzw, proj_g._m00_m10_m20_m30);
    r11.y = dot(r8.xyzw, proj_g._m01_m11_m21_m31);
    r3.w = dot(r8.xyzw, proj_g._m03_m13_m23_m33);
    r11.xy = r11.xy / r3.ww;
    r11.zw = float2(0.5,0.5) * r11.xy;
    r12.xy = r11.xy * float2(0.5,0.5) + float2(0.5,0.5);
    r3.w = max(abs(r11.z), abs(r11.w));
    r3.w = cmp(0.5 < r3.w);
    if (r3.w != 0) {
      r5.yw = r12.xy;
      break;
    }
    r12.w = 1 + -r12.y;
    r12.z = 1 + -r12.y;
    r11.xy = r12.xz * r9.xy;
    r9.z = depthTexture.SampleLevel(samPoint_s, r11.xy, 0).x;
    r3.w = dot(projInv_g._m22_m32, r9.zw);
    r4.w = dot(projInv_g._m23_m33, r9.zw);
    r3.w = r3.w / r4.w;
    r3.w = -r10.z + r3.w;
    r4.w = cmp(0 < r3.w);
    r3.w = cmp(r3.w < r5.z);
    r3.w = r3.w ? r4.w : 0;
    if (r3.w != 0) {
      r5.yw = r12.xz;
      r1.y = -1;
      break;
    }
    r10.xyz = r1.xzw * r0.www + r8.xyz;
    r2.w = (int)r2.w + 1;
    r5.yw = r12.xw;
    r1.y = 0;
  }
  if (r1.y != 0) {
    r1.xyz = -r1.xzw * r0.www + r10.xyz;
    r6.xyz = float3(0.03125,0.03125,0.03125) * r6.xyz;
    r7.w = 1;
    r8.x = resolutionScaling_g;
    r8.yw = float2(1,1);
    r7.xyz = r1.xyz;
    r9.xy = r5.yw;
    r0.w = 16;
    r1.w = 16;
    r2.w = 0;
    while (true) {
      r3.w = cmp((int)r2.w >= 32);
      if (r3.w != 0) break;
      r7.xyz = r6.xyz * r1.www + r7.xyz;
      r10.x = dot(r7.xyzw, proj_g._m00_m10_m20_m30);
      r10.y = dot(r7.xyzw, proj_g._m01_m11_m21_m31);
      r3.w = dot(r7.xyzw, proj_g._m03_m13_m23_m33);
      r10.xy = r10.xy / r3.ww;
      r9.xz = r10.xy * float2(0.5,0.5) + float2(0.5,0.5);
      r0.w = 0.5 * r0.w;
      r9.y = 1 + -r9.z;
      r9.zw = r9.xy * r8.xy;
      r8.z = depthTexture.SampleLevel(samPoint_s, r9.zw, 0).x;
      r3.w = dot(projInv_g._m22_m32, r8.zw);
      r4.w = dot(projInv_g._m23_m33, r8.zw);
      r3.w = r3.w / r4.w;
      r3.w = -r7.z + r3.w;
      r4.w = cmp(0 < r3.w);
      r3.w = cmp(r3.w < r5.z);
      r3.w = r3.w ? r4.w : 0;
      r1.w = r3.w ? -r0.w : r0.w;
      r2.w = (int)r2.w + 1;
    }
    r1.xy = float2(-0.5,-0.5) + r9.xy;
    r0.w = dot(r1.xy, r1.xy);
    r0.w = sqrt(r0.w);
    r0.w = r0.w + r0.w;
    r1.x = r0.w * r0.w;
    r0.w = -r0.w * r1.x + 1;
    r1.xyz = -r7.xyz + r4.xyz;
    r1.x = dot(r1.xyz, r1.xyz);
    r1.x = sqrt(r1.x);
    r0.z = r5.x * 3.92156887 + r0.z;
    r0.z = r1.x / r0.z;
    r0.z = -r0.z * r0.z + 1;
    r0.z = min(r0.w, r0.z);
    r1.x = resolutionScaling_g;
    r1.y = 1;
    r1.xy = r9.xy * r1.xy;
    r0.xy = r1.xy * r0.xy;
    r4.xy = (int2)r0.xy;
    r4.zw = float2(0,0);
    r0.x = mrtTexture.Load(r4.xyz).z;
    r0.x = (uint)r0.x >> 24;
    r0.x = (int)r0.x & 2;
    o0.w = r0.x ? 0 : r0.z;
    r2.xyz = colorTexture.SampleLevel(samPoint_s, r1.xy, 0).xyz;
  } else {
    o0.w = 0;
  }
  r0.xyz = r3.xyz + -r2.xyz;
  o0.xyz = r0.xyz * float3(0.5,0.5,0.5) + r2.xyz;
  return;
}