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
vec3 randomGradient(uvec3 v) {
  vec3 randomValues = random(v);
  float radius = sqrt(randomValues.x); // sqrt to ensure uniform distribution
  float angle = 2.0 * PI * randomValues.y;
  
  float x = radius * cos(angle);
  float y = radius * sin(angle);
  float z = randomValues.z * 2.0 - 1.0; // a bit of a hack to get a z component
  
  return vec3(x, y, z);
}


vec3 gradientNoise(vec3 gradientSeed, float gridSize) {
  
  vec3 gridCoords = vec3(gradientSeed.xy * gridSize, gradientSeed.z); // only scale x and y, z represents time here, no need to scale it here

  vec3 gridPosBase = floor(gridCoords);
  vec3 gridPosDetail = fract(gridCoords);


  vec3 near1 = randomGradient(uvec3(gridPosBase.x, gridPosBase.y, gridPosBase.z));
  vec3 near2 = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y, gridPosBase.z));
  vec3 near3 = randomGradient(uvec3(gridPosBase.x, gridPosBase.y + 1.0, gridPosBase.z));
  vec3 near4 = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, gridPosBase.z));
  
  vec3 far1 = randomGradient(uvec3(gridPosBase.x, gridPosBase.y, gridPosBase.z + 1.0));
  vec3 far2 = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y, gridPosBase.z + 1.0));
  vec3 far3 = randomGradient(uvec3(gridPosBase.x, gridPosBase.y + 1.0, gridPosBase.z + 1.0));
  vec3 far4 = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, gridPosBase.z + 1.0));


  vec3 near1ToCurrentPos = gridPosDetail - vec3(0.0, 0.0, 0.0);
  vec3 near2ToCurrentPos = gridPosDetail - vec3(1.0, 0.0, 0.0);
  vec3 near3ToCurrentPos = gridPosDetail - vec3(0.0, 1.0, 0.0);
  vec3 near4ToCurrentPos = gridPosDetail - vec3(1.0, 1.0, 0.0);

  vec3 far1ToCurrentPos = gridPosDetail - vec3(0.0, 0.0, 1.0);
  vec3 far2ToCurrentPos = gridPosDetail - vec3(1.0, 0.0, 1.0);
  vec3 far3ToCurrentPos = gridPosDetail - vec3(0.0, 1.0, 1.0);
  vec3 far4ToCurrentPos = gridPosDetail - vec3(1.0, 1.0, 1.0);


  float dotNear1 = dot(near1, near1ToCurrentPos);
  float dotNear2 = dot(near2, near2ToCurrentPos);
  float dotNear3 = dot(near3, near3ToCurrentPos);
  float dotNear4 = dot(near4, near4ToCurrentPos);
  float dotFar1 = dot(far1, far1ToCurrentPos);
  float dotFar2 = dot(far2, far2ToCurrentPos);
  float dotFar3 = dot(far3, far3ToCurrentPos);
  float dotFar4 = dot(far4, far4ToCurrentPos);

  // gridPosDetail = gridPosDetail * gridPosDetail * (3.0 - 2.0 * gridPosDetail);
  gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

  float nearBottom = mix(dotNear1, dotNear2, gridPosDetail.x);
  float nearTop = mix(dotNear3, dotNear4, gridPosDetail.x);
  float farBottom = mix(dotFar1, dotFar2, gridPosDetail.x);
  float farTop = mix(dotFar3, dotFar4, gridPosDetail.x);
  
  float near = mix(nearBottom, nearTop, gridPosDetail.y);
  float far = mix(farBottom, farTop, gridPosDetail.y);

  float finalValue = mix(near, far, gridPosDetail.z);

  finalValue = remap(finalValue, -0.5, 0.5, 0.0, 1.0);
  finalValue = smoothstep(0.4, 0.41, finalValue);

  vec3 finalColour = vec3(finalValue);

  return finalColour;
}


vec3 fractalGradientNoise(vec3 gradientSeed, float gridSize, float octaves) {
  vec3 composedGradientNoise = vec3(0.0);

  float amplitude = 1.0;
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

  vec3 gradientSeed = vec3(v_uv, time * 0.5);

  // colour = gradientNoise(gradientSeed, 5.0);
  colour = fractalGradientNoise(gradientSeed, 10.0, 1.0);

  gl_FragColor = vec4(colour, 1.0);
}