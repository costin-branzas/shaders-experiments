varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_position;
varying vec4 v_colour;

uniform vec2 resolution;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 baseColour = v_colour.xyz;

  float tValue = v_colour.w;
  float tLine = smoothstep(0.003, 0.004, abs(v_position.y - mix(-0.5, 0.0, tValue))); // the mix is there to basically reference the bottom half of the cube (i think)
  baseColour = mix (yellow, baseColour, tLine);

  // Fragment shader part
  if(v_position.y > 0.0) {
    float tFragment = remap(v_position.x, -0.5, 0.5, 0.0, 1.0);
    tFragment = pow(tFragment, 2.0);
    baseColour = mix(red, blue, tFragment);

    float tFragmentLine = smoothstep(0.003, 0.004, abs(v_position.y - mix(0.0, 0.5, tFragment))); // the mix is there to basically reference the top half of the cube (i think)
    baseColour = mix (yellow, baseColour, tFragmentLine);
  }

  float middleLine = smoothstep(0.004, 0.005, abs(v_position.y)); // the line is actually 0.004*2 thik, but it has a bleed area of 0.005 on each side
  baseColour = mix(black, baseColour, middleLine);

  vec3 normal = normalize(v_normal);

  // Ambient
  vec3 ambientLighting = vec3(0.5);

  // Hemi lighting
  vec3 skyColour = vec3(0.0, 0.3, 0.6);
  vec3 groundColour = vec3(0.6, 0.3, 0.1);

  float normalYRemappedTo01 = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  vec3 hemiLighting = mix(groundColour, skyColour, normalYRemappedTo01);

  // Diffuse lighting (aka lambertian lighting)
  vec3 diffuseLightDirection = normalize(vec3(1.0, 1.0, 1.0));
  vec3 diffuseLightColour = vec3(1.0, 1.0, 0.9);

  // float dotProduct = dot(diffuseLightDirection, normal); //this actually ends up being negative where the normal is oposite to the light direction, so it actually removes light in those areas (not how light works!)
  float dotProduct = max(0.0, dot(diffuseLightDirection, normal));
  vec3 diffuseLight = diffuseLightColour * dotProduct;


  // Final mixing of lighting
  vec3 totalLighting = ambientLighting * 0.5 + hemiLighting * 0.3 + diffuseLight * 1.0;

  vec3 finalColor = baseColour * totalLighting;

  gl_FragColor = vec4(finalColor, 1.0);
}