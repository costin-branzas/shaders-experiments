varying vec2 varying_uv;

uniform vec4 color1;
uniform vec4 color2;

varying vec3 varying_costinColors;

void main() {
  // gl_FragColor = vec4(1.0 - varying_uv.x, 0.0 + varying_uv.x, 0.0, 1);
  
  // gl_FragColor = mix(
  //   color1,
  //   color2,
  //   varying_uv.x
  // );

  gl_FragColor = vec4(varying_costinColors, 1.0);
}