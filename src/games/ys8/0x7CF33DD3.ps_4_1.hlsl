// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 03:07:20 2025

cbuffer CB0 : register(b0)
{
  float4 fparam : packoffset(c0);
  float4 fparam2 : packoffset(c1);
}

SamplerState tex_samp_s : register(s0);
SamplerState depthtex_samp_s : register(s1);
SamplerState redtex1_samp_s : register(s2);
SamplerState redtex2_samp_s : register(s3);
SamplerState redtex3_samp_s : register(s4);
SamplerState redtex4_samp_s : register(s5);
SamplerState redtex5_samp_s : register(s6);
SamplerState redtex6_samp_s : register(s7);
SamplerState redtex7_samp_s : register(s8);
Texture2D<float4> tex_tex : register(t0);
Texture2D<float4> depthtex_tex : register(t1);
Texture2D<float4> redtex1_tex : register(t2);
Texture2D<float4> redtex2_tex : register(t3);
Texture2D<float4> redtex3_tex : register(t4);
Texture2D<float4> redtex4_tex : register(t5);
Texture2D<float4> redtex5_tex : register(t6);
Texture2D<float4> redtex6_tex : register(t7);
Texture2D<float4> redtex7_tex : register(t8);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = depthtex_tex.Sample(depthtex_samp_s, w0.xy).yz;
  r1.xyzw = redtex1_tex.Sample(redtex1_samp_s, w0.xy).xyzw;
  r0.y = 20 * r0.y;
  r0.y = r0.y / fparam2.w;
  r0.y = sqrt(r0.y);
  r0.z = 1 / fparam2.w;
  r0.y = saturate(r0.y + -r0.z);
  r0.x = r0.y * r0.x;
  r0.y = 1 + -r1.w;
  r0.x = max(r0.y, r0.x);
  r0.y = fparam2.w * r0.x;
  r0.y = trunc(r0.y);
  r0.x = r0.x * fparam2.w + -r0.y;
  r0.y = (int)r0.y;
  if (r0.y == 0) {
    r2.xyz = tex_tex.Sample(tex_samp_s, v0.xy).xyz;
    r3.xyz = -r2.xyz + r1.xyz;
    r2.xyz = r0.xxx * r3.xyz + r2.xyz;
  } else {
    r0.z = cmp((int)r0.y == 1);
    if (r0.z != 0) {
      r3.xyz = redtex2_tex.Sample(redtex2_samp_s, w0.xy).xyz;
    } else {
      r0.z = cmp((int)r0.y == 2);
      if (r0.z != 0) {
        r1.xyz = redtex2_tex.Sample(redtex2_samp_s, w0.xy).xyz;
        r3.xyz = redtex3_tex.Sample(redtex3_samp_s, w0.xy).xyz;
      } else {
        r0.z = cmp((int)r0.y == 3);
        if (r0.z != 0) {
          r1.xyz = redtex3_tex.Sample(redtex3_samp_s, w0.xy).xyz;
          r3.xyz = redtex4_tex.Sample(redtex4_samp_s, w0.xy).xyz;
        } else {
          r0.z = cmp((int)r0.y == 4);
          if (r0.z != 0) {
            r1.xyz = redtex4_tex.Sample(redtex4_samp_s, w0.xy).xyz;
            r3.xyz = redtex5_tex.Sample(redtex5_samp_s, w0.xy).xyz;
          } else {
            r0.z = cmp((int)r0.y == 5);
            if (r0.z != 0) {
              r1.xyz = redtex5_tex.Sample(redtex5_samp_s, w0.xy).xyz;
              r3.xyz = redtex6_tex.Sample(redtex6_samp_s, w0.xy).xyz;
            } else {
              r0.y = cmp((int)r0.y == 6);
              if (r0.y != 0) {
                r1.xyz = redtex6_tex.Sample(redtex6_samp_s, w0.xy).xyz;
                r3.xyz = redtex7_tex.Sample(redtex7_samp_s, w0.xy).xyz;
              } else {
                r3.xyz = redtex7_tex.Sample(redtex7_samp_s, w0.xy).xyz;
                r1.xyz = r3.xyz;
              }
            }
          }
        }
      }
    }
    r0.yzw = r3.xyz + -r1.xyz;
    r2.xyz = r0.xxx * r0.yzw + r1.xyz;
  }
  o0.xyz = r2.xyz;
  o0.w = 1;
  return;
}