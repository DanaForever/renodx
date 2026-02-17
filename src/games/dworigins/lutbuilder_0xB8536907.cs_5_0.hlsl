// ---- Fixed compute shader HLSL (from your DXBC) ----
#include "common.hlsl"
cbuffer cbHdrLut : register(b4)
{
  float4 g_vHdrLutInfo;               // c0
  float4 g_vNeutralTonemapperParams0; // c1
  float4 g_vNeutralTonemapperParams1; // c2
}

Texture3D<float3>    g_tInputMap      : register(t0);
RWTexture3D<float3>  g_uRwOutputLut   : register(u0);

// [numthreads(4, 4, 4)]
// #define DISPATCH_BLOCK 16

// [numthreads(DISPATCH_BLOCK, DISPATCH_BLOCK, 1)]
[numthreads(4, 4, 4)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  float4 r0, r1, r2, r3, r4, r5, r6;

  // Load input 3D texel at dispatch id (matches ld_indexable + r0.w=0)
  r0.xyz = g_tInputMap.Load(int4(vThreadID, 0));
  r0.w = (int)g_vHdrLutInfo.z;

  // r0.rgb = renodx::color::arri::logc::c1000::Decode(r0.rgb);
  // r0.rgb /= 2;

  switch ((int)r0.w)
  {
    case 0:
    {
      // AP1 -> BT709 
      r1.x = dot(float3( 1.705080, -0.624233, -0.080846), r0.xyz);
      r1.y = dot(float3(-0.129701,  1.138469, -0.008768), r0.xyz);
      r1.z = dot(float3(-0.024167, -0.124615,  1.148782), r0.xyz);

      
      g_uRwOutputLut[vThreadID] = r1.xyz;
      break;
    }

    case 1:
    {
      // AP1 -> BT709
      r1.x = dot(float3( 1.705080, -0.624233, -0.080846), r0.xyz);
      r1.y = dot(float3(-0.129701,  1.138469, -0.008768), r0.xyz);
      r1.z = dot(float3(-0.024167, -0.124615,  1.148782), r0.xyz);

      // r2.xy = cb4[0].xy / cb4[0].yx
      r2.xy = g_vHdrLutInfo.xy / g_vHdrLutInfo.yx;

      bool4 m = (float4(0.5, 0.5, 0.5, 0.5) < r1.xyzx);

      r4 = (r1.xyzx + float4(-0.5, -0.5, -0.5, -0.5)) * float4(-0.137504, -0.137504, -0.137504, -0.137504);
      r4 = exp2(r4);

      r0.w = r2.x - 1.0;
      r4   = (-r4 * r0.wwww) + r2.xxxx;

      // movc
      r3 = m ? r4 : float4(1, 1, 1, 1);

      // NOTE: dxbc divides by r3.wyzw (we preserve that exact swizzle)
      r1 = r1.xyzx / r3.wyzw;
      r1 = max(r1, 0.0);

      // Neutral tonemapper block (matches your decompile / dxbc)
      r2.xz = g_vNeutralTonemapperParams0.ww * g_vNeutralTonemapperParams1.xx; // cb4[1].w * cb4[2].xxyx
      r0.w  = g_vNeutralTonemapperParams0.y * g_vNeutralTonemapperParams0.z;

      r2.w  = g_vNeutralTonemapperParams0.x * g_vNeutralTonemapperParams1.z + r0.w;
      r2.w  = g_vNeutralTonemapperParams1.z * r2.w + r2.x;

      r4.x  = g_vNeutralTonemapperParams0.x * g_vNeutralTonemapperParams1.z + g_vNeutralTonemapperParams0.y;
      r4.x  = g_vNeutralTonemapperParams1.z * r4.x + r2.z;

      r2.w  = r2.w / r4.x;

      r4.x  = g_vNeutralTonemapperParams1.x / g_vNeutralTonemapperParams1.y;
      r2.w  = r2.w - r4.x;
      r2.w  = 1.0 / r2.w;

      r1    = r1 * r2.wwww;

      // These swizzles are exactly what DXBC does (r1.wyzw pattern)
      r5    = g_vNeutralTonemapperParams0.xxxx * r1.wyzw + r0.wwww;
      r5    = r1.wyzw * r5 + r2.xxxx;

      r6    = g_vNeutralTonemapperParams0.xxxx * r1.wyzw + g_vNeutralTonemapperParams0.yyyy;
      r1    = r1 * r6 + r2.zzzz;

      r1    = r5 / r1;
      r1    = r1 - r4.xxxx;

      r0.w  = r2.w / g_vNeutralTonemapperParams1.w;
      r1    = r1 * r0.wwww;

      r1    = r1 * r3;         // * r3.xyzw
      r1    = r1 * r2.yyyy;    // * r2.y

      g_uRwOutputLut[vThreadID] = r1.xyz;
      break;
    }

    case 2:
    case 4:
    {
      // This is your big path; I’m leaving the math as-is, just making it compile.
      // It ends with the cb4[0].w color space matrix switch and a final store.
      // --- begin: verbatim from your decompile (just “cmp” fixed) ---
      r1.y = dot(float3(0.695452213,0.140678704,0.163869068), r0.xyz);
      r2.y = dot(float3(0.0447945632,0.859671116,0.0955343172), r0.xyz);
      r3.y = dot(float3(-0.00552588282,0.00402521016,1.00150073), r0.xyz);

      bool cond0 = (r1.y < r2.y);
      if (cond0)
      {
        bool cond1 = (r2.y < r3.y);
        r3.z = r3.y - r1.y;
        bool condZ = (0.0 < r3.z);

        r2.w = (r1.y - r2.y) * 60.0;
        r2.w = r2.w / r3.z;
        r2.w = 240.0 + r2.w;
        r3.x = condZ ? r2.w : 0.0;

        bool cond2 = (r1.y < r3.y);
        r4.z = r2.y - r1.y;
        bool cond4z = (0.0 < r4.z);

        r4.y = 60.0 * r3.z;
        r4.w = r4.y / r4.z;
        r4.w = 120.0 + r4.w;
        r4.x = cond4z ? r4.w : 0.0;

        r5.z = r2.y - r3.y;
        bool cond5z = (0.0 < r5.z);

        r4.y = r4.y / r5.z;
        r4.y = 120.0 + r4.y;
        r5.x = cond5z ? r4.y : 0.0;

        r2.xz  = cond2 ? r4.xz : r5.xz;
        r2.xzw = cond1 ? r3.yzx : r2.yzx;
      }
      else
      {
        bool cond1 = (r1.y < r3.y);
        r3.z = r3.y - r2.y;
        bool condZ = (0.0 < r3.z);

        r4.z = r1.y - r2.y;
        r4.y = (60.0 * r4.z) / r3.z;
        r4.y = 240.0 + r4.y;
        r3.x = condZ ? r4.y : 0.0;

        bool cond2 = (r2.y < r3.y);
        bool cond4z = (0.0 < r4.z);

        r4.w = (r2.y - r3.y) * 60.0;
        r5.x = r4.w / r4.z;
        r4.x = cond4z ? r5.x : 0.0;

        r5.z = r1.y - r3.y;
        bool cond5z = (0.0 < r5.z);

        r4.w = r4.w / r5.z;
        r5.x = cond5z ? r4.w : 0.0;

        r1.xz  = cond2 ? r4.xz : r5.xz;
        r2.xzw = cond1 ? r3.yzx : r1.yzx;
      }

      // Hue wrap
      bool lt0 = (r2.w < 0.0);
      bool gt360 = (360.0 < r2.w);
      float h_minus = r2.w + 360.0;
      float h_plus  = r2.w - 360.0;
      float h = gt360 ? h_plus : r2.w;
      h = lt0 ? h_minus : h;

      // Protect div-by-zero
      float s = (r2.x == 0.0) ? 0.0 : (r2.z / r2.x);
      r1.x = s;       // using r1.x as s

      // (rest of your path)
      r1.z = r3.y - r2.y;
      r1.w = r2.y - r1.y;
      r1.w = r2.y * r1.w;
      r1.z = r3.y * r1.z + r1.w;
      r1.w = r1.y - r3.y;
      r1.z = r1.y * r1.w + r1.z;
      r1.z = sqrt(r1.z);

      r1.w = r2.y + r1.y;
      r1.w = r1.w + r3.y;
      r1.z = r1.w + r1.z;
      r1.z = 1.75 + r1.z;
      r1.w = (1.0/3.0) * r1.z;

      float t = r1.x - 0.4;
      float a = 2.5 * t;
      float tri = max(0.0, 1.0 - abs(a));
      float signT = (t >= 0.0) ? 1.0 : -1.0;
      float k = 1.0 - tri * tri;
      float mixv = 1.0 + signT * k;

      float mix25 = 0.025 * mixv;

      bool le016 = (r1.z <= 0.16);
      bool ge048 = (r1.z >= 0.48);

      float ramp = (0.08 / r1.w) - 0.5;
      ramp = 1.0 + mix25 * ramp;

      float mixv25p1 = 1.0 + 0.025 * mixv;
      float zsel = ge048 ? 1.0 : ramp;
      zsel = le016 ? mixv25p1 : zsel;

      r1.z = zsel;

      // r2.yzw = r1.zzzz * r3.zzwy  (but r3.z=r1.y, r3.w=r2.y)
      r3.z = r1.y;
      r3.w = r2.y;
      r2.yzw = r1.zzz * r3.zwy;

      // hue shaping
      bool h_lt_m180 = (h < -180.0);
      bool h_gt_p180 = (180.0 < h);

      float h_add = h + 360.0;
      float h_sub = h - 360.0;
      float h2 = h_gt_p180 ? h_sub : h;
      h2 = h_lt_m180 ? h_add : h2;

      float u = 2.43902445 * h2;
      u = max(0.0, 1.0 - abs(u));

      float p = (u * -2.0) + 3.0;
      u = u * u;
      u = p * u;
      u = u * u;
      u = u * r1.x;

      float w = 0.03 - r3.z * r1.z;
      u = u * w;

      r2.x = 0.18 * u + r2.y;

      r1.xyz = max(float3(0,0,0), r2.xzw);
      r1.xyz = min(float3(65504,65504,65504), r1.xyz);

      // matrix + rest of pipeline (kept as in your decompile; it already matches dxbc)
      r2.x = dot(float3(1.45143926,-0.236510754,-0.214928567), r1.xyz);
      r2.y = dot(float3(-0.0765537769,1.17622972,-0.0996759236), r1.xyz);
      r2.z = dot(float3(0.00831614807,-0.00603244966,0.997716308), r1.xyz);
      r1.xyz = max(float3(0,0,0), r2.xyz);
      r1.xyz = min(float3(65504,65504,65504), r1.xyz);
      
      r0.w = dot(r1.xyz, float3(0.272228986,0.674081981,0.0536894985));
      r1.xyz = (r1.xyz - r0.www) * 0.96 + r0.www;

      r2.xy = g_vHdrLutInfo.xy / g_vHdrLutInfo.yx;
      bool3 mm = (float3(0.5,0.5,0.5) < r1.xyz);

      r4.xyz = (r1.xyz + float3(-0.5,-0.5,-0.5)) * float3(-0.137504,-0.137504,-0.137504);
      r4.xyz = exp2(r4.xyz);

      r0.w = r2.x - 1.0;
      r2.xzw = (-r4.xyz * r0.www) + r2.xxx;
      r2.xzw = mm ? r2.xzw : float3(1,1,1);

      r1.xyz = r1.xyz / r2.xzw;

      float3 x = r1.rgb;
      float3 W = r2.xzw;
      float A = 30.9882221;
      float B = 1.19912136;
      float C = 32.667881;
      float D = 9.87056255;
      float E = 8.97784805;
      float3 base = ApplyNiohCurve(x, A, B, C, D, E);
      float3 extended = ApplyNiohExtended(x, base, A, B, C, D, E);

      extended = renodx::color::bt709::from::AP1(extended);
      extended = LMS_Vibrancy(extended, 1.0, 1.1f);
      extended = CastleDechroma_CVVDPStyle_NakaRushton(extended, 50.f);
      extended = renodx::color::ap1::from::BT709(extended);
      // r3.xyz = r1.xyz * 30.9882221 + 1.19912136;
      // r3.xyz = r3.xyz * r1.xyz;
      // r4.xyz = r1.xyz * 32.667881  + 9.87056255;
      // r1.xyz = r1.xyz * r4.xyz + 8.97784805;
      // r1.xyz = r3.xyz / r1.xyz;
      // r1.xyz = r1.xyz * r2.xzw;
      r1.rgb = extended * W;

      r0.w = dot(float3(0.662454188,0.134004205,0.156187683), r1.xyz);
      r1.w = dot(float3(0.272228718,0.674081743,0.0536895171), r1.xyz);
      r1.x = dot(float3(-0.00557464967,0.0040607336,1.01033914), r1.xyz);
      r1.y = r1.w + r0.w;
      r1.x = r1.y + r1.x;

      r1.xy = max(float2(1.0e-10, 0.0), r1.xw);
      r0.w  = r0.w / r1.x;
      r1.x  = r1.w / r1.x;

      // DXBC log/exp are log2/exp2; keep log2/exp2 (matches your decompile)
      r1.y  = log2(r1.y);
      r1.y  = 0.981100023 * r1.y;
      r3.y  = exp2(r1.y);

      r1.y  = max(1.0e-10, r1.x);
      r1.y  = r3.y / r1.y;
      r3.x  = r1.y * r0.w;

      r0.w  = (1.0 - r0.w) - r1.x;
      r3.z  = r0.w * r1.y;

      r1.x = dot(float3(1.6410234,-0.324803293,-0.236424699), r3.xyz);
      r1.y = dot(float3(-0.663662851,1.61533165,0.0167563483), r3.xyz);
      r1.z = dot(float3(0.0117218941,-0.00828444213,0.988394856), r3.xyz);

      r0.w = dot(r1.xyz, float3(0.272228986,0.674081981,0.0536894985));
      r1.xyz = (r1.xyz - r0.www) * 0.93 + r0.www;

      r3.x = dot(float3(0.662454188,0.134004205,0.156187683), r1.xyz);
      r3.y = dot(float3(0.272228718,0.674081743,0.0536895171), r1.xyz);
      r3.z = dot(float3(-0.00557464967,0.0040607336,1.01033914), r1.xyz);

      r4.x = dot(float3(0.988232493,-0.00788563583,0.0167578701), r3.xyz);
      r4.y = dot(float3(-0.00569321448,0.998692274,0.00667246478), r3.xyz);
      r4.z = dot(float3(0.000352954201,0.00112296687,1.07808423), r3.xyz);

      // Final output matrix based on g_vHdrLutInfo.w
      int outM = (int)g_vHdrLutInfo.w;
      float3 outRgb = r4.xyz;
      if (outM == 0)
      {
        // XYZ -> BT.709 - in use
        outRgb = float3(
          dot(float3(3.240970, -1.537383, -0.498611), r4.xyz),
          dot(float3(-0.969244, 1.875968, 0.041555), r4.xyz),
          dot(float3(0.055630, -0.203977, 1.056972), r4.xyz)
        );
      }
      else if (outM == 1)
      {
        // XYZ_TO_BT2020_MAT
        outRgb = float3(
          dot(float3(1.716651, -0.355671, -0.253366), r4.xyz),
          dot(float3(-0.666684, 1.616481, 0.015769), r4.xyz),
          dot(float3(0.017640, -0.042771, 0.942103), r4.xyz)
        );
        
      }
      else if (outM == 2)
      {
        // not sure 
        outRgb = float3(
            dot(float3(2.421405, -0.872936, -0.393461), r4.xyz),
            dot(float3(-0.831190, 1.764043, 0.023843), r4.xyz),
            dot(float3(0.030596, -0.162594, 1.040821), r4.xyz)
        );
        
      }

      // Multiply by r2.y (same as dxbc: mul r1, r2.yyyy, r1)
      outRgb *= r2.y;

      // outRgb *= 10;
      g_uRwOutputLut[vThreadID] = outRgb;
      break;
      // --- end ---
    }

    case 3:
    {
      // This is your "alt tonemap" path; your decompile is fine, just fix final store + cmp.

      // AP1 -> BT709
      r1.x = dot(float3( 1.705080, -0.624233, -0.080846), r0.xyz);
      r1.y = dot(float3(-0.129701,  1.138469, -0.008768), r0.xyz);
      r1.z = dot(float3(-0.024167, -0.124615,  1.148782), r0.xyz);

      r2.xy = g_vHdrLutInfo.xy / g_vHdrLutInfo.yx;
      bool4 m = (float4(0.5,0.5,0.5,0.5) < r1.xyzx);

      r4 = (r1.xyzx + float4(-0.5,-0.5,-0.5,-0.5)) * float4(-0.137504,-0.137504,-0.137504,-0.137504);
      r4 = exp2(r4);

      r0.w = r2.x - 1.0;
      r4   = (-r4 * r0.wwww) + r2.xxxx;
      r3   = m ? r4 : float4(1,1,1,1);

      r1 = r1.xyzx / r3.wyzw;

      // constants built from cb4[2].z (matches dxbc)
      float2 p0 = g_vNeutralTonemapperParams1.zz * float2(0.150000006, 0.150000006) + float2(0.0500000007, 0.5);
      float2 p1 = g_vNeutralTonemapperParams1.zz * p0 + float2(0.00400000019, 0.0600000024);

      r0.w = p1.x / p1.y;
      r0.w = (r0.w - 0.0666666627);
      r0.w = 1.0 / r0.w;

      r1 = max(r1, 0.0);

      r4 = r1.wyzw * 0.150000006 + 0.0500000007;
      r4 = r1.wyzw * r4 + 0.00400000019;

      r5 = r1.wyzw * 0.150000006 + 0.5;
      r1 = r1 * r5 + 0.0600000024;

      r1 = r4 / r1;
      r1 = r1 + (-0.0666666627).xxxx;
      r1 = r1 * r0.wwww;
      r1 = r1 * r3;
      r1 = r1 * r2.yyyy;

      g_uRwOutputLut[vThreadID] = r1.xyz;
      break;
    }

    default:
    {
      // DXBC default writes input back out
      g_uRwOutputLut[vThreadID] = r0.xyz;
      break;
    }
  }
}
