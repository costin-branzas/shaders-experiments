varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_position;

uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

mat3 rotateY(float radians) {
  float s = sin(radians);
  float c = cos(radians);

  return mat3(
    c, 0.0, s,
    0.0, 1.0, 0.0,
    -s, 0.0, c
  );
}

void main() {	
  vec3 localSpacePosition = position; //local space is the space relative to the object

  // Translating (simple moving)
  // localSpacePosition.x += sin(time * 0.10);
  // localSpacePosition.y += cos(time * 0.10);


  // Scaling
  // localSpacePosition *= sin(time); // multiplication results in scaling, please note that sin will output -1, which will produce some wierd results - it will basically invert the shape
  // localSpacePosition *= remap(sin(time), -1.0, 1.0, 0.5, 1.5); //propper way of doing it
  // localSpacePosition.xz *= remap(sin(time), -1.0, 1.0, 0.5, 1.5); //scaling just on 2 dimensions

  // Rotating
  // localSpacePosition *= rotateY(sin(time)* 3.14);
  // localSpacePosition *= rotateY(time);
  // localSpacePosition = rotateY(time) * localSpacePosition;
  localSpacePosition = localSpacePosition * rotateY(time); //!order in which we mutiply matters... don't know why



  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // translates from local space to clip space

  v_uv = uv;
  v_normal = (modelMatrix * vec4(normal, 0.0)).xyz; //translates the normal from local space to world space (i think)
  v_position = (modelMatrix * vec4(position, 1.0)).xyz;
}