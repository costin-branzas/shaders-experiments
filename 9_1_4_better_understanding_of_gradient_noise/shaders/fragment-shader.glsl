varying vec2 v_uv;
uniform vec2 resolution;
uniform float time;


vec3 random(uvec3 v) {
  v = v * 1664525u + 1013904223u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  v ^= v >> 16u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  return vec3(v) * (1.0/float(0xffffffffu));
}

// vec3 valueNoise(vec2 uv, float gridSize) {
//   // gridSize = 8.0; // grid size can be thought of as "frequency" because it basically tells us how many grid cells fit in 1 unit of UV space or how often the noise changes
//   vec2 gridCoords = uv * gridSize;

//   vec2 gridPosBase = floor(gridCoords);
//   vec2 gridPosDetail = fract(gridCoords);

  

//   vec3 bottomLeftCornerColour = random(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
//   vec3 bottomRightCornerColour = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
//   vec3 topLeftCornerColour = random(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
//   vec3 topRightCornerColour = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

//   gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

//   vec3 bottomColour = mix(bottomLeftCornerColour, bottomRightCornerColour, gridPosDetail.x);
//   vec3 topColour = mix(topLeftCornerColour, topRightCornerColour, gridPosDetail.x);
  
//   vec3 finalColour = mix(bottomColour, topColour, gridPosDetail.y);

//   return finalColour;
// }


// vec3 fractalValueNoise(vec2 uv, float gridSize, float octaves) {
//   vec3 composedValueNoise = vec3(0.0);

//   float amplitude = 0.5;
//   float frequency = 1.0;

//   for (float i = 0.0; i < octaves; i += 1.0) {
//     composedValueNoise += amplitude * valueNoise(uv, gridSize * frequency); // grid size is basically frequency, we mutiply it to increase it, so frequency would be better called "frequency coefficient"
//     amplitude *= 0.5;
//     frequency *= 2.0;
//   }
  
//   return composedValueNoise;
// }


vec3 gradientNoise(vec2 uv, float gridSize) {
  // gridSize = 8.0; // grid size can be thought of as "frequency" because it basically tells us how many grid cells fit in 1 unit of UV space or how often the noise changes
  vec2 gridCoords = uv * gridSize;

  vec2 gridPosBase = floor(gridCoords);
  vec2 gridPosDetail = fract(gridCoords);

  // vec3 bottomLeftCornerColour = random(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
  // vec3 bottomRightCornerColour = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
  // vec3 topLeftCornerColour = random(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
  // vec3 topRightCornerColour = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

  vec3 bottomLeftCornerVector = random(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
  vec3 bottomRightCornerVector = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
  vec3 topLeftCornerVector = random(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
  vec3 topRightCornerVector = random(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

  vec3 bottomLeftToCurrentPos = vec3(gridPosDetail, 0.0) - bottomLeftCornerVector;
  vec3 bottomRightToCurrentPos = vec3(gridPosDetail - vec2(1.0, 0.0), 0.0) - bottomRightCornerVector;
  vec3 topLeftToCurrentPos = vec3(gridPosDetail - vec2(0.0, 1.0), 0.0) - topLeftCornerVector;
  vec3 topRightToCurrentPos = vec3(gridPosDetail - vec2(1.0, 1.0), 0.0) - topRightCornerVector;

  


  // gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

  vec3 bottomColour = mix(bottomLeftCornerVector, bottomRightCornerVector, gridPosDetail.x);
  vec3 topColour = mix(topLeftCornerVector, topRightCornerVector, gridPosDetail.x);
  
  vec3 finalColour = mix(bottomColour, topColour, gridPosDetail.y);

  return finalColour;
}


vec3 fractalGradientNoise(vec2 uv, float gridSize, float octaves) {
  vec3 composedGradientNoise = vec3(0.0);

  float amplitude = 0.5;
  float frequency = 1.0;

  for (float i = 0.0; i < octaves; i += 1.0) {
    composedGradientNoise += amplitude * gradientNoise(uv, gridSize * frequency); // grid size is basically frequency, we mutiply it to increase it, so frequency would be better called "frequency coefficient"
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  
  return composedGradientNoise;
}


void main() {
  vec3 colour = vec3(0.0, 0.0, 0.0);
  
  // colour = valueNoise(v_uv, 8.0);
  // colour = valueNoise(v_uv + time * 0.1, 8.0); // animated noise - the pos shifts with time

  // colour = fractalValueNoise(v_uv, 1.0, 8.0);
  // colour = fractalValueNoise(v_uv, 4.0, 1.0);

  colour = gradientNoise(v_uv, 3.0); // animated noise - the pos shifts with time

  gl_FragColor = vec4(colour, 1.0);
}