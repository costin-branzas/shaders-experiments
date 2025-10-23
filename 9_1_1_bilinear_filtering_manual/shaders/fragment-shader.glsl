varying vec2 v_uv;

// uniform vec2 resolution;
// uniform float time;

uniform sampler2D simple4PixelTexture; // the texture we will sample from


//version done by me (Costin) just to experiment and understand what simon is doing in the video
// vec4 filteredSample(sampler2D originalTexture, vec2 coords) {
//   vec2 textureSize = vec2(2.0);
//   vec2 pixelCoords = coords * textureSize; // transform coords from 0-1 to 0-textureSize, so basically 0-2 in this case
//   vec2 base = floor(pixelCoords); // this will be, in our case, between 0-1, since our texture is 2x2 pixels (not sure about possibly having 2.0 values though)

//   // vec4 s1 = texture(originalTexture, vec2(0.6, 0.1)); // testing with hardcoded coords just to figure out how texture sampling works
//   // vec4 s1 = texture(originalTexture, coords);
//   // if (base.x == 1.0) {
//   //   base.x = 1.0 - 0.009;
//   // }
//   // if (base.x == 2.0) {
//   //   base.x = 1.0 - 0.009;
//   // }

//   // if (base.y == 1.0) {
//   //   base.y = 1.0 - 0.009;
//   //   return vec4(1.0, 0.0, 0.0, 1.0); // red to indicate error
//   // }
//   // if (base.y == 2.0) {
//   //   base.y = 1.0 - 0.009;
//   //   return vec4(1.0, 0.0, 0.0, 1.0); // red to indicate error
//   // }

//   // vec4 s1 = texture(originalTexture, base); // this produces artifacts, i'm assuming it because base can reach 1.0 (including), or even (maybe, not sure) 2.0 which is outside expected texture coords [0, 1)
//   // vec4 s1 = texture(originalTexture, base / textureSize); // this eliminates artifacts by ensuring coords are always in 0, 1 interval - not sure if 1.0 is possible here though, so this may still have artifacts on the right and top edges
//   vec4 s1 = texture(originalTexture, (base + 0.5) / textureSize); // seems to work just as above, but this basically guarantees we are sampling from the "center" of each texture pixel
//   // vec4 s1 = texture(originalTexture, (base + vec2(0.0, 0.0)) / textureSize);
  
//   return s1;
// }


//version by simon with some renamings and comments added by me (Costin) for better understanding
vec4 filteredSampleCostin(sampler2D originalTexture, vec2 coords) {
  vec2 textureSize = vec2(2.0);
  vec2 pixelCoords = coords * textureSize + 0.5; // transform coords from 0-1 to 0-textureSize, so basically 0-2 in this case and we substract 0.5 resulting in -0.5 to 1.5 range
  vec2 base = floor(pixelCoords) - 0.5; // this will be, in our case, either -1.0 or 1.0 - 0.5, so either -1.5 or 0.5

  vec4 bottomLeft = texture(originalTexture, (base + vec2(0.0, 0.0)) / textureSize); // will sample from interval (-1.5 / 2.0 = -0.75) -> (0.5 / 2.0 = 0.25); x and y: -0.75 -> 0.25
  vec4 bottomRight = texture(originalTexture, (base + vec2(1.0, 0.0)) / textureSize); // for uv.x will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); x: -0.25 -> 0.75
  vec4 topLeft = texture(originalTexture, (base + vec2(0.0, 1.0)) / textureSize); // for uv.y will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); y: -0.25 -> 0.75
  vec4 topRight = texture(originalTexture, (base + vec2(1.0, 1.0)) / textureSize); //will sample from interval (-0.5 / 2.0 = -0.25) -> (1.5 / 2.0 = 0.75); x and y: -0.25 -> 0.75
  
  // vec2 fractPartOfPixelCoords = fract(pixelCoords); // where in the "cell" are we?
  // vec2 fractPartOfPixelCoords = smoothstep(0.0, 1.0, fract(pixelCoords)); // smoothstep instead of linear interpolation
  vec2 fractPartOfPixelCoords = smoothstep(0.49, 0.51, fract(pixelCoords)); // some adjustent to smoothstep to make the transition sharper

  vec4 mixBottomValues = mix(bottomLeft, bottomRight, fractPartOfPixelCoords.x);
  vec4 mixTopValues = mix(topLeft, topRight, fractPartOfPixelCoords.x);

  vec4 mixTopAndBottomValues = mix(mixBottomValues, mixTopValues, fractPartOfPixelCoords.y);

  return mixTopAndBottomValues;
}


//original simon version
vec4 filteredSample(sampler2D target, vec2 coords) {
  vec2 texSize = vec2(2.0);
  vec2 pc = coords * texSize - 0.5;
  vec2 base = floor(pc) + 0.5;

  vec4 s1 = texture2D(target, (base + vec2(0.0, 0.0)) / texSize);
  vec4 s2 = texture2D(target, (base + vec2(1.0, 0.0)) / texSize);
  vec4 s3 = texture2D(target, (base + vec2(0.0, 1.0)) / texSize);
  vec4 s4 = texture2D(target, (base + vec2(1.0, 1.0)) / texSize);

  vec2 f = smoothstep(0.0, 1.0, fract(pc));

  vec4 px1 = mix(s1, s2, f.x);
  vec4 px2 = mix(s3, s4, f.x);
  vec4 result = mix(px1, px2, f.y);
  return result;
}


void main() {
  
  // vec4 textureSample = texture(simple4PixelTexture, v_uv);//use normal texture filtering (as defined in main.js)
  // vec4 textureSample = filteredSample(simple4PixelTexture, v_uv);
  vec4 textureSample = filteredSampleCostin(simple4PixelTexture, v_uv);
  
  // try and experiment to see if v_uv.x can reach 1.0
  // if (v_uv.x == 1.0)
  //   gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
  // else
  //   gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

  // experiment to see the value of v_uv
  // gl_FragColor = vec4(v_uv.y, 0.0, 0.0, 1.0);

  gl_FragColor = textureSample;
}