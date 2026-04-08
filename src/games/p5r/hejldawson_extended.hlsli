// HDR extension of the Hejl-Dawson filmic tonemapper (GDC 2010).
//
// Curve:  u = max(0, x - 0.004)
//         f(x) = u*(6.2*u + 0.5) / (u*(6.2*u + 1.7) + 0.06)
//
// Unlike Uncharted2/Hable, this curve:
//   - Has fixed constants (no configurable A,B,...,F)
//   - Is self-normalizing (no white-point division needed)
//   - Is purely concave everywhere: f''(u) < 0 for all u >= 0
//   - f'''(u) > 0 for all u >= 0
//
// Because the curve has no inflection point, the derivative-root pivot methods
// from uncharted2extended.hlsli (FindSecondDerivativeRoot, FindThirdDerivativeRoot)
// have no solution here. The sign changes that make those roots possible in UC2
// come from the E/F toe and the C shoulder parameters — Hejl-Dawson has neither.
//
// Alternative pivot: solve f(x) = target_output analytically.
// Setting f(u) = t gives the quadratic:
//   A*(1-t)*u^2 + (C - B*t)*u - DF*t = 0
// whose discriminant is always positive for t in (0,1), giving a clean closed form.
//
// This is more intuitive than a slope threshold:
// "preserve the curve up to output t, then extend highlights linearly into HDR."
//
// Example values (a=6.2, b=1.7, c=0.5, df=0.06, offset=0.004):
//   t=0.50  →  x_pivot ≈ 0.178,  slope ≈ 2.04
//   t=0.65  →  x_pivot ≈ 0.322,  slope ≈ 0.73
//   t=0.75  →  x_pivot ≈ 0.557,  slope ≈ 0.32
//   t=0.80  →  x_pivot ≈ 0.812,  slope ≈ 0.19

namespace HejlDawson {

static const float HD_A      = 6.2f;
static const float HD_B      = 1.7f;
static const float HD_C      = 0.5f;   // numerator linear coefficient
static const float HD_DF     = 0.06f;  // denominator constant (analogous to D*F)
static const float HD_OFFSET = 0.00f;    // original was 0.004 (film black crush), zeroed for HDR to preserve shadow detail

// Core Hejl-Dawson curve.
float Apply(float x) {
  float u = max(0.f, x - HD_OFFSET);
  return (u * (HD_A * u + HD_C))
       / (u * (HD_A * u + HD_B) + HD_DF);
}

float3 Apply(float3 x) {
  return float3(Apply(x.r), Apply(x.g), Apply(x.b));
}

// First derivative df/dx (equals df/du for x > HD_OFFSET since du/dx = 1).
//
// f'(u) = [A*(B-C)*u^2 + 2*A*DF*u + C*DF] / [A*u^2 + B*u + DF]^2
//
// The numerator has all-positive coefficients, so f'(u) > 0 everywhere.
// There is no root — the curve is monotonically increasing.
float Derivative(float x) {
  float u = max(0.f, x - HD_OFFSET);
  float D = u * (HD_A * u + HD_B) + HD_DF;
  float num = HD_A * (HD_B - HD_C) * u * u
            + 2.f * HD_A * HD_DF * u
            + HD_C * HD_DF;
  return num / (D * D);
}

// Find the input x_pivot where f(x_pivot) = target_output.
//
// Setting f(u) = t and rearranging gives the quadratic:
//   A*(1-t)*u^2 + (C - B*t)*u - DF*t = 0
//
// Discriminant = (C - B*t)^2 + 4*A*(1-t)*DF*t > 0 for all t in (0,1),
// so the positive root always exists analytically.
float FindOutputPivot(float target_output) {
  float t  = target_output;
  float Aq = HD_A * (1.f - t);
  float Bq = HD_C - HD_B * t;
  float Cq = -HD_DF * t;

  float disc = Bq * Bq - 4.f * Aq * Cq;
  disc = max(disc, 0.f);

  float u = (-Bq + sqrt(disc)) / (2.f * Aq);
  return max(u, 0.f) + HD_OFFSET;
}

// Apply with linear HDR extension beyond a pivot specified by output value.
//
//   pivot_output: curve output value at which to branch off (e.g. 0.75).
//                 Below: normal Hejl-Dawson.
//                 Above: pivot_output + f'(pivot_x) * (x - pivot_x).
//
// The join is C1-continuous (slope matches at the pivot).

#define HD_APPLY_EXTENDED_GENERATOR(T)                          \
  T ApplyExtended(T x, T base, float pivot_x) {                \
    float pivot_y = Apply(pivot_x);                            \
    float slope   = Derivative(pivot_x);                       \
    T extended    = pivot_y + slope * (x - pivot_x);           \
    return lerp(base, extended, step(pivot_x, x));             \
  }

HD_APPLY_EXTENDED_GENERATOR(float)
HD_APPLY_EXTENDED_GENERATOR(float3)
#undef HD_APPLY_EXTENDED_GENERATOR

float ApplyExtended(float x, float pivot_output) {
  float base    = Apply(x);
  float pivot_x = FindOutputPivot(pivot_output);
  return ApplyExtended(x, base, pivot_x);
}

float3 ApplyExtended(float3 x, float pivot_output) {
  float3 base    = Apply(x);
  float  pivot_x = FindOutputPivot(pivot_output);
  return ApplyExtended(x, base, pivot_x);
}

}  // namespace HejlDawson
