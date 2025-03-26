varying vec2 v_uv;

varying vec3 v_normal;
varying vec3 v_position;
varying vec3 v_color;

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

  float rippleAmplitude = sin(localSpacePosition.y * 20.0 + time * 10.0);
  rippleAmplitude = remap(rippleAmplitude, -1.0, 1.0, 0.0, 0.2);

  // float rippleAmplitude2 = sin(localSpacePosition.x * 25.0 - time * 10.0);
  // rippleAmplitude2 = remap(rippleAmplitude2, -1.0, 1.0, -0.0, 0.05);
  
  localSpacePosition += normal * rippleAmplitude; 
  // localSpacePosition += normal * rippleAmplitude2;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0);

  

  v_uv = uv;
  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  v_position = (modelMatrix * vec4(position, 1.0)).xyz;

  vec3 blueish = vec3(0.0, 0.0, 0.5);
  vec3 lightBlueish = vec3(0.1, 0.5, 0.8);

  v_color = mix (blueish, lightBlueish, smoothstep(0.0, 0.2, rippleAmplitude));
}