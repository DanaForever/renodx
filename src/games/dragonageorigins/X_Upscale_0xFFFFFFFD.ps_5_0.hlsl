#include "./shared.h"

// This shader performs upsampling on a texture,
// as taken from Call Of Duty method, presented at ACM Siggraph 2014.

// Remember to add bilinear minification filter for this texture!
// Remember to use a floating-point texture format (for HDR)!
// Remember to use edge clamping for this texture!
SamplerState sourceSampler : register(s15);
Texture2D<float4> sourceTexture : register(t50);

void main(float4 vpos : SV_Position,
        float2 texCoord : TEXCOORD,
    out float4 upsample : SV_Target0)
{
    // The filter kernel is applied with a radius, specified in texture
    // coordinates, so that the radius will vary across mip resolutions.
    float x = injectedData.internalBloomFilterRadiusX;
    float y = injectedData.internalBloomFilterRadiusY;

    // Take 9 samples around current texel:
    // a - b - c
    // d - e - f
    // g - h - i
    // === ('e' is the current texel) ===
    float3 a = sourceTexture.Sample(sourceSampler, float2(texCoord.x - x, texCoord.y + y)).rgb;
    float3 b = sourceTexture.Sample(sourceSampler, float2(texCoord.x,     texCoord.y + y)).rgb;
    float3 c = sourceTexture.Sample(sourceSampler, float2(texCoord.x + x, texCoord.y + y)).rgb;

    float3 d = sourceTexture.Sample(sourceSampler, float2(texCoord.x - x, texCoord.y)).rgb;
    float3 e = sourceTexture.Sample(sourceSampler, float2(texCoord.x,     texCoord.y)).rgb;
    float3 f = sourceTexture.Sample(sourceSampler, float2(texCoord.x + x, texCoord.y)).rgb;

    float3 g = sourceTexture.Sample(sourceSampler, float2(texCoord.x - x, texCoord.y - y)).rgb;
    float3 h = sourceTexture.Sample(sourceSampler, float2(texCoord.x,     texCoord.y - y)).rgb;
    float3 i = sourceTexture.Sample(sourceSampler, float2(texCoord.x + x, texCoord.y - y)).rgb;

    // Apply weighted distribution, by using a 3x3 tent filter:
    //  1   | 1 2 1 |
    // -- * | 2 4 2 |
    // 16   | 1 2 1 |
    upsample.rgb = e*4.0;
    upsample.rgb += (b+d+f+h)*2.0;
    upsample.rgb += (a+c+g+i);
    upsample.rgb *= 1.0 / 16.0;
}