shader_type spatial;
render_mode world_vertex_coords;
uniform float RED : hint_range(0.1,0.8) = 0.2;
uniform float BLUE : hint_range(0.1,0.8) = 0.2;
uniform float GREEN : hint_range(0.1,0.8) = 0.2;
varying vec3 wor;

float opacity_calc(float a, float b, float c) {
	float to_b = ceil(abs(a) - abs(b)) * 0.5;
	float to_c = ceil(abs(a) - abs(c)) * 0.5;
	return 1.0 - trunc(to_b + to_c);
}

vec3 bottom_vec3(vec3 vect, float bottom) {
	vect.x = max(vect.x, bottom);
	vect.y = max(vect.y, bottom);
	vect.z = max(vect.z, bottom);
	return vect;
}
vec3 ceil_vec3(vec3 vect) {
	vect.x = ceil(vect.x);
	vect.y = ceil(vect.y);
	vect.z = ceil(vect.z);
	return vect;
}

void vertex() {
	wor = VERTEX;
}

void fragment() {
	vec4 _n = vec4(NORMAL,1.0) * VIEW_MATRIX;
	vec3 n_opacities = vec3(0.0);
	n_opacities.x = opacity_calc(_n.x, _n.y, _n.z);
	n_opacities.y = opacity_calc(_n.y, _n.x, _n.z);
	n_opacities.z = opacity_calc(_n.z, _n.x, _n.y);
	vec3 big_boxes = bottom_vec3(vec3(0.03) - mod(wor, 2.0), 0.0);
	vec3 small_boxes = bottom_vec3(vec3(0.01) - mod(wor, 0.5), 0.0);
	vec3 grid = ceil_vec3(big_boxes + small_boxes) * n_opacities;
	ALBEDO = vec3(RED,BLUE,GREEN);
	if(bool(grid.x+grid.y+grid.z)){
		ALBEDO = vec3(max(max(ALBEDO.x,ALBEDO.y),ALBEDO.z) + 0.2);
	}
}
