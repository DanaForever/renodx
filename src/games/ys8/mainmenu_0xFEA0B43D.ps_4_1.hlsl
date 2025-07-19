// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 21:44:46 2025

cbuffer CB0 : register(b0)
{
  float altest : packoffset(c0);
  float danalightmode : packoffset(c0.y);
  float mulblend : packoffset(c0.z);
  float noalpha : packoffset(c0.w);
  float znear : packoffset(c1);
  float zfar : packoffset(c1.y);
  float zwrite : packoffset(c1.z);
  float4 shadowcolor : packoffset(c2);
  float4 cascadeBound : packoffset(c3);
  float4 lightColor : packoffset(c4);
  float4 specColor : packoffset(c5);
  float4 rimcolor : packoffset(c6);
  float4 lightvec : packoffset(c7);
  float4 param : packoffset(c8);
  float4 danalight : packoffset(c9);
  float numLight : packoffset(c1.w);

  struct
  {
    float4 pos;
    float4 color;
  } lightinfo[64] : packoffset(c10);

}

SamplerState tex_samp_s : register(s0);
SamplerState shadow_samp_s : register(s1);
SamplerState tex2_samp_s : register(s3);
SamplerState PointClampSamplerState_s : register(s5);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> shadow_tex : register(t1);
Texture2D<float4> tex2_tex : register(t3);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float4 v4 : TEXCOORD2,
  float4 v5 : TEXCOORD3,
  float4 v6 : TEXCOORD4,
  float4 v7 : TEXCOORD5,
  float4 v8 : TEXCOORD6,
  float4 v9 : TEXCOORD7,
  float4 v10 : SV_Position0,
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

  r0.xyzw = tex_tex.Sample(tex_samp_s, v2.xy).xyzw;
  r1.x = v0.w * r0.w;
  r1.z = cmp(0 != noalpha);
  r1.z = ~(int)r1.z;
  r2.x = altest;
  r2.y = 0.00400000019;
  r1.y = r0.w;
  r1.yw = -r2.xy + r1.yx;
  r1.yw = cmp(r1.yw < float2(0,0));
  r0.w = (int)r1.w | (int)r1.y;
  r0.w = r1.z ? r0.w : 0;
  if (r0.w != 0) discard;
  r0.w = cmp(0 < param.w);
  if (r0.w != 0) {
    r0.w = -param.z + v10.w;
    r0.w = r0.w / param.w;
    r0.w = min(1, r0.w);
    r1.y = cmp(0 != zwrite);
    if (r1.y != 0) {
      r1.yw = float2(0.25,0.25) * v10.yx;
      r2.xy = cmp(r1.yw >= -r1.yw);
      r1.yw = frac(abs(r1.yw));
      r1.yw = r2.xy ? r1.yw : -r1.yw;
      r1.yw = float2(4,4) * r1.yw;
      r1.yw = (uint2)r1.yw;
      r2.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r1.w+0].xyzw);
      r2.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r1.w+0].xyzw);
      r2.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r1.w+0].xyzw);
      r2.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r1.w+0].xyzw);
      r2.x = dot(r2.xyzw, icb[r1.y+0].xyzw);
      r2.y = 0.00400000019;
      r1.yw = -r2.xy + r0.ww;
      r1.yw = cmp(r1.yw < float2(0,0));
      r1.y = (int)r1.w | (int)r1.y;
      if (r1.y != 0) discard;
    } else {
      r1.x = r1.x * r0.w;
      r0.w = cmp(r1.x < 0.00400000019);
      if (r0.w != 0) discard;
    }
  }
  r0.w = cmp(0 < danalightmode);
  r1.y = cmp(0 >= danalight.w);
  r1.w = ~(int)r1.y;
  r2.x = r0.w ? r1.y : 0;
  r2.yz = cmp(float2(1,2) == danalightmode);
  r2.x = r2.y ? r2.x : 0;
  if (r2.x != 0) discard;
  r1.w = r0.w ? r1.w : 0;
  r2.xyw = -danalight.xyz + v6.xyz;
  r2.x = dot(r2.xyw, r2.xyw);
  r2.x = sqrt(r2.x);
  r2.x = r2.x / danalight.w;
  r2.x = min(1, r2.x);
  r2.x = 1 + -r2.x;
  r2.x = min(0.5, r2.x);
  r2.y = r2.x + r2.x;
  r2.x = -r2.x * 2 + 1;
  r2.x = r2.z ? r2.x : r2.y;
  r2.x = r2.x * r1.x;
  r2.y = cmp(r2.x < 0.00100000005);
  r1.w = r1.w ? r2.y : 0;
  if (r1.w != 0) discard;
  r1.w = dot(v6.xyz, v6.xyz);
  r1.w = rsqrt(r1.w);
  r2.yzw = v6.xyz * r1.www;
  r1.w = dot(-r2.yzw, v7.xyz);
  r1.w = saturate(1 + -r1.w);
  r2.y = cmp(param.y < 10);
  r1.w = log2(r1.w);
  r2.z = param.y * r1.w;
  r2.z = exp2(r2.z);
  r2.z = 1 + -r2.z;
  r2.w = cmp(r2.z < altest);
  r1.z = r1.z ? r2.w : 0;
  r1.z = r1.z ? r2.y : 0;
  if (r1.z != 0) discard;
  r1.y = r1.y ? r1.x : r2.x;
  r0.w = r0.w ? r1.y : r1.x;
  r1.x = r0.w * r2.z;
  r3.xyzw = tex2_tex.Sample(tex2_samp_s, v2.zw).xyzw;
  r1.y = v1.w * r3.w;
  r2.xzw = r3.xyz + -r0.xyz;
  r0.xyz = r1.yyy * r2.xzw + r0.xyz;
  r2.xzw = v0.xyz * r0.xyz;
  r3.xyz = lightColor.xyz * r2.xzw;
  r0.w = r2.y ? r1.x : r0.w;
  r1.x = dot(v7.xyz, lightvec.xyz);
  r1.x = saturate(1 + -r1.x);
  r1.x = log2(r1.x);
  r1.x = lightvec.w * r1.x;
  r1.x = exp2(r1.x);
  r1.y = cmp(shadowcolor.w >= 0);
  if (r1.y != 0) {
    r4.xyz = v9.xyz / v9.www;
    r5.xyz = float3(-0.5,-0.5,-0.000500000024) + r4.xyz;
    r1.yz = float2(0.5,0.5) + -abs(r5.xy);
    r1.yz = float2(10,10) * r1.yz;
    r1.yz = max(float2(0,0), r1.yz);
    r1.yz = min(float2(0.5,0.5), r1.yz);
    r1.y = r1.y * r1.z;
    r1.z = cmp(0.000000 == shadowcolor.w);
    if (r1.z != 0) {
      r6.xyzw = shadow_tex.Gather(shadow_samp_s, r4.xy).xyzw;
      r6.xyzw = cmp(r5.zzzz >= r6.xyzw);
      r6.xyzw = r6.xyzw ? float4(1,1,1,1) : 0;
      r4.zw = r6.xy + r6.zw;
      r1.z = r4.z + r4.w;
      r1.z = r1.z * r1.y;
    } else {
      r2.y = cmp(1.000000 == shadowcolor.w);
      if (r2.y != 0) {
        shadow_tex.GetDimensions(0, fDest.x, fDest.y, fDest.z);
        r2.y = fDest.x;
        r6.y = 1 / r2.y;
        r6.xz = -r6.yy;
        r7.xyzw = shadow_tex.Gather(shadow_samp_s, r4.xy).xyzw;
        r7.xyzw = cmp(r5.zzzz >= r7.xyzw);
        r7.xyzw = r7.xyzw ? float4(1,1,1,1) : 0;
        r4.zw = r7.xy + r7.zw;
        r2.y = r4.z + r4.w;
        r7.xyzw = r6.xxzy + r4.xyxy;
        r8.xyzw = shadow_tex.Gather(shadow_samp_s, r7.xy).xyzw;
        r8.xyzw = cmp(r5.zzzz >= r8.xyzw);
        r8.xyzw = r8.xyzw ? float4(1,1,1,1) : 0;
        r4.zw = r8.xy + r8.zw;
        r3.w = r4.z + r4.w;
        r2.y = r3.w + r2.y;
        r7.xyzw = shadow_tex.Gather(shadow_samp_s, r7.zw).xyzw;
        r7.xyzw = cmp(r5.zzzz >= r7.xyzw);
        r7.xyzw = r7.xyzw ? float4(1,1,1,1) : 0;
        r4.zw = r7.xy + r7.zw;
        r3.w = r4.z + r4.w;
        r2.y = r3.w + r2.y;
        r6.xyzw = r6.yzyy + r4.xyxy;
        r7.xyzw = shadow_tex.Gather(shadow_samp_s, r6.xy).xyzw;
        r7.xyzw = cmp(r5.zzzz >= r7.xyzw);
        r7.xyzw = r7.xyzw ? float4(1,1,1,1) : 0;
        r4.zw = r7.xy + r7.zw;
        r3.w = r4.z + r4.w;
        r2.y = r3.w + r2.y;
        r6.xyzw = shadow_tex.Gather(shadow_samp_s, r6.zw).xyzw;
        r6.xyzw = cmp(r5.zzzz >= r6.xyzw);
        r6.xyzw = r6.xyzw ? float4(1,1,1,1) : 0;
        r4.zw = r6.xy + r6.zw;
        r3.w = r4.z + r4.w;
        r2.y = r3.w + r2.y;
        r2.y = r2.y * r1.y;
        r1.z = 0.200000003 * r2.y;
      } else {
        r2.y = shadowcolor.w * 3.33333337e-005;
        r3.w = dot(v10.xy, float2(0.0671105608,0.00583714992));
        r3.w = frac(r3.w);
        r3.w = 52.9829178 * r3.w;
        r3.w = frac(r3.w);
        r3.w = 6.28318548 * r3.w;
        r4.zw = float2(0,0);
        while (true) {
          r5.x = cmp((int)r4.w >= 16);
          if (r5.x != 0) break;
          r5.x = (int)r4.w;
          r5.y = 0.5 + r5.x;
          r5.y = sqrt(r5.y);
          r5.y = 0.25 * r5.y;
          r5.x = r5.x * 2.4000001 + r3.w;
          sincos(r5.x, r5.x, r6.x);
          r6.x = r6.x * r5.y;
          r6.y = r5.y * r5.x;
          r5.xy = r6.xy * r2.yy;
          r5.xy = r5.xy * float2(3,3) + r4.xy;
          r6.xyzw = shadow_tex.Gather(PointClampSamplerState_s, r5.xy).xyzw;
          r6.xyzw = cmp(r5.zzzz >= r6.xyzw);
          r6.xyzw = r6.xyzw ? float4(1,1,1,1) : 0;
          r5.xy = r6.xy + r6.zw;
          r5.x = r5.x + r5.y;
          r4.z = r5.x + r4.z;
          r4.w = (int)r4.w + 1;
        }
        r1.y = r4.z * r1.y;
        r1.z = 0.0625 * r1.y;
      }
    }
    r1.x = max(r1.z, r1.x);
  }
  r1.y = numLight;
  r4.xyz = float3(0,0,0);
  r1.z = 0;
  while (true) {
    r2.y = cmp((int)r1.z >= (int)r1.y);
    if (r2.y != 0) break;
    r2.y = (uint)r1.z << 1;
    r5.xyz = lightinfo[r2.y].pos.xyz + -v6.xyz;
    r3.w = dot(r5.xyz, r5.xyz);
    r5.w = sqrt(r3.w);
    r3.w = cmp(r5.w >= lightinfo[r2.y].pos.w);
    if (r3.w != 0) {
      r3.w = (int)r1.z + 1;
      r1.z = r3.w;
      continue;
    }
    r6.x = r5.w;
    r6.w = lightinfo[r2.y].pos.w;
    r5.xyzw = r5.xyzw / r6.xxxw;
    r3.w = 1 + -r5.w;
    r3.w = log2(r3.w);
    r3.w = lightinfo[r2.y].color.w * r3.w;
    r3.w = exp2(r3.w);
    r4.w = dot(r5.xyz, v7.xyz);
    r4.w = max(0, r4.w);
    r3.w = r4.w * r3.w;
    r4.xyz = lightinfo[r2.y].color.xyz * r3.www + r4.xyz;
    r1.z = (int)r1.z + 1;
  }
  r1.yz = float2(0.224250004,0.440250009) * r4.xy;
  r1.y = r1.y + r1.z;
  r1.y = r4.z * 0.0855000019 + r1.y;
  r1.y = saturate(1 + -r1.y);
  r1.x = r1.x * r1.y;
  r0.xyz = r4.xyz * r0.xyz;
  r2.xyz = r2.xzw * lightColor.xyz + r0.xyz;
  r0.xyz = -r3.xyz * r0.xyz + r2.xyz;
  r2.xyz = lightColor.xyz + r4.xyz;
  r2.xyz = -r4.xyz * lightColor.xyz + r2.xyz;
  r2.xyz = rimcolor.xyz * r2.xyz;
  r1.y = rimcolor.w * r1.w;
  r1.y = exp2(r1.y);
  r1.yzw = r2.xyz * r1.yyy + v1.xyz;
  r2.xyz = shadowcolor.xyz * r0.xyz + -r0.xyz;
  r0.xyz = r1.xxx * r2.xyz + r0.xyz;
  r0.xyz = r0.xyz + r1.yzw;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r1.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.y = dot(v8.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = -r1.y * 0.5 + r1.x;
  r1.x = max(0, r1.x);
  r1.y = 1 + -v8.w;
  r1.y = v7.w * r1.y;
  r1.x = r1.x * r1.y;
  r1.yzw = r0.xyz * v8.www + v8.xyz;
  r2.xyz = r1.xxx * r0.xyz;
  r0.xyz = r0.xyz * r1.xxx + r1.yzw;
  r0.xyz = -r1.yzw * r2.xyz + r0.xyz;
  r1.x = cmp(0 != mulblend);
  r1.y = -r0.w * v8.w + 1;
  r2.xyz = float3(1,1,1) + -r0.xyz;
  r1.yzw = r1.yyy * r2.xyz + r0.xyz;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.x = cmp(0 < zwrite);
  r0.y = cmp(8.000000 == zwrite);
  r1.xyz = v7.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = v8.w;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.w = r0.w;
  return;
}