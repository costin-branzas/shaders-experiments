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
  
  //hard coded values for testing
  // float radius = 1.0; // sqrt to ensure uniform distribution
  // float angle = PI / 4.0; // 90 degrees angle for testing
  
  vec2 randomGradientVector = vec2(radius * cos(angle), radius * sin(angle));
  
  return randomGradientVector;
}


// uses the basic random function
// the problem with this implementation is that the random function gives only positive values, while gradient noise needs gradients that can point in any direction (positive and negative)
// vec3 gradientNoise(vec2 uv, float gridSize) {
//   vec2 gridCoords = uv * gridSize;

//   vec2 gridPosBase = floor(gridCoords);
//   vec2 gridPosDetail = fract(gridCoords);


//   vec3 bottomLeftCornerVector = random(uvec3(gridPosBase.x, gridPosBase.y, 0.0)); // in the tutorial the last value is 1.0, but honestly i dont see why it matters, it's gonna return different random values anyway, so 0.0 or 1.0 as seed value is irrelevant (i think)
//   vec3 bottomRightCornerVector = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
//   vec3 topLeftCornerVector = random(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
//   vec3 topRightCornerVector = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

//   vec3 bottomLeftToCurrentPosVector = vec3(gridPosDetail, 0.0) - bottomLeftCornerVector; // i believe i made  mistake here by subtracting the corner vectors
//   vec3 bottomRightToCurrentPosVector = vec3(gridPosDetail - vec2(1.0, 0.0), 0.0) - bottomRightCornerVector;
//   vec3 topLeftToCurrentPosVector = vec3(gridPosDetail - vec2(0.0, 1.0), 0.0) - topLeftCornerVector;
//   vec3 topRightToCurrentPosVector = vec3(gridPosDetail - vec2(1.0, 1.0), 0.0) - topRightCornerVector;

//   float bottomLeftDotProduct = dot(bottomLeftCornerVector, bottomLeftToCurrentPosVector);
//   float bottomRightDotProduct = dot(bottomRightCornerVector, bottomRightToCurrentPosVector);
//   float topLeftDotProduct = dot(topLeftCornerVector, topLeftToCurrentPosVector);
//   float topRightDotProduct = dot(topRightCornerVector, topRightToCurrentPosVector);

//   // gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

//   float bottomColour = mix(bottomLeftDotProduct, bottomRightDotProduct, gridPosDetail.x);
//   float topColour = mix(topLeftDotProduct, topRightDotProduct, gridPosDetail.x);
  
//   vec3 finalColour = vec3(mix(bottomColour, topColour, gridPosDetail.y) + 0.5);

//   return finalColour;
// }


// this uses the randomGradient function whichgives us actual gradients, unlike the random function that gives only positive values which is not correct for gradient noise
// vec3 gradientNoiseWithDebugLines(vec2 uv, float gridSize) {
//   vec2 gridCoords = uv * gridSize;

//   vec2 gridPosBase = floor(gridCoords);
//   vec2 gridPosDetail = fract(gridCoords);


//   vec2 bottomLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
//   vec2 bottomRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
//   vec2 topLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
//   vec2 topRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

//   // i think this is wrong, i don't think the subtraction part is incorrect
//   // vec3 bottomLeftToCurrentPosVector = vec3(gridPosDetail, 0.0) - bottomLeftCornerVector;
//   // vec3 bottomRightToCurrentPosVector = vec3(gridPosDetail - vec2(1.0, 0.0), 0.0) - bottomRightCornerVector;
//   // vec3 topLeftToCurrentPosVector = vec3(gridPosDetail - vec2(0.0, 1.0), 0.0) - topLeftCornerVector;
//   // vec3 topRightToCurrentPosVector = vec3(gridPosDetail - vec2(1.0, 1.0), 0.0) - topRightCornerVector;

//   vec2 bottomLeftToCurrentPosVector = gridPosDetail;
//   vec2 bottomRightToCurrentPosVector = gridPosDetail - vec2(1.0, 0.0);
//   vec2 topLeftToCurrentPosVector = gridPosDetail - vec2(0.0, 1.0);
//   vec2 topRightToCurrentPosVector = gridPosDetail - vec2(1.0, 1.0);


//   float bottomLeftDotProduct = dot(bottomLeftCornerVector, bottomLeftToCurrentPosVector);
//   float bottomRightDotProduct = dot(bottomRightCornerVector, bottomRightToCurrentPosVector);
//   float topLeftDotProduct = dot(topLeftCornerVector, topLeftToCurrentPosVector);
//   float topRightDotProduct = dot(topRightCornerVector, topRightToCurrentPosVector);

//   // gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

//   //testing individual components
//   // vec3 finalColour = vec3(bottomLeftToCurrentPosVector, 0.0); 
//   // vec3 finalColour = vec3(bottomRightToCurrentPosVector, 0.0); // red is negative, hence the next line with abs produces the expected colors
//   // vec3 finalColour = vec3(abs(bottomRightToCurrentPosVector), 0.0); 
//   // dot products output directly (black where dot is negative, hence the use of abs)
//   // vec3 finalColour = vec3(abs(bottomLeftDotProduct));
//   // vec3 finalColour = vec3(abs(topRightDotProduct)); // this mirrors the previous one because of the way the gradients are defined in the corners (ex: 45 deg from bottom left to top right)
//   // vec3 finalColour = vec3(bottomRightDotProduct);
//   // vec3 finalColour = vec3(topLeftDotProduct);

//   float bottomColour = mix(bottomLeftDotProduct, bottomRightDotProduct, gridPosDetail.x);
//   float topColour = mix(topLeftDotProduct, topRightDotProduct, gridPosDetail.x);
  


//   vec3 finalColour = vec3(mix(bottomColour, topColour, gridPosDetail.y) + 0.5);
  
//   //testing
//   // bottomColour = remap(bottomColour, -1.0, 1.0, 0.0, 1.0);
//   // finalColour = vec3(bottomColour + 0.5);
//   // finalColour = vec3(abs(topColour));
//   // finalColour = vec3(remap(finalColour.x, -1.0, 1.0, 0.0, 1.0), remap(finalColour.y, -1.0, 1.0, 0.0, 1.0), remap(finalColour.z, -1.0, 1.0, 0.0, 1.0));  
  

//   return finalColour;
// }


vec3 gradientNoise(vec2 uv, float gridSize) {
  vec2 gridCoords = uv * gridSize;

  vec2 gridPosBase = floor(gridCoords);
  vec2 gridPosDetail = fract(gridCoords);


  vec2 bottomLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
  vec2 bottomRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
  vec2 topLeftCornerVector = randomGradient(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
  vec2 topRightCornerVector = randomGradient(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

  vec2 bottomLeftToCurrentPosVector = gridPosDetail;
  vec2 bottomRightToCurrentPosVector = gridPosDetail - vec2(1.0, 0.0);
  vec2 topLeftToCurrentPosVector = gridPosDetail - vec2(0.0, 1.0);
  vec2 topRightToCurrentPosVector = gridPosDetail - vec2(1.0, 1.0);

  float bottomLeftDotProduct = dot(bottomLeftCornerVector, bottomLeftToCurrentPosVector);
  float bottomRightDotProduct = dot(bottomRightCornerVector, bottomRightToCurrentPosVector);
  float topLeftDotProduct = dot(topLeftCornerVector, topLeftToCurrentPosVector);
  float topRightDotProduct = dot(topRightCornerVector, topRightToCurrentPosVector);

  // gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

  // bottomLeftDotProduct = remap(bottomLeftDotProduct, -1.0, 1.0, 0.0, 1.0);
  // bottomRightDotProduct = remap(bottomRightDotProduct, -1.0, 1.0, 0.0, 1.0);
  // topLeftDotProduct = remap(topLeftDotProduct, -1.0, 1.0, 0.0, 1.0);
  // topRightDotProduct = remap(topRightDotProduct, -1.0, 1.0, 0.0, 1.0);

  float bottomColour = mix(bottomLeftDotProduct, bottomRightDotProduct, gridPosDetail.x);
  float topColour = mix(topLeftDotProduct, topRightDotProduct, gridPosDetail.x);

  vec3 finalColour = vec3(mix(bottomColour, topColour, gridPosDetail.y) + 0.5);

  return finalColour;
}


// vec3 fractalGradientNoise(vec2 uv, float gridSize, float octaves) {
//   vec3 composedGradientNoise = vec3(0.0);

//   float amplitude = 0.5;
//   float frequency = 1.0;

//   for (float i = 0.0; i < octaves; i += 1.0) {
//     composedGradientNoise += amplitude * gradientNoise(uv, gridSize * frequency); // grid size is basically frequency, we mutiply it to increase it, so frequency would be better called "frequency coefficient"
//     amplitude *= 0.5;
//     frequency *= 2.0;
//   }
  
//   return composedGradientNoise;
// }


void main() {
  vec3 colour = vec3(0.0, 0.0, 0.0);

  colour = gradientNoise(v_uv, 5.0); 

  gl_FragColor = vec4(colour, 1.0);
}