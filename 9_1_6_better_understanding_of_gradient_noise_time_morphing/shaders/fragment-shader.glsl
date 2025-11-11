varying vec2 v_uv;
uniform vec2 resolution;
uniform float time;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}


float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}


vec3 random(uvec3 v) {
  v = v * 1664525u + 1013904223u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  v ^= v >> 16u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  return vec3(v) * (1.0/float(0xffffffffu));
}


#define PI 3.14159265359
vec2 randomGradient(uvec3 v) {
  vec3 randomValues = random(v);
  float radius = sqrt(randomValues.x); // sqrt to ensure uniform distribution
  float angle = 2.0 * PI * randomValues.y;
  
  vec2 randomGradientVector = vec2(radius * cos(angle), radius * sin(angle));
  
  return randomGradientVector;
}


vec3 gradientNoise(vec3 gradientSeed, float gridSize) {
  
  float time = gradientSeed.z;
  vec2 gridCoords = gradientSeed.xy * gridSize;

  vec2 gridPosBase = floor(gridCoords);
  vec2 gridPosDetail = fract(gridCoords);


  vec2 bottomLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y, time));
  vec2 bottomRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y, time));
  vec2 topLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y + 1.0, time));
  vec2 topRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, time));

  vec2 bottomLeftToCurrentPosVector = gridPosDetail;
  vec2 bottomRightToCurrentPosVector = gridPosDetail - vec2(1.0, 0.0);
  vec2 topLeftToCurrentPosVector = gridPosDetail - vec2(0.0, 1.0);
  vec2 topRightToCurrentPosVector = gridPosDetail - vec2(1.0, 1.0);

  float bottomLeftDotProduct = dot(bottomLeftCornerVector, bottomLeftToCurrentPosVector);
  float bottomRightDotProduct = dot(bottomRightCornerVector, bottomRightToCurrentPosVector);
  float topLeftDotProduct = dot(topLeftCornerVector, topLeftToCurrentPosVector);
  float topRightDotProduct = dot(topRightCornerVector, topRightToCurrentPosVector);

  gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

  float bottomColour = mix(bottomLeftDotProduct, bottomRightDotProduct, gridPosDetail.x);
  float topColour = mix(topLeftDotProduct, topRightDotProduct, gridPosDetail.x);

  vec3 finalColour = vec3(mix(bottomColour, topColour, gridPosDetail.y) + 0.5);

  return finalColour;
}


vec3 fractalGradientNoise(vec3 gradientSeed, float gridSize, float octaves) {
  vec3 composedGradientNoise = vec3(0.0);

  float amplitude = 0.5;
  float frequency = 1.0;

  for (float i = 0.0; i < octaves; i += 1.0) {
    composedGradientNoise += amplitude * gradientNoise(gradientSeed, gridSize * frequency); // grid size is basically frequency, we mutiply it to increase it, so frequency would be better called "frequency coefficient"
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  
  return composedGradientNoise;
}


void main() {
  vec3 colour = vec3(0.0, 0.0, 0.0);

  vec3 gradientSeed = vec3(v_uv, time);

  colour = gradientNoise(gradientSeed, 5.0);
  // colour = fractalGradientNoise(v_uv, 5.0, 3.0);

  gl_FragColor = vec4(colour, 1.0);
}