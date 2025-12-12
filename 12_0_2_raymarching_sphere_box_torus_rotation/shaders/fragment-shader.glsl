
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

mat3 RotateX(float radians) {
  float sin = sin(radians);
  float cos = cos(radians);

  mat3 rotationMatrix = mat3(
    1.0, 0.0, 0.0,
    0.0, cos, -sin,
    0.0, sin, cos
  );

  return rotationMatrix;
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

//overall "scene" sdf function
float map(vec3 pos) {
  // float dist = sdfSphere(pos - vec3(0.0, 0.0, 5.0), 1.0);
  
  // float dist = sdfBox(pos - vec3(0.0, 0.0, 5.0), vec3(1.0, 1.0, 1.0));

  float dist = sdfTorus(pos * RotateX(time * 0.4) - vec3(0.0, 0.0, 0.0), vec2(0.5, 0.2));
  // float dist = sdfTorus(pos * RotateX(time * 0.1) - vec3(0.0, 0.0, 5.0), vec2(0.5, 0.2));
  
  return dist;
}

const int NUM_STEPS = 256;
const float MAX_DIST = 1000.0;

// Perform the sphere tracing for the scene
vec3 RayMarch(vec3 cameraOrigin, vec3 cameraDir) {

  vec3 pos;
  float dist = 0.0;

  for(int i = 0; i < NUM_STEPS; ++i) {
    pos = cameraOrigin + dist * cameraDir;

    float distToScene = map(pos);

    // Case 1: distToScene < 0, intersected scene
    // BREAK
    if (distToScene < 0.001) {
      // break; 
    }
    dist += distToScene;

    // Case 2: dist > MAX_DIST, meaning that we are out of the scene entirely
    // RETURN
    if(distToScene > MAX_DIST) {
      return vec3(0.0);
    }

    // Case 3: Continue looping (do nothing) 

  }
  
  // Finished loop, return the colour of the object that was hit

  return vec3(1.0);
}

// Perform the sphere tracing for the scene
vec3 RayMarchCostin(vec3 rayOrigin, vec3 rayDirection) {

  vec3 currentPosition;
  float distanceFromOrigin = 0.0;

  for(int i = 0; i < NUM_STEPS; ++i) {
    currentPosition = rayOrigin + distanceFromOrigin * rayDirection;

    float distToScene = map(currentPosition);

    // Case 1: distToScene < 0, intersected scene
    // BREAK
    if (distToScene < 0.001) {
      // break; 
    }
    distanceFromOrigin += distToScene;

    // Case 2: dist > MAX_DIST, meaning that we are out of the scene entirely
    // RETURN
    if(distToScene > MAX_DIST) {
      return vec3(0.0);
    }

    // Case 3: Continue looping (do nothing) 

  }
  
  // Finished loop, return the colour of the object that was hit

  return vec3(1.0);
}

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  
  vec3 cameraPosition = vec3(0.0, 0.0, -5.0);
  
  vec3 rayDirection = normalize(vec3(pixelCoords * 2.0 / resolution.y, 1.0));
  // vec3 rayDirection = normalize(vec3(pixelCoords / resolution, 1.0));

  vec3 colour = RayMarchCostin(cameraPosition, rayDirection);
  
  // gl_FragColor = vec4(colour, 1.0); // simple
  colour = pow(colour, vec3(1.0 / 2.2));
  gl_FragColor = vec4(colour, 1.0);
}