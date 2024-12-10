varying vec2 varying_uv;

void main() {
  //gl_FragColor = vec4(varying_uv.x, varying_uv.x, varying_uv.x, 1.0);
  gl_FragColor = vec4(1.0 - varying_uv.x, 0.0, 1.0-varying_uv.y, 1.0);
}