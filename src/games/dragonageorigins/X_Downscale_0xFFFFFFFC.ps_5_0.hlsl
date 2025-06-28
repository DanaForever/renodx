#include "./shared.h"

// This shader performs downsampling on a texture,
// as taken from Call Of Duty method, presented at ACM Siggraph 2014.
// This particular method was customly designed to eliminate
// "pulsating artifacts and temporal stability issues".

// Remember to add bilinear minification filter for this texture!
// Remember to use a floating-point texture format (for HDR)!
// Remember to use edge clamping for this texture!
SamplerState sourceSampler : register(s15);
Texture2D<float4> sourceTexture : register(t50);

void main(float4 vpos : SV_Position,
        float2 texCoord : TEXCOORD,
    out float4 downsample : SV_Target0)
{
    float x = injectedData.internalBloomSrcTexelSizeX;
    float y = injectedData.internalBloomSrcTexelSizeY;

    // Take 13 samples around current texel:
    // a - b - c
    // - j - k -
    // d - e - f
    // - l - m -
    // g - h - i
    // === ('e' is the current texel) ===
    float3 a = sourceTexture.Sample(sourceSampler, float2(texCoord.x - 2*x, texCoord.y + 2*y)).rgb;
    float3 b = sourceTexture.Sample(sourceSampler, float2(texCoord.x,       texCoord.y + 2*y)).rgb;
    float3 c = sourceTexture.Sample(sourceSampler, float2(texCoord.x + 2*x, texCoord.y + 2*y)).rgb;

    float3 d = sourceTexture.Sample(sourceSampler, float2(texCoord.x - 2*x, texCoord.y)).rgb;
    float3 e = sourceTexture.Sample(sourceSampler, float2(texCoord.x,       texCoord.y)).rgb;
    float3 f = sourceTexture.Sample(sourceSampler, float2(texCoord.x + 2*x, texCoord.y)).rgb;

    float3 g = sourceTexture.Sample(sourceSampler, float2(texCoord.x - 2*x, texCoord.y - 2*y)).rgb;
    float3 h = sourceTexture.Sample(sourceSampler, float2(texCoord.x,       texCoord.y - 2*y)).rgb;
    float3 i = sourceTexture.Sample(sourceSampler, float2(texCoord.x + 2*x, texCoord.y - 2*y)).rgb;

    float3 j = sourceTexture.Sample(sourceSampler, float2(texCoord.x - x, texCoord.y + y)).rgb;
    float3 k = sourceTexture.Sample(sourceSampler, float2(texCoord.x + x, texCoord.y + y)).rgb;
    float3 l = sourceTexture.Sample(sourceSampler, float2(texCoord.x - x, texCoord.y - y)).rgb;
    float3 m = sourceTexture.Sample(sourceSampler, float2(texCoord.x + x, texCoord.y - y)).rgb;

    // Apply weighted distribution:
    // 0.5 + 0.125 + 0.125 + 0.125 + 0.125 = 1
    // a,b,d,e * 0.125
    // b,c,e,f * 0.125
    // d,e,g,h * 0.125
    // e,f,h,i * 0.125
    // j,k,l,m * 0.5
    // This shows 5 square areas that are being sampled. But some of them overlap,
    // so to have an energy preserving downsample we need to make some adjustments.
    // The weights are the distributed, so that the sum of j,k,l,m (e.g.)
    // contribute 0.5 to the final color output. The code below is written
    // to effectively yield this sum. We get:
    // 0.125*5 + 0.03125*4 + 0.0625*4 = 1
    downsample.rgb = e*0.125;
    downsample.rgb += (a+c+g+i)*0.03125;
    downsample.rgb += (b+d+f+h)*0.0625;
    downsample.rgb += (j+k+l+m)*0.125;
}