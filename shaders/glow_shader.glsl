vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 c = Texel(texture, texture_coords);

	float r = c.r * 1.25f;
	float g = c.g * 1.25f;
	float b = c.b;
	float a = c.a;

	return vec4(r, g, b, a);
}

