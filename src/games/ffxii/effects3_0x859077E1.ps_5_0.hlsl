// ---- Created with 3Dmigoto v1.3.16 on Sun Jun 01 01:46:56 2025
#include "./shared.h"

cbuffer _Globals : register(b0)
{
  float4 regionClamp : packoffset(c0);
  float2 regionClampE : packoffset(c1);
  int texAEnable : packoffset(c1.z);
  float texA : packoffset(c1.w);
  int tfx : packoffset(c2);
  int tcc : packoffset(c2.y);
  int softParticleEnabled : packoffset(c2.z);
  int blendFix : packoffset(c2.w);
  int psDATE : packoffset(c3);
  int psDATM : packoffset(c3.y);
  float softParticleFactor : packoffset(c3.z);
  int usePositonUv : packoffset(c3.w);
  int b : packoffset(c4);
  int c : packoffset(c4.y);
}

SamplerState TextureSampler_s : register(s0);
Texture2D<float4> Texture : register(t0);
Texture2D<float4> Palette : register(t1);
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = floor(v1.xyzw);
  Texture.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r1.xy = fDest.xy;
  if (usePositonUv != 0) {
    r1.zw = v0.xy / r1.xy;
  } else {
    r2.xyz = cmp(float3(0.99000001,0.99000001,1.99000001) < regionClampE.xyx);
    r3.xyz = cmp(regionClampE.xyx < float3(1.00999999,1.00999999,2.00999999));
    r2.xyz = r2.xyz ? r3.xyz : 0;
    r3.xy = v2.xy * r1.xy;
    r3.zw = regionClamp.xz * r1.xy;
    r3.zw = r1.xy * v2.xy + -r3.zw;
    r3.zw = cmp(r3.zw < float2(0.5,0.5));
    r4.xy = float2(0.5,0.5) / r1.xy;
    r4.zw = regionClamp.xz + r4.xy;
    r3.zw = r3.zw ? r4.zw : v2.xy;
    r3.xy = r1.xy * regionClamp.yw + -r3.xy;
    r3.xy = cmp(r3.xy < float2(0.5,0.5));
    r4.xy = regionClamp.yw + -r4.xy;
    r3.xy = r3.xy ? r4.xy : r3.zw;
    r1.zw = r2.xy ? r3.xy : v2.xy;
    if (r2.z != 0) {
      r2.x = cmp(1.99000001 < regionClampE.y);
      r2.y = cmp(regionClampE.y < 2.00999999);
      r2.x = r2.y ? r2.x : 0;
      if (r2.x != 0) {
        r2.xy = r1.zw / regionClamp.xz;
        r2.zw = floor(r2.xy);
        r2.xy = r2.xy + -r2.zw;
        r1.zw = r2.xy * regionClamp.xz + regionClamp.yw;
        r2.xy = float2(1,1) / r1.xy;
        r3.xyzw = r1.xyxy * r1.zwzw + float4(-0.5,-0.5,0.5,0.5);
        r2.zw = -r1.xy * regionClamp.yw + r3.xy;
        r4.xy = cmp(r2.zw < float2(0,0));
        r2.zw = regionClamp.xz + regionClamp.yw;
        r5.xy = r2.zw + -r2.xy;
        r5.xy = r5.xy * r1.xy + float2(0.100000001,0.100000001);
        r6.xyz = regionClamp.yww + r2.xxy;
        r6.xyw = r6.xyz * r1.xyy + float3(-0.100000001,-0.100000001,-0.100000001);
        r5.z = r6.x;
        r7.xy = r4.xx ? r5.xz : r3.xz;
        r6.x = r5.y;
        r6.z = -1;
        r4.zw = r3.yw;
        r4.xyz = r4.yyy ? r6.xyz : r4.zwx;
        r2.z = r1.x * r2.z + -r7.y;
        r2.z = cmp(r2.z < 0);
        r5.w = -1;
        r7.z = r4.z;
        r5.xyz = r2.zzz ? r5.xzw : r7.xyz;
        r2.z = r1.y * r2.w + -r4.y;
        r2.z = cmp(r2.z < 0);
        r4.w = r5.z;
        r4.xyz = r2.zzz ? r6.xwz : r4.xyw;
        r2.z = floor(r5.x);
        r2.w = floor(r4.x);
        r6.zw = r2.zw * r2.xy;
        r5.x = floor(r5.y);
        r5.y = floor(r4.y);
        r6.xy = r5.xy * r2.xy;
        r5.xyzw = r2.xyxy * float4(0.5,0.5,0.5,0.5) + r6.zwxw;
        r2.z = Texture.Sample(TextureSampler_s, r5.xy).x;
        r2.w = Texture.Sample(TextureSampler_s, r5.zw).x;
        r5.xyzw = r2.xyxy * float4(0.5,0.5,0.5,0.5) + r6.zyxy;
        r2.x = Texture.Sample(TextureSampler_s, r5.xy).x;
        r2.y = Texture.Sample(TextureSampler_s, r5.zw).x;
        if (r4.z != 0) {
          r3.xy = frac(r3.xy);
          r2.xz = float2(255,255) * r2.xz;
          r4.x = (uint)r2.z;
          r2.z = 255 * r2.w;
          r5.x = (uint)r2.z;
          r6.x = (uint)r2.x;
          r2.x = 255 * r2.y;
          r2.x = (uint)r2.x;
          r4.yzw = float3(0,0,0);
          r4.xyzw = Palette.Load(r4.xyz).xyzw;
          r5.yzw = float3(0,0,0);
          r5.xyzw = Palette.Load(r5.xyz).xyzw;
          r6.yzw = float3(0,0,0);
          r6.xyzw = Palette.Load(r6.xyz).xyzw;
          r2.yzw = float3(0,0,0);
          r2.xyzw = Palette.Load(r2.xyz).xyzw;
          r5.xyzw = r5.xyzw + -r4.xyzw;
          r4.xyzw = r3.xxxx * r5.xyzw + r4.xyzw;
          r2.xyzw = r2.xyzw + -r6.xyzw;
          r2.xyzw = r3.xxxx * r2.xyzw + r6.xyzw;
          r2.xyzw = r2.xyzw + -r4.xyzw;
          r2.xyzw = r3.yyyy * r2.xyzw + r4.xyzw;
          r2.xyzw = float4(255,255,255,255) * r2.xyzw;
          r2.w = texAEnable ? texA : r2.w;
          r3.x = cmp(blendFix == 2);
          if (tfx == 0) {
            r3.y = cmp(tcc == 1);
            r4.xyzw = r2.xyzw * r0.xyzw;
            r4.xyzw = float4(0.0078125,0.0078125,0.0078125,0.0078125) * r4.xyzw;
            r4.xyzw = floor(r4.xyzw);
            r5.xyz = r4.xyz;
            r5.w = r0.w;
            r4.xyzw = r3.yyyy ? r4.xyzw : r5.xyzw;
          } else {
            r3.yzw = cmp(tfx == int3(1,1,2));
            r5.w = r3.z ? r2.w : r0.w;
            r6.xyz = r2.xyz * r0.xyz;
            r6.xyz = float3(0.0078125,0.0078125,0.0078125) * r6.xyz;
            r6.xyz = floor(r6.xyz);
            r6.xyz = r6.xyz + r0.www;
            r2.w = r2.w + r0.w;
            r6.w = r3.z ? r2.w : r0.w;
            r5.xyz = r6.xyz;
            r6.xyzw = r3.wwww ? r6.xyzw : r5.xyzw;
            r5.xyz = r2.xyz;
            r4.xyzw = r3.yyyy ? r5.xyzw : r6.xyzw;
          }
          r2.xyzw = float4(0.00392156886,0.00392156886,0.00392156886,0.00392156886) * r4.xyzw;
          if (softParticleEnabled != 0) {
            r4.xy = (int2)v0.xy;
            r4.zw = float2(0,0);
            r3.yzw = depthTexture.Load(r4.xyz).xyz;
            r3.y = dot(r3.yzw, float3(0.99609381,0.00389099144,1.51991853e-005));
            r3.y = -r3.y * 999.900024 + 1000;
            r3.z = -v0.z * 999.900024 + 1000;
            r3.yz = float2(100,100) / r3.yz;
            r3.y = r3.y + -r3.z;
            r3.z = saturate(r3.y / softParticleFactor);
            r3.y = 0.5 + r3.y;
            r3.w = cmp(0 < r3.y);
            r3.y = cmp(r3.y < 0);
            r3.y = (int)-r3.w + (int)r3.y;
            r3.y = (int)r3.y;
            r3.y = saturate(1 + r3.y);
            r3.z = -1 + r3.z;
            r3.y = r3.y * r3.z + 1;
            r2.w = r3.y * r2.w;
          }
          if (r3.x != 0) {
            o1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r2.wwww;
            r2.x = 1;
            r2.xyzw = r2.xxxw;
          } else {
            r3.x = cmp(blendFix == 3);
            if (r3.x != 0) {
              r2.xyzw = (r2.xyzw);
              o1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r2.wwww;
              r3.xyzw = float4(255,255,255,255) * r2.xyzw;
              r4.xy = (int2)v0.xy;
              r4.zw = float2(0,0);
              r4.xyz = frameTexture.Load(r4.xyz).xyz;
              r3.xyz = -r4.xyz * float3(255,255,255) + r3.xyz;
              r3.xyz = r3.xyz * r3.www;
              r3.xyz = float3(0.0078125,0.0078125,0.0078125) * r3.xyz;
              r3.xyz = floor(r3.xyz);
              r3.xyz = r2.xyz * float3(255,255,255) + r3.xyz;
              r2.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
            } else {
              r3.x = cmp(blendFix == 5);
              if (r3.x != 0) {
                r2.xyzw = saturate(r2.xyzw);
                o1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r2.wwww;
                r3.x = 255 * r2.w;
                r4.xy = (int2)v0.xy;
                r4.zw = float2(0,0);
                r3.yzw = frameTexture.Load(r4.xyz).xyz;
                r4.xyz = float3(255,255,255) * r3.yzw;
                r4.xyz = r2.xyz * float3(255,255,255) + -r4.xyz;
                r4.xyz = r4.xyz * r3.xxx;
                r4.xyz = float3(0.0078125,0.0078125,0.0078125) * r4.xyz;
                r4.xyz = floor(r4.xyz);
                r3.xyz = r3.yzw * float3(255,255,255) + r4.xyz;
                r2.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r3.xyz;
              } else {
                r3.x = cmp(blendFix == 4);
                r4.xyzw = saturate(r2.xyzw);
                r3.y = 1.9921875 * r4.w;
                r4.xyz = r4.xyz * r3.yyy;
                r2.xyzw = r3.xxxx ? r4.xyzw : r2.xyzw;
                o1.xyzw = float4(1,1,1,1);
              }
            }
          }
          o0.xyzw = saturate(r2.xyzw);
          return;
        }
      } else {
        o0.xyzw = float4(0,1,0,1);
        o1.xyzw = float4(0,0,0,1);
        return;
      }
    }
  }
  r2.xy = float2(1,1) / r1.xy;
  r1.xy = r1.xy * r1.zw + float2(-0.5,-0.5);
  r1.zw = frac(r1.xy);
  r1.xy = floor(r1.xy);
  r2.zw = float2(0.5,0.5) * r2.xy;
  r1.xy = r1.xy * r2.xy + r2.zw;
  r2.xyzw = Texture.Gather(TextureSampler_s, r1.xy).xyzw;
  r2.xyzw = float4(255,255,255,255) * r2.wzxy;
  r2.xyzw = (uint4)r2.wxyz;
  r3.x = r2.y;
  r3.yzw = float3(0,0,0);
  r3.xyzw = Palette.Load(r3.xyz).xyzw;
  r4.x = r2.z;
  r4.yzw = float3(0,0,0);
  r4.xyzw = Palette.Load(r4.xyz).xyzw;
  r5.x = r2.w;
  r5.yzw = float3(0,0,0);
  r5.xyzw = Palette.Load(r5.xyz).xyzw;
  r2.yzw = float3(0,0,0);
  r2.xyzw = Palette.Load(r2.xyz).xyzw;
  r4.xyzw = r4.xyzw + -r3.xyzw;
  r3.xyzw = r1.zzzz * r4.xyzw + r3.xyzw;
  r2.xyzw = r2.xyzw + -r5.xyzw;
  r2.xyzw = r1.zzzz * r2.xyzw + r5.xyzw;
  r2.xyzw = r2.xyzw + -r3.xyzw;
  r1.xyzw = r1.wwww * r2.xyzw + r3.xyzw;
  r1.xyzw = float4(255,255,255,255) * r1.xyzw;
  r1.w = texAEnable ? texA : r1.w;
  r2.x = cmp(blendFix == 2);
  if (tfx == 0) {
    r2.y = cmp(tcc == 1);
    r3.xyzw = r1.xyzw * r0.xyzw;
    r3.xyzw = float4(0.0078125,0.0078125,0.0078125,0.0078125) * r3.xyzw;
    r3.xyzw = floor(r3.xyzw);
    r0.xyz = r3.xyz;
    r3.xyzw = r2.yyyy ? r3.xyzw : r0.xyzw;
  } else {
    r2.yzw = cmp(tfx == int3(1,1,2));
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
  if (softParticleEnabled != 0) {
    r1.xy = (int2)v0.xy;
    r1.zw = float2(0,0);
    r1.xyz = depthTexture.Load(r1.xyz).xyz;
    r1.x = dot(r1.xyz, float3(0.99609381,0.00389099144,1.51991853e-005));
    r1.x = -r1.x * 999.900024 + 1000;
    r1.y = -v0.z * 999.900024 + 1000;
    r1.xy = float2(100,100) / r1.xy;
    r1.x = r1.x + -r1.y;
    r1.y = saturate(r1.x / softParticleFactor);
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
    r0.xyzw = r0.xxxw;
  } else {
    r2.x = cmp(blendFix == 3);
    if (r2.x != 0) {
      r0.xyzw = (r0.xyzw);
      r1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r0.wwww;
      r2.xyzw = float4(255,255,255,255) * r0.xyzw;
      r3.xy = (int2)v0.xy;
      r3.zw = float2(0,0);
      r3.xyz = frameTexture.Load(r3.xyz).xyz;
      r2.xyz = -r3.xyz * float3(255,255,255) + r2.xyz;
      r2.xyz = r2.xyz * r2.www;
      r2.xyz = float3(0.0078125,0.0078125,0.0078125) * r2.xyz;
      r2.xyz = floor(r2.xyz);
      r2.xyz = r0.xyz * float3(255,255,255) + r2.xyz;
      r0.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r2.xyz;
    } else {
      r2.x = cmp(blendFix == 5);
      if (r2.x != 0) {
        r0.xyzw = (r0.xyzw);
        r1.xyzw = float4(1.9921875,1.9921875,1.9921875,1.9921875) * r0.wwww;
        r2.x = 255 * r0.w;
        r3.xy = (int2)v0.xy;
        r3.zw = float2(0,0);
        r2.yzw = frameTexture.Load(r3.xyz).xyz;
        r3.xyz = float3(255,255,255) * r2.yzw;
        r3.xyz = r0.xyz * float3(255,255,255) + -r3.xyz;
        r3.xyz = r3.xyz * r2.xxx;
        r3.xyz = float3(0.0078125,0.0078125,0.0078125) * r3.xyz;
        r3.xyz = floor(r3.xyz);
        r2.xyz = r2.yzw * float3(255,255,255) + r3.xyz;
        r0.xyz = float3(0.00392156886,0.00392156886,0.00392156886) * r2.xyz;
      } else {
        r2.x = cmp(blendFix == 4);
        r3.xyzw = (r0.xyzw);
        r2.y = 1.9921875 * r3.w;
        r3.xyz = r3.xyz * r2.yyy;
        r2.y = 1.9921875 * r0.w;
        r0.xyzw = r2.xxxx ? r3.xyzw : r0.xyzw;
        r1.xyzw = r2.xxxx ? float4(1,1,1,1) : r2.yyyy;
      }
    }
  }
  o0.xyzw = (r0.xyzw);
  o1.xyzw = (r1.xyzw);

  return;
}