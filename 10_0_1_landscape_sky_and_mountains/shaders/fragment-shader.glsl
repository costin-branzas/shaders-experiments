
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


vec3 GenerateSky() {
  vec3 color1 = vec3(0.4, 0.6, 0.9);
  vec3 color2 = vec3(0.1, 0.15, 1.4);

  vec3 skyColour = mix(color1, color2, smoothstep(0.875, 1.0, v_uv.y));

  return skyColour;
}

vec3 DrawMountains(vec3 background, vec3 mountainColour, vec2 pixelCoords, float depth) {
  // just to ilustrate the magic numbers - because sin is expecting rads as input, and returning [-1,1], we divide horiz pixel coord by horiz resolution to get [-1, 1]  values, then mutiply by 2 pi to basically get the entire range of radians (0 - 2pi)
  // float mountainLine = sin(pixelCoords.x / resolution.x * 6.28); // here y is the height of the mountain at this x position
  // mountainLine *= resolution.y / 2.0; // the result of sin is in [-1, 1] range, so we mutiply by resolution to make sure we actually see something (the divide by 2 is needed because we are offset from the bottom left... i think)

  // simple version with actual numbers so that output looks good - using sin
  // float mountainLine = sin(pixelCoords.x / 64.0); // wave frequency / how many radians we cover
  // mountainLine *= 64.0; // how high

  // using fbm instead of sin
  //adding depth to x, to basically have a different seed for each of the mountains depending on the depth of the mountain chain...
  vec3 fbmSeed = vec3(depth + pixelCoords.x / 256.0, 1.432, 3.643); // 1st param is basically the frequency along the x axis - lower number means more rough terrain, higher is smoother, other 2 params are just noise seeds, can be random (but they are basically the same as x - frequencies but in the y and z directions)
  float mountainLine = fbm(fbmSeed, 6, 0.5, 2.0);
  mountainLine *= 256.0; // how high

  //fog
  vec3 fogColour = vec3(0.4, 0.6, 0.9); // this is the same colour used for the sky - lower to the horizon
  // float fogFactor = depth * 0.00005; // retarded verison
  float fogFactor = smoothstep(0.0, 8000.0, depth) * 0.5; // better verison - with smoothstep, but to be honest, it's just a matter of fidling with the numbers, the above version can work just as well...
  

  //fog at the base of the mountains
  float heightFactor = smoothstep(256.0, -512.0, pixelCoords.y);
  heightFactor *= heightFactor;
  fogFactor = mix(heightFactor, fogFactor, fogFactor);
  
  // final fog
  mountainColour = mix(mountainColour, fogColour, fogFactor);

  float sdfMountain = pixelCoords.y - mountainLine; // signed distance from the mountain surface (the sine wave basically)
  
  float blur = 1.0; // this blurs all mountains equally
  blur += smoothstep(500.0, 6000.0, depth) * 128.0; // blurs mountains starting from distance 200 (close mountains will basically have NO blur - we need to add that separately)
  
  blur += smoothstep(500.0, -500.0, depth) * 128.0;
  
  vec3 colour = mix(mountainColour, background, smoothstep(0.0, blur, sdfMountain));

  return colour;
}


void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  vec3 colour = vec3(0.0, 0.0, 0.0);
   
  colour = GenerateSky();

  vec2 timeOffset = vec2(time * 50.0, 0.0);

  vec2 mountainCoords = (pixelCoords - vec2(0.0, 400.0)) * 8.0 + timeOffset; //subtracting 400 moves the SDF up, mutiplying by 8 basically increases floor points in the noise (noise grid frequency)
  colour = DrawMountains(colour, vec3(0.5), mountainCoords, 6000.0);

  mountainCoords = (pixelCoords - vec2(0.0, 360.0)) * 4.0 + timeOffset;
  colour = DrawMountains(colour, vec3(0.45), mountainCoords, 3200.0);

  mountainCoords = (pixelCoords - vec2(0.0, 280.0)) * 2.0 + timeOffset;
  colour = DrawMountains(colour, vec3(0.4), mountainCoords, 1600.0);

  mountainCoords = (pixelCoords - vec2(0.0, 150.0)) * 1.0 + timeOffset;
  colour = DrawMountains(colour, vec3(0.35), mountainCoords, 800.0);

  mountainCoords = (pixelCoords - vec2(0.0, -100.0)) * 0.5 + timeOffset;
  colour = DrawMountains(colour, vec3(0.3), mountainCoords, 400.0);

  mountainCoords = (pixelCoords - vec2(0.0, -500.0)) * 0.25 + timeOffset;
  colour = DrawMountains(colour, vec3(0.25), mountainCoords, 200.0);

  // for some reason, this mountain chain is not visible, probably something in the way te camera or pixels or whatever are set up in main.js
  mountainCoords = (pixelCoords - vec2(0.0, -1400.0)) * 0.125 + timeOffset;
  colour = DrawMountains(colour, vec3(0.2), mountainCoords, 0.0);

  

  gl_FragColor = vec4(colour, 1.0);
}