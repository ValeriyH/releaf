shader_type canvas_item;
// Hides the part of the sprite under the water line, the feet are at local y 16

uniform float sink = 0.0;
uniform vec4 water_line_color: source_color = vec4(0.804, 0.922, 0.949, 1.0); // Releaf32 #CDEBF2

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	if (sink > 0.0) {
		float line = 16.0 - sink;
		if (local_y > line) {
			COLOR.a = 0.0;
		} else if (local_y > line - 1.0) {
			COLOR.rgb = mix(COLOR.rgb, water_line_color.rgb, 0.6);
		}
	}
}
