varying vec2 v_uv;

uniform vec2 resolution;
uniform float time;

// vec3 black = vec3(0.0, 0.0, 0.0);
// vec3 white = vec3(1.0, 1.0, 1.0);
// vec3 red = vec3(1.0, 0.0, 0.0);
// vec3 blue = vec3(0.0, 0.0, 1.0);
// vec3 yellow = vec3(1.0, 1.0, 0.0);

// float inverseLerp(float v, float minValue, float maxValue) {
//   return (v - minValue) / (maxValue - minValue);
// }

// float remap(float v, float inMin, float inMax, float outMin, float outMax) {
//   float t = inverseLerp(v, inMin, inMax);
//   return mix(outMin, outMax, t);
// }

// vec3 linearTosRGB(vec3 value) {
//   vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308)));
  
//   vec3 v1 = value * 12.92;
//   vec3 v2 = pow(value.xyz, vec3(0.41666)) * 1.055 - vec3(0.055);

// 	return mix(v2, v1, lt);
// }

float MathRandom(vec2 p) {
  p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
  return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}

float noise(in vec2 p)
{
  vec2 posFloorValue = floor(p); // this basically "id"s the grid cell
  vec2 posFractValue = fract(p); // this is the position inside the grid cell, i think it is 0,0 in the top left corner, 1, 1 in the bottom right corner, used for interpolation

  // posFractValue = posFractValue; // this implements linear interpolation - the value used in mixing is basically just the position in the cell
  posFractValue = smoothstep(0.0, 1.0, posFractValue); // this implements smoothstep interpolation

  // posFractValue = posFractValue * posFractValue * (3.0 - 2.0 * posFractValue); // this implements smoothstep interpolation (a more efficient version of it, kinda hardcoded)
  
  //disable interpolation just to show that the floor and fract values are used as constant values for each grid "cell", then interpolation is done between those cells
  // return mix(mix( MathRandom(posFloorValue + vec2(0.0, 0.0)), MathRandom(posFloorValue + vec2(1.0, 0.0)), 0.0),
  //            mix( MathRandom(posFloorValue + vec2(0.0, 1.0)), MathRandom(posFloorValue + vec2(1.0, 1.0)), 0.0), 
  //            0.0);

  // this implement bilinear interpolation between the 4 corners of the grid cell
  return mix(mix( MathRandom(posFloorValue + vec2(0.0, 0.0)), MathRandom(posFloorValue + vec2(1.0, 0.0)), posFractValue.x),
             mix( MathRandom(posFloorValue + vec2(0.0, 1.0)), MathRandom(posFloorValue + vec2(1.0, 1.0)), posFractValue.x), 
             posFractValue.y);
  
  

}

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution;
  // vec2 pixelCoords = (v_uv) * resolution;

  // vec3 color = vec3(MathRandom(pixelCoords / 100.0));
  // vec3 color = vec3(MathRandom(floor(pixelCoords / 100.0)));
  vec3 color = vec3(noise(pixelCoords / 100.0));

  gl_FragColor = vec4(color, 1.0);
}