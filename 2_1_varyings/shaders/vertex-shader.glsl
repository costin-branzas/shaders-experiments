varying vec2 varying_uv;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  //gl_Position = projectionMatrix * modelViewMatrix * localPosition; // this is a "standard" line that, as far as i can tell, ensures that the vertex remains in the same position...
  gl_Position = vec4(position*2.0, 1.0); // the 1.9 is "random", it's just something that ensures that the vertex positions ends up being on the screen
  
  varying_uv = uv;
}