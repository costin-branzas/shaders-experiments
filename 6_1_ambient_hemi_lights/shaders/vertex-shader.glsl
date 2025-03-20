varying vec2 v_uv;

varying vec3 v_normal;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;

  v_uv = uv;

  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
}