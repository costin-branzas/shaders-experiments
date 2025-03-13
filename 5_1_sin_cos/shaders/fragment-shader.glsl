varying vec2 v_uv;

uniform vec2 resolution;

uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float normalizedV = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, normalizedV);
}

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 finalColor = vec3(0.0);

  // float value = sin(time);
  // value = remap(value, -1.0, 1.0, 0.0, 1.0);
  // vec3 finalColor = mix(red, blue, value);

  //horizontal bars
  // float value = v_uv.y * 100.0;
  // value = sin(value);
  // finalColor = vec3(value);

  //checkboard pattern
  // float value1 = v_uv.y * 100.0;
  // value1 = sin(value1);
  
  // float value2 = v_uv.x * 100.0;
  // value2 = sin(value2);

  // finalColor = vec3(value1 * value2);


  //scrolling bars
  float value = v_uv.y * 100.0;
  value = sin(value + time * 12.0);

  float value2 = v_uv.y * 10.0;
  value2 = sin(value2 - time * 2.0);

  finalColor = vec3(value * value2);
  
  gl_FragColor = vec4(finalColor, 1.0);
}