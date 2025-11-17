shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest_mipmap;
uniform sampler2D normal_texture : hint_normal_roughness_texture, filter_linear_mipmap;

const float sobel[3] = {
	1.0, 0.0, -1.0
};



vec3 normalize_normal(vec3 normal) {
	return normalize(normal*2.0 - 1.0);
}

float depth_sobel1(vec2 uv, vec2 pixel_size) {
	float neighbors[5];
	float res;
	float horizontal = 0.0;
	float vertical = 0.0;
	
	neighbors[0] = texture(depth_texture, uv + vec2(0, -pixel_size.y)).r;
	neighbors[1] = texture(depth_texture, uv + vec2(-pixel_size.x, 0)).r;
	neighbors[2] = texture(depth_texture, uv).r;
	neighbors[3] = texture(depth_texture, uv + vec2(pixel_size.x, 0)).r;
	neighbors[4] = texture(depth_texture, uv + vec2(0, pixel_size.y)).r;
	
	horizontal += sobel[0] * neighbors[1];
	horizontal += sobel[2] * neighbors[3];

	vertical += sobel[2] * neighbors[0];
	vertical += sobel[0] * neighbors[4];
	
	res = 100.0 * sqrt((horizontal * horizontal) + (vertical * vertical));
	
	if (res < 0.8) return 0.0;
	return res;
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

float[9] get_depth_neighbors(vec2 uv, vec2 pixel_size) {
	float neighbors[9];
	for (int col = 0; col < 3; col++){
		float offset_y = float(col-1) * pixel_size.y;
		for (int row = 0; row < 3; row++) {
			float offset_x = float(row-1) * pixel_size.x;
			neighbors[col*3 + row] = texture(depth_texture, uv + vec2(offset_x, offset_y)).r;
		}
	}
	return neighbors;
}

float outline(vec2 uv, vec2 pixel_size, float depth, float grazing) {
	float depth_neighbors[9];
	vec3 normal_neighbors[9];
	float res;
	float depth_threshold = 25.0; //25
	float normal_threshold = 4.0; //4.0
	float offset = 1.0;
	depth_neighbors = get_depth_neighbors(uv, offset * pixel_size);
	normal_neighbors = get_normal_neighbors(uv, offset * pixel_size);
	

	float sobel_depth_x = depth_neighbors[0] + 2.0 * depth_neighbors[3] + depth_neighbors[6] - depth_neighbors[2] - 2.0 * depth_neighbors[5] - depth_neighbors[8];
	float sobel_depth_y = depth_neighbors[0] + 2.0 * depth_neighbors[1] + depth_neighbors[2] - depth_neighbors[6] - 2.0 * depth_neighbors[7] - depth_neighbors[8];
	float depth_gradient = 100.0 * (abs(sobel_depth_x) + abs(sobel_depth_y));
	
	depth_threshold *= depth_neighbors[4] * (1.0 + 50.0 * grazing); // 50 * grazing
	if (depth_gradient > depth_threshold) depth_gradient = 1.0;
	else depth_gradient = 0.0;
	
	vec3 sobel_norm_x_vec = normal_neighbors[0] + 2.0 * normal_neighbors[3] + normal_neighbors[6] - normal_neighbors[2] - 2.0 * normal_neighbors[5] - normal_neighbors[8];
	vec3 sobel_norm_y_vec = normal_neighbors[0] + 2.0 * normal_neighbors[1] + normal_neighbors[2] - normal_neighbors[6] - 2.0 * normal_neighbors[7] - normal_neighbors[8];
	float normal_gradient = abs(dot(sobel_norm_x_vec, sobel_norm_x_vec)) + abs(dot(sobel_norm_y_vec, sobel_norm_y_vec));
	
	normal_threshold *= 3.0 * (1.0 - depth_neighbors[4]) * (1.0 + grazing); // worked well without "3.0 *"
	if (normal_gradient > normal_threshold) normal_gradient = 1.0;
	else normal_gradient = 0.0;
	
	res = max(depth_gradient, normal_gradient);
	return res;
}


float[9] avg_neighbors(vec3 neighbors[9]) {
	float avg_neighbors[9];
	for (int i = 0; i < 9; i++) {
		avg_neighbors[i] = (neighbors[i].r + neighbors[i].b + neighbors[i].b)/3.0;
	}
	return avg_neighbors;
}

void vertex() {
  	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = vec2(1.0/VIEWPORT_SIZE.x, 1.0/VIEWPORT_SIZE.y);
	vec4 color = texture(screen_texture, uv);
	vec4 normal = texture(normal_texture, uv);
	float depth = texture(depth_texture, uv).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	float grazing = clamp(pow(1.0 - abs(normal.z), 2), 0.0, 1.0);
	//grazing = clamp(pow(1.0 - dot(normal, view), 2), 0.0, 1.0);
	//ALBEDO.rgb = color.rgb + vec3(grazing);
	ALBEDO.rgb = color.rgb - (outline(uv, pixel_size, linear_depth, grazing));
	//ALBEDO.rgb = normal.rgb;
}
