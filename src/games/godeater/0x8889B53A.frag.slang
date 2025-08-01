#version 450
#extension GL_EXT_demote_to_helper_invocation : require

layout(constant_id = 12) const uint _50 = 0u;
layout(constant_id = 2) const uint _57 = 0u;
layout(constant_id = 1) const uint _69 = 0u;
layout(constant_id = 4) const uint _77 = 0u;

layout(set = 1, binding = 0, std140) uniform cbuffer_t
{
    ivec4 i[16];
    vec4 f[224];
} c;

layout(set = 1, binding = 1, std140) uniform D3D9SharedPS
{
    vec4 _m0;
    vec2 _m1;
    vec2 _m2;
    float _m3;
    float _m4;
    vec4 _m5;
    vec2 _m6;
    vec2 _m7;
    float _m8;
    float _m9;
    vec4 _m10;
    vec2 _m11;
    vec2 _m12;
    float _m13;
    float _m14;
    vec4 _m15;
    vec2 _m16;
    vec2 _m17;
    float _m18;
    float _m19;
    vec4 _m20;
    vec2 _m21;
    vec2 _m22;
    float _m23;
    float _m24;
    vec4 _m25;
    vec2 _m26;
    vec2 _m27;
    float _m28;
    float _m29;
    vec4 _m30;
    vec2 _m31;
    vec2 _m32;
    float _m33;
    float _m34;
    vec4 _m35;
    vec2 _m36;
    vec2 _m37;
    float _m38;
    float _m39;
} D3D9SharedPS_1;

layout(set = 1, binding = 2, std140) uniform spec_state_t
{
    uint dword0;
    uint dword1;
    uint dword2;
    uint dword3;
    uint dword4;
    uint dword5;
    uint dword6;
    uint dword7;
    uint dword8;
    uint dword9;
    uint dword10;
    uint dword11;
    uint dword12;
    uint dword13;
    uint dword14;
} spec_state;

layout(push_constant, std430) uniform render_state_t
{
    vec3 fog_color;
    float fog_scale;
    float fog_end;
    float fog_density;
    uint alpha_ref;
    float point_size;
    float point_size_min;
    float point_size_max;
    float point_scale_a;
    float point_scale_b;
    float point_scale_c;
} render_state;

layout(set = 0, binding = 0) uniform sampler2D s0_2d;
layout(set = 0, binding = 0) uniform sampler2DShadow s0_2d_shadow;

layout(location = 0, index = 0) out vec4 oC0;
layout(location = 0) in vec4 in_Texcoord0;
layout(location = 3) in vec4 in_Texcoord1;
layout(location = 4) in vec4 in_Texcoord2;
layout(location = 5) in vec4 in_Texcoord3;
layout(location = 6) in vec4 in_Texcoord4;
layout(location = 7) in vec4 in_Texcoord5;
layout(location = 8) in vec4 in_Texcoord6;
layout(location = 9) in vec4 in_Texcoord7;
vec4 v[16];
vec4 r0 = vec4(0.0);
vec4 r1 = vec4(0.0);
vec4 r2 = vec4(0.0);
const vec4 _1095_init = vec4(0.0);

void ps_main()
{
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r0 = vec4(texture(s0_2d_shadow, vec3(v[1].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[1].z, 0.0, 1.0) : v[1].z)));
    }
    else
    {
        r0 = mix(mix(texture(s0_2d, v[1].xy), textureGather(s0_2d, v[1].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[6].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[6].zwzw.z, 0.0, 1.0) : v[6].zwzw.z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[6].zwzw.xy), textureGather(s0_2d, v[6].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r0 += r1;
    r0 = mix(r0, vec4(0.0), equal(c.f[1].xxxx, vec4(0.0))) * mix(c.f[1].xxxx, vec4(0.0), equal(r0, vec4(0.0)));
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[0].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[0].z, 0.0, 1.0) : v[0].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[0].xy), textureGather(s0_2d, v[0].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[7].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[7].zwzw.z, 0.0, 1.0) : v[7].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[7].zwzw.xy), textureGather(s0_2d, v[7].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[0].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[0].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[2].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[2].z, 0.0, 1.0) : v[2].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[2].xy), textureGather(s0_2d, v[2].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[5].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[5].zwzw.z, 0.0, 1.0) : v[5].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[5].zwzw.xy), textureGather(s0_2d, v[5].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[2].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[2].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[3].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[3].z, 0.0, 1.0) : v[3].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[3].xy), textureGather(s0_2d, v[3].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[4].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[4].zwzw.z, 0.0, 1.0) : v[4].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[4].zwzw.xy), textureGather(s0_2d, v[4].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[3].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[3].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[4].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[4].z, 0.0, 1.0) : v[4].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[4].xy), textureGather(s0_2d, v[4].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[3].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[3].zwzw.z, 0.0, 1.0) : v[3].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[3].zwzw.xy), textureGather(s0_2d, v[3].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[4].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[4].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[5].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[5].z, 0.0, 1.0) : v[5].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[5].xy), textureGather(s0_2d, v[5].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[2].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[2].zwzw.z, 0.0, 1.0) : v[2].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[2].zwzw.xy), textureGather(s0_2d, v[2].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[5].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[5].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[6].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[6].z, 0.0, 1.0) : v[6].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[6].xy), textureGather(s0_2d, v[6].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[1].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[1].zwzw.z, 0.0, 1.0) : v[1].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[1].zwzw.xy), textureGather(s0_2d, v[1].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    r0 = (mix(c.f[6].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[6].xxxx, vec4(0.0)))) + r0;
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r1 = vec4(texture(s0_2d_shadow, vec3(v[7].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[7].z, 0.0, 1.0) : v[7].z)));
    }
    else
    {
        r1 = mix(mix(texture(s0_2d, v[7].xy), textureGather(s0_2d, v[7].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r2 = vec4(texture(s0_2d_shadow, vec3(v[0].zwzw.xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[0].zwzw.z, 0.0, 1.0) : v[0].zwzw.z)));
    }
    else
    {
        r2 = mix(mix(texture(s0_2d, v[0].zwzw.xy), textureGather(s0_2d, v[0].zwzw.xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    r1 += r2;
    oC0 = (mix(c.f[7].xxxx, vec4(0.0), equal(r1, vec4(0.0))) * mix(r1, vec4(0.0), equal(c.f[7].xxxx, vec4(0.0)))) + r0;
}

void main()
{
    oC0 = _1095_init;
    oC0 = _1095_init;
    vec4 _1113 = vec4(gl_PointCoord, 0.0, 0.0);
    bvec4 _1122 = bvec4(bitfieldExtract(bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 24, 2), 1, 1) == 1u);
    v[0u] = mix(vec4(in_Texcoord0.x, in_Texcoord0.y, in_Texcoord0.z, in_Texcoord0.w), _1113, _1122);
    v[1u] = mix(vec4(in_Texcoord1.x, in_Texcoord1.y, in_Texcoord1.z, in_Texcoord1.w), _1113, _1122);
    v[2u] = mix(vec4(in_Texcoord2.x, in_Texcoord2.y, in_Texcoord2.z, in_Texcoord2.w), _1113, _1122);
    v[3u] = mix(vec4(in_Texcoord3.x, in_Texcoord3.y, in_Texcoord3.z, in_Texcoord3.w), _1113, _1122);
    v[4u] = mix(vec4(in_Texcoord4.x, in_Texcoord4.y, in_Texcoord4.z, in_Texcoord4.w), _1113, _1122);
    v[5u] = mix(vec4(in_Texcoord5.x, in_Texcoord5.y, in_Texcoord5.z, in_Texcoord5.w), _1113, _1122);
    v[6u] = mix(vec4(in_Texcoord6.x, in_Texcoord6.y, in_Texcoord6.z, in_Texcoord6.w), _1113, _1122);
    v[7u] = mix(vec4(in_Texcoord7.x, in_Texcoord7.y, in_Texcoord7.z, in_Texcoord7.w), _1113, _1122);
    ps_main();
    uint _1175 = bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 21, 3);
    uint _1181 = bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 27, 4);
    if (_1175 != 7u)
    {
        float _1219;
        float _1220;
        if (_1181 <= 8u)
        {
            _1219 = float((render_state.alpha_ref << _1181) | (render_state.alpha_ref >> (8u - _1181)));
            _1220 = roundEven(oC0.w * float((256u << _1181) - 1u));
        }
        else
        {
            _1219 = float(render_state.alpha_ref) / 255.0;
            _1220 = oC0.w;
        }
        bool _1229;
        switch (_1175)
        {
            case 0u:
            {
                _1229 = false;
                break;
            }
            case 1u:
            {
                _1229 = _1220 < _1219;
                break;
            }
            case 2u:
            {
                _1229 = _1220 == _1219;
                break;
            }
            case 3u:
            {
                _1229 = _1220 <= _1219;
                break;
            }
            case 4u:
            {
                _1229 = _1220 > _1219;
                break;
            }
            case 5u:
            {
                _1229 = _1220 != _1219;
                break;
            }
            case 6u:
            {
                _1229 = _1220 >= _1219;
                break;
            }
            default:
            {
                _1229 = true;
                break;
            }
        }
        if (!_1229)
        {
          discard;
        }
    }
}

