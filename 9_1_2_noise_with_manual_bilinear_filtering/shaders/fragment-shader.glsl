varying vec2 v_uv;

// uniform vec2 resolution;
// uniform float time;

uniform sampler2D simple4PixelTexture; // the texture we will sample from


//version by simon with some renamings and comments added by me (Costin) for better understanding
// vec4 filteredSampleCostin(sampler2D originalTexture, vec2 coords) {
//   vec2 textureSize = vec2(2.0);
//   vec2 pixelCoords = coords * textureSize +  0.5; // transform coords from 0-1 to 0-textureSize, so basically 0-2 in this case and we substract 0.5 resulting in -0.5 to 1.5 range
//   vec2 base = floor(pixelCoords) - 0.5; // this will be, in our case, either -1.0 or 1.0 - 0.5, so either -1.5 or 0.5

//   vec4 bottomLeft = texture(originalTexture, (base + vec2(0.0, 0.0)) / textureSize); // will sample from interval (-1.5 / 2.0 = -0.75) -> (0.5 / 2.0 = 0.25); x and y: -0.75 -> 0.25
//   vec4 bottomRight = texture(originalTexture, (base + vec2(1.0, 0.0)) / textureSize); // for uv.x will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); x: -0.25 -> 0.75
//   vec4 topLeft = texture(originalTexture, (base + vec2(0.0, 1.0)) / textureSize); // for uv.y will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); y: -0.25 -> 0.75
//   vec4 topRight = texture(originalTexture, (base + vec2(1.0, 1.0)) / textureSize); //will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); x and y: -0.25 -> 0.75
  
//   // vec2 fractPartOfPixelCoords = fract(pixelCoords); // where in the "cell" are we?
//   vec2 fractPartOfPixelCoords = smoothstep(0.3, 0.7, fract(pixelCoords)); // smoothstep instead of linear interpolation
//   // vec2 fractPartOfPixelCoords = smoothstep(0.49, 0.51, fract(pixelCoords)); // some adjustent to smoothstep to make the transition sharper

//   vec4 mixBottomValues = mix(bottomLeft, bottomRight, fractPartOfPixelCoords.x);
//   vec4 mixTopValues = mix(topLeft, topRight, fractPartOfPixelCoords.x);

//   vec4 mixTopAndBottomValues = mix(mixBottomValues, mixTopValues, fractPartOfPixelCoords.y);

//   return mixTopAndBottomValues;
// }


//original simon version
// vec4 filteredSample(sampler2D target, vec2 coords) {
//   vec2 texSize = vec2(2.0);
//   vec2 pc = coords * texSize - 0.5;
//   vec2 base = floor(pc) + 0.5;

//   vec4 s1 = texture2D(target, (base + vec2(0.0, 0.0)) / texSize);
//   vec4 s2 = texture2D(target, (base + vec2(1.0, 0.0)) / texSize);
//   vec4 s3 = texture2D(target, (base + vec2(0.0, 1.0)) / texSize);
//   vec4 s4 = texture2D(target, (base + vec2(1.0, 1.0)) / texSize);

//   vec2 f = smoothstep(0.0, 1.0, fract(pc));

//   vec4 px1 = mix(s1, s2, f.x);
//   vec4 px2 = mix(s3, s4, f.x);
//   vec4 result = mix(px1, px2, f.y);
//   return result;
// }


float MathRandom(vec2 p) {
  p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
  return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}


vec4 noise(vec2 coords) {
  vec2 textureSize = vec2(1.0);
  vec2 pixelCoords = coords * textureSize;
  vec2 base = floor(pixelCoords);

  float bottomLeft = MathRandom((base + vec2(0.0, 0.0)) / textureSize);
  float bottomRight = MathRandom((base + vec2(1.0, 0.0)) / textureSize);
  float topLeft = MathRandom((base + vec2(0.0, 1.0)) / textureSize);
  float topRight = MathRandom((base + vec2(1.0, 1.0)) / textureSize);
  
  // vec2 fractPartOfPixelCoords = fract(pixelCoords); // where in the "cell" are we?
  vec2 fractPartOfPixelCoords = smoothstep(0.0, 1.0, fract(pixelCoords)); // smoothstep instead of linear interpolation
  // vec2 fractPartOfPixelCoords = smoothstep(0.3, 0.7, fract(pixelCoords)); // smoothstep instead of linear interpolation
  // vec2 fractPartOfPixelCoords = smoothstep(0.49, 0.51, fract(pixelCoords)); // some adjustent to smoothstep to make the transition sharper

  float mixBottomValues = mix(bottomLeft, bottomRight, fractPartOfPixelCoords.x);
  float mixTopValues = mix(topLeft, topRight, fractPartOfPixelCoords.x);

  float mixTopAndBottomValues = mix(mixBottomValues, mixTopValues, fractPartOfPixelCoords.y);

  return vec4(vec3(mixTopAndBottomValues), 1.0);
}

vec4 noiseSimon(vec2 coords) {
  vec2 texSize = vec2(1.0);
  vec2 pc = coords * texSize;
  vec2 base = floor(pc);

  float s1 = MathRandom((base + vec2(0.0, 0.0)) / texSize);
  float s2 = MathRandom((base + vec2(1.0, 0.0)) / texSize);
  float s3 = MathRandom((base + vec2(0.0, 1.0)) / texSize);
  float s4 = MathRandom((base + vec2(1.0, 1.0)) / texSize);

  vec2 f = smoothstep(0.0, 1.0, fract(pc));

  float px1 = mix(s1, s2, f.x);
  float px2 = mix(s3, s4, f.x);
  float result = mix(px1, px2, f.y);
  return vec4(vec3(result), 1.0);
}

void main() {
  vec4 noiseSample = noise(v_uv * 20.0); 
  gl_FragColor = noiseSample;

  // vec4 colour = noiseSimon(v_uv * 20.0);
  // gl_FragColor = colour;
}