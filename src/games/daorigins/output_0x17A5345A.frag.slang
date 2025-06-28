#version 450
#extension GL_EXT_samplerless_texture_functions : require

layout(constant_id = 6) const bool c_composite_hud = false;
layout(constant_id = 7) const bool c_composite_cursor = false;
layout(constant_id = 2) const uint c_src_color_space = 0u;
layout(constant_id = 3) const bool c_src_is_srgb = true;
const bool _312 = (!c_src_is_srgb);
layout(constant_id = 1) const bool c_gamma = false;
const bool _370 = (c_src_color_space != 1000104013u);
layout(constant_id = 4) const uint c_dst_color_space = 0u;
const bool _435 = (c_dst_color_space != 1000104013u);
layout(constant_id = 5) const bool c_dst_is_srgb = true;
const bool _478 = (!c_gamma);
const bool _479 = (c_src_is_srgb != c_dst_is_srgb);
const bool _480 = (_478 && _479);
const bool _516 = (!c_dst_is_srgb);
layout(constant_id = 0) const uint c_samples = 0u;

layout(push_constant, std430) uniform present_info_t
{
    ivec2 src_offset;
    ivec2 src_extent;
    ivec2 dst_offset;
    ivec2 cursor_offset;
    ivec2 cursor_extent;
} _260;

layout(set = 0, binding = 2) uniform texture2D s_hud;
layout(set = 0, binding = 3) uniform sampler2D s_cursor;
layout(set = 0, binding = 1) uniform sampler1D s_gamma;
layout(set = 0, binding = 0) uniform sampler2D s_image;
layout(set = 0, binding = 0) uniform sampler2DMS s_image_ms;

layout(location = 0) out vec4 o_color;
mat3 rec709_to_rec2020;
mat3 rec2020_to_rec709;

vec3 srgb_to_linear(vec3 srgb)
{
    bvec3 isLo = lessThanEqual(srgb, vec3(0.040449999272823333740234375));
    vec3 loPart = srgb / vec3(12.9200000762939453125);
    vec3 hiPart = pow((srgb + vec3(0.054999999701976776123046875)) / vec3(1.05499994754791259765625), vec3(2.400000095367431640625));
    return mix(hiPart, loPart, isLo);
}

vec3 nits_to_sc_rgb(vec3 nits)
{
    return nits / vec3(80.0);
}

vec3 pq_to_nits(vec3 pq)
{
    vec3 pq_m2 = pow(pq, vec3(0.0126833133399486541748046875));
    vec3 num = max(pq_m2 - vec3(0.8359375), vec3(0.0));
    vec3 den = vec3(18.8515625) - (pq_m2 * 18.6875);
    vec3 y = pow(num / den, vec3(6.277394771575927734375));
    return y * 10000.0;
}

vec4 input_to_sc_rgb(inout vec4 color)
{
    switch (c_src_color_space)
    {
        case 0u:
        {
            if (_312)
            {
                vec3 param = color.xyz;
                vec3 _318 = srgb_to_linear(param);
                color.x = _318.x;
                color.y = _318.y;
                color.z = _318.z;
            }
            vec3 param_1 = color.xyz * 203.0;
            vec3 _329 = nits_to_sc_rgb(param_1);
            color.x = _329.x;
            color.y = _329.y;
            color.z = _329.z;
            return color;
        }
        case 1000104002u:
        {
            return color;
        }
        case 1000104008u:
        {
            vec3 param_2 = color.xyz;
            vec3 param_3 = pq_to_nits(param_2);
            vec3 _345 = nits_to_sc_rgb(param_3);
            color.x = _345.x;
            color.y = _345.y;
            color.z = _345.z;
            vec4 _353 = color;
            vec3 _355 = rec2020_to_rec709 * _353.xyz;
            color.x = _355.x;
            color.y = _355.y;
            color.z = _355.z;
            return color;
        }
        default:
        {
            return color;
        }
    }
}

vec4 blend_sc_rgb(vec4 dst, vec4 src)
{
    return mix(dst, vec4(src.xyz, 1.0), src.wwww);
}

vec4 blend_linear_sdr(vec4 dst, inout vec4 src)
{
    vec3 param = src.xyz * 203.0;
    vec3 _210 = nits_to_sc_rgb(param);
    src.x = _210.x;
    src.y = _210.y;
    src.z = _210.z;
    vec4 param_1 = dst;
    vec4 param_2 = src;
    return blend_sc_rgb(param_1, param_2);
}

vec4 composite_image(inout vec4 color)
{
    ivec2 coord = ivec2(gl_FragCoord.xy);
    if (c_composite_hud)
    {
        vec4 param = color;
        vec4 param_1 = texelFetch(s_hud, coord, 0);
        vec4 _252 = blend_linear_sdr(param, param_1);
        color = _252;
    }
    if (c_composite_cursor)
    {
        ivec2 rel_ofs = coord - _260.cursor_offset;
        bool _272 = max(rel_ofs.x, rel_ofs.y) >= 0;
        bool _282;
        if (_272)
        {
            _282 = all(lessThan(rel_ofs, _260.cursor_extent));
        }
        else
        {
            _282 = _272;
        }
        if (_282)
        {
            vec4 param_2 = color;
            vec4 param_3 = texture(s_cursor, vec2(rel_ofs) / vec2(_260.cursor_extent));
            vec4 _299 = blend_linear_sdr(param_2, param_3);
            color = _299;
        }
    }
    return color;
}

vec3 sc_rgb_to_nits(vec3 sc_rgb)
{
    return sc_rgb * 80.0;
}

vec3 linear_to_srgb(vec3 linear)
{
    bvec3 isLo = lessThanEqual(linear, vec3(0.003130800090730190277099609375));
    vec3 loPart = linear * 12.9200000762939453125;
    vec3 hiPart = (pow(linear, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
    return mix(hiPart, loPart, isLo);
}

vec3 nits_to_pq(vec3 nits)
{
    vec3 y = clamp(nits / vec3(10000.0), vec3(0.0), vec3(1.0));
    vec3 y_m1 = pow(y, vec3(0.1593017578125));
    vec3 num = vec3(0.8359375) + (y_m1 * 18.8515625);
    vec3 den = vec3(1.0) + (y_m1 * 18.6875);
    return pow(num / den, vec3(78.84375));
}

vec4 sc_rgb_to_output(inout vec4 color)
{
    if (c_gamma)
    {
        if (_370)
        {
            vec3 param = color.xyz;
            vec3 _378 = sc_rgb_to_nits(param) / vec3(203.0);
            color.x = _378.x;
            color.y = _378.y;
            color.z = _378.z;
            vec3 param_1 = color.xyz;
            vec3 _388 = linear_to_srgb(param_1);
            color.x = _388.x;
            color.y = _388.y;
            color.z = _388.z;
        }
        else
        {
            if (c_src_is_srgb)
            {
                vec3 param_2 = color.xyz;
                vec3 _401 = linear_to_srgb(param_2);
                color.x = _401.x;
                color.y = _401.y;
                color.z = _401.z;
            }
        }
        float _414 = color.x;
        float _419 = color.y;
        float _424 = color.z;
        vec3 _427 = vec3(texture(s_gamma, _414).x, texture(s_gamma, _419).y, texture(s_gamma, _424).z);
        color.x = _427.x;
        color.y = _427.y;
        color.z = _427.z;
        if (_435)
        {
            vec3 param_3 = color.xyz;
            vec3 _441 = srgb_to_linear(param_3);
            color.x = _441.x;
            color.y = _441.y;
            color.z = _441.z;
            vec3 param_4 = color.xyz * 203.0;
            vec3 _452 = nits_to_sc_rgb(param_4);
            color.x = _452.x;
            color.y = _452.y;
            color.z = _452.z;
        }
        else
        {
            if (c_dst_is_srgb)
            {
                vec3 param_5 = color.xyz;
                vec3 _466 = srgb_to_linear(param_5);
                color.x = _466.x;
                color.y = _466.y;
                color.z = _466.z;
            }
        }
    }
    switch (c_dst_color_space)
    {
        case 0u:
        {
            vec3 param_8 = color.xyz;
            vec3 _509 = sc_rgb_to_nits(param_8) / vec3(203.0);
            color.x = _509.x;
            color.y = _509.y;
            color.z = _509.z;
            if (_516)
            {
                vec3 param_9 = color.xyz;
                vec3 _522 = linear_to_srgb(param_9);
                color.x = _522.x;
                color.y = _522.y;
                color.z = _522.z;
            }
            return color;
        }
        case 1000104002u:
        {
            return color;
        }
        case 1000104008u:
        {
            vec4 _534 = color;
            vec3 _536 = rec709_to_rec2020 * _534.xyz;
            color.x = _536.x;
            color.y = _536.y;
            color.z = _536.z;
            vec3 param_10 = color.xyz;
            vec3 param_11 = sc_rgb_to_nits(param_10);
            vec3 _548 = nits_to_pq(param_11);
            color.x = _548.x;
            color.y = _548.y;
            color.z = _548.z;
            return color;
        }
        default:
        {
            if (_480)
            {
                vec3 _483;
                if (c_src_is_srgb)
                {
                    vec3 param_6 = color.xyz;
                    _483 = linear_to_srgb(param_6);
                }
                else
                {
                    vec3 param_7 = color.xyz;
                    _483 = srgb_to_linear(param_7);
                }
                color.x = _483.x;
                color.y = _483.y;
                color.z = _483.z;
            }
            return color;
        }
    }
}

void main()
{
    rec709_to_rec2020 = mat3(vec3(0.627403914928436279296875, 0.0690972506999969482421875, 0.01639144122600555419921875), vec3(0.329282939434051513671875, 0.9195404052734375, 0.088013350963592529296875), vec3(0.043313063681125640869140625, 0.0113622285425662994384765625, 0.8955953121185302734375));
    rec2020_to_rec709 = inverse(rec709_to_rec2020);
    ivec2 coord = (ivec2(gl_FragCoord.xy) + _260.src_offset) - _260.dst_offset;
    vec4 param = texelFetch(s_image, coord, 0);
    vec4 _578 = input_to_sc_rgb(param);
    o_color = _578;
    vec4 param_1 = o_color;
    vec4 _581 = composite_image(param_1);
    o_color = _581;
    vec4 param_2 = o_color;
    vec4 _584 = sc_rgb_to_output(param_2);
    o_color = _584;
}

