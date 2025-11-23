shader_type canvas_item;

uniform sampler2D palette : filter_nearest, repeat_disable;
uniform int row = 0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);

	ivec2 palette_size = textureSize(palette, 0);
	int num_colors = palette_size.x;
	int num_rows = palette_size.y;

	vec4 result_color = original_color;
	for (int i = 0; i < num_colors; i++) {
		vec3 palette_color = texture(palette, vec2(float(i) / float(num_colors - 1), 0.0)).rgb;
		if (all(lessThan(abs(original_color.rgb - palette_color), vec3(1.0/255.0)))) {
			// Use the row parameter directly
			vec3 final_rgb = texture(palette, vec2(float(i) / float(num_colors - 1), float(row) / float(num_rows - 1))).rgb;
			result_color = vec4(final_rgb, original_color.a);
			break;
		}
	}
	COLOR = result_color;
}