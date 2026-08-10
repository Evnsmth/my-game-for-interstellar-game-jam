shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec3 final_color = mix(
		tex.rgb,
		vec3(1.0),
		flash_amount
	);

	COLOR = vec4(final_color, tex.a);
}