
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

float saturate(float x) {
  return clamp(x, 0.0, 1.0);
}

// Copyright (C) 2011 by Ashima Arts (Simplex noise)
// Copyright (C) 2011-2016 by Stefan Gustavson (Classic noise and others)
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://github.com/ashima/webgl-noise/tree/master/src
vec3 mod289(vec3 x)
{
    return x - floor(x / 289.0) * 289.0;
}

vec4 mod289(vec4 x)
{
    return x - floor(x / 289.0) * 289.0;
}

vec4 permute(vec4 x)
{
    return mod289((x * 34.0 + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - r * 0.85373472095314;
}

vec4 snoise(vec3 v)
{
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    vec3 i  = floor(v + dot(v, vec3(C.y)));
    vec3 x0 = v   - i + dot(i, vec3(C.x));

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.x;
    vec3 x2 = x0 - i2 + C.y;
    vec3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec4 p =
      permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0))
                            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
                            + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    vec4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    vec4 x_ = floor(j / 7.0);
    vec4 y_ = floor(j - 7.0 * x_); 

    vec4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 g0 = vec3(a0.xy, h.x);
    vec3 g1 = vec3(a0.zw, h.y);
    vec3 g2 = vec3(a1.xy, h.z);
    vec3 g3 = vec3(a1.zw, h.w);

    // Normalize gradients
    vec4 norm = taylorInvSqrt(vec4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Compute noise and gradient at P
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    vec4 m2 = m * m;
    vec4 m3 = m2 * m;
    vec4 m4 = m2 * m2;
    vec3 grad =
      -6.0 * m3.x * x0 * dot(x0, g0) + m4.x * g0 +
      -6.0 * m3.y * x1 * dot(x1, g1) + m4.y * g1 +
      -6.0 * m3.z * x2 * dot(x2, g2) + m4.z * g2 +
      -6.0 * m3.w * x3 * dot(x3, g3) + m4.w * g3;
    vec4 px = vec4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * vec4(grad, dot(m4, px));
}

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
//
// https://www.shadertoy.com/view/Xsl3Dl
vec3 hash3( vec3 p ) // replace this by something better
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
            dot(p,vec3(269.5,183.3,246.1)),
            dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec3 p )
{
  vec3 i = floor( p );
  vec3 f = fract( p );
	
	vec3 u = f*f*(3.0-2.0*f);

  return mix( mix( mix( dot( hash3( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                        dot( hash3( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                   mix( dot( hash3( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                        dot( hash3( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
              mix( mix( dot( hash3( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                        dot( hash3( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                   mix( dot( hash3( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                        dot( hash3( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

float fbm(vec3 p, int octaves, float persistence, float lacunarity, float exponentiation) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = snoise(p * frequency).w;
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;
  total = total * 0.5 + 0.5;
  total = pow(total, exponentiation);

  return total;
}

//costin's version
vec3 GenerateGridStars(vec2 pixelCoords, float starRadius, float cellWidth, float seed, bool twinkle) {
  // i believe cellCoords is a bad name, this basically begins being 1 at the center of each cell, and then increases as we go up and right
  vec2 cellCoords = (fract(pixelCoords / cellWidth) - 0.5) * cellWidth; // multiplying with cell width just saturates (makes it > 1 quickly) the gradient ... In the end: this is 0 at the cell center, and very quickly increases as we move away
  vec2 cellID = floor(pixelCoords / cellWidth) + seed / 100.0; // this will be the same 2 numbers everywhere in the "current" cell
  vec3 cellHashValue = hash3(vec3(cellID, 0.0));
  // return cellHashValue; // just to prove that we have random values in this
  
  float starBrightness = saturate(cellHashValue.z);

  vec2 starPosition = vec2(0.0);
  starPosition += cellHashValue.xy * (cellWidth * 0.5 - starRadius * 4.0);
  
  float distToStar = length(cellCoords - starPosition); // basically distance to center of cell // i had a + instead of - here, and the stars glow was for some reason less pronounced

  // float glow = smoothstep(starRadius + 1.0, starRadius, distToStar); // inverting 1st 2 params inverts the colour
  float glow = exp(-2.0 * distToStar / starRadius); // exp = e^... // this will basically end up being 1 right near the star center, and then decrease exp as we move away, just like a star glow

  //twinkle
  if (twinkle) {
    float noiseSample = noise(vec3(cellID, time * 1.5));
    float twinkleSize = remap(noiseSample, -1.0, 1.0, 1.0, 0.1) * starRadius * 6.0;
    vec2 absDist = abs(cellCoords - starPosition);
    // float twinkleValue = smoothstep(1.0 , 0.0, absDist.y); // horizontal line appears as we near in on the star vertically
    float twinkleValue = smoothstep(starRadius * 0.25, 0.0, absDist.y) * smoothstep(twinkleSize, 0.0, absDist.x); // mutiply with va;lue determined by how close we are horizpontaly to fade out the twinkle as we get further from the star

    twinkleValue += smoothstep(starRadius * 0.25, 0.0, absDist.x) * smoothstep(twinkleSize, 0.0, absDist.y); // mutiply with va;lue determined by how close we are horizpontaly to fade out the twinkle as we get further from the star

    glow += twinkleValue;
  }

  vec3 colour = vec3(glow * starBrightness);

  return colour;
}


vec3 GenerateStars(vec2 pixelCoords) {
  vec3 stars = vec3(0.0);

  float size = 4.0;
  float cellWidth = 500.0;
  for (float i = 0.0; i <= 2.0; i += 1.0) {
    stars += GenerateGridStars(pixelCoords, size, cellWidth, i, true);
    // stars += GenerateGridStarsSimon(pixelCoords, size, cellWidth, i, true);
    size *= 0.5;
    cellWidth *= 0.35;
  }

  for (float i = 3.0; i < 5.0; i += 1.0) {
    stars += GenerateGridStars(pixelCoords, size, cellWidth, i, false);
    size *= 0.5;
    cellWidth *= 0.35;
  }

  return stars;
}


float sdfCircle(vec2 p, float r) {
  return length(p) - r;
}

float map(vec3 pos) {
  return fbm(pos, 6, 0.5, 2.0, 4.0);
}

vec3 calcNormal(vec3 pos, vec3 originalSurfaceNormal) {
  vec2 e = vec2(0.00010, 0.0); // just place to store a small offset, we could have simply used hard coded vec2s below, instead we use this "e" (offset) // by increasing the offset we can sample a bit further away from the current point, which can increase the "slope" of the normals, so lighting looks more dramatic
  vec3 normal = normalize(
    originalSurfaceNormal - 500.0 * vec3( //the 500- 1000 number given here is basically a constant that exagerates the gradients a bit so lighting is more dramatic ("steeper" gradients in the noise)
      map(pos + e.xyy) - map(pos - e.xyy),
      map(pos + e.yxy) - map(pos - e.yxy),
      map(pos + e.yyx) - map(pos - e.yyx)
    )
  );

  return normal;
}

vec3 DrawPlanet(vec2 pixelCoords, vec3 originalColour) {
  float d = sdfCircle(pixelCoords, 400.0); //distance to planet

  vec3 planetColour = vec3(1.0);
  
  if(d <= 0.0) {
    // the next 3 lines are basically an implementation for sphere quation (x^2 + y^2 + z^2 = r^1)
    // these are the lines that basicalyl give us a 3d looking sphere
    float x = pixelCoords.x / 400.0; // we know x
    float y = pixelCoords.y / 400.0; // we know y
    float z = sqrt(1.0 - x * x - y * y); // we calculate z

    // planetColour = vec3(z); // this would basically be white in the middle, and slowly fade away on the sides giving the specific appearance of a sphere :)

    vec3 viewNormal = vec3(x, y, z);
    vec3 wsPosition = viewNormal;

    vec3 wsNormal = normalize(wsPosition);
    vec3 wsViewDir = vec3(0.0, 0.0, 1.0);

    vec3 noiseCoord = wsPosition * 2.0; // multiply by 2 to increase noise density basically the noise space is zoomed out, capturing a larger portion of the noise - hence more details
    float noiseSample = fbm(noiseCoord, 6, 0.5, 2.0, 4.0); // we are basically sampling from the 3d space of the noise along the sphere surface, so we colour the sphere with the value at that exact point in the 3d noise space
    // planetColour = vec3(noiseSample); // visualize the noise directly
    float moistureMap = fbm(noiseCoord * 0.5 + vec3(20.0), 2, 0.5, 2.0, 1.0); // a different noise sample used to further add some detail on the planet surface


    //colouring
    vec3 waterColour = mix(vec3(0.01, 0.09, 0.55), vec3(0.09, 0.26, 0.57), smoothstep(0.02, 0.06, noiseSample));
    vec3 landColour = mix(vec3(0.5, 1.0, 0.3), vec3(0.0, 0.7, 0.0), smoothstep(0.05, 0.1, noiseSample));

    // adding moisture map based deserts into land colour:
    landColour = mix(vec3(1.0, 1.0, 0.5), landColour, smoothstep(0.4, 0.5, moistureMap));

    //adding mountains and snow on the base noise sample
    landColour = mix(landColour, vec3(0.5), smoothstep(0.1, 0.2, noiseSample));
    landColour = mix(landColour, vec3(1.0), smoothstep(0.2, 0.3, noiseSample));

    //add snow at the "poles" (where the y component of the viewNormal is closer to 1)
    landColour = mix(landColour, vec3(0.9), smoothstep(0.5, 0.9, abs(viewNormal.y)));

    // planetColour = mix(waterColour, landColour, step(0.3, noiseSample)); // just for fun, tried it with step function
    planetColour = mix(waterColour, landColour, smoothstep(0.05, 0.06, noiseSample));
  
    //Lighting
    vec3 wsLightDir = normalize(vec3(0.5, 1.0, 0.5));
    vec3 wsSurfaceNormal = calcNormal(noiseCoord, wsNormal); // manually calculated normal

    //calculating normals from dfdx and dfdy - for reasons i don;t quite understand, the dFdx and dFdy functions return very low "resolution" results, so the lighting looks super low res
    // vec3 wsSurfacePosition = wsPosition + wsNormal * noiseSample * 0.5;
    // vec3 wsSurfaceNormal = normalize(
    //   cross(dFdx(wsSurfacePosition), dFdy(wsSurfacePosition))
    // );

    float dp = max(0.0, dot(wsLightDir, wsSurfaceNormal));

    // planetColour = vec3(dp); // just to see the directional light
    vec3 lightColour = vec3(0.75);
    vec3 ambient = vec3(0.02);
    vec3 diffuse = lightColour * dp;

    vec3 r = normalize(reflect(-wsLightDir, wsSurfaceNormal)); // reflection of the diffuse light
    float phongValue = max(0.0, dot(wsViewDir, r));
    phongValue = pow(phongValue, 4.0);
    vec3 specular = vec3(phongValue) * 0.5 * diffuse;
    // specular = vec3(0.0);


    vec3 planetShading = planetColour * (diffuse + ambient) + specular;
    
    planetColour = planetShading;

    //fresnel (atmosphere scaterring at the "edges")
    float fresnel = smoothstep(1.0, 0.1, viewNormal.z); // playing with smoothsteps parameters here will change the scattering spread over the planet surface
    fresnel = pow(fresnel, 8.0) * dp;
    planetColour = mix(planetColour, vec3(0.0, 0.5, 1.0), fresnel);
  }

  vec3 colour = mix(originalColour, planetColour, smoothstep(0.0, -1.0, d));

  return colour;
}


void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  vec3 colour = vec3(0.0, 0.0, 0.0);
  
  colour = GenerateStars(pixelCoords);

  colour = DrawPlanet(pixelCoords, colour);

  gl_FragColor = vec4(colour, 1.0);
}