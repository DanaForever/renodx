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
  } cb : packoffset(c0);

}

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
  float4 r0,r1,r2,r3,r4;
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
  r1.xyzw = float4(0.00392156886,0.00392156886,0.00392156886,0.00392156886) * r0.xyzw;
  if (cb.softParticleEnabled != 0) {
    r2.xy = (int2)v0.xy;
    r2.zw = float2(0,0);
    r2.xyz = depthTexture.Load(r2.xyz).xyz;
    r2.x = dot(r2.xyz, float3(0.99609381,0.00389099144,1.51991853e-005));
    r2.x = -r2.x * 999.900024 + 1000;
    r2.y = -v0.z * 999.900024 + 1000;
    r2.xy = float2(100,100) / r2.xy;
    r2.x = r2.x + -r2.y;
    r2.y = saturate(r2.x / cb.softParticleFactor);
    r2.x = 0.5 + r2.x;
    r2.z = cmp(0 < r2.x);
    r2.x = cmp(r2.x < 0);
    r2.x = (int)-r2.z + (int)r2.x;
    r2.x = (int)r2.x;
    r2.x = saturate(1 + r2.x);
    r2.y = -1 + r2.y;
    r2.x = r2.x * r2.y + 1;
    r0.w = r2.x * r1.w;
  } else {
    r0.w = r1.w;
  }
  r1.w = cmp(asint(cb.blendFix) == 2);
  if (r1.w != 0) {
    r2.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r0.wwww;
    r0.x = 1;
    r0.xyzw = r0.xxxw;
  } else {
    r1.w = cmp(asint(cb.blendFix) == 3);
    if (r1.w != 0) {
      r3.xyzw = float4(1,1,1,255) * r0.xyzw;
      r4.xy = (int2)v0.xy;
      r4.zw = float2(0,0);
      r4.xyz = frameTexture.Load(r4.xyz).xyz;
      r3.xyz = -r4.xyz * float3(255,255,255) + r3.xyz;
      r3.xyz = r3.xyz * r3.www;
      r3.xyz = float3(0.0078125,0.0078125,0.0078125) * r3.xyz;
      r3.xyz = floor(r3.xyz);
      r3.xyz = r0.xyz * float3(1,1,1) + r3.xyz;
      r0.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
      r3.xy = float2(1.9921875,1) * r0.ww;
      r0.w = r3.y;
      r2.xyzw = r3.xxxx;
    } else {
      r1.w = cmp(asint(cb.blendFix) == 5);
      if (r1.w != 0) {
        r1.w = 255 * r0.w;
        r3.xy = (int2)v0.xy;
        r3.zw = float2(0,0);
        r3.xyz = frameTexture.Load(r3.xyz).xyz;
        r4.xyz = float3(255,255,255) * r3.xyz;
        r4.xyz = r0.xyz * float3(1,1,1) + -r4.xyz;
        r4.xyz = r4.xyz * r1.www;
        r4.xyz = float3(0.0078125,0.0078125,0.0078125) * r4.xyz;
        r4.xyz = floor(r4.xyz);
        r3.xyz = r3.xyz * float3(255,255,255) + r4.xyz;
        r0.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
        r3.xy = float2(1.9921875,1) * r0.ww;
        r0.w = r3.y;
        r2.xyzw = r3.xxxx;
      } else {
        r1.w = cmp(asint(cb.blendFix) == 4);
        r3.x = 1.9921875 * r0.w;
        r3.yzw = r3.xxx * r1.xyz;
        r2.xyzw = r1.wwww ? float4(1,1,1,1) : r3.xxxx;
        r0.xyz = r1.www ? r3.yzw : r1.xyz;
      }
    }
  }
  o0.xyzw = (r0.xyzw);
  o1.xyzw = (r2.xyzw);
  
  return;
}