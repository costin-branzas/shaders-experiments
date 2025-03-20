varying vec2 v_uv;

varying vec3 v_normal;

uniform vec2 resolution;

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

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 baseColour = vec3(0.5);

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
  vec3 totalLighting = ambientLighting * 0.0 + hemiLighting * 0.0 + diffuseLight * 1.0;

  vec3 finalColor = baseColour * totalLighting;

  // finalColor = linearTosRGB(finalColor);
  finalColor = pow(finalColor, vec3(1.0 / 2.2)); //approximation

  gl_FragColor = vec4(finalColor, 1.0);
}