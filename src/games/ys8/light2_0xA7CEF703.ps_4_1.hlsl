// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 15:55:53 2025
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[134];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float w0 : TEXCOORD9,
  float4 v1 : TEXCOORD1,
  float3 v2 : TEXCOORD2,
  float4 v3 : COLOR0,
  float4 v4 : COLOR1,
  float4 v5 : TEXCOORD8,
  float4 v6 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = dot(v1.xyz, v1.xyz);
  r0.x = rsqrt(r0.x);
  r0.yzw = v1.xyz * r0.xxx;
  r1.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  r2.xyzw = v3.xyzw * r1.xyzw;
  r3.x = cmp(0 != cb0[0].w);
  r3.x = ~(int)r3.x;
  r4.x = -cb0[0].x;
  r4.y = -0.00400000019;
  r5.x = r1.w;
  r5.y = r2.w;
  r3.yz = r5.xy + r4.xy;
  r3.yz = cmp(r3.yz < float2(0,0));
  r1.w = (int)r3.z | (int)r3.y;
  r1.w = r3.x ? r1.w : 0;
  if (r1.w != 0) discard;
  r1.w = cmp(cb0[4].x < 10);
  r0.y = dot(-r0.yzw, v2.xyz);
  r0.y = saturate(1 + -r0.y);
  r0.y = log2(r0.y);
  r0.y = cb0[4].x * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 1 + -r0.y;
  r0.y = r2.w * r0.y;
  r0.z = cmp(r0.y < 0.00100000005);
  r0.z = r0.z ? r1.w : 0;
  if (r0.z != 0) discard;
  r3.w = r1.w ? r0.y : r2.w;
  r0.y = cmp(0 < cb0[4].z);
  if (r0.y != 0) {
    r0.y = -cb0[4].y + v6.w;
    r0.y = r0.y / cb0[4].z;
    r0.y = min(1, r0.y);
    r0.z = cmp(0 != cb0[1].z);
    if (r0.z != 0) {
      r0.zw = float2(0.25,0.25) * v6.yx;
      r4.xy = cmp(r0.zw >= -r0.zw);
      r0.zw = frac(abs(r0.zw));
      r0.zw = r4.xy ? r0.zw : -r0.zw;
      r0.zw = float2(4,4) * r0.zw;
      r0.zw = (uint2)r0.zw;
      r4.x = dot(float4(0.061999999,0.559000015,0.247999996,0.745000005), icb[r0.w+0].xyzw);
      r4.y = dot(float4(0.806999981,0.31099999,0.994000018,0.497000009), icb[r0.w+0].xyzw);
      r4.z = dot(float4(0.186000004,0.683000028,0.123999998,0.620999992), icb[r0.w+0].xyzw);
      r4.w = dot(float4(0.931999981,0.435000002,0.870000005,0.372999996), icb[r0.w+0].xyzw);
      r4.x = dot(r4.xyzw, icb[r0.z+0].xyzw);
      r4.y = 0.00400000019;
      r0.zw = -r4.xy + r0.yy;
      r0.zw = cmp(r0.zw < float2(0,0));
      r0.z = (int)r0.w | (int)r0.z;
      if (r0.z != 0) discard;
    } else {
      r3.w = r3.w * r0.y;
      r0.y = cmp(r3.w < 0.00400000019);
      if (r0.y != 0) discard;
    }
  }
  r0.y = cmp(0 < cb0[4].w);
  if (r0.y != 0) {
    r0.yz = v6.xy / cb0[5].xy;
    r0.yzw = t1.Sample(s1_s, r0.yz).xyz;
    r0.y = dot(r0.yz, float2(65536,256));
    r0.y = r0.y + r0.w;
    r0.y = saturate(1.52587891e-005 * r0.y);
    r0.y = 1 + -r0.y;
    r0.z = cb0[1].y + -cb0[1].x;
    r0.y = r0.y * r0.z + cb0[1].x;
    r0.y = v6.w + -r0.y;
    r0.z = cmp(r0.y >= cb0[4].w);
    if (r0.z != 0) discard;
    r0.z = cmp(0 < r0.y);
    r0.y = r0.y / cb0[4].w;
    r0.y = 1 + -r0.y;
    r0.y = r3.w * r0.y;
    r3.w = r0.z ? r0.y : r3.w;
  }
  r0.y = (int)cb0[1].w;
  r4.xyz = float3(0,0,0);
  r5.xyz = float3(0,0,0);
  r0.z = 0;
  while (true) {
    r0.w = cmp((int)r0.z >= (int)r0.y);
    if (r0.w != 0) break;
    r0.w = (uint)r0.z << 1;
    r6.xyz = cb0[r0.w+6].xyz + -v1.xyz;
    r1.w = dot(r6.xyz, r6.xyz);
    r6.w = sqrt(r1.w);
    r1.w = cmp(r6.w >= cb0[r0.w+6].w);
    if (r1.w != 0) {
      r1.w = (int)r0.z + 1;
      r0.z = r1.w;
      continue;
    }
    r7.x = r6.w;
    r7.w = cb0[r0.w+6].w;
    r6.xyzw = r6.xyzw / r7.xxxw;
    r1.w = 1 + -r6.w;
    r1.w = log2(r1.w);
    r1.w = cb0[r0.w+7].w * r1.w;
    r1.w = exp2(r1.w);
    r7.xyz = -v1.xyz * r0.xxx + r6.xyz;
    r2.w = dot(r7.xyz, r7.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r7.xyz * r2.www;
    r2.w = dot(r6.xyz, v2.xyz);
    r4.w = dot(r7.xyz, v2.xyz);
    r5.w = cmp(r2.w >= 0);
    r6.x = max(0, r2.w);
    r2.w = cmp(r4.w >= 0);
    r2.w = r5.w ? r2.w : 0;
    r4.w = r4.w * r4.w;
    r6.y = r2.w ? r4.w : 0;
    r6.xy = r6.xy * r1.ww;
    r4.xyz = cb0[r0.w+7].xyz * r6.xxx + r4.xyz;
    r5.xyz = cb0[r0.w+7].xyz * r6.yyy + r5.xyz;
    r0.z = (int)r0.z + 1;
  }
  r0.xyz = r4.xyz * r1.xyz;
  r1.xyz = r1.xyz * v3.xyz + r0.xyz;
  r0.xyz = -r2.xyz * r0.xyz + r1.xyz;
  r1.xyz = r5.xyz * float3(0.100000001,0.100000001,0.100000001) + v4.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = dot(v5.xyz, float3(0.298999995,0.587000012,0.114));
  r0.w = -r1.x * 0.5 + r0.w;
  r0.w = max(0, r0.w);
  r1.x = 1 + -v5.w;
  r1.x = w0.x * r1.x;
  r0.w = r1.x * r0.w;
  r1.xyz = r0.xyz * v5.www + v5.xyz;
  r2.xyz = r0.xyz * r0.www;
  r0.xyz = r0.xyz * r0.www + r1.xyz;
  r0.xyz = -r1.xyz * r2.xyz + r0.xyz;
  r0.w = cmp(0 != cb0[0].z);
  r1.x = -r3.w * v5.w + 1;
  r1.yzw = float3(1,1,1) + -r0.xyz;
  r1.xyz = r1.xxx * r1.yzw + r0.xyz;
  r3.xyz = r0.www ? r1.xyz : r0.xyz;
  r0.x = cmp(0 < cb0[1].z);
  r0.y = cmp(8.000000 == cb0[1].z);
  r1.xyz = v2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.w = 1;
  r2.xyw = r1.xyw;
  r2.z = v5.w;
  r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
  o1.xyzw = r0.xxxx ? r1.xyzw : 0;
  o0.xyzw = r3.xyzw;

  // o0 = saturate(o0);
  // o1 = saturate(o1);
  // o1 *= 2;
  // o0 *= 2;
  // o0 = 0;
  // o0.w = 0;
  return;
}