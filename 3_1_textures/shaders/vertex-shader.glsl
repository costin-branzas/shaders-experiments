varying vec2 varying_uv;

void main() {	
  vec4 localPosition = vec4(position, 1.0);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;

  //does not invert
  varying_uv = uv; 

  //inverts the texture vert + horiz
  //varying_uv.x = 1.0 - uv.x;
  //varying_uv.y = 1.0 - uv.y;
}