varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_position;

uniform vec2 resolution;
uniform samplerCube specMap;

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

  vec3 baseColour = vec3(0.25);

  vec3 normal = normalize(v_normal);

  vec3 viewDir = normalize(cameraPosition - v_position);

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

  // Phong specular
  vec3 reflection = normalize(reflect(-diffuseLightDirection, normal));
  float phongValue = max(0.0, dot(viewDir, reflection));
  phongValue = pow(phongValue, 32.0);
  vec3 specularLighting = vec3(phongValue);


  // IBL Specular
  vec3 iblCoord = normalize(reflect(-viewDir, normal));
  vec3 iblSample = textureCube(specMap, iblCoord).xyz;

  specularLighting += iblSample * 0.5;

  // Fresnel effect (shalow angle = stronger reflection)
  float fresnelEffect = 1.0 - max(0.0, dot(viewDir, normal));
  fresnelEffect = pow(fresnelEffect, 5.0);

  specularLighting *= fresnelEffect;


  // Final mixing of lighting
  // vec3 totalLighting = ambientLighting * 0.2 + hemiLighting * 0.1 + diffuseLight * 1.0 + specularLighting; //seems like specular can be added here as well...
  vec3 totalLighting = ambientLighting * 0.05 + hemiLighting * 0.0 + diffuseLight * 1.0;

  vec3 finalColor = baseColour * totalLighting + specularLighting;

  // finalColor = linearTosRGB(finalColor);
  finalColor = pow(finalColor, vec3(1.0 / 2.2)); //approximation

  gl_FragColor = vec4(finalColor, 1.0);
}