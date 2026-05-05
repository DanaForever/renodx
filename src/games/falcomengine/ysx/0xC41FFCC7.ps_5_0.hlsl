// ---- Created with 3Dmigoto v1.3.16 on Wed May 06 00:21:42 2026

cbuffer cb_scene : register(b2)
{
  float4x4 view_proj_[2] : packoffset(c0);
  float4x4 view_ : packoffset(c8);
  float4x4 view_inv_ : packoffset(c12);
  float4x4 proj_inv_ : packoffset(c16);
  float4x4 rain_mask_matrix_ : packoffset(c20);
  float2 inv_vp_size_ : packoffset(c24);
  float2 screen_uv_scale_ : packoffset(c24.z);
}

SamplerState colorSampler_s : register(s0);
SamplerState depthSampler_s : register(s5);
Texture2D<float4> colorMap : register(t0);
Texture2D<float4> depthTexture : register(t5);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float4 v3 : COLOR0,
  float4 v4 : COLOR1,
  float4 v5 : TEXCOORD4,
  float4 v6 : TEXCOORD5,
  float4 v7 : TEXCOORD6,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(255.000015,255.000015) * v1.wz;
  r0.xy = (uint2)r0.xy;
  r0.y = (uint)r0.y << 8;
  r0.x = (int)r0.y | (int)r0.x;
  r1.xyzw = (int4)r0.xxxx & int4(4096,8192,1,8);
  r0.yz = cmp(v1.xy < float2(0.5,0.5));
  r2.xy = float2(1,1) + -v1.xy;
  r0.yz = r0.yz ? v1.xy : r2.xy;
  r0.w = cmp(0 < v5.x);
  r0.yz = r0.yz / v5.xx;
  r0.yz = min(float2(1,1), r0.yz);
  r0.yz = log2(r0.yz);
  r0.yz = v5.yy * r0.yz;
  r0.yz = exp2(r0.yz);
  r0.yz = min(float2(1,1), r0.yz);
  r0.yz = r0.ww ? r0.yz : float2(1,1);
  r0.yz = r1.xy ? r0.yz : float2(1,1);
  r0.y = r0.y * r0.z;
  r0.z = cmp(0 < v6.w);
  if (r0.z != 0) {
    r2.x = v0.z;
    r2.yw = float2(1,1);
    r0.z = dot(proj_inv_._m22_m32, r2.xy);
    r0.w = dot(proj_inv_._m23_m33, r2.xy);
    r0.z = r0.z / r0.w;
    r1.xy = inv_vp_size_.xy * v0.xy;
    r1.xy = screen_uv_scale_.xy * r1.xy;
    r2.z = depthTexture.SampleLevel(depthSampler_s, r1.xy, 0).x;
    r0.w = dot(proj_inv_._m22_m32, r2.zw);
    r1.x = dot(proj_inv_._m23_m33, r2.zw);
    r0.w = r0.w / r1.x;
    r0.z = -r0.w + r0.z;
    r0.z = saturate(v6.w * r0.z);
    r0.y = r0.y * r0.z;
  }
  r0.zw = v1.yx * float2(2,2) + float2(-1,-1);
  r1.x = dot(r0.zw, r0.zw);
  r1.x = sqrt(r1.x);
  r1.x = 1 + -r1.x;
  r2.x = min(abs(r0.z), abs(r0.w));
  r2.y = max(abs(r0.z), abs(r0.w));
  r2.y = 1 / r2.y;
  r2.x = r2.x * r2.y;
  r2.y = r2.x * r2.x;
  r2.z = r2.y * 0.0208350997 + -0.0851330012;
  r2.z = r2.y * r2.z + 0.180141002;
  r2.z = r2.y * r2.z + -0.330299497;
  r2.y = r2.y * r2.z + 0.999866009;
  r2.z = r2.x * r2.y;
  r2.w = cmp(abs(r0.w) < abs(r0.z));
  r2.z = r2.z * -2 + 1.57079637;
  r2.z = r2.w ? r2.z : 0;
  r2.x = r2.x * r2.y + r2.z;
  r2.y = cmp(r0.w < -r0.w);
  r2.y = r2.y ? -3.141593 : 0;
  r2.x = r2.x + r2.y;
  r2.y = min(-r0.z, r0.w);
  r0.z = max(-r0.z, r0.w);
  r0.w = cmp(r2.y < -r2.y);
  r0.z = cmp(r0.z >= -r0.z);
  r0.z = r0.z ? r0.w : 0;
  r0.z = r0.z ? -r2.x : r2.x;
  r0.z = 3.14159274 + r0.z;
  r1.y = 0.159154937 * r0.z;
  r0.zw = r1.zz ? r1.xy : v1.yx;
  r0.zw = r0.zw * v2.wz + v2.yx;
  r0.zw = r1.ww ? r0.zw : r0.wz;
  r1.xyz = (int3)r0.xxx & int3(64,512,0x8000);
  r2.xy = float2(1,1) + -r0.zw;
  r0.xz = r1.xy ? r2.xy : r0.zw;
  r2.xyzw = colorMap.Sample(colorSampler_s, r0.xz).xyzw;
  r0.x = v3.w * r0.y;
  r0.yzw = v3.xyz;
  r0.x = r2.w * r0.x;
  r0.yzw = r2.xyz * r0.yzw + v4.xyz;
  r1.x = cmp(r0.z < r0.w);
  r2.xy = r0.wz;
  r2.zw = float2(-1,0.666666687);
  r3.xy = r2.yx;
  r3.zw = float2(0,-0.333333343);
  r2.xyzw = r1.xxxx ? r2.xyzw : r3.xyzw;
  r1.x = cmp(r0.y < r2.x);
  r3.xyz = r2.xyw;
  r3.w = r0.y;
  r2.xyw = r3.wyx;
  r2.xyzw = r1.xxxx ? r3.yxzw : r2.yxzw;
  r1.x = min(r2.w, r2.x);
  r1.x = r2.y + -r1.x;
  r1.y = r2.w + -r2.x;
  r1.w = r1.x * 6 + 1.00000001e-010;
  r1.y = r1.y / r1.w;
  r1.y = r2.z + r1.y;
  r1.w = 1.00000001e-010 + r2.y;
  r2.x = r1.x / r1.w;
  r1.x = v5.z + abs(r1.y);
  r1.y = cmp(1 < r1.x);
  r1.w = -1 + r1.x;
  r1.x = r1.y ? r1.w : r1.x;
  r3.x = v5.w;
  r3.y = v4.w;
  r1.yw = r3.xy * r2.xy;
  r2.xyz = float3(1,0.666666687,0.333333343) + r1.xxx;
  r2.xyz = frac(r2.xyz);
  r2.xyz = r2.xyz * float3(6,6,6) + float3(-3,-3,-3);
  r2.xyz = saturate(float3(-1,-1,-1) + abs(r2.xyz));
  r2.xyz = float3(-1,-1,-1) + r2.xyz;
  r2.xyz = r1.yyy * r2.xyz + float3(1,1,1);
  r1.xyw = r2.xyz * r1.www;
  o0.xyz = r1.zzz ? r1.xyw : r0.yzw;
  o0.w = r0.x;
  return;
}