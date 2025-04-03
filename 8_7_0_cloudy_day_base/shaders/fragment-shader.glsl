varying vec2 v_uv;

uniform vec2 resolution;
uniform float time;

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

float sdfCircle(vec2 p, float r) {
  return length(p) - r;
}

float opUnion(float d1, float d2) {
  return min(d1, d2);
}

float opSubtraction(float d1, float d2) {
  return max(-d1, d2);
}

float opIntersection(float d1, float d2) {
  return max(d1, d2);
}

mat2 rotate2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat2(
    c, -s, 
    s, c);
}

vec3 drawBackground() {
  vec3 blue1 = vec3(0.42, 0.58, 0.75);
  vec3 blue2 = vec3(0.36, 0.46, 0.82);
  // vec3 background = mix(blue1, blue2, smoothstep(0.0, 1.0, v_uv.x * v_uv.y));
  vec3 background = mix(blue1, blue2, smoothstep(0.0, 1.0, pow(v_uv.x * v_uv.y, 0.5)));
  return background;
}

float sdfCloud(vec2 pixelCoords) {
  float puff1 = sdfCircle(pixelCoords, 100.0);
  float puff2 = sdfCircle(pixelCoords - vec2(120, -10.0), 75.0);
  float puff3 = sdfCircle(pixelCoords + vec2(120.0, 10.0), 75.0);

  float cloud = min(puff1, puff2);
  cloud = min(cloud, puff3);
  return cloud;
}

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution;

  vec3 color = drawBackground();

  float cloudShadow = sdfCloud(pixelCoords + vec2(50.0));
  color = mix(color, black, 0.5 * smoothstep(0.0, -1.0, cloudShadow));


  float cloud = sdfCloud(pixelCoords - vec2(0.0, 0.0));
  color = mix(white, color, smoothstep(0.0, 1.0, cloud));
  

  // color = pow(color, vec3(1.0 / 2.2)); //approximation

  gl_FragColor = vec4(color, 1.0);
}