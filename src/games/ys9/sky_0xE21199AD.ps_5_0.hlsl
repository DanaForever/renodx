// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 04:10:57 2025
#include "common.hlsl"
cbuffer CB0 : register(b0)
{

  struct
  {
    float4 m_param[5];

    struct
    {
      float4 fInsightColor;
      float4 isInsightMode;
      float4 fGrimwardColor;
      float3 fOtherParam;
    } m_scrEfxData;

  } shdBasicParam : packoffset(c0);

}

cbuffer CB2 : register(b2)
{

  struct
  {
    float4 m_lightvec;
    float4 m_param;
    float2 m_depthuv;
  } shd32Param : packoffset(c0);

}

SamplerState tex_samp_s : register(s0);
SamplerState linearztex_samp_s : register(s1);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> linearztex_tex : register(t1);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float3 v2 : TEXCOORD2,
  float4 v3 : COLOR0,
  float4 v4 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(0 != shdBasicParam.m_param[1].z);
  if (r0.x != 0) {
    r0.yz = float2(0.25,0.25) * v4.xy;
    r1.xy = cmp(r0.yz >= -r0.yz);
    r0.yz = frac(abs(r0.yz));
    r0.yz = r1.xy ? r0.yz : -r0.yz;
    r0.yz = float2(4,4) * r0.yz;
    r0.yz = (int2)r0.yz;
    r1.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r0.y+0].xyzw);
    r1.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r0.y+0].xyzw);
    r1.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r0.y+0].xyzw);
    r1.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r0.y+0].xyzw);
    r1.x = dot(r1.xyzw, icb[r0.z+0].xyzw);
    r1.y = 0.00400000019;
    r0.yz = shdBasicParam.m_scrEfxData.fOtherParam.xx * v0.zz + -r1.xy;
    r0.yz = cmp(r0.yz < float2(0,0));
    r0.y = (int)r0.z | (int)r0.y;
    if (r0.y != 0) discard;
    r1.x = v3.w;
  } else {
    r0.y = shdBasicParam.m_scrEfxData.fOtherParam.x * v0.z;
    r1.x = v3.w * r0.y;
    r0.y = cmp(r1.x < 0.00400000019);
    if (r0.y != 0) discard;
  }
  r0.y = dot(v1.xyz, v1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v1.xyz * r0.yyy;
  r2.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).wxyz;
  r1.yzw = v3.xyz;
  r1.xyzw = r2.yzwx * r1.yzwx;
  r2.z = cmp(0 != shdBasicParam.m_param[0].w);
  r2.z = ~(int)r2.z;
  r3.x = -shdBasicParam.m_param[0].x;
  r3.y = -0.00400000019;
  r2.y = r1.w;
  r2.xy = r2.xy + r3.xy;
  r2.xy = cmp(r2.xy < float2(0,0));
  r2.x = (int)r2.y | (int)r2.x;
  r2.x = r2.z ? r2.x : 0;
  if (r2.x != 0) discard;
  r2.x = cmp(shd32Param.m_param.x < 10);
  r0.y = dot(-r0.yzw, v2.xyz);
  r0.z = saturate(1 + -r0.y);
  // r0.z = log2(r0.z);
  // r0.z = shd32Param.m_param.x * r0.z;
  // r0.z = exp2(r0.z);
  r0.z = renodx::math::SafePow(r0.z, shd32Param.m_param.x);
  r0.z = 1 + -r0.z;
  r0.z = r1.w * r0.z;
  r0.w = cmp(r0.z < 0.00100000005);
  r0.w = r0.w ? r2.x : 0;
  if (r0.w != 0) discard;
  r2.w = r2.x ? r0.z : r1.w;
  r0.z = cmp(0 < shd32Param.m_param.z);
  if (r0.z != 0) {
    r0.z = -shd32Param.m_param.y + v4.w;
    r0.z = shd32Param.m_param.z * r0.z;
    r0.z = min(1, r0.z);
    if (r0.x != 0) {
      r0.xw = float2(0.25,0.25) * v4.xy;
      r3.xy = cmp(r0.xw >= -r0.xw);
      r0.xw = frac(abs(r0.xw));
      r0.xw = r3.xy ? r0.xw : -r0.xw;
      r0.xw = float2(4,4) * r0.xw;
      r0.xw = (int2)r0.xw;
      r3.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r0.x+0].xyzw);
      r3.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r0.x+0].xyzw);
      r3.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r0.x+0].xyzw);
      r3.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r0.x+0].xyzw);
      r3.x = dot(r3.xyzw, icb[r0.w+0].xyzw);
      r3.y = 0.00400000019;
      r0.xw = -r3.xy + r0.zz;
      r0.xw = cmp(r0.xw < float2(0,0));
      r0.x = (int)r0.w | (int)r0.x;
      if (r0.x != 0) discard;
    } else {
      r2.w = r2.w * r0.z;
      r0.x = cmp(r2.w < 0.00400000019);
      if (r0.x != 0) discard;
    }
  }
  r0.x = cmp(0 < shd32Param.m_param.w);
  if (r0.x != 0) {
    r0.xz = v4.xy / shd32Param.m_depthuv.xy;
    r0.xzw = linearztex_tex.Sample(linearztex_samp_s, r0.xz).xyz;
    r0.x = dot(r0.xz, float2(65536,256));
    r0.x = r0.x + r0.w;
    r0.x = saturate(1.52587891e-005 * r0.x);
    r0.x = 1 + -r0.x;
    r0.z = shdBasicParam.m_param[1].y + -shdBasicParam.m_param[1].x;
    r0.x = r0.x * r0.z + shdBasicParam.m_param[1].x;
    r0.x = -v4.w + r0.x;
    r0.z = cmp(r0.x < 0);
    if (r0.z != 0) discard;
    r0.z = cmp(r0.x < shd32Param.m_param.w);
    r0.x = r0.x / shd32Param.m_param.w;
    r0.x = r2.w * r0.x;
    r2.w = r0.z ? r0.x : r2.w;
  }
  r0.x = cmp(0 != shdBasicParam.m_param[0].z);
  r0.z = 1 + -r2.w;
  r3.xyz = r2.www * r1.xyz + r0.zzz;
  r2.xyz = r0.xxx ? r3.xyz : r1.xyz;
  r0.x = cmp(0 < shdBasicParam.m_scrEfxData.fGrimwardColor.w);
  if (r0.x != 0) {
    // r0.x = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
    r0.x = calculateLuminanceSRGB(r2.rgb);
    r0.z = cmp(0 < r0.x);
    r0.w = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.w);
    r1.xyz = r2.xyz * r0.www;
    r0.w = dot(shdBasicParam.m_scrEfxData.fGrimwardColor.xyz, shdBasicParam.m_scrEfxData.fGrimwardColor.xyz);
    r0.w = rsqrt(r0.w);
    r3.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.www;
    r0.w = dot(r1.xyz, r3.xyz);
    r1.x = cmp(0 < r0.w);
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r0.w;
    r0.w = r0.w * r0.w;
    r0.w = r1.x ? r0.w : 0;
    r1.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.www;
    r3.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.www + r0.xxx;
    r1.xyz = -r0.xxx * r1.xyz + r3.xyz;
    r0.w = cmp(shdBasicParam.m_scrEfxData.fGrimwardColor.y == 1.000000);
    r0.x = sqrt(r0.x);
    r3.xyz = r1.xyz * r0.xxx;
    r3.xyz = r0.zzz ? r3.xyz : 0;
    r1.xyz = r0.www ? r3.xyz : r1.xyz;
    r1.xyz = r1.xyz + -r2.xyz;
    r1.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.www * r1.xyz + r2.xyz;
    r1.xyz = r1.xyz * r0.xxx;
    r2.xyz = r0.zzz ? r1.xyz : 0;
  }
  r0.x = cmp(shdBasicParam.m_scrEfxData.isInsightMode.x != 0.000000);
  r0.y = max(0, r0.y);
  r0.y = 1 + -r0.y;
  r0.z = cmp(0 < r0.y);
  // r0.w = log2(r0.y);
  // r0.w = shdBasicParam.m_scrEfxData.isInsightMode.w * r0.w;
  // r0.w = exp2(r0.w);
  r0.w = renodx::math::SafePow(r0.y, shdBasicParam.m_scrEfxData.isInsightMode.w);
  r0.y = r0.z ? r0.w : r0.y;
  // r0.z = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
  r0.z = calculateLuminanceSRGB(r2.rgb);
  r0.w = cmp(0 < r0.z);
  r0.z = sqrt(r0.z);
  r1.xyz = r0.zzz * shdBasicParam.m_scrEfxData.fOtherParam.zzz + -r2.xyz;
  r1.xyz = shdBasicParam.m_scrEfxData.isInsightMode.zzz * r1.xyz + r2.xyz;
  r3.xyz = shdBasicParam.m_scrEfxData.fInsightColor.xyz * r0.yyy;
  r1.xyz = r3.xyz * shdBasicParam.m_scrEfxData.fInsightColor.www + r1.xyz;
  r1.xyz = min(float3(1,1,1), r1.xyz);
  r1.xyz = r0.www ? r1.xyz : 0;
  r0.z = cmp(shdBasicParam.m_scrEfxData.isInsightMode.y < 1);
  r0.y = r2.w * r0.y;
  r0.w = shdBasicParam.m_scrEfxData.fInsightColor.w * r0.y;
  r0.y = -r0.y * shdBasicParam.m_scrEfxData.fInsightColor.w + r2.w;
  r0.y = shdBasicParam.m_scrEfxData.isInsightMode.y * r0.y + r0.w;
  r1.w = r0.z ? r0.y : r2.w;
  o0.xyzw = r0.xxxx ? r1.xyzw : r2.xyzw;
  r0.x = cmp(0 < shdBasicParam.m_param[1].z);
  r0.y = cmp(shdBasicParam.m_param[1].z == 8.000000);
  r1.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = 0;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  return;
}