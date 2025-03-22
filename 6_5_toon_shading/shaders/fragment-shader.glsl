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

  float dotProduct = max(0.0, dot(diffuseLightDirection, normal));
  
  // Toon
  // dotProduct = step(0.5, dotProduct); //step outputs either 0 or 1, nothing in between, so if threshold is 0.5 this just means that anything below that is simply reduced to 0
  // dotProduct = dotProduct * step(0.5, dotProduct); // by multiplying the step result to dotProduct, means that it only cuts off below the threshold value, above it, dotProdct basically remains unchanged (mutiplied by 1), it basically cuts off al diffuse light where the dotProduct is below a given threshold
  // dotProduct = dotProduct * smoothstep(0.5, 0.505, dotProduct); // switch step with smoothstep

  // 3 Colours
  // dotProduct = mix(0.5, 1.0, step(0.65, dotProduct)) * step(0.5, dotProduct);
  // A much longer version of the 3 colours with explanations.
  if (true) {
    // Calculate the fully shadowed area by doing a step on the dot product of the
    // light direction and normal.
    float fullShadow = smoothstep(0.5, 0.505, dotProduct);

    // Calculate the partially shadowed area by doing another step, but using a
    // higher threshold value than the fully shadowed area. Make the output from
    // this step 0.5 in the partially shadowed area, and 1.0 in the lit area.

    // FYI there are a bunch of ways to do this:
    // float partialShadow = remap(smoothstep(0.65, 0.655, dp), 0.0, 1.0, 0.5, 1.0);
    // float partialShadow = mix(0.5, 1.0, smoothstep(0.65, 0.655, dp));
    float partialShadow = smoothstep(0.65, 0.655, dotProduct) * 0.5 + 0.5;

    // In this last step, you combine them. There are a couple ways you can do that.

    // You can multiply them together, which works specifically in this case because:
    // dp range [0, 0.5],    fullShadow = 0, partialShadow = 0.5, so 0 * 0.5 = 0
    // dp range (0.5, 0.65], fullShadow = 1, partialShadow = 0.5, so 1 * 0.5 = 0.5
    // dp range (0.65, 1],   fullShadow = 1, partialShadow = 1, so 1 * 1 = 1
    // dp = partialShadow * fullShadow;

    // You could also just do a min on the values.
    dotProduct = min(partialShadow, fullShadow);
  }

  vec3 diffuseLight = diffuseLightColour * dotProduct;

  // Phong specular
  vec3 reflection = normalize(reflect(-diffuseLightDirection, normal));
  float phongValue = max(0.0, dot(viewDir, reflection));
  phongValue = pow(phongValue, 128.0);
  phongValue = smoothstep(0.5, 0.55, phongValue);
  
  // Fresnel effect (shalow angle = stronger reflection)
  float fresnelEffect = 1.0 - max(0.0, dot(viewDir, normal));
  fresnelEffect = pow(fresnelEffect, 2.0);
  fresnelEffect *= step(0.6, fresnelEffect);
  
  vec3 specularLighting = vec3(phongValue);

  // Final mixing of lighting
  vec3 totalLighting = hemiLighting * (fresnelEffect + 0.2) + diffuseLight * 0.8; //adding 0.2 to fresnelEffect means that some hemi light will be present all over the model, regardles of our fresnell calculation

  vec3 finalColor = baseColour * totalLighting + specularLighting;

  // finalColor = linearTosRGB(finalColor);
  finalColor = pow(finalColor, vec3(1.0 / 2.2)); //approximation

  gl_FragColor = vec4(finalColor, 1.0);
}