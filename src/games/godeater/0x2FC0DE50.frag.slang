#version 450
#extension GL_EXT_demote_to_helper_invocation : require

layout(constant_id = 12) const uint _54 = 0u;
layout(constant_id = 2) const uint _61 = 0u;
layout(constant_id = 1) const uint _73 = 0u;
layout(constant_id = 4) const uint _81 = 0u;

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
layout(location = 1) centroid in vec4 in_Color0;
vec4 v[16];
vec4 r0 = vec4(0.0);
vec4 r1 = vec4(0.0);
const vec4 _168_init = vec4(0.0);

void ps_main()
{
    if (bitfieldExtract((_54 != 0u) ? _73 : spec_state.dword1, 0, 1) != 0u)
    {
        r0 = vec4(texture(s0_2d_shadow, vec3(v[0].xy, (bitfieldExtract((_54 != 0u) ? _81 : spec_state.dword4, 0, 1) != 0u) ? clamp(v[0].z, 0.0, 1.0) : v[0].z)));
    }
    else
    {
        r0 = mix(mix(texture(s0_2d, v[0].xy), textureGather(s0_2d, v[0].xy + (vec2(0.99609375) / vec2(textureSize(s0_2d, 0) * ivec2(2)))).zxyw, bvec4(bitfieldExtract((_54 != 0u) ? _81 : spec_state.dword4, 16, 1) != 0u)), vec4(0.0, 0.0, 0.0, 1.0), bvec4(bitfieldExtract((_54 != 0u) ? _61 : spec_state.dword2, 0, 1) != 0u));
    }
    vec4 _138 = r0;
    _138.x = ((v[1].w == 0.0) ? 0.0 : r0.w) * ((r0.w == 0.0) ? 0.0 : v[1].w);
    r0 = _138;
    float _144 = -v[1].w;
    vec4 _153 = r0;
    _153.y = (((_144 == 0.0) ? 0.0 : r0.w) * ((r0.w == 0.0) ? 0.0 : _144)) + 0.5;
    r0 = _153;
    r1 = mix(vec4(0.5, -1.0, -0.0, 0.0).zzzz, vec4(0.5, -1.0, -0.0, 0.0).yyyy, greaterThanEqual(r0.yyyy, vec4(0.0)));
    if (any(lessThan(r1, vec4(0.0))))
    {
      discard;
    }
    vec4 _180 = oC0;
    _180.w = ((c.f[0].x == 0.0) ? 0.0 : r0.x) * ((r0.x == 0.0) ? 0.0 : c.f[0].x);
    oC0 = _180;
    oC0 = vec4(c.f[1].xyz.x, c.f[1].xyz.y, c.f[1].xyz.z, oC0.w);

    oC0 = saturate(oC0);
}

void main()
{
    oC0 = _168_init;
    oC0 = _168_init;
    v[0u] = mix(vec4(in_Texcoord0.x, in_Texcoord0.y, in_Texcoord0.z, in_Texcoord0.w), vec4(gl_PointCoord, 0.0, 0.0), bvec4(bitfieldExtract(bitfieldExtract((_54 != 0u) ? _73 : spec_state.dword1, 24, 2), 1, 1) == 1u));
    v[1u] = vec4(in_Color0.x, in_Color0.y, in_Color0.z, in_Color0.w);
    ps_main();
    uint _221 = bitfieldExtract((_54 != 0u) ? _73 : spec_state.dword1, 21, 3);
    uint _228 = bitfieldExtract((_54 != 0u) ? _61 : spec_state.dword2, 27, 4);
    if (_221 != 7u)
    {
        float _267;
        float _268;
        if (_228 <= 8u)
        {
            _267 = float((render_state.alpha_ref << _228) | (render_state.alpha_ref >> (8u - _228)));
            _268 = roundEven(oC0.w * float((256u << _228) - 1u));
        }
        else
        {
            _267 = float(render_state.alpha_ref) / 255.0;
            _268 = oC0.w;
        }
        bool _277;
        switch (_221)
        {
            case 0u:
            {
                _277 = false;
                break;
            }
            case 1u:
            {
                _277 = _268 < _267;
                break;
            }
            case 2u:
            {
                _277 = _268 == _267;
                break;
            }
            case 3u:
            {
                _277 = _268 <= _267;
                break;
            }
            case 4u:
            {
                _277 = _268 > _267;
                break;
            }
            case 5u:
            {
                _277 = _268 != _267;
                break;
            }
            case 6u:
            {
                _277 = _268 >= _267;
                break;
            }
            default:
            {
                _277 = true;
                break;
            }
        }
        if (!_277)
        {
          discard;
        }
    }
}

