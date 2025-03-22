varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_position;
varying vec4 v_colour;

uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

mat3 rotateY(float radians) {
  float s = sin(radians);
  float c = cos(radians);

  return mat3(
    c, 0.0, s,
    0.0, 1.0, 0.0,
    -s, 0.0, c
  );
}

void main() {	
  vec3 localSpacePosition = position; //local space is the space relative to the object

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // translates from local space to clip space

  v_uv = uv;
  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  v_position = (modelMatrix * vec4(position, 1.0)).xyz;

  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  float t = remap(v_position.x, -0.5, 0.5, 0.0, 1.0);
  t = pow(t, 2.0);

  v_colour = vec4(mix(red, blue, t), t);
}