// ---- Created with 3Dmigoto v1.3.16 on Sun Jul 20 18:06:32 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
}




// 3Dmigoto declarations
#define cmp -


void main(
  linear noperspective float4 v0 : TEXCOORD0,
  float4 v1 : SV_POSITION0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.xy * cb0[0].xy + float2(-0.5,-0.5);
  r0.xy = floor(r0.xy);
  r1.xyzw = float4(0.5,0.5,-0.5,-0.5) + r0.xyxy;
  r0.xy = float2(2.5,2.5) + r0.xy;
  r0.zw = v0.yx * cb0[0].yx + -r1.yx;
  r2.xy = r0.wz * r0.wz;
  r2.zw = r2.xy * r0.wz;
  r3.xy = float2(2.5,2.5) * r2.yx;
  r2.zw = r2.wz * float2(1.5,1.5) + -r3.xy;
  r2.zw = float2(1,1) + r2.zw;
  r3.xy = r2.yx * r0.zw + r0.zw;
  r0.zw = r2.xy * r0.wz + -r2.xy;
  r2.xy = -r3.xy * float2(0.5,0.5) + r2.yx;
  r3.xy = float2(1,1) + -r2.yx;
  r3.xy = r3.xy + -r2.wz;
  r3.xy = -r0.zw * float2(0.5,0.5) + r3.xy;
  r0.zw = float2(0.5,0.5) * r0.zw;
  r2.zw = r3.yx + r2.zw;
  r3.xy = r3.xy / r2.wz;
  r1.xy = r3.xy + r1.xy;
  r3.xy = float2(1,1) / cb0[0].xy;
  r4.xyzw = r3.xyxy * r1.xyzw;
  r1.xy = r3.xy * r0.xy;
  r3.xyzw = t0.SampleLevel(s0_s, r4.zy, 0).xyzw;
  r5.xyzw = t0.SampleLevel(s0_s, r4.xw, 0).xyzw;
  r5.xyzw = r5.xyzw * r2.wwww;
  r3.xyzw = r3.xyzw * r2.yyyy;
  r3.xyzw = r3.xyzw * r2.zzzz;
  r3.xyzw = r5.xyzw * r2.xxxx + r3.xyzw;
  r0.x = dot(r2.wz, r2.xy);
  r0.x = r2.w * r2.z + r0.x;
  r0.x = r0.z * r2.z + r0.x;
  r0.x = r0.w * r2.w + r0.x;
  r5.xyzw = t0.SampleLevel(s0_s, r4.xy, 0).xyzw;
  r1.zw = r4.yx;
  r4.xyzw = r5.xyzw * r2.wwww;
  r3.xyzw = r4.xyzw * r2.zzzz + r3.xyzw;
  r4.xyzw = t0.SampleLevel(s0_s, r1.xz, 0).xyzw;
  r1.xyzw = t0.SampleLevel(s0_s, r1.wy, 0).xyzw;
  r1.xyzw = r1.xyzw * r2.wwww;
  r4.xyzw = r4.xyzw * r0.zzzz;
  r2.xyzw = r4.xyzw * r2.zzzz + r3.xyzw;
  r1.xyzw = r1.xyzw * r0.wwww + r2.xyzw;
  o0.xyzw = r1.xyzw / r0.xxxx;
  return;
}