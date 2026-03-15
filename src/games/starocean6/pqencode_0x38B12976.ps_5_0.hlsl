// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 04 18:24:05 2025

cbuffer cb_gp : register(b2)
{
  float4 cvConst_0 : packoffset(c0);
  float4 cvConst_1 : packoffset(c1);
  float4 cvConst_2 : packoffset(c2);
  float4 cvConst_3 : packoffset(c3);
  float4 cvConst_4 : packoffset(c4);
  float4 cvConst_5 : packoffset(c5);
  float4 cvConst_6 : packoffset(c6);
  float4 cvConst_7 : packoffset(c7);
  float4 cvConst_8 : packoffset(c8);
  float4 cvConst_9 : packoffset(c9);
  float4 cvConst_10 : packoffset(c10);
  float4 cvConst_11 : packoffset(c11);
  float4 cvConst_12 : packoffset(c12);
  float4 cvConst_13 : packoffset(c13);
  float4 cvConst_14 : packoffset(c14);
  float4 cvConst_15 : packoffset(c15);
  float4 cvConst_16 : packoffset(c16);
  float4 cvConst_17 : packoffset(c17);
  float4 cvConst_18 : packoffset(c18);
  float4 cvConst_19 : packoffset(c19);
  float4 cvConst_20 : packoffset(c20);
  float4 cvConst_21 : packoffset(c21);
  float4 cvConst_22 : packoffset(c22);
  float4 cvConst_23 : packoffset(c23);
  float4 cvConst_24 : packoffset(c24);
  float4 cvUVOffsetTBR[5] : packoffset(c27);
  float4 cvConst_48 : packoffset(c48);
  float4 cvConst_95 : packoffset(c95);
}

SamplerState asTexSamp_0__s : register(s0);
SamplerState asTexSamp_2__s : register(s2);
SamplerState asTexSamp_4__s : register(s4);
Texture2D<float4> asTexObject_0_ : register(t0);
Texture2D<float4> asTexObject_2_ : register(t2);
Texture2D<float4> asTexObject_4_ : register(t4);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  linear centroid float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  uint v3 : SV_IsFrontFace0,
  out float4 o0 : SV_TARGET0,
  out float oDepth : SV_DEPTH)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = asTexObject_4_.Sample(asTexSamp_4__s, v1.xy).xyz;
  r1.xyzw = asTexObject_0_.Sample(asTexSamp_0__s, v1.xy).xyzw;
  r0.xyz = cvConst_1.yyy * r0.xyz;
  r0.xyz = r1.xyz * cvConst_1.xxx + r0.xyz;
  r1.xyz = cvConst_0.zzz * r0.xyz;
  r2.xyz = r1.xyz * cvConst_0.xxx + float3(1,1,1);
  r1.xyz = r2.xyz * r1.xyz;
  r0.xyz = r0.xyz * cvConst_0.zzz + float3(1,1,1);
  r0.xyz = r1.xyz / r0.xyz;
  r0.w = cmp(0 < cvConst_14.x);
  if (r0.w != 0) {

    // primaries conversion
    r1.x = dot(float3(0.627403975,0.329281986,0.0433139987), r0.xyz);
    r1.y = dot(float3(0.0690969974,0.919541001,0.0113620004), r0.xyz);
    r1.z = dot(float3(0.016392,0.0880130008,0.895595014), r0.xyz);

    // srgb encoding
    r1.xyz = saturate(float3(0.00999999978,0.00999999978,0.00999999978) * r1.xyz);
    r2.xyz = float3(89.6549988,89.6549988,89.6549988) * r1.xyz;
    r2.xyz = log2(r2.xyz);
    r2.xyz = float3(0.416666657,0.416666657,0.416666657) * r2.xyz;
    r2.xyz = exp2(r2.xyz);
    r2.xyz = r2.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
    r3.xyz = float3(1158.34363,1158.34363,1158.34363) * r1.xyz;
    r1.xyz = cmp(float3(3.50000009e-005,3.50000009e-005,3.50000009e-005) >= r1.xyz);
    r1.xyz = r1.xyz ? r3.xyz : r2.xyz;

    // 2.4 decoding
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(2.4000001,2.4000001,2.4000001) * r1.xyz;
    r1.xyz = exp2(r1.xyz);

    // cvConst_14.y is likely nits value, so this is * nits / 10000
    r0.w = cvConst_14.y * 9.99999975e-005;
    r1.xyz = saturate(r1.xyz * r0.www);

    // PQ encoding
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(0.159301758,0.159301758,0.159301758) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r2.xyz = r1.xyz * float3(18.8515625,18.8515625,18.8515625) + float3(0.8359375,0.8359375,0.8359375);
    r1.xyz = r1.xyz * float3(18.6875,18.6875,18.6875) + float3(1,1,1);
    r1.xyz = r2.xyz / r1.xyz;
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(78.84375,78.84375,78.84375) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
  } else {
    r2.xyz = cmp(float3(0.00313080009,0.00313080009,0.00313080009) >= r0.xyz);
    r3.xyz = float3(12.9200001,12.9200001,12.9200001) * r0.xyz;
    r0.xyz = saturate(r0.xyz);
    r0.xyz = log2(r0.xyz);
    r0.xyz = float3(0.416666657,0.416666657,0.416666657) * r0.xyz;
    r0.xyz = exp2(r0.xyz);
    r0.xyz = r0.xyz * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
    r1.xyz = r2.xyz ? r3.xyz : r0.xyz;
  }
  r0.xyz = asTexObject_2_.Sample(asTexSamp_2__s, v1.zw).xyz;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  o0.xyz = r0.xyz * cvConst_0.yyy + r1.xyz;
  o0.w = r1.w;
  oDepth = 0;
  return;
}