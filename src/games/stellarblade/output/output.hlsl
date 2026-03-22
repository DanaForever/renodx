#include "../common.hlsl"


float3 PQtoLinear(float3 x) {

    x = renodx::color::pq::DecodeSafe(x, RENODX_DIFFUSE_WHITE_NITS);
    x = renodx::color::bt709::from::BT2020(x);
    return x;
}

float3 PQtoSRGB(float3 x) {
    if (shader_injection.processing_path == 0.f)    {
        x = renodx::color::pq::DecodeSafe(x, RENODX_DIFFUSE_WHITE_NITS);
        x = renodx::color::bt709::from::BT2020(x);
        x = renodx::color::srgb::EncodeSafe(x);
    }
    return x;
}


float3 LinearToPQ(float3 x) {

    x = renodx::color::bt2020::from::BT709(x);
    x = renodx::color::pq::EncodeSafe(x, RENODX_DIFFUSE_WHITE_NITS);
    
    return x;
}

float3 SRGBtoPQ(float3 x) {
    if (shader_injection.processing_path == 0.f)    {
        x = renodx::color::srgb::DecodeSafe(x);
        x = renodx::color::bt2020::from::BT709(x);
        x = renodx::color::pq::EncodeSafe(x, RENODX_DIFFUSE_WHITE_NITS);
    }
    return x;
}
