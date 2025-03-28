varying vec2 v_uv;

varying vec3 v_normal;
varying vec3 v_position;

uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

float easeOutBounce(float x) {
  const float n1 = 7.5625;
  const float d1 = 2.75;

  if(x < 1.0 / d1) {
    return n1 * x * x;
  } else if (x < 2.0 / d1) {
    x -= 1.5 / d1;
    return n1 * x * x + 0.75;
  } else if (x < 2.5 / d1) {
    x-=2.25 / d1;
    return n1 * x * x + 0.9375;
  } else {
    x -= 2.625 / d1;
    return n1 * x * x + 0.984375;
  }
}

float easeInBounce(float x) {
  return 1.0 - easeOutBounce(1.0 - x);
}

float easeInOutBounce(float x) {
  return x < 0.5
    ? (1.0 - easeOutBounce(1.0 - 2.0 * x)) / 2.0
    : (1.0 + easeOutBounce(2.0 * x - 1.0)) / 2.0;
}

void main() {	
  vec3 localSpacePosition = position;

  localSpacePosition *= easeOutBounce(clamp(time-1.0, 0.0, 1.0));

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0);

  

  v_uv = uv;
  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  v_position = (modelMatrix * vec4(position, 1.0)).xyz;
}