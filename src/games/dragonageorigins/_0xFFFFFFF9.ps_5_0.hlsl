SamplerState sampler_s : register(s1);
Texture2D<float4> lut : register(t1);


float3 FindLUTClippingPoints(Texture2D<float4> lut, SamplerState samplerState, float lutWidth)
{
  // find the clipping point of the lut
  float3 lutEnds = lutWidth;
  
  while (lutEnds.r >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.r / lutWidth, 0.5f)).r;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.r - 1.0f) / lutWidth, 0.5f)).r;
    if (col != nextCol) {
      break;
    }
    lutEnds.r = lutEnds.r - 1.0;
  }

  while (lutEnds.g >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.g / lutWidth, 0.5f)).g;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.g - 1.0f) / lutWidth, 0.5f)).g;
    if (col != nextCol) {
      break;
    }
    lutEnds.g = lutEnds.g - 1.0;
  }

  while (lutEnds.b >= 1.0) {
    float col = lut.Sample(samplerState, float2(lutEnds.b / lutWidth, 0.5f)).b;
    float nextCol = lut.Sample(samplerState, float2((lutEnds.b - 1.0f) / lutWidth, 0.5f)).b;
    if (col != nextCol) {
      break;
    }
    lutEnds.b = lutEnds.b - 1.0;
  }

  return lutEnds;
}

float Remap(float a_oldValue, float a_oldMin, float a_oldMax, float a_newMin, float a_newMax)
{
    return (((a_oldValue - a_oldMin) * (a_newMax - a_newMin)) / (a_oldMax - a_oldMin)) + a_newMin;
}


float3 SampleLUT(float2 uv, float lutWidth, float3 lutClippingPoints)
{
    float3 uvClippingPoints = lutClippingPoints / lutWidth;
    if (uv.x > uvClippingPoints.r || uv.x > uvClippingPoints.g || uv.x > uvClippingPoints.b) {
        float3 backwardsColor;
        backwardsColor.r = lut.Sample(sampler_s, float2((uvClippingPoints.r / 4.f) * 3.f, uv.y)).r;
        backwardsColor.g = lut.Sample(sampler_s, float2((uvClippingPoints.g / 4.f) * 3.f, uv.y)).g;
        backwardsColor.b = lut.Sample(sampler_s, float2((uvClippingPoints.b / 4.f) * 3.f, uv.y)).b;

        float3 velocity;
        velocity.r = (1 - backwardsColor.r) / 0.25f;
        velocity.g = (1 - backwardsColor.g) / 0.25f;
        velocity.b = (1 - backwardsColor.b) / 0.25f;

        float3 outColor = 1.f;
        if (uv.x > uvClippingPoints.r) {
            outColor.r += velocity.r * max((((uv.x * lutWidth) / lutClippingPoints.r) - 1.f), 0.f);
        } else {
            outColor.r = lut.Sample(sampler_s, uv.xy).r;
        }
        if (uv.x > uvClippingPoints.g) {
            outColor.g += velocity.g * max((((uv.x * lutWidth) / lutClippingPoints.g) - 1.f), 0.f);
        } else {
            outColor.g = lut.Sample(sampler_s, uv.xy).g;
        }
        if (uv.x > uvClippingPoints.b) {
            outColor.b += velocity.b * max((((uv.x * lutWidth) / lutClippingPoints.b) - 1.f), 0.f);
        } else {
            outColor.b = lut.Sample(sampler_s, uv.xy).b;
        }
        return outColor;
    }

    return lut.Sample(sampler_s, uv.xy).rgb;
}

float3 BlurSample(float2 uv, float lutWidth, float3 lutClippingPoints)
{
    if (uv.x == 0)
    {
        return lut.Sample(sampler_s, uv.xy).rgb;
    }

    float texelSize = 1 / lutWidth;

    //float2 uvLeftmost = float2(uv.x - texelSize * 2, uv.y);
    float2 uvLeft = float2(uv.x - texelSize, uv.y);
    float2 uvRight = float2(uv.x + texelSize, uv.y);
    //float2 uvRightmost = float2(uv.x + texelSize * 2, uv.y);

    //float3 lutLeftmost = SampleLUT(uvLeftmost, lutWidth, lutClippingPoints);
    float3 lutLeft = SampleLUT(uvLeft, lutWidth, lutClippingPoints);
    float3 lutColor = SampleLUT(uv, lutWidth, lutClippingPoints);
    float3 lutRight = SampleLUT(uvRight, lutWidth, lutClippingPoints);
    //float3 lutRightmost = SampleLUT(uvRightmost, lutWidth, lutClippingPoints);

    //return (lutLeftmost + lutLeft + lutColor + lutRight + lutRightmost) / 5.f;
    return (lutLeft + lutColor + lutRight) / 3.f;
}

void main(float4 vpos : SV_Position,
        float2 texCoord : TEXCOORD,
    out float4 outputColor : SV_Target0)
{
    float lutWidth;
    float lutHeight;
    lut.GetDimensions(lutWidth, lutHeight);

    float3 lutClippingPoints = FindLUTClippingPoints(lut, sampler_s, lutWidth);
    float3 lutColor = BlurSample(texCoord, lutWidth, lutClippingPoints);

    outputColor.rgb = lutColor.rgb;
    outputColor.a = 0.f;
}