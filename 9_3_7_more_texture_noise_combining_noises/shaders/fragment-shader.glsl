
varying vec2 v_uv;
uniform vec2 resolution;
uniform float time;

vec3 BLACK = vec3(0.0, 0.0, 0.0);
vec3 YELLOW = vec3(1.0, 1.0, 0.5);
vec3 BLUE = vec3(0.25, 0.25, 1.0);
vec3 RED = vec3(1.0, 0.25, 0.25);
vec3 GREEN = vec3(0.25, 1.0, 0.25);
vec3 PURPLE = vec3(1.0, 0.25, 1.0);

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

float noise(in vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);

  vec3 u = f * f * (3.0 - 2.0 * f);

  //dot product between each corner random vector (calculated via hash) and the vrector from the corner to the "current" point
  //all mixed together via trilinear (identical with bilinear, we just have 3 dimensions) interpolation
  return mix(mix(mix(dot(hash(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
                     dot(hash(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
                     dot(hash(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
             mix(mix(dot(hash(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
                     dot(hash(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
                 mix(dot(hash(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
                     dot(hash(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
}

float fbm(vec3 seed, int octaves, float persistance, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; i++) {
    float noiseValue = noise(seed * frequency);
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistance;
    frequency *= lacunarity;
  }

  total /= normalization; // normalization is basically the sum of all amplitudes used, so dividing by it ensure result ends up normalized (up to 1.0)
  return total;
}

float ridgedFbm(vec3 seed, int octaves, float persistance, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; i++) {
    float noiseValue = noise(seed * frequency);
    //the ridged part: abs and invert
    noiseValue = abs(noiseValue);
    noiseValue = 1.0 - noiseValue;

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistance;
    frequency *= lacunarity;
  }

  total /= normalization; // normalization is basically the sum of all amplitudes used, so dividing by it ensure result ends up normalized (up to 1.0)
 
  total *= total;
  return total;
}

float turbulenceFbm(vec3 seed, int octaves, float persistance, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; i++) {
    float noiseValue = noise(seed * frequency);
    //the ridged part: abs and invert
    noiseValue = abs(noiseValue);
    // noiseValue = 1.0 - noiseValue;

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistance;
    frequency *= lacunarity;
  }

  total /= normalization; // normalization is basically the sum of all amplitudes used, so dividing by it ensure result ends up normalized (up to 1.0)
 
  // total *= total;
  return total;
}


float cellularNoise(vec3 seed) {
  vec2 gridBase = floor(seed.xy);
  vec2 gridFraction = fract(seed.xy);

  float closest = 1.0;

  // iterate thorugh neighbouring cells
  for(float y = -2.0; y <= 2.0; y += 1.0) {
    for(float x = -2.0; x <= 2.0; x += 1.0) {
      vec2 neighbouringCellOffset = vec2(x, y);
      vec2 neighbouringCellAbsPos = gridBase + neighbouringCellOffset;

      // cellOffset is a bad name, it's actually the random point chosen within the cell, basically the "feature point" as known in cellular noise
      // vec2 cellOffset = vec2(
      //   noise(vec3(neighbouringCellAbsPos, seed.z) + vec3(1.1, 1.5, 2.0)),
      //   noise(vec3(neighbouringCellAbsPos, seed.z))
      // );

      // vec2 cellOffset = vec2(
      //   noise(vec3(neighbouringCellAbsPos, seed.z)),
      //   noise(vec3(neighbouringCellAbsPos, seed.z))
      // );

      // vec2 cellOffset = vec2(noise(vec3(neighbouringCellAbsPos, seed.z)), 0.5);

      vec2 cellFeaturePoint = vec2(
        noise(vec3(neighbouringCellAbsPos, seed.z)),
        noise(vec3(neighbouringCellAbsPos, seed.z) + vec3(1.1, 1.5, 2.0)) // adding something to the 2nd point to ensure that the feature points are not moving corelated (x and y should not be related)
      );

      vec2 distanceToNeighbouringCellFeaturePoint = neighbouringCellOffset + cellFeaturePoint;
      float distToNeighbour = length(distanceToNeighbouringCellFeaturePoint - gridFraction); // gridFraction is the position within the current cell
      
      closest = min(closest, distToNeighbour);
    }
  }

  //just some playing around
  // return closest * 30.0;
  // return 1.0 - closest; // invert so that close points are white, far points are black
  return closest;
}

float steppedNoise(float noiseSample) {
  float steppedSample = floor(noiseSample * 10.0) / 10.0;
  float remainder = fract(noiseSample * 10.0);
  steppedSample = (steppedSample - remainder) * 0.5 + 0.5; // this line is a bit of a mistery... this whole function seems to basically invert the gradients of color, but in "steps". there has to be a better way of doing this...
  
  return steppedSample;
}

float domainWarpingFBM(vec3 seed) {
  vec3 offset = vec3(
    fbm(seed, 4, 0.5, 2.0),
    fbm(seed + vec3(43.235, 23.112, 0.0), 4, 0.5, 2.0),
    0.0
  );
  float noiseSample = fbm(seed + offset, 1, 0.5, 2.0);

  vec3 offset2 = vec3(
    fbm(seed + 4.0 * offset + vec3(5.325, 1.421, 3.235), 4, 0.5, 2.0),
    fbm(seed + 4.0 * offset + vec3(4.32, 0.532, 6.324), 4, 0.5, 2.0),
    0.0
  );
  noiseSample = fbm(seed + 4.0 * offset2, 1, 0.5, 2.0);

  return noiseSample;
}


void main() {
  vec3 colour = vec3(0.0, 0.0, 0.0);
  float gridSize = 4.0;
  vec3 gridSeed = vec3(v_uv.x * gridSize, v_uv.y * gridSize, time * 0.2);
  
  //classic fbm
  // float noiseSample = fbm(gridSeed, 16, 0.5, 2.0); // 16 octaves, persistance 0.5 (how quickly amplitude drops off), lacunarity 2.0 (how quickly frequency increases)
  // noiseSample = remap(noiseSample, -1.0, 1.0, 0.0, 1.0);

  //ridged fbm
  // float noiseSample = ridgedFbm(gridSeed, 4, 0.5, 2.0);

  //turbulence fbm
  // float noiseSample = turbulenceFbm(gridSeed, 4, 0.5, 2.0);

  //cellular noise
  // float noiseSample = cellularNoise(gridSeed);

  //stepped noise
  // float noiseSample = noise(gridSeed);
  // noiseSample = remap(noiseSample, -1.0, 1.0, 0.0, 1.0);
  // float steppedNoiseSample = steppedNoise(noiseSample);
  // colour = vec3(steppedNoiseSample);

  //domain warping
  // float noiseSample = domainWarpingFBM(gridSeed);
  // noiseSample = remap(noiseSample, -1.0, 1.0, 0.0, 1.0);
  // colour = vec3(noiseSample);

  //basic fbm combined with stepped noise
  float noiseSample = fbm(gridSeed, 6, 0.5, 2.0);
  // noiseSample += 0.5;
  noiseSample = remap(noiseSample, -1.0, 1.0, 0.0, 1.0);
  noiseSample = steppedNoise(noiseSample);
  
  colour = vec3(noiseSample);

  gl_FragColor = vec4(colour, 1.0);
}