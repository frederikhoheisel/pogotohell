shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;


uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest_mipmap;
uniform sampler2D normal_texture : hint_normal_roughness_texture, filter_linear_mipmap;

const float sobelx[9] = {
	-1.0, 0.0, 1.0, -2.0, 0.0, 2.0, -1.0, 0.0, 1.0
};

const float sobely[9] = {
	-1.0, -2.0, -1.0, 0.0, 0.0, 0.0, 1.0, 2.0, 1.0
};

void vertex() {
  	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

vec3 sobel(vec2 uv, vec2 pixel_size) {
	vec3 res;
	float horizontal = 0.0;
	float vertical = 0.0;
	horizontal += sobelx[0] * texture(depth_texture, uv + vec2(-pixel_size.x, -pixel_size.y), 2.0).x;
	horizontal += sobelx[2] * texture(depth_texture, uv + vec2(pixel_size.x, - pixel_size.y), 2.0).x;
	horizontal += sobelx[3] * texture(depth_texture, uv + vec2(-pixel_size.x, 0.0), 2.0).x;
	horizontal += sobelx[5] * texture(depth_texture, uv + vec2(pixel_size.x, 0.0), 2.0).x;
	horizontal += sobelx[6] * texture(depth_texture, uv + vec2(-pixel_size.x, pixel_size.y),2.0).x;
	horizontal += sobelx[8] * texture(depth_texture, uv + vec2(pixel_size.x, pixel_size.y), 2.0).x;
	
	vertical += sobely[0] * texture(depth_texture, uv + vec2(pixel_size.x, pixel_size.y), 2.0).x;
	vertical += sobely[1] * texture(depth_texture, uv + vec2(0.0, -pixel_size.y), 2.0).x;
	vertical += sobely[2] * texture(depth_texture, uv + vec2(pixel_size.x, -pixel_size.y), 2.0).x;
	vertical += sobely[6] * texture(depth_texture, uv + vec2(-pixel_size.x, pixel_size.y), 2.0).x;
	vertical += sobely[7] * texture(depth_texture, uv + vec2(0.0, pixel_size.y), 2.0).x;
	vertical += sobely[8] * texture(depth_texture, uv + vec2(pixel_size.x, pixel_size.y), 2.0).x;
	
	res.rgb += vec3(abs((dot(horizontal, horizontal)) + abs(dot(vertical, vertical))));
	return res;
}
void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	vec2 uv = SCREEN_UV;
	//color.rgb -= sobel(uv, vec2(1.0/VIEWPORT_SIZE.x, 1.0/VIEWPORT_SIZE.y));

	ALBEDO.rgb = texture(normal_texture, uv).rgb;
}
