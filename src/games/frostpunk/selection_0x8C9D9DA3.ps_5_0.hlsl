// ---- Created with 3Dmigoto v1.3.16 on Wed Jun 11 20:40:06 2025



// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  o0.xyzw = v1.xyzw;

  // o0 = saturate(o0);
  return;
}