// ---- Created with 3Dmigoto v1.3.16 on Wed Feb 18 12:10:28 2026
#include "uicommon.hlsli"
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[4];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : COLOR0,
  float3 v2 : ORIGINAL_POSITION0,
  float4 v3 : TEXCOORD0,
  float4 v4 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v4.xy * v4.zw;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.xyzw = v1.xyzw * r0.xyzw;
  r1.x = cmp(cb0[0].y != 1.000000);
  r1.yzw = log2(r0.xyz);
  r1.yzw = cb0[0].xxx * r1.yzw;
  r2.xyz = exp2(r1.yzw);
  r3.xyz = float3(12.9200001,12.9200001,12.9200001) * r2.xyz;
  r2.xyz = cmp(r2.xyz >= float3(0.00313066994,0.00313066994,0.00313066994));
  r1.yzw = float3(0.416666657,0.416666657,0.416666657) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.yzw = r1.yzw * float3(1.05499995,1.05499995,1.05499995) + float3(-0.0549999997,-0.0549999997,-0.0549999997);
  r1.yzw = r2.xyz ? r1.yzw : r3.xyz;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r0.x = r0.w * -2 + 1;
  r0.x = cb0[2].x * r0.x + r0.w;
  r0.y = cmp(v2.z != 0.000000);
  r0.zw = -cb0[3].xy + v0.xy;
  r0.zw = r0.zw / cb0[3].zw;
  r1.x = t1.Sample(s1_s, r0.zw).x;
  r1.y = ddx_coarse(r0.z);
  r2.x = abs(r1.y);
  r1.y = ddy_coarse(r0.w);
  r3.x = abs(r1.y);
  r2.y = 0;
  r1.yz = r2.xy + r0.zw;
  r1.y = t1.Sample(s1_s, r1.yz).x;
  r2.z = -r2.x;
  r1.zw = r2.zy + r0.zw;
  r1.z = t1.Sample(s1_s, r1.zw).x;
  r3.y = 0;
  r2.yz = r3.yx + r0.zw;
  r1.w = t1.Sample(s1_s, r2.yz).x;
  r3.z = -r3.x;
  r2.yz = r3.yz + r0.zw;
  r2.y = t1.Sample(s1_s, r2.yz).x;
  r2.w = r3.x;
  r3.yz = r2.xw + r0.zw;
  r2.z = t1.Sample(s1_s, r3.yz).x;
  r4.z = r2.x;
  r4.w = -r3.x;
  r3.xy = r4.zw + r0.zw;
  r3.x = t1.Sample(s1_s, r3.xy).x;
  r4.xy = float2(-1,1) * r2.xw;
  r4.xyzw = r4.xyxw + r0.zwzw;
  r0.z = t1.Sample(s1_s, r4.xy).x;
  r0.w = t1.Sample(s1_s, r4.zw).x;
  if (r0.y != 0) {
    r0.y = cmp(v2.z < r1.x);
    if (r0.y != 0) {
      r0.y = cmp(r1.y < v2.z);
      r0.y = r0.y ? 1.000000 : 0;
      r1.x = cmp(r1.z < v2.z);
      r1.x = r1.x ? 1.000000 : 0;
      r0.y = r1.x + r0.y;
      r1.x = cmp(r1.w < v2.z);
      r1.x = r1.x ? 1.000000 : 0;
      r0.y = r1.x + r0.y;
      r1.x = cmp(r2.y < v2.z);
      r1.x = r1.x ? 1.000000 : 0;
      r0.y = r1.x + r0.y;
      r1.x = cmp(r2.z < v2.z);
      r1.y = cmp(r3.x < v2.z);
      r1.xy = r1.xy ? float2(1,1) : 0;
      r1.x = r1.x + r1.y;
      r0.zw = cmp(r0.zw < v2.zz);
      r0.zw = r0.zw ? float2(1,1) : 0;
      r0.z = r1.x + r0.z;
      r0.z = r0.z + r0.w;
      r0.z = 0.125 * r0.z;
      r0.y = r0.y * 0.25 + r0.z;
      r0.y = min(1, r0.y);
      o0.w = r0.x * r0.y;
    } else {
      o0.w = r0.x;
    }
  } else {
    o0.w = r0.x;
  }

  o0.rgb = renodx::color::srgb::DecodeSafe(o0.rgb);

  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    o0.rgb = renodx::color::correct::GammaSafe(o0.rgb, false, 2.4f);
  }
  
  o0.rgb *= RENODX_GRAPHICS_WHITE_NITS / 80.f;

  return;
}