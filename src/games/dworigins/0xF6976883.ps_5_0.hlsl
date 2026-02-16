// ---- Created with 3Dmigoto v1.3.16 on Mon Feb 16 11:15:57 2026

cbuffer _Globals : register(b0)
{
  float4 vToneMapParams : packoffset(c0);
  float fGamma : packoffset(c1);
  float fToneCurveType : packoffset(c1.y);
}

SamplerState s0_s : register(s0);
SamplerState s1_s : register(s1);
SamplerState s2_s : register(s2);
Texture2D<float4> t0 : register(t0);
Texture2D<float4> t1 : register(t1);
Texture3D<float4> t2 : register(t2);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : COLOR0,
  float2 v2 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xy = t1.Sample(s1_s, float2(0.75,0.5)).xy;
  r1.z = cmp(vToneMapParams.w < 0);
  r2.xyz = cmp(r0.xyz == float3(0,0,0));
  r1.w = r2.y ? r2.x : 0;
  r1.w = r2.z ? r1.w : 0;
  r1.w = r1.w ? 0 : r1.x;
  r1.x = r1.z ? r1.w : r1.x;
  r1.x = cmp(r1.x == 0.500000);
  if (r1.x != 0) {
    r1.x = t1.Sample(s1_s, float2(0.25,0.5)).x;
    r0.xyz = r1.xxx * r0.xyz;
    r1.x = cmp(fToneCurveType == 0.000000);
    if (r1.x != 0) {
      r1.x = dot(r0.xyz, float3(0.298909992,0.586610019,0.114480004));
      r1.z = r1.x * vToneMapParams.x + 1;
      r1.x = 1 + r1.x;
      r1.x = r1.z / r1.x;
      r0.xyz = r1.xxx * r0.xyz;
    } else {
      r1.xz = cmp(fToneCurveType == float2(0.100000001,0.200000003));
      r1.x = (int)r1.z | (int)r1.x;
      if (r1.x != 0) {
        r1.x = cmp(fToneCurveType < 0.200000003);
        r2.xyzw = r1.xxxx ? float4(0.219999999,0.300000012,0.0299999993,0.00200000009) : float4(0.150000006,0.5,0.0500000007,0.00400000019);
        r3.xyz = r2.xxx * r0.xyz + r2.zzz;
        r3.xyz = r0.xyz * r3.xyz + r2.www;
        r2.xyz = r2.xxx * r0.xyz + r2.yyy;
        r2.xyz = r0.xyz * r2.xyz + float3(0.0599999987,0.0599999987,0.0599999987);
        r2.xyz = r3.xyz / r2.xyz;
        r1.x = r1.x ? -0.0333000012 : -0.0670000017;
        r1.xzw = r2.xyz + r1.xxx;
        r0.xyz = r1.xzw * r1.yyy;
      } else {
        r1.x = cmp(fToneCurveType < 0);
        if (r1.x != 0) {
          r1.xyz = r0.xyz * float3(5.55555582,5.55555582,5.55555582) + float3(0.0479959995,0.0479959995,0.0479959995);
          r1.xyz = log2(r1.xyz);
          r1.xyz = saturate(r1.xyz * float3(0.0734997839,0.0734997839,0.0734997839) + float3(0.386036009,0.386036009,0.386036009));
          r0.xyz = t2.SampleLevel(s2_s, r1.xyz, 0).xyz;
        }
      }
    }
  }
  r0.xyz = log2(abs(r0.xyz));
  r0.xyz = fGamma * r0.xyz;
  o0.xyz = exp2(r0.xyz);
  o0.w = r0.w;
  return;
}