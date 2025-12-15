
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


float sdfSphere(vec3 pixelCoords, float radius) {
  return length(pixelCoords) - radius;
}

float sdfBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdfTorus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

float sdfPlane(vec3 pos) {
  return pos.y;
}

struct MaterialData {
  vec3 colour;
  float dist;
};

vec3 RED = vec3(1.0, 0.0, 0.0);
vec3 GREEN = vec3(0.0, 1.0, 0.0);
vec3 BLUE = vec3(0.0, 0.0, 1.0);
vec3 YELLOW = vec3(1.0, 1.0, 0.0);
vec3 GRAY = vec3(0.5);
vec3 WHITE = vec3(1.0);
vec3 BLACK = vec3(0.0);

//overall "scene" sdf function  - simple version (no material data)
float mapSimple(vec3 pos) {
  
  float dist = sdfPlane(pos - vec3(0.0, -2.0, 0.0));
  
  dist = min(dist, sdfBox(pos - vec3(-2.0, -0.85, 5.0), vec3(1.0)));
  
  dist = min(dist, sdfBox(pos - vec3(2.0, -0.85, 5.0), vec3(1.0)));
  
  return dist;
}

//overall "scene" sdf function
MaterialData map(vec3 pos) {
  
  MaterialData result = MaterialData(
      GRAY, sdfPlane(pos - vec3(0.0, -2.0, 0.0)));
  
  float dist;

  dist = sdfBox(pos - vec3(-2.0, -0.85, 5.0), vec3(1.0));
  result.colour = dist < result.dist ? RED : result.colour;
  result.dist = min(result.dist, dist);

  dist = sdfBox(pos - vec3(2.0, -0.6, 5.0), vec3(1.0));
  result.colour = dist < result.dist ? BLUE : result.colour;
  result.dist = min(result.dist, dist);

  return result;
}

vec3 CalculateNormal(vec3 pos) {
  const float EPS = 0.0001;
  vec3 n = vec3(
    map(pos + vec3(EPS, 0.0, 0.0)).dist - map(pos - vec3(EPS, 0.0, 0.0)).dist,
    map(pos + vec3(0.0, EPS, 0.0)).dist - map(pos - vec3(0.0, EPS, 0.0)).dist,
    map(pos + vec3(0.0, 0.0, EPS)).dist - map(pos - vec3(0.0, 0.0, EPS)).dist
  );
  return normalize(n);
}

vec3 CalculateLighting(vec3 pos, vec3 normal, vec3 lightColour, vec3 lightDir) {
  float dp = saturate(dot(normal, lightDir));
  
  return lightColour * dp;
}

float CalculateShadow(vec3 pos, vec3 lightDir) {
  float d = 0.01;
  for(int i = 0; i < 64; ++i) {
    float distToScene = map(pos + lightDir * d).dist;

    if (distToScene < 0.001) {
      return 0.0; // in shadow
    }
    d += distToScene;
  }

  return 1.0;
}

float CalculateAO(vec3 pos, vec3 normal) {
  float ao = 0.0;
  float stepSize = 0.1;

  for(float i = 0.0; i < 5.0; ++i) {
    float distFactor = 1.0 / pow(2.0, i);

    ao += distFactor * (i * stepSize - map(pos + normal * i * stepSize).dist);
  }

  return 1.0 - ao;
}

// Performs sphere tracing for the scene.
const int NUM_STEPS = 256;
const float MAX_DIST = 1000.0;
vec3 RayMarch(vec3 cameraOrigin, vec3 cameraDir) {

  vec3 pos;
  MaterialData material = MaterialData(vec3(0.0), 0.0);

  vec3 skyColour = vec3(0.55, 0.6, 1.0);

  for (int i = 0; i < NUM_STEPS; ++i) {
    pos = cameraOrigin + material.dist * cameraDir;

    MaterialData result = map(pos);

    // Case 1: distToScene < 0, intersected scene
    // BREAK
    if (result.dist < 0.001) {
      break;
    }
    material.dist += result.dist;
    material.colour = result.colour;

    // Case 2: dist > MAX_DIST, out of the scene entirely
    // RETURN
    if (material.dist > MAX_DIST) {
      return BLACK;
    }
    // this is just to prove that this raymarching alorithm DOES hit max steps quite a few times
    // if(i == NUM_STEPS - 1) 
    //   return YELLOW;
    
    // Case 3: Loop around, in reality, do nothing.
  }

  // this is hit if the scene is hit OR if the max number of steps was exceded

  // lighting
  vec3 lightDir = normalize(vec3(1.0, 2.0, -1.0)); // from the right, up and from the camera
  vec3 normal = CalculateNormal(pos);
  float shadowed = CalculateShadow(pos, lightDir); // we basically march from the surface towards the light, and we march towards the light dir, checking if we hit anything (return 0 if we hit)
  vec3 lighting = CalculateLighting(pos, normal, vec3(1.0), lightDir);
  lighting *= shadowed;

  float ao = CalculateAO(pos, normal);
  return vec3(ao);

  // return material.colour * lighting;
}


// vec3 RayMarchCostin(vec3 rayOrigin, vec3 rayDirection) {

//   vec3 rayPosition = rayOrigin;
//   float distanceTraveled = 0.0; // we store distance traveled separately to avoid having to calculate length each time (expensive)

//   for(int i = 1; i <= MAX_STEPS; i++) {
//     float distanceToScene = mapSimple(rayPosition);
    
//     if(distanceToScene < 0.001) {
//       return WHITE; // for now, all scene is basically white
//     } 
    
//     rayPosition += distanceToScene * rayDirection; //advance ray
    
//     if(length(rayPosition - rayOrigin) > MAX_DIST) {
//       return BLACK;
//     }
    
//   }

//   // we hit the "hard" MAX_STEPS limit - not an ideal situation, return a "warning" colour
//   return YELLOW;
// }

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  
  vec3 cameraPosition = vec3(0.0);
  
  vec3 rayDirection = normalize(vec3(pixelCoords * 2.0 / resolution.y, 1.0));
  // vec3 rayDirection = normalize(vec3(pixelCoords / resolution, 1.0));

  vec3 colour = RayMarch(cameraPosition, rayDirection);
  
  // gl_FragColor = vec4(colour, 1.0); // simple
  colour = pow(colour, vec3(1.0 / 2.2));
  gl_FragColor = vec4(colour, 1.0);
}