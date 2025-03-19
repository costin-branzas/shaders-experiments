varying vec2 v_uv;

uniform vec2 resolution;

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 finalColor = vec3(0.75);
  finalColor = mix(white, red, v_uv.x );
  gl_FragColor = vec4(finalColor, 1.0);
}