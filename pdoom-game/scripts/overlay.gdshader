//src: https://godotshaders.com/shader/dynamic2d_censorship_effect/
shader_type canvas_item;

uniform float escala_pixel : hint_range(1.0, 100.0) = 15.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    vec2 screen_size = vec2(textureSize(screen_texture, 0));
    
    vec2 grid = screen_size / escala_pixel;
    uv = floor(uv * grid) / grid;
    
    COLOR = texture(screen_texture, uv);
}
