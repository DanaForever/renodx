#include "shared.h"
#define DEFAULT_GAMMA true

float3 PQtoLinear(float3 pqColor, float white,
                  bool gamma_correction = DEFAULT_GAMMA,
                  float gamma = 2.4) {
  float3 output = renodx::color::pq::DecodeSafe(pqColor, white);
  if (gamma_correction)
    output = renodx::color::correct::GammaSafe(output, true, gamma);
  
  output = renodx::color::bt709::from::BT2020(output);

  return output;
}

float3 LinearToPQ(float3 pqColor, float white,
                  bool gamma_correction = DEFAULT_GAMMA,
                  float gamma = 2.4) {
  float3 output = renodx::color::bt2020::from::BT709(pqColor);
  if (gamma_correction)
    output = renodx::color::correct::GammaSafe(output, false, gamma);
  
  output = renodx::color::pq::EncodeSafe(output, white);

  return output;
}

float3 UIToPQ(float3 pqColor, float white, bool gamma_correction = DEFAULT_GAMMA) {
  float3 output = pqColor;
  if (gamma_correction)
    output = renodx::color::correct::GammaSafe(output, false, 2.4f);

  output = renodx::color::pq::EncodeSafe(output, white);

  return output;
}
