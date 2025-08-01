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
vec4 v[16];
vec4 r0 = vec4(0.0);
const vec4 _125_init = vec4(0.0);

void ps_main()
{
    if (bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 0, 1) != 0u)
    {
        r0 = vec4(texture(s0_2d_shadow, vec3(v[0].xy, (bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[0].z, 0.0, 1.0) : v[0].z)));
    }
    else
    {
        r0 = mix(mix(texture(s0_2d, v[0].xy), textureGather(s0_2d, v[0].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_50 != 0u) ? _77 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 0, 1) != 0u));
    }
    oC0 = mix(r0, vec4(0.0), equal(c.f[0], vec4(0.0))) * mix(c.f[0], vec4(0.0), equal(r0, vec4(0.0)));
}

void main()
{
    oC0 = _125_init;
    oC0 = _125_init;
    v[0u] = mix(vec4(in_Texcoord0.x, in_Texcoord0.y, in_Texcoord0.z, in_Texcoord0.w), vec4(gl_PointCoord, 0.0, 0.0), bvec4(bitfieldExtract(bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 24, 2), 1, 1) == 1u));
    ps_main();
    uint _165 = bitfieldExtract((_50 != 0u) ? _69 : spec_state.dword1, 21, 3);
    uint _172 = bitfieldExtract((_50 != 0u) ? _57 : spec_state.dword2, 27, 4);
    if (_165 != 7u)
    {
        float _211;
        float _212;
        if (_172 <= 8u)
        {
            _211 = float((render_state.alpha_ref << _172) | (render_state.alpha_ref >> (8u - _172)));
            _212 = roundEven(oC0.w * float((256u << _172) - 1u));
        }
        else
        {
            _211 = float(render_state.alpha_ref) / 255.0;
            _212 = oC0.w;
        }
        bool _221;
        switch (_165)
        {
            case 0u:
            {
                _221 = false;
                break;
            }
            case 1u:
            {
                _221 = _212 < _211;
                break;
            }
            case 2u:
            {
                _221 = _212 == _211;
                break;
            }
            case 3u:
            {
                _221 = _212 <= _211;
                break;
            }
            case 4u:
            {
                _221 = _212 > _211;
                break;
            }
            case 5u:
            {
                _221 = _212 != _211;
                break;
            }
            case 6u:
            {
                _221 = _212 >= _211;
                break;
            }
            default:
            {
                _221 = true;
                break;
            }
        }
        if (!_221)
        {
            discard;
        }
    }
}

