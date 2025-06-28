#include "./shared.h"

Texture2D<float4> t0 : register(t0);
SamplerState s0_s : register(s0);


// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD8,
  float4 v2 : COLOR0,
  float4 v3 : COLOR1,
  float4 v4 : TEXCOORD9,
  float4 v5 : TEXCOORD0,
  float4 v6 : TEXCOORD1,
  float4 v7 : TEXCOORD2,
  float4 v8 : TEXCOORD3,
  float4 v9 : TEXCOORD4,
  float4 v10 : TEXCOORD5,
  float4 v11 : TEXCOORD6,
  float4 v12 : TEXCOORD7,
  out float4 o0 : SV_TARGET0)
{
  //v5.xy *= 2;
  //v6.xy *= 2;
  //v7.xy *= 2;
  //v8.xy *= 2;
  //v9.xy *= 2;
  //v10.xy *= 2;
  //v11.xy *= 2;
  if (injectedData.improvedBloom) {
    float4 sceneColor = t0.Sample(s0_s, v5.xy);  // scene color
    float4 color = sceneColor;

    float2 resolution;
    t0.GetDimensions(resolution.x, resolution.y);

    float2 pixelSize = float2(1.f, 1.f) / resolution;
    
    //const int blurIter = 6;
    //const float offsets[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
    //const float weights[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
    const int blurIter = 11;
    const float offsets[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
    const float weights[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };

    bool isVertical = (v11.x - v5.x) == 0;   // hack to figure out whether it's the horizontal or vertical pass
    float2 uvMult = float2(isVertical ? 0 : 1, isVertical ? 1 : 0);
    
    color *= weights[0];
    for (int i = 1; i < blurIter; ++i) {
      float2 offset = float2(offsets[i] * pixelSize.x, offsets[i] * pixelSize.y) * uvMult;
      
      color += t0.Sample(s0_s, v5.xy + offset) * weights[i];
      color += t0.Sample(s0_s, v5.xy - offset) * weights[i];
    }
    
    bool skipBloom = cmp(sceneColor.w >= color.w);
    o0 = skipBloom ? sceneColor : color;
  } else {
    float4 sceneColor = t0.Sample(s0_s, v5.xy);  // scene color
    
    float4 color = sceneColor;
    color += t0.Sample(s0_s, v6.xy); 
    color += t0.Sample(s0_s, v7.xy); 
    color += t0.Sample(s0_s, v8.xy); 
    color += t0.Sample(s0_s, v9.xy); 
    color += t0.Sample(s0_s, v10.xy);
    color += t0.Sample(s0_s, v11.xy);

    color /= 7.f;

    bool skipBloom = cmp(sceneColor.w >= color.w);
    o0 = skipBloom ? sceneColor : color;
  }

  if (injectedData.toneMapType == 0) {
    o0 = saturate(o0);
  }
}