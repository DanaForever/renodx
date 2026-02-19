// ---- Created with 3Dmigoto v1.3.16 on Fri Feb 20 00:50:06 2026
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

cbuffer CB1 : register(b1)
{

  struct
  {
    float4 pos;
    float4 color;
  } lightinfo[64] : packoffset(c0);

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
  float3 v0 : TEXCOORD0,
  float w0 : TEXCOORD4,
  float4 v1 : TEXCOORD1,
  float3 v2 : TEXCOORD2,
  float4 v3 : COLOR0,
  float4 v4 : COLOR1,
  float4 v5 : TEXCOORD3,
  float4 v6 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(0 != shdBasicParam.m_param[1].z);
  if (r0.x != 0) {
    r0.yz = float2(0.25,0.25) * v6.xy;
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
  r2.xyz = v1.xyz * r0.yyy;
  r3.xyzw = tex_tex.Sample(tex_samp_s, v0.xy).xyzw;
  r3.rgb = renodx::color::srgb::DecodeSafe(r3.rgb);
  r1.yzw = v3.xyz;
  r4.xyzw = r3.xyzw * r1.yzwx;
  r0.z = cmp(0 != shdBasicParam.m_param[0].w);
  r0.z = ~(int)r0.z;
  r5.x = -shdBasicParam.m_param[0].x;
  r5.y = -0.00400000019;
  r6.x = r3.w;
  r6.y = r4.w;
  r5.xy = r6.xy + r5.xy;
  r5.xy = cmp(r5.xy < float2(0,0));
  r0.w = (int)r5.y | (int)r5.x;
  r0.z = r0.z ? r0.w : 0;
  if (r0.z != 0) discard;
  r0.z = cmp(shd32Param.m_param.x < 10);
  r0.w = dot(-r2.xyz, v2.xyz);
  r1.x = saturate(1 + -r0.w);
  r1.x = log2(r1.x);
  r1.x = shd32Param.m_param.x * r1.x;
  r1.x = exp2(r1.x);
  r1.x = 1 + -r1.x;
  r1.x = r4.w * r1.x;
  r2.x = cmp(r1.x < 0.00100000005);
  r2.x = r0.z ? r2.x : 0;
  if (r2.x != 0) discard;
  r2.w = r0.z ? r1.x : r4.w;
  r0.z = cmp(0 < shd32Param.m_param.z);
  if (r0.z != 0) {
    r0.z = -shd32Param.m_param.y + v6.w;
    r0.z = shd32Param.m_param.z * r0.z;
    r0.z = min(1, r0.z);
    if (r0.x != 0) {
      r5.xy = float2(0.25,0.25) * v6.xy;
      r5.zw = cmp(r5.xy >= -r5.xy);
      r5.xy = frac(abs(r5.xy));
      r5.xy = r5.zw ? r5.xy : -r5.xy;
      r5.xy = float2(4,4) * r5.xy;
      r5.xy = (int2)r5.xy;
      r6.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r5.x+0].xyzw);
      r6.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r5.x+0].xyzw);
      r6.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r5.x+0].xyzw);
      r6.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r5.x+0].xyzw);
      r5.x = dot(r6.xyzw, icb[r5.y+0].xyzw);
      r5.y = 0.00400000019;
      r5.xy = -r5.xy + r0.zz;
      r5.xy = cmp(r5.xy < float2(0,0));
      r0.x = (int)r5.y | (int)r5.x;
      if (r0.x != 0) discard;
    } else {
      r2.w = r2.w * r0.z;
      r0.x = cmp(r2.w < 0.00400000019);
      if (r0.x != 0) discard;
    }
  }
  r0.x = cmp(0 < shd32Param.m_param.w);
  if (r0.x != 0) {
    r0.xz = v6.xy / shd32Param.m_depthuv.xy;
    r5.xyz = linearztex_tex.Sample(linearztex_samp_s, r0.xz).xyz;
    r5.rgb = renodx::color::srgb::DecodeSafe(r5.rgb);
    r0.x = dot(r5.xy, float2(65536,256));
    r0.x = r0.x + r5.z;
    r0.x = saturate(1.52587891e-005 * r0.x);
    r0.x = 1 + -r0.x;
    r0.z = shdBasicParam.m_param[1].y + -shdBasicParam.m_param[1].x;
    r0.x = r0.x * r0.z + shdBasicParam.m_param[1].x;
    r0.x = -v6.w + r0.x;
    r0.z = cmp(r0.x < 0);
    if (r0.z != 0) discard;
    r0.z = cmp(r0.x < shd32Param.m_param.w);
    r0.x = r0.x / shd32Param.m_param.w;
    r0.x = r2.w * r0.x;
    r2.w = r0.z ? r0.x : r2.w;
  }
  r0.x = (int)shdBasicParam.m_param[2].w;
  r5.xyz = float3(0,0,0);
  r6.xyz = float3(0,0,0);
  r0.z = 0;
  while (true) {
    r1.x = cmp((int)r0.z >= (int)r0.x);
    if (r1.x != 0) break;
    r1.x = (uint)r0.z << 1;
    r7.xyz = lightinfo[r1.x].pos.xyz + -v1.xyz;
    r3.w = dot(r7.xyz, r7.xyz);
    r7.w = sqrt(r3.w);
    r3.w = cmp(r7.w >= lightinfo[r1.x].pos.w);
    if (r3.w != 0) {
      r3.w = (int)r0.z + 1;
      r0.z = r3.w;
      continue;
    }
    r8.x = r7.w;
    r8.w = lightinfo[r1.x].pos.w;
    r7.xyzw = r7.xyzw / r8.xxxw;
    r3.w = 1 + -r7.w;
    r3.w = log2(r3.w);
    r3.w = lightinfo[r1.x].color.w * r3.w;
    r3.w = exp2(r3.w);
    r8.xyz = -v1.xyz * r0.yyy + r7.xyz;
    r4.w = dot(r8.xyz, r8.xyz);
    r4.w = rsqrt(r4.w);
    r8.xyz = r8.xyz * r4.www;
    r4.w = dot(r7.xyz, v2.xyz);
    r5.w = dot(r8.xyz, v2.xyz);
    r6.w = cmp(r4.w >= 0);
    r7.x = max(0, r4.w);
    r4.w = cmp(r5.w >= 0);
    r4.w = r6.w ? r4.w : 0;
    r5.w = r5.w * r5.w;
    r7.y = r4.w ? r5.w : 0;
    r7.xy = r7.xy * r3.ww;
    r5.xyz = lightinfo[r1.x].color.xyz * r7.xxx + r5.xyz;
    r6.xyz = lightinfo[r1.x].color.xyz * r7.yyy + r6.xyz;
    r0.z = (int)r0.z + 1;
  }
  r0.xyz = r5.xyz * r4.xyz;
  r1.xyz = r3.xyz * r1.yzw + r0.xyz;
  r0.xyz = -r4.xyz * r0.xyz + r1.xyz;
  r1.xyz = r6.xyz * float3(0.100000001,0.100000001,0.100000001) + v4.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  // r1.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = calculateLuminance(r0.rgb);
  // r1.y = dot(v5.xyz, float3(0.298999995,0.587000012,0.114));
  r1.y = calculateLuminance(v5.rgb);
  r1.x = -r1.y * 0.5 + r1.x;
  r1.x = max(0, r1.x);
  r1.y = 1 + -v5.w;
  r1.y = w0.x * r1.y;
  r1.x = r1.x * r1.y;
  r1.yzw = r0.xyz * v5.www + v5.xyz;
  r3.xyz = r1.xxx * r0.xyz;
  r0.xyz = r0.xyz * r1.xxx + r1.yzw;
  r0.xyz = -r1.yzw * r3.xyz + r0.xyz;
  r1.x = cmp(0 != shdBasicParam.m_param[0].z);
  r1.y = v5.w * r2.w;
  r1.z = -r2.w * v5.w + 1;
  r1.yzw = r1.yyy * r0.xyz + r1.zzz;
  r2.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.x = cmp(0 < shdBasicParam.m_scrEfxData.fGrimwardColor.w);
  if (r0.x != 0) {
    // r0.x = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
    r0.x = calculateLuminance(r2.rgb);
    r0.y = cmp(0 < r0.x);
    r0.z = dot(r2.xyz, r2.xyz);
    r0.z = rsqrt(r0.z);
    r1.xyz = r2.xyz * r0.zzz;
    r0.z = dot(shdBasicParam.m_scrEfxData.fGrimwardColor.xyz, shdBasicParam.m_scrEfxData.fGrimwardColor.xyz);
    r0.z = rsqrt(r0.z);
    r3.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.zzz;
    r0.z = dot(r1.xyz, r3.xyz);
    r1.x = cmp(0 < r0.z);
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.z;
    r0.z = r0.z * r0.z;
    r0.z = r1.x ? r0.z : 0;
    r1.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.zzz;
    r3.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.xyz * r0.zzz + r0.xxx;
    r1.xyz = -r0.xxx * r1.xyz + r3.xyz;
    r0.z = cmp(shdBasicParam.m_scrEfxData.fGrimwardColor.y == 1.000000);
    r0.x = sqrt(r0.x);
    r3.xyz = r1.xyz * r0.xxx;
    r3.xyz = r0.yyy ? r3.xyz : 0;
    r1.xyz = r0.zzz ? r3.xyz : r1.xyz;
    r1.xyz = r1.xyz + -r2.xyz;
    r1.xyz = shdBasicParam.m_scrEfxData.fGrimwardColor.www * r1.xyz + r2.xyz;
    r1.xyz = r1.xyz * r0.xxx;
    r2.xyz = r0.yyy ? r1.xyz : 0;
  }
  r0.x = cmp(shdBasicParam.m_scrEfxData.isInsightMode.x != 0.000000);
  r0.y = max(0, r0.w);
  r0.y = 1 + -r0.y;
  r0.z = cmp(0 < r0.y);
  r0.w = log2(r0.y);
  r0.w = shdBasicParam.m_scrEfxData.isInsightMode.w * r0.w;
  r0.w = exp2(r0.w);
  r0.y = r0.z ? r0.w : r0.y;
  // r0.z = dot(r2.xyz, float3(0.298999995,0.587000012,0.114));
  r0.z = calculateLuminance(r2.rgb);
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
  o0.rgb = renodx::color::srgb::EncodeSafe(o0.rgb);
  r0.x = cmp(0 < shdBasicParam.m_param[1].z);
  r0.y = cmp(shdBasicParam.m_param[1].z == 8.000000);
  r1.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = v5.w;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  return;
}