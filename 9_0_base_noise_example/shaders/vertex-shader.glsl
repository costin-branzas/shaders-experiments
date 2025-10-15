varying vec2 v_uv;

// varying vec3 v_normal;
// varying vec3 v_position;

uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {	
  vec3 localSpacePosition = position;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0);

  v_uv = uv;
  // v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  // v_position = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}