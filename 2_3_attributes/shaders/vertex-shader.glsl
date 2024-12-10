varying vec2 varying_uv;

attribute vec3 costinColors;
varying vec3 varying_costinColors;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;

  varying_uv = uv;
  varying_costinColors = costinColors;
}