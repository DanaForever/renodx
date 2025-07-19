#include "./shared.h"

namespace renodx {
namespace color {
namespace correct {


float3 ChrominanceOKLab(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_lab = renodx::color::oklab::from::BT709(incorrect_color);
  float3 correct_lab = renodx::color::oklab::from::BT709(correct_color);

  float2 incorrect_ab = incorrect_lab.yz;
  float2 correct_ab = correct_lab.yz;

  // Compute chrominance (magnitude of the a–b vector)
  float incorrect_chrominance = length(incorrect_ab);
  float correct_chrominance = length(correct_ab);

  // Scale original chrominance vector toward target chrominance
  float chrominance_ratio = renodx::math::DivideSafe(correct_chrominance, incorrect_chrominance, 1.f);
  float scale = lerp(1.f, chrominance_ratio, strength);
  incorrect_lab.yz = incorrect_ab * scale;

  float3 result = renodx::color::bt709::from::OkLab(incorrect_lab);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 ChrominanceICtCp(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_ictcp = renodx::color::ictcp::from::BT709(incorrect_color);
  float3 correct_ictcp = renodx::color::ictcp::from::BT709(correct_color);

  float2 incorrect_ctcp = incorrect_ictcp.yz;
  float2 correct_ctcp = correct_ictcp.yz;

  // Compute chrominance (magnitude of the Ct–Cp vector)
  float incorrect_chrominance = length(incorrect_ctcp);
  float correct_chrominance = length(correct_ctcp);

  // Scale chrominance vector to match target chrominance
  float chroma_ratio = renodx::math::DivideSafe(correct_chrominance, incorrect_chrominance, 1.f);
  float scale = lerp(1.f, chroma_ratio, strength);
  incorrect_ictcp.yz = incorrect_ctcp * scale;

  float3 result = renodx::color::bt709::from::ICtCp(incorrect_ictcp);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 ChrominancedtUCS(float3 incorrect_color, float3 correct_color, float strength = 1.f) {
  if (strength == 0.f) return incorrect_color;

  float3 incorrect_uvY = renodx::color::dtucs::uvY::from::BT709(incorrect_color);
  float3 correct_uvY = renodx::color::dtucs::uvY::from::BT709(correct_color);

  float2 incorrect_uv = incorrect_uvY.xy;
  float2 correct_uv = correct_uvY.xy;

  float Y_incorrect = incorrect_uvY.z;
  float Y_correct = correct_uvY.z;

  // Compute perceptual lightness (L*) for both colors
  float L_star_hat_i = pow(Y_incorrect, 0.631651345306265f);
  float L_star_i = 2.098883786377f * L_star_hat_i / (L_star_hat_i + 1.12426773749357f);
  float L_star_hat_c = pow(Y_correct, 0.631651345306265f);
  float L_star_c = 2.098883786377f * L_star_hat_c / (L_star_hat_c + 1.12426773749357f);

  // Compute chrominance (C) for both colors
  float M2_incorrect = dot(incorrect_uv, incorrect_uv);
  float M2_correct = dot(correct_uv, correct_uv);
  float C_incorrect = 15.932993652962535f * pow(L_star_i, 0.6523997524738018f) * pow(M2_incorrect, 0.6007557017508491f) / color::dtucs::L_WHITE;
  float C_correct = 15.932993652962535f * pow(L_star_c, 0.6523997524738018f) * pow(M2_correct, 0.6007557017508491f) / color::dtucs::L_WHITE;

  // Interpolate chrominance while preserving original hue direction
  float C = lerp(C_incorrect, C_correct, strength);
  float h = atan2(incorrect_uv.y, incorrect_uv.x);

  // Compute original perceptual lightness (J)
  float J = pow(L_star_i / color::dtucs::L_WHITE, 1.f);

  // Build JCH from original J, interpolated chrominance, and original hue
  float3 final_jch = float3(J, C, h);

  float3 result = renodx::color::bt709::from::dtucs::JCH(final_jch);
  return renodx::color::bt709::clamp::AP1(result);
}

float3 Chrominance(float3 incorrect_color, float3 correct_color, float strength = 1.f, uint method = 0u) {
  if (method == 1u) return ChrominanceICtCp(incorrect_color, correct_color, strength);
  if (method == 2u) return ChrominancedtUCS(incorrect_color, correct_color, strength);
  return ChrominanceOKLab(incorrect_color, correct_color, strength);
}

}  // namespace correct

}  // namespace color

} // namespace renodx