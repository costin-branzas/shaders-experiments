varying vec2 v_uv;
uniform sampler2D diffuse;

void main() {
  vec4 diffuseSample = texture(diffuse, vec2(v_uv.x, v_uv.y));
  
  //gl_FragColor = diffuseSample;
  gl_FragColor = smoothstep(vec4(0.0), vec4(1.0), diffuseSample);
}