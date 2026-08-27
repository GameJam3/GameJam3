shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.5, 1.0); // Color base del resplandor
uniform float glow_thickness : hint_range(0.0, 20.0) = 3.0; // Grosor del efecto
uniform float intensity : hint_range(0.0, 10.0) = 1.5; // Multiplicador para el WorldEnvironment (HDR)

void fragment() {
    // Tamaño del píxel de la textura original
    vec2 size = TEXTURE_PIXEL_SIZE * glow_thickness;
    vec4 base_color = texture(TEXTURE, UV);
    float alpha = 0.0;

    // Muestreo octagonal (8 direcciones) para suavizar los bordes del resplandor
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;

    // Limitamos el alfa para evitar excesos en las esquinas interiores
    alpha = min(alpha, 1.0);

    // Aplicamos la intensidad para forzar los valores por encima de 1.0 (necesario para HDR)
    vec4 final_glow = glow_color * intensity;
    final_glow.a = alpha * glow_color.a;

    // Mezclamos el sprite original por encima del resplandor
    COLOR = mix(final_glow, base_color, base_color.a);
}