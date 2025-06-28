SamplerState sampler_s : register(s0);
Texture2D<float4> sourceTexture : register(t0);


void main(float4 vpos : SV_Position,
        float2 texCoord : TEXCOORD,
    out float4 outputColor : SV_Target0)
{
    outputColor = sourceTexture.Sample(sampler_s, texCoord.xy);
}