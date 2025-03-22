varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_position;

void main() {	
  vec3 localSpacePosition = position;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // translates from local space to clip space

  v_uv = uv;
  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  v_position = (modelMatrix * vec4(position, 1.0)).xyz;
}