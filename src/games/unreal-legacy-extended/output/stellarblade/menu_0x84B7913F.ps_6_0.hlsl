#include "../output.hlsli"

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<uint2> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture3D<float4> t6 : register(t6);

cbuffer cb0 : register(b0) {
  float cb0_050z : packoffset(c050.z);
  float cb0_050w : packoffset(c050.w);
  float cb0_051x : packoffset(c051.x);
  float cb0_051y : packoffset(c051.y);
  float cb0_058z : packoffset(c058.z);
  float cb0_058w : packoffset(c058.w);
  float cb0_059x : packoffset(c059.x);
  float cb0_059y : packoffset(c059.y);
  float cb0_060x : packoffset(c060.x);
  float cb0_060y : packoffset(c060.y);
  float cb0_060z : packoffset(c060.z);
  float cb0_061x : packoffset(c061.x);
  float cb0_061y : packoffset(c061.y);
  float cb0_061z : packoffset(c061.z);
  float cb0_062x : packoffset(c062.x);
  float cb0_064w : packoffset(c064.w);
  int cb0_065x : packoffset(c065.x);
  float cb0_066x : packoffset(c066.x);
  float cb0_066y : packoffset(c066.y);
  float cb0_066z : packoffset(c066.z);
  float cb0_067x : packoffset(c067.x);
  float cb0_067y : packoffset(c067.y);
  float cb0_067z : packoffset(c067.z);
  float cb0_067w : packoffset(c067.w);
};

cbuffer cb1 : register(b1) {
  float4 View_000[4] : packoffset(c000.x);
  float4 View_064[4] : packoffset(c004.x);
  float4 View_128[4] : packoffset(c008.x);
  float4 View_192[4] : packoffset(c012.x);
  float4 View_256[4] : packoffset(c016.x);
  float4 View_320[4] : packoffset(c020.x);
  float4 View_384[4] : packoffset(c024.x);
  float4 View_448[4] : packoffset(c028.x);
  float4 View_512[4] : packoffset(c032.x);
  float4 View_576[4] : packoffset(c036.x);
  float4 View_640[4] : packoffset(c040.x);
  float4 View_704[4] : packoffset(c044.x);
  float4 View_768[4] : packoffset(c048.x);
  float4 View_832[4] : packoffset(c052.x);
  float4 View_896[4] : packoffset(c056.x);
  float3 View_960 : packoffset(c060.x);
  float View_972 : packoffset(c060.w);
  float3 View_976 : packoffset(c061.x);
  float View_988 : packoffset(c061.w);
  float3 View_992 : packoffset(c062.x);
  float View_1004 : packoffset(c062.w);
  float3 View_1008 : packoffset(c063.x);
  float View_1020 : packoffset(c063.w);
  float3 View_1024 : packoffset(c064.x);
  float View_1036 : packoffset(c064.w);
  float4 View_1040 : packoffset(c065.x);
  float4 View_1056 : packoffset(c066.x);
  float3 View_1072 : packoffset(c067.x);
  float View_1084 : packoffset(c067.w);
  float3 View_1088 : packoffset(c068.x);
  float View_1100 : packoffset(c068.w);
  float3 View_1104 : packoffset(c069.x);
  float View_1116 : packoffset(c069.w);
  float3 View_1120 : packoffset(c070.x);
  float View_1132 : packoffset(c070.w);
  float4 View_1136[4] : packoffset(c071.x);
  float4 View_1200[4] : packoffset(c075.x);
  float4 View_1264[4] : packoffset(c079.x);
  float4 View_1328[4] : packoffset(c083.x);
  float4 View_1392[4] : packoffset(c087.x);
  float4 View_1456[4] : packoffset(c091.x);
  float4 View_1520[4] : packoffset(c095.x);
  float4 View_1584[4] : packoffset(c099.x);
  float4 View_1648[4] : packoffset(c103.x);
  float4 View_1712[4] : packoffset(c107.x);
  float3 View_1776 : packoffset(c111.x);
  float View_1788 : packoffset(c111.w);
  float3 View_1792 : packoffset(c112.x);
  float View_1804 : packoffset(c112.w);
  float3 View_1808 : packoffset(c113.x);
  float View_1820 : packoffset(c113.w);
  float4 View_1824[4] : packoffset(c114.x);
  float4 View_1888[4] : packoffset(c118.x);
  float4 View_1952[4] : packoffset(c122.x);
  float4 View_2016 : packoffset(c126.x);
  float4 View_2032 : packoffset(c127.x);
  float2 View_2048 : packoffset(c128.x);
  float2 View_2056 : packoffset(c128.z);
  float4 View_2064 : packoffset(c129.x);
  float4 View_2080 : packoffset(c130.x);
  float4 View_2096 : packoffset(c131.x);
  float4 View_2112 : packoffset(c132.x);
  float4 View_2128 : packoffset(c133.x);
  float4 View_2144 : packoffset(c134.x);
  int View_2160 : packoffset(c135.x);
  float View_2164 : packoffset(c135.y);
  float View_2168 : packoffset(c135.z);
  float View_2172 : packoffset(c135.w);
  float4 View_2176 : packoffset(c136.x);
  float4 View_2192 : packoffset(c137.x);
  float4 View_2208 : packoffset(c138.x);
  float2 View_2224 : packoffset(c139.x);
  float View_2232 : packoffset(c139.z);
  float View_2236 : packoffset(c139.w);
  float View_2240 : packoffset(c140.x);
  float View_2244 : packoffset(c140.y);
  float View_2248 : packoffset(c140.z);
  float View_2252 : packoffset(c140.w);
  float3 View_2256 : packoffset(c141.x);
  float View_2268 : packoffset(c141.w);
  float View_2272 : packoffset(c142.x);
  float View_2276 : packoffset(c142.y);
  float View_2280 : packoffset(c142.z);
  float View_2284 : packoffset(c142.w);
  float View_2288 : packoffset(c143.x);
  float View_2292 : packoffset(c143.y);
  float View_2296 : packoffset(c143.z);
  int View_2300 : packoffset(c143.w);
  int View_2304 : packoffset(c144.x);
  int View_2308 : packoffset(c144.y);
  int View_2312 : packoffset(c144.z);
  int View_2316 : packoffset(c144.w);
  float View_2320 : packoffset(c145.x);
  float View_2324 : packoffset(c145.y);
  float View_2328 : packoffset(c145.z);
  float View_2332 : packoffset(c145.w);
  float4 View_2336 : packoffset(c146.x);
  float3 View_2352 : packoffset(c147.x);
  float View_2364 : packoffset(c147.w);
  float4 View_2368[2] : packoffset(c148.x);
  float4 View_2400[2] : packoffset(c150.x);
  float4 View_2432 : packoffset(c152.x);
  float4 View_2448 : packoffset(c153.x);
  int View_2464 : packoffset(c154.x);
  float View_2468 : packoffset(c154.y);
  float View_2472 : packoffset(c154.z);
  float View_2476 : packoffset(c154.w);
  float View_2480 : packoffset(c155.x);
  float View_2484 : packoffset(c155.y);
  float View_2488 : packoffset(c155.z);
  float View_2492 : packoffset(c155.w);
  float View_2496 : packoffset(c156.x);
  float View_2500 : packoffset(c156.y);
  float View_2504 : packoffset(c156.z);
  float View_2508 : packoffset(c156.w);
  float3 View_2512 : packoffset(c157.x);
  float View_2524 : packoffset(c157.w);
  float View_2528 : packoffset(c158.x);
  float View_2532 : packoffset(c158.y);
  float View_2536 : packoffset(c158.z);
  float View_2540 : packoffset(c158.w);
  float View_2544 : packoffset(c159.x);
  float View_2548 : packoffset(c159.y);
  float View_2552 : packoffset(c159.z);
  float View_2556 : packoffset(c159.w);
  float View_2560 : packoffset(c160.x);
  float View_2564 : packoffset(c160.y);
  float View_2568 : packoffset(c160.z);
  float View_2572 : packoffset(c160.w);
  float4 View_2576[2] : packoffset(c161.x);
  float4 View_2608[2] : packoffset(c163.x);
  float4 View_2640[2] : packoffset(c165.x);
  float4 View_2672[2] : packoffset(c167.x);
  float4 View_2704[2] : packoffset(c169.x);
  float4 View_2736 : packoffset(c171.x);
  float3 View_2752 : packoffset(c172.x);
  float View_2764 : packoffset(c172.w);
  float4 View_2768 : packoffset(c173.x);
  float4 View_2784[4] : packoffset(c174.x);
  float4 View_2848 : packoffset(c178.x);
  float View_2864 : packoffset(c179.x);
  float View_2868 : packoffset(c179.y);
  float View_2872 : packoffset(c179.z);
  float View_2876 : packoffset(c179.w);
  float4 View_2880 : packoffset(c180.x);
  float View_2896 : packoffset(c181.x);
  float View_2900 : packoffset(c181.y);
  float View_2904 : packoffset(c181.z);
  float View_2908 : packoffset(c181.w);
  float View_2912 : packoffset(c182.x);
  float View_2916 : packoffset(c182.y);
  int View_2920 : packoffset(c182.z);
  int View_2924 : packoffset(c182.w);
  float3 View_2928 : packoffset(c183.x);
  float View_2940 : packoffset(c183.w);
  float View_2944 : packoffset(c184.x);
  float View_2948 : packoffset(c184.y);
  float View_2952 : packoffset(c184.z);
  float View_2956 : packoffset(c184.w);
  float4 View_2960 : packoffset(c185.x);
  float View_2976 : packoffset(c186.x);
  float View_2980 : packoffset(c186.y);
  float View_2984 : packoffset(c186.z);
  float View_2988 : packoffset(c186.w);
  float4 View_2992 : packoffset(c187.x);
  float View_3008 : packoffset(c188.x);
  float View_3012 : packoffset(c188.y);
  float View_3016 : packoffset(c188.z);
  float View_3020 : packoffset(c188.w);
  float4 View_3024[7] : packoffset(c189.x);
  float View_3136 : packoffset(c196.x);
  float View_3140 : packoffset(c196.y);
  float View_3144 : packoffset(c196.z);
  float View_3148 : packoffset(c196.w);
  int View_3152 : packoffset(c197.x);
  float View_3156 : packoffset(c197.y);
  float View_3160 : packoffset(c197.z);
  float View_3164 : packoffset(c197.w);
  float3 View_3168 : packoffset(c198.x);
  int View_3180 : packoffset(c198.w);
  float4 View_3184[4] : packoffset(c199.x);
  float4 View_3248[4] : packoffset(c203.x);
  float View_3312 : packoffset(c207.x);
  float View_3316 : packoffset(c207.y);
  float View_3320 : packoffset(c207.z);
  float View_3324 : packoffset(c207.w);
  int2 View_3328 : packoffset(c208.x);
  float View_3336 : packoffset(c208.z);
  float View_3340 : packoffset(c208.w);
  float3 View_3344 : packoffset(c209.x);
  float View_3356 : packoffset(c209.w);
  float3 View_3360 : packoffset(c210.x);
  float View_3372 : packoffset(c210.w);
  float2 View_3376 : packoffset(c211.x);
  float View_3384 : packoffset(c211.z);
  float View_3388 : packoffset(c211.w);
  float3 View_3392 : packoffset(c212.x);
  float View_3404 : packoffset(c212.w);
  float3 View_3408 : packoffset(c213.x);
  float View_3420 : packoffset(c213.w);
  float3 View_3424 : packoffset(c214.x);
  float View_3436 : packoffset(c214.w);
  float3 View_3440 : packoffset(c215.x);
  float View_3452 : packoffset(c215.w);
  float View_3456 : packoffset(c216.x);
  float View_3460 : packoffset(c216.y);
  float View_3464 : packoffset(c216.z);
  float View_3468 : packoffset(c216.w);
  float4 View_3472[4] : packoffset(c217.x);
  float4 View_3536[2] : packoffset(c221.x);
  int View_3568 : packoffset(c223.x);
  int View_3572 : packoffset(c223.y);
  int View_3576 : packoffset(c223.z);
  int View_3580 : packoffset(c223.w);
  float4 View_3584 : packoffset(c224.x);
  float2 View_3600 : packoffset(c225.x);
  float View_3608 : packoffset(c225.z);
  float View_3612 : packoffset(c225.w);
  float4 View_3616 : packoffset(c226.x);
  int View_3632 : packoffset(c227.x);
  float View_3636 : packoffset(c227.y);
  float View_3640 : packoffset(c227.z);
  float View_3644 : packoffset(c227.w);
  float4 View_3648 : packoffset(c228.x);
  int View_3664 : packoffset(c229.x);
  int View_3668 : packoffset(c229.y);
  int View_3672 : packoffset(c229.z);
};

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

float4 main(
  noperspective float2 TEXCOORD : TEXCOORD,
  noperspective float2 TEXCOORD_3 : TEXCOORD3,
  noperspective float3 TEXCOORD_1 : TEXCOORD1,
  noperspective float4 TEXCOORD_2 : TEXCOORD2,
  noperspective float2 TEXCOORD_4 : TEXCOORD4,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  uint _28 = uint(View_2112.x * TEXCOORD.x);
  uint _29 = uint(View_2112.y * TEXCOORD.y);
  float4 _30 = t1.Load(int3(_28, _29, 0));
  uint2 _32 = t2.Load(int3(_28, _29, 0));
  float4 _34 = t0.Load(int3(_28, _29, 0));
  float4 _59 = t3.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  float _284;
  float _285;
  float _286;
  float _287;
  if (!((bool)(_32.y == 200) && (bool)(abs((((((-0.0f - View_1040.y) - (View_1040.x * _34.x)) - (1.0f / ((View_1040.z * _34.x) - View_1040.w))) + View_1040.y) + (View_1040.x * _30.x)) + (1.0f / ((View_1040.z * _30.x) - View_1040.w))) < 0.009999999776482582f))) {
    float4 _98 = t4.Sample(s1, float2(min(max(((cb0_058z * TEXCOORD.x) + cb0_059x), cb0_050z), cb0_051x), min(max(((cb0_058w * TEXCOORD.y) + cb0_059y), cb0_050w), cb0_051y)));
    float4 _115 = t5.Sample(s2, float2(((((cb0_067z * TEXCOORD_3.x) + cb0_067x) * 0.5f) + 0.5f), (0.5f - (((cb0_067w * TEXCOORD_3.y) + cb0_067y) * 0.5f))));
    float _141 = cb0_062x * TEXCOORD_1.y;
    float _142 = cb0_062x * TEXCOORD_1.z;
    float _145 = 1.0f / (dot(float2(_141, _142), float2(_141, _142)) + 1.0f);
    float _146 = _145 * _145;
    float _148 = (TEXCOORD_1.x * 0.009999999776482582f) * View_2168;
    float _161 = exp2(log2((_148 * (((cb0_061x + (cb0_066x * _115.x)) * _98.x) + (cb0_060x * _59.x))) * _146) * 0.1593017578125f);
    float _162 = exp2(log2((_148 * (((cb0_061y + (cb0_066y * _115.y)) * _98.y) + (cb0_060y * _59.y))) * _146) * 0.1593017578125f);
    float _163 = exp2(log2((_148 * (((cb0_061z + (cb0_066z * _115.z)) * _98.z) + (cb0_060z * _59.z))) * _146) * 0.1593017578125f);
    float4 _197 = t6.Sample(s3, float3(((exp2(log2((1.0f / ((_161 * 18.6875f) + 1.0f)) * ((_161 * 18.8515625f) + 0.8359375f)) * 78.84375f) * 0.96875f) + 0.015625f), ((exp2(log2((1.0f / ((_162 * 18.6875f) + 1.0f)) * ((_162 * 18.8515625f) + 0.8359375f)) * 78.84375f) * 0.96875f) + 0.015625f), ((exp2(log2((1.0f / ((_163 * 18.6875f) + 1.0f)) * ((_163 * 18.8515625f) + 0.8359375f)) * 78.84375f) * 0.96875f) + 0.015625f)));
    float _201 = _197.x * 1.0499999523162842f;
    float _202 = _197.y * 1.0499999523162842f;
    float _203 = _197.z * 1.0499999523162842f;
    float _206 = (frac(sin((TEXCOORD_2.w * 543.3099975585938f) + TEXCOORD_2.z) * 493013.0f) * 0.00390625f) + -0.001953125f;
    float _207 = _201 + _206;
    float _208 = _202 + _206;
    float _209 = _203 + _206;
    float _210 = saturate(dot(float3(_201, _202, _203), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f)));
    [branch]
    if (!(cb0_065x == 0)) {
      float _221 = (pow(_207, 0.012683313339948654f));
      float _222 = (pow(_208, 0.012683313339948654f));
      float _223 = (pow(_209, 0.012683313339948654f));
      float _256 = max(6.103519990574569e-05f, ((exp2(log2(max(0.0f, (_221 + -0.8359375f)) / (18.8515625f - (_221 * 18.6875f))) * 6.277394771575928f) * 10000.0f) / cb0_064w));
      float _257 = max(6.103519990574569e-05f, ((exp2(log2(max(0.0f, (_222 + -0.8359375f)) / (18.8515625f - (_222 * 18.6875f))) * 6.277394771575928f) * 10000.0f) / cb0_064w));
      float _258 = max(6.103519990574569e-05f, ((exp2(log2(max(0.0f, (_223 + -0.8359375f)) / (18.8515625f - (_223 * 18.6875f))) * 6.277394771575928f) * 10000.0f) / cb0_064w));
      _284 = min((_256 * 12.920000076293945f), ((exp2(log2(max(_256, 0.0031306699384003878f)) * 0.4166666567325592f) * 1.0549999475479126f) + -0.054999999701976776f));
      _285 = min((_257 * 12.920000076293945f), ((exp2(log2(max(_257, 0.0031306699384003878f)) * 0.4166666567325592f) * 1.0549999475479126f) + -0.054999999701976776f));
      _286 = min((_258 * 12.920000076293945f), ((exp2(log2(max(_258, 0.0031306699384003878f)) * 0.4166666567325592f) * 1.0549999475479126f) + -0.054999999701976776f));
      _287 = _210;
    } else {
      _284 = _207;
      _285 = _208;
      _286 = _209;
      // _287 = _210;

      float3 color = float3(_284, _285, _286);
      color = renodx::color::pq::DecodeSafe(color, RENODX_DIFFUSE_WHITE_NITS);
      float y = renodx::color::y::from::BT2020(color);

      color = renodx::color::pq::EncodeSafe(color, RENODX_DIFFUSE_WHITE_NITS);
      _287 = saturate(y);

      _284 = color.x;
      _285 = color.y;
      _286 = color.z;
    }
  } else {
    _284 = _59.x;
    _285 = _59.y;
    _286 = _59.z;
    _287 = 0.0f;
  }
  SV_Target.x = _284;
  SV_Target.y = _285;
  SV_Target.z = _286;
  SV_Target.w = _287;
  return SV_Target;
}
