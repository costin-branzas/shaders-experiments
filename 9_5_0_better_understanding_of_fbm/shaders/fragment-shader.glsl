
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

float fbmNoSmoothstep(vec3 seed, int octaves, float persistance, float lacunarity) {
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
  
  //regardin the smoothstep, i think i understand what it's doing: 
  //the noise function returns values in the range -1 to 1. 
  //By applying smoothstep(-1.0, 1.0, total), we effectively clamp the output to the range [0, 1] while also smoothing the transition at the edges.
  //meaning that we should get almost the same efect if we simply remap (linearly), it will move the values towards 0-1 but it will not make transitions as smooth, the noise will be more "rough" i think - see fbm2 to check it's output

  // hmmm - uplon plotting them, it actually seems that the smoothstep is actually emphasizing the graph, which thinking about it DOES make sense, because it basically moves values towards the edges so the graph actually becomes more agressive, hopefully now i've understood it...

  // total = smoothstep(-1.0, 1.0, total);
  return total;
}

float fbmSmoothstep(vec3 seed, int octaves, float persistance, float lacunarity) {
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
  
  //regardin the smoothstep, see explanation in fbm function above (fbmNoSmoothstep): 
  total = smoothstep(-1.0, 1.0, total);
  return total;
}

float fbmRemap(vec3 seed, int octaves, float persistance, float lacunarity) {
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
  
  //regardin the smoothstep, see explanation in fbm function above (fbmNoSmoothstep): 
  // total = smoothstep(-1.0, 1.0, total);
  total = remap(total, -1.0, 1.0, 0.0, 1.0);
  return total;
}


vec3 AddBackground(vec3 originalColour, vec3 backgroundColour) {
  return mix(originalColour, backgroundColour, 1.0);
}


vec3 AddGrid(vec2 pixelCoords, vec3 originalColour, vec3 gridColour, float gridSize, float lineWidth) {
  vec2 cellBase = floor(pixelCoords / gridSize);
  vec2 cellCoords = fract(pixelCoords / gridSize);
  
  // (cellCoords / gridSize) * lineWidth;
  // float lineWidthNormalized = 0.01;
  float lineWidthNormalized = (1.0 / gridSize) * lineWidth;
  vec2 distanceToGrid = smoothstep(0.5 - (lineWidthNormalized), 0.5, abs(cellCoords - 0.5));

  float distanceToGridMax= max(distanceToGrid.x, distanceToGrid.y);
  
  vec3 colour = mix(originalColour, gridColour, distanceToGridMax);

  return colour;
}


vec3 AddSinFunction(vec2 pixelCoords, vec3 originalColour, vec3 plotColour, float plotThickness) {
  float y = sin(pixelCoords.x * 30.0 / resolution.x); // 0-1, increase the x coord so we see more along the x axis
  // y = smoothstep(-1.0, 1.0, y); // i see how smoothstep works - it moves more of the values towards the edges, makes sense given that it needs to "smooth" transitions towards these edges
  // y = remap(y, -1.0, 1.0, 0.0, 1.0);
  //map to vertical resoltion
  y *= resolution.y / 2.0 * 0.5;

  float distanceToY = abs(pixelCoords.y - y);

  float distanceToPlot = smoothstep(plotThickness, 0.0, distanceToY);

  vec3 colour = mix(originalColour, plotColour, distanceToPlot);

  return colour;
}


vec3 AddCosFunction(vec2 pixelCoords, vec3 originalColour, vec3 plotColour, float plotThickness) {
  float y = cos(pixelCoords.x * 30.0 / resolution.x); // 0-1, increase the x coord so we see more along the x axis
  //map to vertical resoltion
  y *= resolution.y / 2.0 * 0.5;

  float distanceToY = abs(pixelCoords.y - y);

  float distanceToPlot = smoothstep(plotThickness, 0.0, distanceToY);

  vec3 colour = mix(originalColour, plotColour, distanceToPlot);

  return colour;
}

vec3 AddFbmNoSmoothstepFunction(vec2 pixelCoords, vec3 originalColour, vec3 plotColour, float plotThickness) {
  float y = fbmNoSmoothstep(vec3(pixelCoords.x / 50.0, pixelCoords.y / 1000.0, 0.2), 1, 0.5, 2.0);
  //map to vertical resoltion
  y *= resolution.y / 2.0 * 0.5;

  float distanceToY = abs(pixelCoords.y - y);

  float distanceToPlot = smoothstep(plotThickness, 0.0, distanceToY);

  vec3 colour = mix(originalColour, plotColour, distanceToPlot);

  return colour;
}


vec3 AddFbmSmoothstepFunction(vec2 pixelCoords, vec3 originalColour, vec3 plotColour, float plotThickness) {
  float y = fbmSmoothstep(vec3(pixelCoords.x / 50.0, pixelCoords.y / 1000.0, 0.2), 1, 0.5, 2.0);
  //map to vertical resoltion
  y *= resolution.y / 2.0 * 0.5;

  float distanceToY = abs(pixelCoords.y - y);

  float distanceToPlot = smoothstep(plotThickness, 0.0, distanceToY);

  vec3 colour = mix(originalColour, plotColour, distanceToPlot);

  return colour;
}

vec3 AddFbmRemapFunction(vec2 pixelCoords, vec3 originalColour, vec3 plotColour, float plotThickness) {
  float y = fbmRemap(vec3(pixelCoords.x / 50.0, pixelCoords.y / 1000.0, 0.2), 1, 0.5, 2.0);
  //map to vertical resoltion
  y *= resolution.y / 2.0 * 0.5;

  float distanceToY = abs(pixelCoords.y - y);

  float distanceToPlot = smoothstep(plotThickness, 0.0, distanceToY);

  vec3 colour = mix(originalColour, plotColour, distanceToPlot);

  return colour;
}


void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  vec3 colour = vec3(0.0, 0.0, 0.0);

  colour = AddBackground(colour, vec3(0.8));

  colour = AddGrid(pixelCoords, colour, vec3(0.7), 10.0, 1.0); //fine grid
  colour = AddGrid(pixelCoords, colour, vec3(0.1), 50.0, 1.0); // coarse grid

  colour = AddGrid(pixelCoords, colour, vec3(1.0, 0.0, 0.0), max(resolution.x, resolution.y), 1.0);

  // sin and cos just for warm up before fbm stuff
  colour = AddSinFunction(pixelCoords, colour, vec3(0.0, 0.0, 1.0), 5.0);
  
  // colour = AddCosFunction(pixelCoords, colour, vec3(0.0, 1.0, 1.0), 5.0);
  
  
  // fukin about with fbm
  // colour = AddFbmNoSmoothstepFunction(pixelCoords, colour, vec3(1.0, 0.0, 0.0), 3.0);
  
  // colour = AddFbmSmoothstepFunction(pixelCoords, colour, vec3(0.0, 1.0, 0.0), 3.0);
  
  // colour = AddFbmRemapFunction(pixelCoords, colour, vec3(0.0, 0.0, 1.0), 3.0);

  gl_FragColor = vec4(colour, 1.0);
}