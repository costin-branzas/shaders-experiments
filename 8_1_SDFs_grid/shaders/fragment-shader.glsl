varying vec2 v_uv;

uniform vec2 resolution;

vec3 black = vec3(0.0, 0.0, 0.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 linearTosRGB(vec3 value) {
  vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308)));
  
  vec3 v1 = value * 12.92;
  vec3 v2 = pow(value.xyz, vec3(0.41666)) * 1.055 - vec3(0.055);

	return mix(v2, v1, lt);
}

vec3 backgroundColor() {
  float distFromCenter = length(abs(v_uv - 0.5));
  float vignette = 1.0 - distFromCenter;
  vignette = smoothstep(0.0, 0.7, vignette);
  vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);
  vec3 tint = vec3(0.9, 0.9, 0.8);
  return vec3(vignette);
}

vec3 drawGrid(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) {
  // 1 set of lines at a time
  // float lines = fract(v_uv.y * (resolution.y / cellSpacing)); // this gives *n lines where fract "restarts" from 0, so because we use smoothstep below, its a line with hart stop at the bottom fading towards the top
  // lines = lines - 0.5; // this offsets the lines, so now the fract will be offet by 0.5, but this will now also give negative values for half the places, meaning that the lines will actually be ative in the negative reagion so incorrectly thik lines, next line will correct that
  // lines = abs(lines); // correct the negative fracts
  // float smoothstepLines = smoothstep(0.0, lineWidth, lines);
  // color = mix(lineColor, color, smoothstepLines);

  // both sets of lines (horiz + vert)
  vec2 offset_v_uv = v_uv - 0.5;
  vec2 lines = fract(offset_v_uv * (resolution / cellSpacing)); // this gives *n lines where fract "restarts" from 0, so because we use smoothstep below, its a line with hart stop at the bottom fading towards the top
  lines = lines - 0.5; // this offsets the lines, so now the fract will be offet by 0.5, but this will now also give negative values for half the places, meaning that the lines will actually be ative in the negative reagion so incorrectly thik lines, next line will correct that
  lines = abs(lines); // correct the negative fracts

  // easy straight forward but needs each set of lines to be plotted individually
  // lines.x = (lines.x) * cellSpacing; //somehow this makes the line width be in pixels instead of screen units
  // float smoothstepLines = smoothstep(0.0, lineWidth, lines.x);
  // color = mix(lineColor, color, smoothstepLines);

  // combine both set of lines in 1 variable
  float distanceToEdge = (0.5 - max(lines.x, lines.y)) * cellSpacing; // substraction from 0.5 inverts => black where lines, white in center


  float smoothstepLines = smoothstep(0.0, lineWidth, distanceToEdge);
  color = mix(lineColor, color, smoothstepLines);

  return color;
}

vec3 drawGridSimon(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) {
  vec2 center = v_uv - 0.5;
  vec2 cells = abs(fract(center * resolution / cellSpacing) - 0.5);
  float distToEdge = (0.5 - max(cells.x, cells.y)) * cellSpacing;
  float lines = smoothstep(0.0, lineWidth, distToEdge);
  color = mix(lineColor, color, lines);
  
  return color;
}

void main() {
  vec2 pixelCoords = (v_uv - 0.5 * resolution);

  vec3 color = backgroundColor();

  // color = drawGrid(color, black, 300.0, 0.1); // line width is given in screen units
  color = drawGrid(color, vec3(0.5), 10.0, 1.0); // line width is given in pixels
  color = drawGrid(color, black, 100.0, 2.0);

  gl_FragColor = vec4(color, 1.0);
}