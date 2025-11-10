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

vec3 normalize_normal(vec3 normal) {
	return normalize(normal*2.0 - 1.0);
}

vec3[9] get_depth_neighbors(vec2 uv, vec2 pixel_size) {
	vec3 neighbors[9];
	for (int col = 0; col < 3; col++){
		float offset_y = float(col-1) * pixel_size.y;
		for (int row = 0; row < 3; row++) {
			float offset_x = float(row-1) * pixel_size.x;
			neighbors[col*3 + row] = normalize_normal(texture(depth_texture, uv + vec2(offset_x, offset_y)).rgb);
		}
	}
	return neighbors;
}

vec3[9] get_normal_neighbors(vec2 uv, vec2 pixel_size) {
	vec3 neighbors[9];
	for (int col = 0; col < 3; col++){
		float offset_y = float(col-1) * pixel_size.y;
		for (int row = 0; row < 3; row++) {
			float offset_x = float(row-1) * pixel_size.x;
			neighbors[col*3 + row] = normalize_normal(texture(normal_texture, uv + vec2(offset_x, offset_y)).rgb);
		}
	}
	return neighbors;
}

vec3[9] get_color_neighbors(vec2 uv, vec2 pixel_size) {
	vec3 neighbors[9];
	for (int col = 0; col < 3; col++){
		float offset_y = float(col-1) * pixel_size.y;
		for (int row = 0; row < 3; row++) {
			float offset_x = float(row-1) * pixel_size.x;
			neighbors[col*3 + row] = normalize_normal(texture(screen_texture, uv + vec2(offset_x, offset_y)).rgb);
		}
	}
	return neighbors;
}


float[9] avg_neighbors(vec3 neighbors[9]) {
	float avg_neighbors[9];
	for (int i = 0; i < 9; i++) {
		avg_neighbors[i] = (neighbors[i].r + neighbors[i].b + neighbors[i].b)/3.0;
	}
	return avg_neighbors;
}
float sobel(vec2 uv, vec2 pixel_size, float neighbors[9]) {
	float res;
	float horizontal = 0.0;
	float vertical = 0.0;
	horizontal += sobelx[0] * neighbors[0];
	horizontal += sobelx[2] * neighbors[2];
	horizontal += sobelx[3] * neighbors[3];
	horizontal += sobelx[5] * neighbors[5];
	horizontal += sobelx[6] * neighbors[6];
	horizontal += sobelx[8] * neighbors[8];

	vertical += sobely[0] * neighbors[0];
	vertical += sobely[1] * neighbors[1];
	vertical += sobely[2] * neighbors[2];
	vertical += sobely[6] * neighbors[6];
	vertical += sobely[7] * neighbors[7];
	vertical += sobely[8] * neighbors[8];

	res = sqrt((dot(horizontal, horizontal)) + abs(dot(vertical, vertical)));
	if (res > 0.2) {
		return res;
	}
	return 0.0;
}


void vertex() {
  	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = vec2(1.0/VIEWPORT_SIZE.x, 1.0/VIEWPORT_SIZE.y);
	vec4 color = texture(screen_texture, uv);
	vec3 normal = normalize_normal(texture(normal_texture, uv).rgb);
	vec4 depth = texture(depth_texture, uv);
	float depth_avg = (depth.r + depth.g + depth.b)/3.0;
	float normal_avg = (normal.r + normal.g + normal.b)/3.0;

	float normal_neighbors[9] = avg_neighbors(get_normal_neighbors(uv, pixel_size));
	float normal_outlines = sobel(uv, pixel_size, normal_neighbors);

	float depth_neighbors[9] = avg_neighbors(get_depth_neighbors(uv, pixel_size));
	float depth_outlines = sobel(uv, pixel_size, normal_neighbors);

	float color_neighbors[9] = avg_neighbors(get_color_neighbors(uv, pixel_size));
	float color_outlines = sobel(uv, pixel_size, color_neighbors);

	ALBEDO.rgb = color.rgb + 0.5*depth_outlines;

}
