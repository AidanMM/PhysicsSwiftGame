void main(void)
{
    // vec2 uv = gl_FragCoord.xy / u_sprite_size.xy; //OLD!
    vec2 uv = v_tex_coord;
    //uv.y = -uv.y; // uncomment for a different effect
    
    uv.y += (cos((uv.y + (u_time * 0.08)) * 85.0) * 0.0019) +
    (sin((uv.y + (u_time * 0.1)) * 15.0) * 0.002);
    
    uv.x += (sin((uv.y + (u_time * 0.13)) * 55.0) * 0.0029) +
    (sin((uv.y + (u_time * 0.1)) * 15.0) * 0.002);
    
    vec4 texColor = texture2D(u_texture, uv);
    gl_FragColor = texColor;
}