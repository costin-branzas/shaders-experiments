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

vec3 drawBackground(float dayTime) {
  vec3 morning1 = vec3(0.44, 0.64, 0.84);
  vec3 morning2 = vec3(0.34, 0.51, 0.94);
  vec3 morning = mix(morning1, morning2, smoothstep(0.0, 1.0, pow(v_uv.x * v_uv.y, 0.5)));

  vec3 midday1 = vec3(0.42, 0.58, 0.75);
  vec3 midday2 = vec3(0.36, 0.46, 0.82);
  vec3 midday = mix(midday1, midday2, smoothstep(0.0, 1.0, pow(v_uv.x * v_uv.y, 0.5)));

  vec3 evening1 = vec3(0.82, 0.51, 0.25);
  vec3 evening2 = vec3(0.88, 0.71, 0.39);
  vec3 evening = mix(evening1, evening2, smoothstep(0.0, 1.0, pow(v_uv.x * v_uv.y, 0.5)));

  vec3 night1 = vec3(0.07, 0.10, 0.19);
  vec3 night2 = vec3(0.19, 0.20, 0.29);
  vec3 night = mix(night1, night2, smoothstep(0.0, 1.0, pow(v_uv.x * v_uv.y, 0.5)));
  
  float dayLength = 20.0;

  vec3 color;
  if (dayTime < dayLength * 0.25) {
    color = mix(morning, midday, smoothstep(0.0, dayLength * 0.25, dayTime));
  } else if (dayTime < dayLength * 0.5) {
    color = mix(midday, evening, smoothstep(dayLength * 0.25, dayLength * 0.5, dayTime));
  } else if (dayTime < dayLength * 0.75) {
    color = mix(evening, night, smoothstep(dayLength * 0.5, dayLength * 0.75, dayTime));
  } else {
    color = mix(night, morning, smoothstep(dayLength * 0.75, dayLength, dayTime));
  }

  // return morning;
  // return midday;
  // return evening;
  // return night;
  return color;
}

float sdfCloud(vec2 pixelCoords) {
  float puff1 = sdfCircle(pixelCoords, 100.0);
  float puff2 = sdfCircle(pixelCoords - vec2(120, -10.0), 75.0);
  float puff3 = sdfCircle(pixelCoords + vec2(120.0, 10.0), 75.0);

  float cloud = min(puff1, puff2);
  cloud = min(cloud, puff3);
  return cloud;
}

float sdfMoon(vec2 pixelCoords) {
  float dCircle1 = sdfCircle(pixelCoords + vec2(50.0, 0.0), 80.0);
  float dCircle2 = sdfCircle(pixelCoords + vec2(0.0, 0.0), 80.0);

  float d = opSubtraction(dCircle1, dCircle2);

  return d;
}

float sdStar5(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

float hash(vec2 v) {
  float t = dot(v, vec2(36.5323, 73.945));
  return sin(t);
}

float saturate(float t) {
  return clamp(t, 0.0, 1.0);
}

float easeOut(float x, float p) {
  return 1.0 - pow(1.0 - x, p);
}

float easeOutBounce(float x) {
  const float n1 = 7.5625;
  const float d1 = 2.75;

  if(x < 1.0 / d1) {
    return n1 * x * x;
  } else if (x < 2.0 / d1) {
    x -= 1.5 / d1;
    return n1 * x * x + 0.75;
  } else if (x < 2.5 / d1) {
    x-=2.25 / d1;
    return n1 * x * x + 0.9375;
  } else {
    x -= 2.625 / d1;
    return n1 * x * x + 0.984375;
  }
}

void main() {
  vec2 pixelCoords = v_uv * resolution; //note that i removed v_uv - 0.5, so we'll need to add it back in later

  float dayLength = 20.0;
  float dayTime = mod(time + 8.0, dayLength);

  vec3 color = drawBackground(dayTime);
  
  //Sun
  if(dayTime < dayLength * 0.75) { //just checks if sun should be pressent on screen
    //sun rise (offset it into the frame as the day starts)
    float t = saturate(inverseLerp(dayTime, 0.0 * dayLength, 0.0 * dayLength + 2.0));
    // vec2 offset = vec2(200.0, resolution.y * 0.8) + mix(vec2(0.0, 400.0), vec2(0.0), t);
    // vec2 offset = vec2(200.0, resolution.y * 0.8) + mix(vec2(0.0, 400.0), vec2(0.0), smoothstep(0.0, 1.0, t));
    vec2 offset = vec2(200.0, resolution.y * 0.8) + mix(vec2(0.0, 400.0), vec2(0.0), easeOut(t, 5.0));

    //sun set (offset it into the frame as the day starts)
    if(dayTime > 0.5 * dayLength) {
      t = saturate(inverseLerp(dayTime, 0.5 * dayLength, 0.5 * dayLength + 2.0));
      offset = vec2(200.0, resolution.y * 0.8) + mix(vec2(0.0), vec2(0.0, 400.0), smoothstep(0.0, 1.0, t));
    }

    //set final position
    vec2 sunPos = pixelCoords - offset;

    float sun = sdfCircle(sunPos, 100.0);
    color = mix(vec3(0.84, 0.62, 0.26), color, smoothstep (0.0, 2.0, sun));

    float positiveSun = max(0.001, sun); // 0.001 because raising to power of negative 0 (next line) basically ends up being 1/e^distance? it would be 1/1 so not really sure what the rpoblem would be...
    // float sunAura = saturate(exp(-0.05 * positiveSun)); // simplified version (by costin)
    float sunAura = saturate(exp(-0.001 * positiveSun * positiveSun)); // as done by Simondev
    // float sunAura = smoothstep(40.0, 0.0, positiveSun); // try with smoothstep
    color += 0.5 * mix(vec3(0.0), vec3(0.9, 0.85, 0.47), sunAura);
  }

  //Moon
  if(dayTime > dayLength * 0.5) { //just checks if moon should be pressent on screen
    float t = saturate(inverseLerp(dayTime, 0.5 * dayLength, 0.5 * dayLength + 2.0));
    vec2 offset = vec2(resolution * 0.8) + mix(vec2(0.0, 400.0), vec2(0.0), easeOutBounce(t));

    //moon set (offset it into the frame as the day starts)
    if(dayTime > 0.9 * dayLength) {
      t = saturate(inverseLerp(dayTime, 0.9 * dayLength, 0.9 * dayLength + 2.0));
      offset = vec2(resolution * 0.8) + mix(vec2(0.0), vec2(0.0, 400.0), smoothstep(0.0, 1.0, t));
    }

    //set final position
    vec2 moonShadowPos = pixelCoords - offset;
    moonShadowPos = rotate2D(3.14159 * -0.2) * moonShadowPos;

    float moonShadow = sdfMoon(moonShadowPos + vec2(15.0, 30.0));
    color = mix(black, color, smoothstep (-20.0, 10.0, moonShadow));

    vec2 moonPos = pixelCoords - offset;
    moonPos = rotate2D(3.14159 * -0.2) * moonPos;

    float moon = sdfMoon(moonPos);
    color = mix(vec3(1.0), color, smoothstep (0.0, 2.0, moon));

    float moonGlow = sdfMoon(moonPos);
    color += 0.1 * mix(white, black, smoothstep (-10.0, 15.0, moonGlow));
  }

  const float NUM_STARS = 24.0;
  for(float i = 0.0; i < NUM_STARS; i += 1.0) {
    float hashSample = hash(vec2(i * 13.0)) * 0.5 + 0.5;
    
    //drop in
    float t = saturate(inverseLerp(dayTime + hashSample * 0.5, 0.5 * dayLength, 0.5 * dayLength + 2.0));
    vec2 offset = vec2(i * 100.0, 0.0) + 150.0 * hash(vec2(i));
    offset += mix(vec2(0.0, 600), vec2(0.0), easeOutBounce(t));

    vec2 pos = pixelCoords - offset;
    pos.x = mod(pos.x, resolution.x);
    pos = pos - resolution * vec2(0.5, 0.75);

    //fade out at end of night
    float fade = 0.0;
    if(dayTime > dayLength * 0.9) {
      fade = saturate(inverseLerp(dayTime - hashSample * 0.25, dayLength * 0.9, dayLength * 0.95));
    }

    //random rotate
    float rot = mix(-3.14159, 3.14159, hashSample);
    pos *= rotate2D(rot);

    //random size
    float size = mix(2.0, 1.0, hash(vec2(i, i + 1.0) ));
    float star = sdStar5(pos * size, 10.0, 2.0);
    vec3 starColor = mix(white, color, smoothstep(0.0, 2.0, star));
    starColor += mix(0.2, 0.0, pow(smoothstep(-5.0, 15.0, star), 0.25));

    color = mix(starColor, color, fade);
  }

  const float NUM_CLOUDS = 8.0;
  for(float i = 0.0; i < NUM_CLOUDS; i += 1.0) {
    float size = mix(2.0, 1.0, (i / NUM_CLOUDS) + 0.1 * hash(vec2(i)));
    float speed = size * 0.25;

    vec2 offset = vec2(i * 200.0 + time * 100.0 * speed, 200.0 * hash(vec2(i))); // move by 100 pixels / second
    vec2 pos = pixelCoords - offset;

    pos = mod(pos, resolution);
    pos = pos - resolution * 0.5; // this is basically where add back in "v_uv - 0.5", but here we do it by multiplying res by 0.5 (i don't fully understand this...)
    
    float cloudShadow = sdfCloud(pos * size + vec2(25.0)) - 40.0;
    color = mix(color, black, 0.5 * smoothstep(0.0, -100.0, cloudShadow));

    float cloud = sdfCloud(pos * size - vec2(0.0, 0.0));
    color = mix(white, color, smoothstep(-1.0, 1.0, cloud));
  }
  
  // color = pow(color, vec3(1.0 / 2.2)); //approximation

  gl_FragColor = vec4(color, 1.0);
}