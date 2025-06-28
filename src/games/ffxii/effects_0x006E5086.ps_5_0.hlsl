// ---- Created with 3Dmigoto v1.3.16 on Sun Jun 01 01:46:56 2025
#include "./shared.h"
cbuffer _Globals : register(b0)
{

  struct
  {
    float4 regionClamp;
    float2 regionClampE;
    int texAEnable;
    float texA;
    int tfx;
    int tcc;
    int softParticleEnabled;
    int blendFix;
    int psDATE;
    int psDATM;
    float softParticleFactor;
    int usePositonUv;
  } cb : packoffset(c0);

}

SamplerState samplerState_s : register(s0);
Texture2D<float4> Texture : register(t0);
Texture2D<float4> depthTexture : register(t2);
Texture2D<float4> frameTexture : register(t3);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  out float4 o0 : SV_TARGET0,
  out float4 o1 : SV_TARGET1)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (cb.psDATE != 0) {
    r0.xy = (int2)v0.xy;
    r0.zw = float2(0,0);
    r0.x = frameTexture.Load(r0.xyz).w;
    r0.yz = cmp(asint(cb.psDATM) == int2(0,1));
    r0.w = cmp(r0.x >= 0.501960814);
    r0.y = r0.w ? r0.y : 0;
    if (r0.y != 0) discard;
    r0.x = cmp(r0.x < 0.501960814);
    r0.x = r0.x ? r0.z : 0;
    if (r0.x != 0) discard;
  }
  r0.xyzw = floor(v1.xyzw);
  Texture.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r1.xy = fDest.xy;
  if (cb.usePositonUv != 0) {
    r1.zw = v0.xy / r1.xy;
  } else {
    r2.xyzw = cmp(float4(0.99000001,1.99000001,0.99000001,1.99000001) < cb.regionClampE.xxyy);
    r3.xyzw = cmp(cb.regionClampE.xxyy < float4(1.00999999,2.00999999,1.00999999,2.00999999));
    r2.xyzw = r2.xyzw ? r3.xyzw : 0;
    r3.xy = v2.xy * r1.xy;
    r4.xyzw = cb.regionClamp.xyzw * r1.xxyy;
    r3.zw = r1.xy * v2.xy + -r4.xz;
    r3.zw = cmp(r3.zw < float2(0.5,0.5));
    r4.xz = float2(0.5,0.5) / r1.xy;
    r5.xy = cb.regionClamp.xz + r4.xz;
    r3.zw = r3.zw ? r5.xy : v2.xy;
    r3.xy = r1.xy * cb.regionClamp.yw + -r3.xy;
    r3.xy = cmp(r3.xy < float2(0.5,0.5));
    r4.xz = cb.regionClamp.yw + -r4.xz;
    r3.xy = r3.xy ? r4.xz : r3.zw;
    r2.xz = r2.xz ? r3.xy : v2.xy;
    r3.xy = r2.xz / cb.regionClamp.xz;
    r3.zw = floor(r3.xy);
    r3.xy = r3.xy + -r3.zw;
    r3.zw = r3.xy * cb.regionClamp.xz + cb.regionClamp.yw;
    r4.xz = r3.zw * r1.xy;
    r4.yw = r1.xy * r3.zw + -r4.yw;
    r4.yw = cmp(r4.yw < float2(0.5,0.5));
    r5.xy = r1.xy * cb.regionClamp.yw + float2(0.5,0.5);
    r5.xy = r5.xy / r1.xy;
    r3.zw = r4.yw ? r5.xy : r3.zw;
    r3.xy = cb.regionClamp.yw + r3.xy;
    r1.xy = r1.xy * r3.xy + -r4.xz;
    r1.xy = cmp(r1.xy < float2(0.5,0.5));
    r1.xy = r1.xy ? r3.xy : r3.zw;
    r1.zw = r2.yw ? r1.xy : r2.xz;
  }
  r1.xyzw = Texture.Sample(samplerState_s, r1.zw).xyzw;
  r1.xyzw = float4(255,255,255,255) * r1.xyzw;
  r1.w = cb.texAEnable ? cb.texA : r1.w;
  r2.x = cmp(asint(cb.blendFix) == 2);
  if (cb.tfx == 0) {
    r2.y = cmp(asint(cb.tcc) == 1);
    r3.xyzw = r1.xyzw * r0.xyzw;
    r3.xyzw = float4(0.0078125,0.0078125,0.0078125,0.0078125) * r3.xyzw;
    r3.xyzw = floor(r3.xyzw);
    r0.xyz = r3.xyz;
    r3.xyzw = r2.yyyy ? r3.xyzw : r0.xyzw;
  } else {
    r2.yzw = cmp(asint(cb.tfx) == int3(1,1,2));
    r4.w = r2.z ? r1.w : r0.w;
    r0.xyz = r1.xyz * r0.xyz;
    r0.xyz = float3(0.0078125,0.0078125,0.0078125) * r0.xyz;
    r0.xyz = floor(r0.xyz);
    r5.xyz = r0.xyz + r0.www;
    r0.x = r1.w + r0.w;
    r5.w = r2.z ? r0.x : r0.w;
    r4.xyz = r5.xyz;
    r0.xyzw = r2.wwww ? r5.xyzw : r4.xyzw;
    r4.xyz = r1.xyz;
    r3.xyzw = r2.yyyy ? r4.xyzw : r0.xyzw;
  }
  r0.xyzw = float4(0.00392156886,0.00392156886,0.00392156886,0.00392156886) * r3.xyzw;
  if (cb.softParticleEnabled != 0) {
    r1.xy = (int2)v0.xy;
    r1.zw = float2(0,0);
    r1.xyz = depthTexture.Load(r1.xyz).xyz;
    r1.x = dot(r1.xyz, float3(0.99609381,0.00389099144,1.51991853e-005));
    r1.x = -r1.x * 999.900024 + 1000;
    r1.y = -v0.z * 999.900024 + 1000;
    r1.xy = float2(100,100) / r1.xy;
    r1.x = r1.x + -r1.y;
    r1.y = saturate(r1.x / cb.softParticleFactor);
    r1.x = 0.5 + r1.x;
    r1.z = cmp(0 < r1.x);
    r1.x = cmp(r1.x < 0);
    r1.x = (int)-r1.z + (int)r1.x;
    r1.x = (int)r1.x;
    r1.x = saturate(1 + r1.x);
    r1.y = -1 + r1.y;
    r1.x = r1.x * r1.y + 1;
    r0.w = r1.x * r0.w;
  }
  if (r2.x != 0) {
    r1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r0.wwww;
    r0.x = 1;
    r2.xyzw = r0.xxxw;
  } else {
    r3.x = cmp(asint(cb.blendFix) == 3);
    if (r3.x != 0) {
      r0.xyzw = (r0.xyzw);
      r3.xyzw = float4(255,255,255,255) * r0.xyzw;
      r4.xy = (int2)v0.xy;
      r4.zw = float2(0,0);
      r4.xyz = frameTexture.Load(r4.xyz).xyz;
      r3.xyz = -r4.xyz * float3(255,255,255) + r3.xyz;
      r3.xyz = r3.xyz * r3.www;
      r3.xyz = float3(0.0078125,0.0078125,0.0078125) * r3.xyz;
      r3.xyz = floor(r3.xyz);
      r3.xyz = r0.xyz * float3(255,255,255) + r3.xyz;
      r2.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
      r3.xy = float2(1.9921875,1) * r0.ww;
      r2.w = r3.y;
      r1.xyzw = r3.xxxx;
    } else {
      r3.x = cmp(asint(cb.blendFix) == 5);
      if (r3.x != 0) {
        r0.xyzw = (r0.xyzw);
        r3.x = 255 * r0.w;
        r4.xy = (int2)v0.xy;
        r4.zw = float2(0,0);
        r3.yzw = frameTexture.Load(r4.xyz).xyz;
        r4.xyz = float3(255,255,255) * r3.yzw;
        r4.xyz = r0.xyz * float3(255,255,255) + -r4.xyz;
        r4.xyz = r4.xyz * r3.xxx;
        r4.xyz = float3(0.0078125,0.0078125,0.0078125) * r4.xyz;
        r4.xyz = floor(r4.xyz);
        r3.xyz = r3.yzw * float3(255,255,255) + r4.xyz;
        r2.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
        r3.xy = float2(1.9921875,1) * r0.ww;
        r2.w = r3.y;
        r1.xyzw = r3.xxxx;
      } else {
        r3.x = cmp(asint(cb.blendFix) == 4);
        r4.xyzw = (r0.xyzw);
        r3.y = 1.9921875 * r4.w;
        r4.xyz = r4.xyz * r3.yyy;
        r3.y = 1.9921875 * r0.w;
        r2.xyzw = r3.xxxx ? r4.xyzw : r0.xyzw;
        r1.xyzw = r3.xxxx ? float4(1,1,1,1) : r3.yyyy;
      }
    }
  }
  o0.xyzw = (r2.xyzw);
  o1.xyzw = (r1.xyzw);
  
  return;
}