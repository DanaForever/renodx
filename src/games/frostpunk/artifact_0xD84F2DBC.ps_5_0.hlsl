// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 22:34:02 2025
Texture2D<float4> t7 : register(t7);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s7_s : register(s7);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[21];
}

cbuffer cb5 : register(b5)
{
  float4 cb5[225];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : TEXCOORD2,
  float4 v4 : TEXCOORD3,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD6,
  float4 v7 : TEXCOORD7,
  float2 v8 : TEXCOORD12,
  uint v9 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 o3 : SV_Target3)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v1.w;
  r0.y = v2.w;
  r1.xyz = t0.Sample(s0_s, r0.xy).xyz;
  r2.xyzw = t1.Sample(s1_s, r0.xy).xyzw;
  r0.z = dot(r2.xyzw, cb2[4].xyzw);
  r0.w = dot(r2.xyzw, cb2[6].xyzw);
  r2.xz = r2.yw * float2(-2,-2) + float2(1,1);
  r2.xy = cb2[7].xy * r2.xz + r2.yw;
  r2.xy = float2(-0.5,-0.5) + r2.xy;
  r2.xy = cb2[7].ww * r2.xy + float2(0.5,0.5);
  r3.xyz = cb2[1].xyz + -r1.xyz;
  r3.xyz = cb2[2].xxx * r3.xyz + r1.xyz;
  r4.xyz = cb2[2].yyy * r3.xyz;
  r1.w = cb2[3].x + -r0.z;
  r0.z = cb2[3].y * r1.w + r0.z;
  r1.w = r0.z * -2 + 1;
  r0.z = cb2[3].z * r1.w + r0.z;
  r5.x = cb2[3].w * r0.z;
  r0.z = cb2[5].x + -r0.w;
  r0.z = cb2[5].y * r0.z + r0.w;
  r0.w = r0.z * -2 + 1;
  r0.z = cb2[5].z * r0.w + r0.z;
  r5.y = cb2[5].w * r0.z;
  r0.z = cmp(0 < cb2[8].w);
  if (r0.z != 0) {
    r0.zw = float2(0.5,0.5) * r0.xy;
    r0.z = t0.Sample(s0_s, r0.zw).w;
    r2.zw = r0.xy * cb2[9].xy + cb2[9].zw;
    r0.w = t0.Sample(s0_s, r2.zw).w;
    r1.w = saturate(cb5[222].x + cb5[222].x);
    r2.z = saturate(cb5[222].x);
    r2.w = 1 + -r1.w;
    r3.w = cmp(0.000000 == cb5[222].y);
    r4.w = saturate(cb5[222].y + r2.w);
    r0.w = min(r4.w, r0.w);
    r0.w = r0.w + -r2.w;
    r0.w = r0.w / cb5[222].y;
    r0.w = r3.w ? 1 : r0.w;
    r0.w = saturate(cb2[8].w * r0.w);
    r6.xyz = cb2[10].xyz * v6.xyz;
    r7.xyz = frac(r6.xyz);
    r8.xyz = r7.xyz * r7.xyz;
    r7.xyz = -r7.xyz * float3(2,2,2) + float3(3,3,3);
    r7.xyz = r8.xyz * r7.xyz;
    r6.xyz = floor(r6.xyz);
    r2.w = r6.y * 57 + r6.x;
    r2.w = r6.z * 113 + r2.w;
    r3.w = sin(r2.w);
    r3.w = 43758.5469 * r3.w;
    r3.w = frac(r3.w);
    r6.xyzw = float4(1,57,58,113) + r2.wwww;
    r6.xyzw = sin(r6.xyzw);
    r6.xyzw = float4(43758.5469,43758.5469,43758.5469,43758.5469) * r6.xyzw;
    r6.xyzw = frac(r6.xyzw);
    r4.w = r6.x + -r3.w;
    r3.w = r7.x * r4.w + r3.w;
    r4.w = r6.z + -r6.y;
    r4.w = r7.x * r4.w + r6.y;
    r4.w = r4.w + -r3.w;
    r3.w = r7.y * r4.w + r3.w;
    r6.xyz = float3(114,170,171) + r2.www;
    r6.xyz = sin(r6.xyz);
    r6.xyz = float3(43758.5469,43758.5469,43758.5469) * r6.xyz;
    r6.xyz = frac(r6.xyz);
    r2.w = r6.x + -r6.w;
    r2.w = r7.x * r2.w + r6.w;
    r4.w = r6.z + -r6.y;
    r4.w = r7.x * r4.w + r6.y;
    r4.w = r4.w + -r2.w;
    r2.w = r7.y * r4.w + r2.w;
    r2.w = r2.w + -r3.w;
    r2.w = r7.z * r2.w + r3.w;
    r2.w = cb2[10].w * r2.w;
    r2.z = 1 + -r2.z;
    r0.w = saturate(-r2.w * r2.z + r0.w);
    r0.w = r0.w * r1.w;
    r0.z = max(r0.w, r0.z);
    r0.xy = r0.xy * cb2[16].xy + cb2[16].zw;
    r2.zw = float2(1,1) / cb2[16].xy;
    r2.zw = cb2[17].xy * r2.zw;
    r2.zw = float2(1,1) / r2.zw;
    r0.xy = r0.xy / r2.zw;
    r0.xy = frac(r0.xy);
    r0.xy = r0.xy * cb2[16].xy + cb2[16].zw;
    r6.xyzw = t7.Sample(s7_s, r0.xy).xyzw;
    r0.xy = float2(-0.5,-0.5) + r6.yw;
    r0.xy = cb2[20].zz * r0.xy + float2(0.5,0.5);
    r3.xyz = -r3.xyz * cb2[2].yyy + cb2[8].xyz;
    r4.xyz = r0.zzz * r3.xyz + r4.xyz;
    r2.zw = r6.xz + -r5.xy;
    r5.xy = r0.zz * r2.zw + r5.xy;
    r0.xy = r0.xy + -r2.xy;
    r2.xy = r0.zz * r0.xy + r2.xy;
  }
  r0.xy = r2.xy * float2(2,2) + float2(-1,-1);
  r0.z = dot(r0.xy, r0.xy);
  r0.z = 1 + -r0.z;
  r0.z = max(9.99999975e-005, r0.z);
  r0.z = sqrt(r0.z);
  r2.xyz = v5.xyz * r0.xxx;
  r0.xyw = v3.xyz * r0.yyy + r2.xyz;
  r2.xyz = v2.xyz * r0.zzz;
  r0.z = cmp((int)v9.x == 0);
  r1.w = (int)v9.x & 1;
  r0.z = (int)r0.z + (int)r1.w;
  r0.z = (int)r0.z;
  r0.xyz = r2.xyz * r0.zzz + r0.xyw;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.x = -cb5[224].z + 1;
  r0.x = cb5[224].y * r0.x;
  r0.y = cmp(0 < r0.x);
  r2.xyz = cb5[223].xyz + -r1.xyz;
  r1.xyz = cb5[224].xxx * r2.xyz + r1.xyz;
  r0.xzw = r1.xyz * r0.xxx;
  o2.xyz = r0.yyy ? r0.xzw : 0;
  o0.xyz = r4.xyz;
  o0.w = 1;
  o1.w = 1;
  o2.w = 1;
  r5.z = cb5[221].w;
  r5.w = 1;
  o3.xyzw = r5.yxzw;

  return;
}