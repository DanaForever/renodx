// ---- Created with 3Dmigoto v1.3.16 on Sun Jan 04 12:06:06 2026

cbuffer GFD_PSCONST_SYSTEM : register(b0)
{
  float4 clearColor : packoffset(c0);
  float2 resolution : packoffset(c1);
  float2 resolutionRev : packoffset(c1.z);
}

SamplerState t_color_sampler_s : register(s0);
Texture2D<float4> t_color : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 x0[3];
  r0.xyzw = v1.xyxy;
  r0.xy = r0.xy;
  r1.xyzw = float4(-1,0,0,-1) * resolutionRev.xyxy;
  r1.xyzw = r1.xyzw + r0.xyxy;
  r2.xyzw = float4(1,0,0,1) * resolutionRev.xyxy;
  r2.xyzw = r2.xyzw + r0.xyxy;
  r3.xyzw = float4(-2,0,0,-2) * resolutionRev.xyxy;
  r3.xyzw = r3.xyzw + r0.zwxy;
  r0.xy = r0.xy;
  x0[0].xyzw = r1.xyzw;
  x0[1].xyzw = r2.xyzw;
  x0[2].xyzw = r3.xyzw;
  r0.zw = float2(0.100000001,0.100000001);
  r1.x = 0;
  r1.xyz = t_color.SampleLevel(t_color_sampler_s, r0.xy, r1.x).xyz;
  r1.xyz = r1.xyz;
  r0.xy = x0[0].xy;
  r1.w = 0;
  r2.xyz = t_color.SampleLevel(t_color_sampler_s, r0.xy, r1.w).xyz;
  r2.xyz = r2.xyz;
  r2.xyz = -r2.xyz;
  r2.xyz = r2.xyz + r1.xyz;
  r3.xyz = -r2.xyz;
  r2.xyz = max(r3.xyz, r2.xyz);
  r0.x = max(r2.x, r2.y);
  r0.x = max(r0.x, r2.z);
  r2.xy = x0[0].zw;
  r1.w = 0;
  r2.xyz = t_color.SampleLevel(t_color_sampler_s, r2.xy, r1.w).xyz;
  r2.xyz = r2.xyz;
  r2.xyz = -r2.xyz;
  r2.xyz = r2.xyz + r1.xyz;
  r3.xyz = -r2.xyz;
  r2.xyz = max(r3.xyz, r2.xyz);
  r1.w = max(r2.x, r2.y);
  r0.y = max(r1.w, r2.z);
  r0.zw = cmp(r0.xy >= r0.zw);
  r0.zw = r0.zw ? float2(1,1) : float2(0,0);
  r1.w = dot(r0.zw, float2(1,1));
  r1.w = cmp(r1.w == 0.000000);
  if (r1.w != 0) {
    r2.xyzw = float4(0,0,0,0);
  }
  if (r1.w == 0) {
    r3.xy = x0[1].xy;
    r1.w = 0;
    r3.xyz = t_color.SampleLevel(t_color_sampler_s, r3.xy, r1.w).xyz;
    r3.xyz = -r3.xyz;
    r3.xyz = r3.xyz + r1.xyz;
    r4.xyz = -r3.xyz;
    r3.xyz = max(r4.xyz, r3.xyz);
    r1.w = max(r3.x, r3.y);
    r1.w = max(r1.w, r3.z);
    r3.xy = x0[1].zw;
    r3.z = 0;
    r3.xyz = t_color.SampleLevel(t_color_sampler_s, r3.xy, r3.z).xyz;
    r3.xyz = -r3.xyz;
    r3.xyz = r3.xyz + r1.xyz;
    r4.xyz = -r3.xyz;
    r3.xyz = max(r4.xyz, r3.xyz);
    r3.x = max(r3.x, r3.y);
    r3.x = max(r3.x, r3.z);
    r3.y = max(r0.x, r0.y);
    r1.w = max(r3.y, r1.w);
    r1.w = max(r1.w, r3.x);
    r3.xy = x0[2].xy;
    r3.z = 0;
    r3.xyz = t_color.SampleLevel(t_color_sampler_s, r3.xy, r3.z).xyz;
    r3.xyz = -r3.xyz;
    r3.xyz = r3.xyz + r1.xyz;
    r4.xyz = -r3.xyz;
    r3.xyz = max(r4.xyz, r3.xyz);
    r3.x = max(r3.x, r3.y);
    r3.x = max(r3.x, r3.z);
    r3.yz = x0[2].zw;
    r3.w = 0;
    r3.yzw = t_color.SampleLevel(t_color_sampler_s, r3.yz, r3.w).xyz;
    r3.yzw = -r3.yzw;
    r1.xyz = r3.yzw + r1.xyz;
    r3.yzw = -r1.xyz;
    r1.xyz = max(r3.yzw, r1.xyz);
    r1.x = max(r1.x, r1.y);
    r1.x = max(r1.x, r1.z);
    r1.y = max(r3.x, r1.w);
    r1.x = max(r1.y, r1.x);
    r1.x = 0.5 * r1.x;
    r0.xy = cmp(r0.xy >= r1.xx);
    r0.xy = r0.xy ? float2(1,1) : float2(0,0);
    r2.xy = r0.zw * r0.xy;
    r2.zw = float2(0,0);
    r2.xyzw = r2.xyzw;
  }
  o0.xyzw = r2.xyzw;
  
  return;
}