shader_type canvas_item;


uniform float thick: hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float hole: hint_range(-0.5, 0.5, 0.01) = 0.2;
uniform float halo_thickness: hint_range(0.0, 0.2, 0.01) = 0.01;
uniform float size: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 col: source_color;
uniform bool use_inv_screen_color = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec4 color;
	if (use_inv_screen_color) {
		color = texture(screen_texture, SCREEN_UV);
		color = vec4(1.0) - color;
	}
	else {
		color = col;
	}
	
	vec2 uv = UV;
	
	float alpha = max(step(0.5 - thick, uv.x) - step(0.5 + thick, uv.x), step(0.5 - thick, uv.y) - step(0.5 + thick, uv.y));
	
	alpha -= min(1.0 - (step(0.5 + hole, uv.x) + 1.0 - step(0.5 - hole, uv.x)), 1.0 - (step(0.5 + hole, uv.y) + 1.0 - step(0.5 - hole, uv.y)));
	
	alpha -= step(0.5 + size / 2.0, uv.x);
	alpha -= 1.0 - step(0.5 - size / 2.0, uv.x);
	alpha -= step(0.5 + size / 2.0, uv.y);
	alpha -= 1.0 - step(0.5 - size / 2.0, uv.y);
	
	// uv.y < 0.5 - thick + halo_thickness
	
	if (uv.x > 0.5 + thick - halo_thickness && uv.y < 0.5 - thick + halo_thickness || 
		uv.x < 0.5 - thick + halo_thickness && uv.y < 0.5 - thick + halo_thickness ||
		uv.x > 0.5 + thick - halo_thickness && uv.y > 0.5 + thick - halo_thickness || 
		uv.x < 0.5 - thick + halo_thickness && uv.y > 0.5 + thick - halo_thickness || 
		uv.y < halo_thickness + 0.5 - size / 2.0 || uv.y > 1.0 - halo_thickness - 0.5 + size / 2.0 ||
		uv.x < halo_thickness + 0.5 - size / 2.0 || uv.x > 1.0 - halo_thickness - 0.5 + size / 2.0 ||
		uv.x > 0.5 - hole - halo_thickness && uv.x < 0.5 + hole + halo_thickness &&
		uv.y > 0.5 - hole - halo_thickness && uv.y < 0.5 + hole + halo_thickness) 
	{
		color = vec4(0.0, 0.0, 0.0, 1.0);
	}
	
	COLOR = color;
	COLOR.a = alpha;
}