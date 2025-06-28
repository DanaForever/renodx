#include "./shared.h"

SamplerState sampler_s : register(s15);
Texture2D<float4> sourceTexture : register(t50);


void main(float4 vpos : SV_Position,
        float2 texCoord : TEXCOORD,
    out float4 outputColor : SV_Target0)
{
    float4 color = sourceTexture.Sample(sampler_s, texCoord.xy);

    // threshold
    float brightness = renodx::color::y::from::BT709(color.rgb);
    float knee = injectedData.bloomThreshold * injectedData.bloomThresholdKnee;
    float soft = brightness - injectedData.bloomThreshold + knee;
    soft = clamp(soft, 0, 2 * knee);
    soft = soft * soft / (4 * knee + 0.00001);
	float contribution = max(soft, brightness - injectedData.bloomThreshold);
	contribution /= max(brightness, 0.00001);
	color *= contribution;

    color *= injectedData.bloomContrast;

    outputColor = color;
}