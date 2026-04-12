#ifndef SRC_GAMES_P5R_UNCHARTED2_REDUCED_PARTIAL_HLSLI_
#define SRC_GAMES_P5R_UNCHARTED2_REDUCED_PARTIAL_HLSLI_

#include "./shared.h"

float ApplyCurveReduced(float x, float a, float b, float c, float de, float df, float epf) {
  float numerator = mad(x, mad(a, x, c * b), de);  // x * (a * x + c * b) + d * e
  float denominator = mad(x, mad(a, x, b), df);    // x * (a * x + b) + d * f
  return (numerator / denominator) - (epf);
}

float3 ApplyCurveReduced(float3 x, float a, float b, float c, float de, float df, float epf) {
  float3 numerator = mad(x, mad(a, x, c * b), de);  // x * (a * x + c * b) + d * e
  float3 denominator = mad(x, mad(a, x, b), df);    // x * (a * x + b) + d * f
  return (numerator / denominator) - (epf);
}

// Reduce-coefficient variants of the Uncharted2 extended math.
// P5R's cbuffer only exposes (A, B, C*B, D*E, D*F, E/F, F*White), so D, E, F
// cannot be individually recovered. These overloads take the products directly:
//   de = D * E
//   df = D * F
//   ef = E / F   (only needed by ApplyCurve / InverseUncharted2)
// Every appearance of bare D, E, F below is algebraically rewritten into de/df,
// which is always possible for Derivative / SecondDerivative / ThirdDerivative
// and their roots.

namespace Uncharted2 {
namespace Reduce {



float Derivative(
    float x,
    float a, float b, float c,
    float de, float df, float epf) {
  float num = -a * b * (c - 1.0) * x * x
              + 2.0 * a * (df - de) * x
              + b * (c * df - de);

  float den = x * (a * x + b) + df;
  den = den * den;

  return num / den;
}

float SecondDerivative(
    float x,
    float a, float b, float c,
    float de, float df, float epf) {
  // Common denom: (x*(a*x + b) + d*f)^3
  float t = x * (a * x + b) + df;
  float den = t * t * t;

  // Numerator pieces from WA:
  // 2 * ( a*b*x*(a*(c-1)*x^2 + 3*d*(e - c*f))
  //     + a*d*(e - f)*(3*a*x^2 - d*f)
  //     + b*b*d*(e - c*f) )
  
  float term1 = a * b * x * (a * (c - 1.f) * x * x + 3.f * (de - c * df));
  float term2 = a * (de - df) * (3.f * a * x * x - df);
  float term3 = b * b * (de - c * df);

  float num = 2.f * (term1 + term2 + term3);

  return num / den;
}

float ThirdDerivative(
    float x,
    float a, float b, float c,
    float de, float df, float epf) {
  // Common denom: (x*(a*x + b) + d*f)^4
  float t = x * (a * x + b) + df;
  float den = t * t * t * t;

  // Numerator from WA:
  // -6 * (
  //   a*b*(a^2*(c-1)*x^4 + 6*a*d*x^2*(e - c*f) + d^2*f*(c*f - 2*e + f))
  //   + 4*a^2*d*x*(e - f)*(a*x^2 - d*f)
  //   + 4*a*b*b*d*x*(e - c*f)
  //   + b^3*d*(e - c*f)
  // )
  float x2 = x * x;
  float x4 = x2 * x2;

  float term1 = a * b * (a * a * (c - 1.f) * x4 + 6.f * a * x2 * (de - c * df) + df * (c * df - 2.f * de + df));

  float term2 = 4.f * a * a * x * (de - df) * (a * x2 - df);
  float term3 = 4.f * a * b * b * x * (de - c * df);
  float term4 = b * b * b * (de - c * df);

  float num = -6.f * (term1 + term2 + term3 + term4);

  return num / den;
}


// Analytic smallest positive knee root of f'''(x) = 0.
float FindThirdDerivativeRoot(float a, float b, float c, float de, float df) {
  // sqrt(a b^2 c^2 - 2 a b^2 c + a b^2)
  float sqrt_ab = sqrt(
      a * b * b * c * c
      - 2.f * a * b * b * c
      + a * b * b);

  // sqrt(a d^2 e^2 - 2 a d^2 e f + a d^2 f^2
  //    + b^2 c^2 d f + b^2 (-c) d e - b^2 c d f + b^2 d e)
  float sqrt_df = sqrt(
      a * de * de
      - 2.f * a * de * df
      + a * df * df
      + b * b * c * c * df
      + b * b * (-c) * de
      - b * b * c * df
      + b * b * de);

  // Precompute (d e - d f)
  float de_df = de - df;

  // Inner big piece: sqrt_ab * (...) / (8 * sqrt_df)
  float term_top =
      32.f * (a * de * df - a * df * df + b * b * c * df - b * b * de)
      / (a * a * b * (c - 1.f));

  float term_mid =
      96.f * de_df * (c * df - de)
      / (a * b * (c - 1.f) * (c - 1.f));

  float de_df2 = de_df * de_df;
  float de_df3 = de_df2 * de_df;

  float term_tail =
      64.f * de_df3
      / (b * b * b * (c - 1.f) * (c - 1.f) * (c - 1.f));

  float Tfrac = sqrt_ab * (term_top - term_mid - term_tail)
                / (8.f * sqrt_df);

  // (12 a^2 b c d f - 12 a^2 b d e) / (6 (a^3 b c - a^3 b))
  float Tmid2_num = 12.f * a * a * b * c * df
                    - 12.f * a * a * b * de;
  float Tmid2_den = 6.f * (a * a * a * b * c - a * a * a * b);
  float Tmid2 = Tmid2_num / Tmid2_den;

  // (6 (c d f - d e))/(a (c - 1))
  float T3 = 6.f * (c * df - de)
             / (a * (c - 1.f));

  // (8 (d e - d f)^2)/(b^2 (c - 1)^2)
  float T4 = 8.f * de_df2
             / (b * b * (c - 1.f) * (c - 1.f));

  // Centers for the ± branches
  float centerNeg = -Tfrac + Tmid2 + T3 + T4;  // used with sqrt(-centerNeg)
  float centerPos = Tfrac + Tmid2 + T3 + T4;   // used with sqrt( centerPos)

  // Branch square roots: use SignSqrt for robustness and correct branch behaviour
  float sNeg = renodx::math::SignSqrt(-centerNeg);
  float sPos = renodx::math::SignSqrt(centerPos);

  // Shifts:
  //  - first two roots use:  - sqrt_df/sqrt_ab - (d e - d f)/(b (c - 1))
  //  - last two use:          sqrt_df/sqrt_ab - (d e - d f)/(b (c - 1))
  float shift1 = sqrt_df / sqrt_ab + de_df / (b * (c - 1.f));  // we subtract this
  float shift2 = sqrt_df / sqrt_ab - de_df / (b * (c - 1.f));  // we add this

  // The four analytic roots from WA, mapped to floats:
  float r1 = -0.5f * sNeg - shift1;  // -1/2 * sqrt(-centerNeg) - shift1
  float r2 = 0.5f * sNeg - shift1;   //  1/2 * sqrt(-centerNeg) - shift1
  float r3 = -0.5f * sPos + shift2;  // -1/2 * sqrt( centerPos) + shift2
  float r4 = 0.5f * sPos + shift2;   //  1/2 * sqrt( centerPos) + shift2

  // Max root seems to be always be the right one
  float root = saturate(renodx::math::Max(r1, r2, r3, r4));

  return root;
}



namespace Config {

struct ReduceConfig {
  float pivot_point;
  float white_precompute;
  float a, b, c, de, df, epf;
};

ReduceConfig CreateWithPivotPoint(
    float a, float b, float c, float de, float df, float epf,
    float pivot_point, float white_precompute) {
  ReduceConfig cfg;
  cfg.pivot_point = pivot_point;
  cfg.white_precompute = white_precompute;
  cfg.a = a; cfg.b = b; cfg.c = c; cfg.de = de; cfg.df = df; cfg.epf = epf;
  return cfg;
}

ReduceConfig Create(
    float a, float b, float c, float de, float df, float ef,
    float white_precompute) {
  float pivot = FindThirdDerivativeRoot(a, b, c, de, df);
  return CreateWithPivotPoint(a, b, c, de, df, ef, pivot, white_precompute);
}

}  // Config

#define APPLY_REDUCED_PARTIAL_GENERATOR(T)                                    \
  T ApplyExtended(                                                             \
      T x,                                                                     \
      T base,                                                                  \
      float pivot_point,                                                       \
      float white_precompute,                                                  \
      float a, float b, float c, float de, float df, float ef) {               \
    float pivot_x = pivot_point;                                               \
    float pivot_y = ApplyCurveReduced(pivot_x, a, b, c, de, df, ef) * white_precompute; \
    float slope = Derivative(pivot_x, a, b, c, de, df, ef) * white_precompute;     \
    float offset = pivot_y - slope * pivot_x;                                  \
                                                                               \
    T extended = slope * x + offset;                                           \
                                                                               \
    return lerp(base, extended, step(pivot_x, x));                             \
  }

APPLY_REDUCED_PARTIAL_GENERATOR(float)
APPLY_REDUCED_PARTIAL_GENERATOR(float3)
#undef APPLY_REDUCED_PARTIAL_GENERATOR

float ApplyExtended(float x, Config::ReduceConfig cfg) {

  float base = ApplyCurveReduced(x, cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf) * cfg.white_precompute;
  return ApplyExtended(x, base, cfg.pivot_point, cfg.white_precompute,
                       cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf);
}

float3 ApplyExtended(float3 x, Config::ReduceConfig cfg) {
  float3 base = ApplyCurveReduced(x, cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf) * cfg.white_precompute;
  return ApplyExtended(x, base, cfg.pivot_point, cfg.white_precompute,
                       cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf);
}

float ApplyExtended(float x, float base, Config::ReduceConfig cfg) {
  return ApplyExtended(x, base, cfg.pivot_point, cfg.white_precompute,
                       cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf);
}

float3 ApplyExtended(float3 x, float3 base, Config::ReduceConfig cfg) {
  return ApplyExtended(x, base, cfg.pivot_point, cfg.white_precompute,
                       cfg.a, cfg.b, cfg.c, cfg.de, cfg.df, cfg.epf);
}

}  // Reduce
}  // Uncharted2

#endif  // SRC_GAMES_P5R_UNCHARTED2_REDUCED_PARTIAL_HLSLI_
