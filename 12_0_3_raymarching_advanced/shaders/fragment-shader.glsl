
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
  
  // base material data
  MaterialData materialData = MaterialData(
    GRAY,
    sdfPlane(pos - vec3(0.0, -2.0, 0.0))
  );
  
  // then iterate over various shapes and update the dist and colour as needed
  float dist;

  dist = sdfBox(pos - vec3(-2.0, -0.85, 5.0), vec3(1.0));
  materialData.colour = dist < materialData.dist ? RED : materialData.colour;
  materialData.dist = min(materialData.dist, dist);

  dist = sdfBox(pos - vec3(2.0, -0.85, 5.0), vec3(1.0));
  materialData.colour = dist < materialData.dist ? BLUE : materialData.colour;
  materialData.dist = min(materialData.dist, dist);
  
  return materialData;
}



// Perform the sphere tracing for the scene
// const int NUM_STEPS = 256;
// const float MAX_DIST = 1000.0;
// vec3 RayMarch(vec3 cameraOrigin, vec3 cameraDir) {

//   vec3 pos;
//   float dist = 0.0;

//   for(int i = 0; i < NUM_STEPS; ++i) {
//     pos = cameraOrigin + dist * cameraDir;

//     float distToScene = map(pos);

//     // Case 1: distToScene < 0, intersected scene
//     // BREAK
//     if (distToScene < 0.001) {
//       // break; 
//     }
//     dist += distToScene;

//     // Case 2: dist > MAX_DIST, meaning that we are out of the scene entirely
//     // RETURN
//     if(distToScene > MAX_DIST) {
//       return vec3(0.0);
//     }

//     // Case 3: Continue looping (do nothing) 

//   }
  
//   // Finished loop, return the colour of the object that was hit

//   return vec3(1.0);
// }

// Perform the sphere tracing for the scene
// const int NUM_STEPS = 256;
// const float MAX_DIST = 1000.0;
// vec3 RayMarchCostin(vec3 rayOrigin, vec3 rayDirection) {

//   vec3 currentPosition;
//   MaterialData finalMaterialData = MaterialData(BLACK, 0.0);

//   for(int i = 0; i < NUM_STEPS; ++i) {
//     currentPosition = rayOrigin + finalMaterialData.dist * rayDirection;

//     MaterialData currentPositionMaterialData = map(currentPosition);

//     // Case 1: distToScene < 0, intersected scene
//     // BREAK
//     if (currentPositionMaterialData.dist < 0.001) {
//       // break; - will return at the end of the function // this is such a wierd and confusing way of doing it...
//     }
//     finalMaterialData.dist += currentPositionMaterialData.dist;
//     finalMaterialData.colour = currentPositionMaterialData.colour;

//     // Case 2: dist > MAX_DIST, meaning that we are out of the scene entirely
//     // RETURN
//     if(finalMaterialData.dist > MAX_DIST) {
//       return BLACK;
//     }

//     // Case 3: Continue looping (do nothing) 

//   }
  
//   // Finished loop, return the colour of the object that was hit

//   return finalMaterialData.colour;
// }

const int MAX_STEPS = 256;
const float MAX_DIST = 1000.0;
vec3 RayMarchCostin2(vec3 rayOrigin, vec3 rayDirection) {

  vec3 rayPosition = rayOrigin;
  float distanceTraveled = 0.0; // we store distance traveled separately to avoid having to calculate length each time (expensive)

  for(int i = 1; i <= MAX_STEPS; i++) {
    float distanceToScene = mapSimple(rayPosition);
    
    if(distanceToScene < 0.001) {
      return WHITE; // for now, all scene is basically white
    } 
    
    rayPosition += distanceToScene * rayDirection; //advance ray
    
    if(length(rayPosition - rayOrigin) > MAX_DIST) {
      return BLACK;
    }
    

  }

  // we hit the "hard" MAX_STEPS limit - not an ideal situation, return a "warning" colour
  return YELLOW;
}

void main() {
  vec2 pixelCoords = (v_uv - 0.5) * resolution; // substracting 0.5 from v_uv will basically make the 0,0 coordinate be in the center of the screen, as oposed to having it at the bottom left corner
  
  vec3 cameraPosition = vec3(0.0);
  
  vec3 rayDirection = normalize(vec3(pixelCoords * 2.0 / resolution.y, 1.0));
  // vec3 rayDirection = normalize(vec3(pixelCoords / resolution, 1.0));

  vec3 colour = RayMarchCostin2(cameraPosition, rayDirection);
  
  // gl_FragColor = vec4(colour, 1.0); // simple
  colour = pow(colour, vec3(1.0 / 2.2));
  gl_FragColor = vec4(colour, 1.0);
}