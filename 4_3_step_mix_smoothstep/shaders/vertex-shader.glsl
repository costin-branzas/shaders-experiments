varying vec2 v_uv;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;

  v_uv = uv;
}