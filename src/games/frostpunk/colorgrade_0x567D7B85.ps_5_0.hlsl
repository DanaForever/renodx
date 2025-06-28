// ---- Created with 3Dmigoto v1.3.16 on Sat May 31 12:33:56 2025

cbuffer Constants : register(b2)
{

  struct
  {
    float4 TexelSize;
    float4 RcpFrameOpt;
    float4 RcpFrameOpt2;
    float4 XRcpFrameOpt2;
    float4 XConstDir;
    float4 Params;
    float4 ConsoleParams;
  } PerDrawCall : packoffset(c0);

}

SamplerState InputTextureSampler_s : register(s0);
Texture2D<float4> InputTexture : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0).xyzw;
  r1.xyz = InputTexture.Gather(InputTextureSampler_s, v1.xy).xyz;
  r2.xyz = InputTexture.Gather(InputTextureSampler_s, v1.xy, int2(-1, -1)).xzw;
  r1.w = max(r1.x, r0.w);
  r2.w = min(r1.x, r0.w);
  r1.w = max(r1.z, r1.w);
  r2.w = min(r2.w, r1.z);
  r3.x = max(r2.y, r2.x);
  r3.y = min(r2.y, r2.x);
  r1.w = max(r3.x, r1.w);
  r2.w = min(r3.y, r2.w);
  r3.x = PerDrawCall.Params.y * r1.w;
  r1.w = -r2.w + r1.w;
  r2.w = max(PerDrawCall.Params.z, r3.x);
  r2.w = cmp(r1.w >= r2.w);
  if (r2.w != 0) {
    r2.w = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0, int2(1, -1)).w;
    r3.x = InputTexture.SampleLevel(InputTextureSampler_s, v1.xy, 0, int2(-1, 1)).w;
    r3.yz = r2.yx + r1.xz;
    r1.w = 1 / r1.w;
    r3.w = r3.y + r3.z;
    r3.yz = r0.ww * float2(-2,-2) + r3.yz;
    r4.x = r2.w + r1.y;
    r2.w = r2.z + r2.w;
    r4.y = r1.z * -2 + r4.x;
    r2.w = r2.y * -2 + r2.w;
    r2.z = r3.x + r2.z;
    r1.y = r3.x + r1.y;
    r3.x = abs(r3.y) * 2 + abs(r4.y);
    r2.w = abs(r3.z) * 2 + abs(r2.w);
    r3.y = r2.x * -2 + r2.z;
    r1.y = r1.x * -2 + r1.y;
    r3.x = abs(r3.y) + r3.x;
    r1.y = abs(r1.y) + r2.w;
    r2.z = r2.z + r4.x;
    r1.y = cmp(r3.x >= r1.y);
    r2.z = r3.w * 2 + r2.z;
    r2.x = r1.y ? r2.y : r2.x;
    r1.x = r1.y ? r1.x : r1.z;
    r1.z = r1.y ? PerDrawCall.TexelSize.y : PerDrawCall.TexelSize.x;
    r2.y = r2.z * 0.0833333358 + -r0.w;
    r2.z = r2.x + -r0.w;
    r2.w = r1.x + -r0.w;
    r2.x = r2.x + r0.w;
    r1.x = r1.x + r0.w;
    r3.x = cmp(abs(r2.z) >= abs(r2.w));
    r2.z = max(abs(r2.z), abs(r2.w));
    r1.z = r3.x ? -r1.z : r1.z;
    r1.w = saturate(abs(r2.y) * r1.w);
    r2.y = r1.y ? PerDrawCall.TexelSize.x : 0;
    r2.w = r1.y ? 0 : PerDrawCall.TexelSize.y;
    r3.yz = r1.zz * float2(0.5,0.5) + v1.xy;
    r3.y = r1.y ? v1.x : r3.y;
    r3.z = r1.y ? r3.z : v1.y;
    r4.x = -r2.y * 1.5 + r3.y;
    r4.y = -r2.w * 1.5 + r3.z;
    r5.x = r2.y * 1.5 + r3.y;
    r5.y = r2.w * 1.5 + r3.z;
    r3.y = r1.w * -2 + 3;
    r3.z = InputTexture.SampleLevel(InputTextureSampler_s, r4.xy, 0).w;
    r1.w = r1.w * r1.w;
    r3.w = InputTexture.SampleLevel(InputTextureSampler_s, r5.xy, 0).w;
    r1.x = r3.x ? r2.x : r1.x;
    r2.x = 0.25 * r2.z;
    r2.z = -r1.x * 0.5 + r0.w;
    r1.w = r3.y * r1.w;
    r2.z = cmp(r2.z < 0);
    r3.x = -r1.x * 0.5 + r3.z;
    r3.y = -r1.x * 0.5 + r3.w;
    r3.zw = cmp(abs(r3.xy) >= r2.xx);
    r4.z = -r2.y * 2 + r4.x;
    r4.x = r3.z ? r4.x : r4.z;
    r4.w = -r2.w * 2 + r4.y;
    r4.z = r3.z ? r4.y : r4.w;
    r4.yw = ~(int2)r3.zw;
    r4.y = (int)r4.w | (int)r4.y;
    r4.w = r2.y * 2 + r5.x;
    r5.x = r3.w ? r5.x : r4.w;
    r4.w = r2.w * 2 + r5.y;
    r5.z = r3.w ? r5.y : r4.w;
    if (r4.y != 0) {
      if (r3.z == 0) {
        r3.x = InputTexture.SampleLevel(InputTextureSampler_s, r4.xz, 0).w;
      }
      if (r3.w == 0) {
        r3.y = InputTexture.SampleLevel(InputTextureSampler_s, r5.xz, 0).w;
      }
      r4.y = -r1.x * 0.5 + r3.x;
      r3.x = r3.z ? r3.x : r4.y;
      r1.x = -r1.x * 0.5 + r3.y;
      r3.y = r3.w ? r3.y : r1.x;
      r3.zw = cmp(abs(r3.xy) >= r2.xx);
      r1.x = -r2.y * 8 + r4.x;
      r4.x = r3.z ? r4.x : r1.x;
      r1.x = -r2.w * 8 + r4.z;
      r4.z = r3.z ? r4.z : r1.x;
      r1.x = r2.y * 8 + r5.x;
      r5.x = r3.w ? r5.x : r1.x;
      r1.x = r2.w * 8 + r5.z;
      r5.z = r3.w ? r5.z : r1.x;
    }
    r1.x = v1.x + -r4.x;
    r2.y = v1.y + -r4.z;
    r1.x = r1.y ? r1.x : r2.y;
    r2.xy = -v1.xy + r5.xz;
    r2.x = r1.y ? r2.x : r2.y;
    r2.yw = cmp(r3.xy < float2(0,0));
    r3.x = r2.x + r1.x;
    r2.yz = cmp((int2)r2.zz != (int2)r2.yw);
    r2.w = 1 / r3.x;
    r3.x = cmp(r1.x < r2.x);
    r1.x = min(r2.x, r1.x);
    r2.x = r3.x ? r2.y : r2.z;
    r1.w = r1.w * r1.w;
    r1.x = r1.x * -r2.w + 0.5;
    r1.w = PerDrawCall.Params.x * r1.w;
    r1.x = (int)r1.x & (int)r2.x;
    r1.x = max(r1.x, r1.w);
    r1.xz = r1.xx * r1.zz + v1.xy;
    r2.x = r1.y ? v1.x : r1.x;
    r2.y = r1.y ? r1.z : v1.y;
    r0.xyz = InputTexture.SampleLevel(InputTextureSampler_s, r2.xy, 0).xyz;
  }
  o0.xyzw = r0.xyzw;
  return;
}