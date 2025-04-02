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

vec3 backgroundColor() {
  float distFromCenter = length(abs(v_uv - 0.5));
  float vignette = 1.0 - distFromCenter;
  vignette = smoothstep(0.0, 0.7, vignette);
  vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);
  vec3 tint = vec3(0.9, 0.9, 0.8);
  return vec3(vignette);
}

vec3 drawGrid(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) {
  vec2 offset_v_uv = v_uv - 0.5;
  vec2 lines = fract(offset_v_uv * (resolution / cellSpacing)); // this gives *n lines where fract "restarts" from 0, so because we use smoothstep below, its a line with hart stop at the bottom fading towards the top
  lines = lines - 0.5; // this offsets the lines, so now the fract will be offet by 0.5, but this will now also give negative values for half the places, meaning that the lines will actually be ative in the negative reagion so incorrectly thik lines, next line will correct that
  lines = abs(lines); // correct the negative fracts

  float distanceToEdge = (0.5 - max(lines.x, lines.y)) * cellSpacing; // substraction from 0.5 inverts => black where lines, white in center


  float smoothstepLines = smoothstep(0.0, lineWidth, distanceToEdge);
  color = mix(lineColor, color, smoothstepLines);

  return color;
}

// float sdfCircle(vec2 p, float r) {
//   return length(p) - r;
// }

// float sdfLine(vec2 p, vec2 a, vec2 b) {
//   vec2 pa = p - a;
//   vec2 ba = b - a;
//   float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);

//   return length(pa - ba * h);
// }

float sdfBox(vec2 p, vec2 b) {
  vec2 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// float sdfHexagon( in vec2 p, in float r ) {
//   const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
//   p = abs(p);
//   p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
//   p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
//   return length(p)*sign(p.y);
// }

  mat2 rotate2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat2(
      c, -s, 
      s, c);
  }

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution;

  vec3 color = backgroundColor();

  color = drawGrid(color, vec3(0.5), 10.0, 1.0);
  color = drawGrid(color, black, 100.0, 2.0);

  //step by step
  // vec2 fragCoords = v_uv; //just rename
  // vec2 fragCoordsInPixels = (v_uv - 0.5) * resolution; //multiplying with resolution will give the frag coors in pixels (remeber that edge of screen in clip space is 1.0 so if we mutiply wirh resolution => pixel coords)
  // float distanceToCircle = length(fragCoordsInPixels - vec2(-100.0, 0.0)) - 400.0; // the substraction shifts the origin, we basically compute as if the frag for which we compute, would be shifted or as if the origin would be shifted
  // gl_FragColor = vec4(vec3(distanceToCircle), 1.0); //distance is negative si clolour si black inside the circle



  //classic way
  // float d = sdfCircle(pixelCoords, 100.0);
  // color = mix(red, color, step(0.0, d));

  // float d = sdfLine(pixelCoords, vec2(-100.0, -50.0), vec2(200.0, -75.0));
  // color = mix(blue, color, step(3.0, d));

  // float d = sdfBox(pixelCoords, vec2(300.0, 100.0));
  // color = mix(red, color, step(0.0, d));

  // float d = sdfHexagon(pixelCoords, 100.0);
  // color = mix(red, color, step(0.0, d));

  //transformations
  vec2 pos = pixelCoords;
  
  pos = pos - vec2(100.0, 50.0);//translation
  pos = pos * rotate2D(time * 1.0);//rotation
  
  //note the order in which these are applied - basically reversed compared to transofrmations in the vertex shader, I think this happens because we kinda move the origin in the calculation as opposed to moving the shape
  // pos = pos * rotate2D(time * 1.0);
  // pos = pos - vec2(100.0, 50.0);
  
  

  //translation
  float d = sdfBox(pos, vec2(100.0, 50.0));
  color = mix(red, color, step(0.0, d));

  

  gl_FragColor = vec4(color, 1.0);
  
  
}