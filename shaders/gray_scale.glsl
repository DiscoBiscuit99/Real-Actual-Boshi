vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 c = Texel(texture, texture_coords);

	float av = (c.r + c.g + c.b) / 3.0f;

	return vec4(av, av, av, c.a);
}
