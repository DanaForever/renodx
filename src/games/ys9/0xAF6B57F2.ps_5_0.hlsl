// ---- Created with 3Dmigoto v1.3.16 on Fri Jul 18 20:17:00 2025

SamplerState LinearClampSamplerState_s : register(s1);
Texture2D<float4> tex_tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0).xyz;
  r0.w = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(0, 1)).y;
  r1.x = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(1, 0)).y;
  r1.y = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(0, -1)).y;
  r1.z = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(-1, 0)).y;
  r1.w = max(r0.w, r0.y);
  r2.x = min(r0.w, r0.y);
  r1.w = max(r1.x, r1.w);
  r2.x = min(r2.x, r1.x);
  r2.y = max(r1.y, r1.z);
  r2.z = min(r1.y, r1.z);
  r1.w = max(r2.y, r1.w);
  r2.x = min(r2.z, r2.x);
  r2.y = 0.125 * r1.w;
  r1.w = -r2.x + r1.w;
  r2.x = max(0, r2.y);
  r2.x = cmp(r1.w >= r2.x);
  if (r2.x != 0) {
    tex_tex.GetDimensions(0, fDest.x, fDest.y, fDest.z);
    r2.xy = fDest.xy;
    r2.xy = float2(1,1) / r2.xy;
    r2.z = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(-1, -1)).y;
    r2.w = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(1, 1)).y;
    r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(1, -1)).y;
    r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, v0.xy, 0, int2(-1, 1)).y;
    r3.z = r1.y + r0.w;
    r3.w = r1.z + r1.x;
    r1.w = 1 / r1.w;
    r4.x = r3.z + r3.w;
    r3.z = r0.y * -2 + r3.z;
    r3.w = r0.y * -2 + r3.w;
    r4.y = r3.x + r2.w;
    r3.x = r3.x + r2.z;
    r4.z = r1.x * -2 + r4.y;
    r3.x = r1.y * -2 + r3.x;
    r2.z = r3.y + r2.z;
    r2.w = r3.y + r2.w;
    r3.y = abs(r3.z) * 2 + abs(r4.z);
    r3.x = abs(r3.w) * 2 + abs(r3.x);
    r3.z = r1.z * -2 + r2.z;
    r2.w = r0.w * -2 + r2.w;
    r3.y = abs(r3.z) + r3.y;
    r2.w = abs(r2.w) + r3.x;
    r2.z = r2.z + r4.y;
    r2.w = cmp(r3.y >= r2.w);
    r2.z = r4.x * 2 + r2.z;
    r1.y = r2.w ? r1.y : r1.z;
    r0.w = r2.w ? r0.w : r1.x;
    r1.x = r2.w ? r2.y : r2.x;
    r1.z = r2.z * 0.0833333358 + -r0.y;
    r2.z = r1.y + -r0.y;
    r3.x = r0.w + -r0.y;
    r1.y = r1.y + r0.y;
    r0.w = r0.w + r0.y;
    r3.y = cmp(abs(r2.z) >= abs(r3.x));
    r2.z = max(abs(r3.x), abs(r2.z));
    r1.x = r3.y ? -r1.x : r1.x;
    r1.z = saturate(abs(r1.z) * r1.w);
    r1.w = r2.w ? r2.x : 0;
    r2.x = r2.w ? 0 : r2.y;
    r3.xz = r1.xx * float2(0.5,0.5) + v0.xy;
    r2.y = r2.w ? v0.x : r3.x;
    r3.x = r2.w ? r3.z : v0.y;
    r4.x = r2.y + -r1.w;
    r4.y = r3.x + -r2.x;
    r5.x = r2.y + r1.w;
    r5.y = r3.x + r2.x;
    r2.y = r1.z * -2 + 3;
    r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xy, 0).y;
    r1.z = r1.z * r1.z;
    r3.z = tex_tex.SampleLevel(LinearClampSamplerState_s, r5.xy, 0).y;
    r0.w = r3.y ? r1.y : r0.w;
    r1.y = 0.25 * r2.z;
    r2.z = -r0.w * 0.5 + r0.y;
    r1.z = r2.y * r1.z;
    r2.y = cmp(r2.z < 0);
    r3.x = -r0.w * 0.5 + r3.x;
    r3.y = -r0.w * 0.5 + r3.z;
    r3.zw = cmp(abs(r3.xy) >= r1.yy);
    r2.z = -r1.w * 1.5 + r4.x;
    r4.x = r3.z ? r4.x : r2.z;
    r2.z = -r2.x * 1.5 + r4.y;
    r4.z = r3.z ? r4.y : r2.z;
    r4.yw = ~(int2)r3.zw;
    r2.z = (int)r4.w | (int)r4.y;
    r4.y = r1.w * 1.5 + r5.x;
    r4.y = r3.w ? r5.x : r4.y;
    r5.x = r2.x * 1.5 + r5.y;
    r4.w = r3.w ? r5.y : r5.x;
    if (r2.z != 0) {
      if (r3.z == 0) {
        r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
      }
      if (r3.w == 0) {
        r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
      }
      r2.z = -r0.w * 0.5 + r3.x;
      r3.x = r3.z ? r3.x : r2.z;
      r2.z = -r0.w * 0.5 + r3.y;
      r3.y = r3.w ? r3.y : r2.z;
      r3.zw = cmp(abs(r3.xy) >= r1.yy);
      r2.z = -r1.w * 2 + r4.x;
      r4.x = r3.z ? r4.x : r2.z;
      r2.z = -r2.x * 2 + r4.z;
      r4.z = r3.z ? r4.z : r2.z;
      r5.xy = ~(int2)r3.zw;
      r2.z = (int)r5.y | (int)r5.x;
      r5.x = r1.w * 2 + r4.y;
      r4.y = r3.w ? r4.y : r5.x;
      r5.x = r2.x * 2 + r4.w;
      r4.w = r3.w ? r4.w : r5.x;
      if (r2.z != 0) {
        if (r3.z == 0) {
          r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
        }
        if (r3.w == 0) {
          r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
        }
        r2.z = -r0.w * 0.5 + r3.x;
        r3.x = r3.z ? r3.x : r2.z;
        r2.z = -r0.w * 0.5 + r3.y;
        r3.y = r3.w ? r3.y : r2.z;
        r3.zw = cmp(abs(r3.xy) >= r1.yy);
        r2.z = -r1.w * 2 + r4.x;
        r4.x = r3.z ? r4.x : r2.z;
        r2.z = -r2.x * 2 + r4.z;
        r4.z = r3.z ? r4.z : r2.z;
        r5.xy = ~(int2)r3.zw;
        r2.z = (int)r5.y | (int)r5.x;
        r5.x = r1.w * 2 + r4.y;
        r4.y = r3.w ? r4.y : r5.x;
        r5.x = r2.x * 2 + r4.w;
        r4.w = r3.w ? r4.w : r5.x;
        if (r2.z != 0) {
          if (r3.z == 0) {
            r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
          }
          if (r3.w == 0) {
            r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
          }
          r2.z = -r0.w * 0.5 + r3.x;
          r3.x = r3.z ? r3.x : r2.z;
          r2.z = -r0.w * 0.5 + r3.y;
          r3.y = r3.w ? r3.y : r2.z;
          r3.zw = cmp(abs(r3.xy) >= r1.yy);
          r2.z = -r1.w * 2 + r4.x;
          r4.x = r3.z ? r4.x : r2.z;
          r2.z = -r2.x * 2 + r4.z;
          r4.z = r3.z ? r4.z : r2.z;
          r5.xy = ~(int2)r3.zw;
          r2.z = (int)r5.y | (int)r5.x;
          r5.x = r1.w * 2 + r4.y;
          r4.y = r3.w ? r4.y : r5.x;
          r5.x = r2.x * 2 + r4.w;
          r4.w = r3.w ? r4.w : r5.x;
          if (r2.z != 0) {
            if (r3.z == 0) {
              r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
            }
            if (r3.w == 0) {
              r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
            }
            r2.z = -r0.w * 0.5 + r3.x;
            r3.x = r3.z ? r3.x : r2.z;
            r2.z = -r0.w * 0.5 + r3.y;
            r3.y = r3.w ? r3.y : r2.z;
            r3.zw = cmp(abs(r3.xy) >= r1.yy);
            r2.z = -r1.w * 2 + r4.x;
            r4.x = r3.z ? r4.x : r2.z;
            r2.z = -r2.x * 2 + r4.z;
            r4.z = r3.z ? r4.z : r2.z;
            r5.xy = ~(int2)r3.zw;
            r2.z = (int)r5.y | (int)r5.x;
            r5.x = r1.w * 2 + r4.y;
            r4.y = r3.w ? r4.y : r5.x;
            r5.x = r2.x * 2 + r4.w;
            r4.w = r3.w ? r4.w : r5.x;
            if (r2.z != 0) {
              if (r3.z == 0) {
                r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
              }
              if (r3.w == 0) {
                r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
              }
              r2.z = -r0.w * 0.5 + r3.x;
              r3.x = r3.z ? r3.x : r2.z;
              r2.z = -r0.w * 0.5 + r3.y;
              r3.y = r3.w ? r3.y : r2.z;
              r3.zw = cmp(abs(r3.xy) >= r1.yy);
              r2.z = -r1.w * 2 + r4.x;
              r4.x = r3.z ? r4.x : r2.z;
              r2.z = -r2.x * 2 + r4.z;
              r4.z = r3.z ? r4.z : r2.z;
              r5.xy = ~(int2)r3.zw;
              r2.z = (int)r5.y | (int)r5.x;
              r5.x = r1.w * 2 + r4.y;
              r4.y = r3.w ? r4.y : r5.x;
              r5.x = r2.x * 2 + r4.w;
              r4.w = r3.w ? r4.w : r5.x;
              if (r2.z != 0) {
                if (r3.z == 0) {
                  r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
                }
                if (r3.w == 0) {
                  r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
                }
                r2.z = -r0.w * 0.5 + r3.x;
                r3.x = r3.z ? r3.x : r2.z;
                r2.z = -r0.w * 0.5 + r3.y;
                r3.y = r3.w ? r3.y : r2.z;
                r3.zw = cmp(abs(r3.xy) >= r1.yy);
                r2.z = -r1.w * 2 + r4.x;
                r4.x = r3.z ? r4.x : r2.z;
                r2.z = -r2.x * 2 + r4.z;
                r4.z = r3.z ? r4.z : r2.z;
                r5.xy = ~(int2)r3.zw;
                r2.z = (int)r5.y | (int)r5.x;
                r5.x = r1.w * 2 + r4.y;
                r4.y = r3.w ? r4.y : r5.x;
                r5.x = r2.x * 2 + r4.w;
                r4.w = r3.w ? r4.w : r5.x;
                if (r2.z != 0) {
                  if (r3.z == 0) {
                    r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
                  }
                  if (r3.w == 0) {
                    r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
                  }
                  r2.z = -r0.w * 0.5 + r3.x;
                  r3.x = r3.z ? r3.x : r2.z;
                  r2.z = -r0.w * 0.5 + r3.y;
                  r3.y = r3.w ? r3.y : r2.z;
                  r3.zw = cmp(abs(r3.xy) >= r1.yy);
                  r2.z = -r1.w * 2 + r4.x;
                  r4.x = r3.z ? r4.x : r2.z;
                  r2.z = -r2.x * 2 + r4.z;
                  r4.z = r3.z ? r4.z : r2.z;
                  r5.xy = ~(int2)r3.zw;
                  r2.z = (int)r5.y | (int)r5.x;
                  r5.x = r1.w * 2 + r4.y;
                  r4.y = r3.w ? r4.y : r5.x;
                  r5.x = r2.x * 2 + r4.w;
                  r4.w = r3.w ? r4.w : r5.x;
                  if (r2.z != 0) {
                    if (r3.z == 0) {
                      r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
                    }
                    if (r3.w == 0) {
                      r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
                    }
                    r2.z = -r0.w * 0.5 + r3.x;
                    r3.x = r3.z ? r3.x : r2.z;
                    r2.z = -r0.w * 0.5 + r3.y;
                    r3.y = r3.w ? r3.y : r2.z;
                    r3.zw = cmp(abs(r3.xy) >= r1.yy);
                    r2.z = -r1.w * 2 + r4.x;
                    r4.x = r3.z ? r4.x : r2.z;
                    r2.z = -r2.x * 2 + r4.z;
                    r4.z = r3.z ? r4.z : r2.z;
                    r5.xy = ~(int2)r3.zw;
                    r2.z = (int)r5.y | (int)r5.x;
                    r5.x = r1.w * 2 + r4.y;
                    r4.y = r3.w ? r4.y : r5.x;
                    r5.x = r2.x * 2 + r4.w;
                    r4.w = r3.w ? r4.w : r5.x;
                    if (r2.z != 0) {
                      if (r3.z == 0) {
                        r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
                      }
                      if (r3.w == 0) {
                        r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
                      }
                      r2.z = -r0.w * 0.5 + r3.x;
                      r3.x = r3.z ? r3.x : r2.z;
                      r2.z = -r0.w * 0.5 + r3.y;
                      r3.y = r3.w ? r3.y : r2.z;
                      r3.zw = cmp(abs(r3.xy) >= r1.yy);
                      r2.z = -r1.w * 4 + r4.x;
                      r4.x = r3.z ? r4.x : r2.z;
                      r2.z = -r2.x * 4 + r4.z;
                      r4.z = r3.z ? r4.z : r2.z;
                      r5.xy = ~(int2)r3.zw;
                      r2.z = (int)r5.y | (int)r5.x;
                      r5.x = r1.w * 4 + r4.y;
                      r4.y = r3.w ? r4.y : r5.x;
                      r5.x = r2.x * 4 + r4.w;
                      r4.w = r3.w ? r4.w : r5.x;
                      if (r2.z != 0) {
                        if (r3.z == 0) {
                          r3.x = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.xz, 0).y;
                        }
                        if (r3.w == 0) {
                          r3.y = tex_tex.SampleLevel(LinearClampSamplerState_s, r4.yw, 0).y;
                        }
                        r2.z = -r0.w * 0.5 + r3.x;
                        r3.x = r3.z ? r3.x : r2.z;
                        r0.w = -r0.w * 0.5 + r3.y;
                        r3.y = r3.w ? r3.y : r0.w;
                        r3.zw = cmp(abs(r3.xy) >= r1.yy);
                        r0.w = -r1.w * 8 + r4.x;
                        r4.x = r3.z ? r4.x : r0.w;
                        r0.w = -r2.x * 8 + r4.z;
                        r4.z = r3.z ? r4.z : r0.w;
                        r0.w = r1.w * 8 + r4.y;
                        r4.y = r3.w ? r4.y : r0.w;
                        r0.w = r2.x * 8 + r4.w;
                        r4.w = r3.w ? r4.w : r0.w;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    r0.w = v0.x + -r4.x;
    r1.w = v0.y + -r4.z;
    r0.w = r2.w ? r0.w : r1.w;
    r1.yw = -v0.xy + r4.yw;
    r1.y = r2.w ? r1.y : r1.w;
    r2.xz = cmp(r3.xy < float2(0,0));
    r1.w = r1.y + r0.w;
    r2.xy = cmp((int2)r2.yy != (int2)r2.xz);
    r1.w = 1 / r1.w;
    r2.z = cmp(r0.w < r1.y);
    r0.w = min(r1.y, r0.w);
    r1.y = r2.z ? r2.x : r2.y;
    r1.z = r1.z * r1.z;
    r0.w = r0.w * -r1.w + 0.5;
    r1.z = 0.75 * r1.z;
    r0.w = (int)r0.w & (int)r1.y;
    r0.w = max(r0.w, r1.z);
    r1.xy = r0.ww * r1.xx + v0.xy;
    r2.x = r2.w ? v0.x : r1.x;
    r2.y = r2.w ? r1.y : v0.y;
    r0.xyz = tex_tex.SampleLevel(LinearClampSamplerState_s, r2.xy, 0).xyz;
  }
  o0.xyz = r0.xyz;
  o0.w = 1;
  return;
}