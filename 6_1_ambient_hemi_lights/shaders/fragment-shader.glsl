varying vec2 v_uv;

varying vec3 v_normal;

uniform vec2 resolution;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 baseColour = vec3(0.5);

  vec3 normal = normalize(v_normal);

  // Ambient
  vec3 ambientLighting = vec3(0.5);

  // Hemi lighting
  vec3 skyColour = vec3(0.0, 0.3, 0.6);
  vec3 groundColour = vec3(0.6, 0.3, 0.1);

  float normalYRemappedTo01 = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  vec3 hemiLighting = mix(groundColour, skyColour, normalYRemappedTo01);

  // Final mixing of lighting
  vec3 totalLighting = ambientLighting * 0.0 + hemiLighting;

  vec3 finalColor = baseColour * totalLighting;

  gl_FragColor = vec4(finalColor, 1.0);
}