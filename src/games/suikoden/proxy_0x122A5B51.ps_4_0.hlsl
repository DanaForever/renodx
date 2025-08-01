// ---- Created with 3Dmigoto v1.3.16 on Sun May 18 11:50:33 2025
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r1.xyzw = cmp(r0.xyzw < float4(0,0,0,0));
  r2.xyzw = cmp(float4(0,0,0,0) < r0.xyzw);
  r1.xyzw = (int4)r1.xyzw | (int4)r2.xyzw;
  r2.xyzw = cmp(r0.xyzw == float4(0,0,0,0));
  r1.xyzw = (int4)r1.xyzw | (int4)r2.xyzw;
  r1.xyzw = cmp((int4)r1.xyzw == int4(0,0,0,0));
  r1.x = (int)r1.y | (int)r1.x;
  r1.x = (int)r1.z | (int)r1.x;
  r1.x = (int)r1.w | (int)r1.x;
  o0.xyzw = r1.xxxx ? float4(0,0,0,0) : r0.xyzw;
  return;
}