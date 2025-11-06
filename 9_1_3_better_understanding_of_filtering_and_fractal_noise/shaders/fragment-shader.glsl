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

vec3 hash(vec3 p) {
  p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
           dot(p, vec3(269.5, 183.3, 246.1)),
           dot(p, vec3(113.5, 271.9, 124.6)));

  return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float randomSimon(vec2 p) {
  p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
  return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}

vec3 randomYouTube(uvec3 v) {
  v = v * 1664525u + 1013904223u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  v ^= v >> 16u;
  v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
  return vec3(v) * (1.0/float(0xffffffffu));
}

vec3 valueNoise(vec2 uv, float gridSize) {
  // gridSize = 8.0; // grid size can be thought of as "frequency" because it basically tells us how many grid cells fit in 1 unit of UV space or how often the noise changes
  vec2 gridCoords = uv * gridSize;

  vec2 gridPosBase = floor(gridCoords);
  vec2 gridPosDetail = fract(gridCoords);

  

  vec3 bottomLeftCornerColour = randomYouTube(uvec3(gridPosBase.x, gridPosBase.y, 0.0));
  vec3 bottomRightCornerColour = randomYouTube(uvec3(gridPosBase.x + 1.0, gridPosBase.y, 0.0));
  vec3 topLeftCornerColour = randomYouTube(uvec3(gridPosBase.x, gridPosBase.y + 1.0, 0.0));
  vec3 topRightCornerColour = randomYouTube(uvec3(gridPosBase.x + 1.0, gridPosBase.y + 1.0, 0.0));

  gridPosDetail = smoothstep(0.0, 1.0, gridPosDetail);

  vec3 bottomColour = mix(bottomLeftCornerColour, bottomRightCornerColour, gridPosDetail.x);
  vec3 topColour = mix(topLeftCornerColour, topRightCornerColour, gridPosDetail.x);
  
  vec3 finalColour = mix(bottomColour, topColour, gridPosDetail.y);

  return finalColour;
}


vec3 fractalValueNoise(vec2 uv, float gridSize, float octaves) {
  vec3 composedValueNoise = vec3(0.0);

  float amplitude = 0.5;
  float frequency = 1.0;

  for (float i = 0.0; i < octaves; i += 1.0) {
    composedValueNoise += amplitude * valueNoise(uv, gridSize * frequency); // grid size is basically frequency, we mutiply it to increase it, so frequency would be better called "frequency coefficient"
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  

  return composedValueNoise;
}



void main() {
  vec3 colour = vec3(0.0, 0.0, 0.0);
  
  // colour = randomYouTube(a); // noise at pixel level


  // colour = valueNoise(v_uv, 8.0);
  // colour = valueNoise(v_uv + time * 0.1, 8.0); // animated noise - the pos shifts with time

  colour = fractalValueNoise(v_uv, 4.0, 10.0);


  gl_FragColor = vec4(colour, 1.0);
}