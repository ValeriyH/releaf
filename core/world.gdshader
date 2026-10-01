shader_type canvas_item;

uniform vec4 dusk_color : source_color = vec4(0.02, 0.02, 0.08, 0.95);
uniform float margin_in_pixels = 200.0;
uniform vec2 rect_size = vec2(1000.0, 1000.0);
uniform float falloff : hint_range(0.1, 5.0, 0.1) = 1.5;

// Текстура шуму та параметри органіка-ефекту
uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform float noise_amount : hint_range(0.0, 150.0, 1.0) = 40.0; // Сила викривлення лінії в пікселях
uniform vec2 noise_scale = vec2(2.0, 2.0);                      // Масштаб деталізації шуму

void fragment() {
    vec2 pixel_pos = UV * rect_size;

    // Зчитуємо шум (зсуваємо від 0..1 до -0.5..0.5, щоб викривлення йшло в обидва боки)
    float noise_val = texture(noise_texture, UV * noise_scale).r - 0.5;

    // Відстань до найближчого краю
    vec2 dist_to_edge = min(pixel_pos, rect_size - pixel_pos);
    float min_dist = min(dist_to_edge.x, dist_to_edge.y);

    // Модулюємо відстань значенням шуму
    float distorted_dist = min_dist + (noise_val * noise_amount);

    // Обчислюємо підсумкову прозорість
    float factor = clamp(distorted_dist / margin_in_pixels, 0.0, 1.0);
    float alpha = pow(1.0 - factor, falloff);

    COLOR = vec4(dusk_color.rgb, dusk_color.a * alpha);
}