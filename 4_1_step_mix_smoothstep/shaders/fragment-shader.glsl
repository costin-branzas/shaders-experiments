varying vec2 v_uv;

void main() {
  vec3 color = vec3(0.0);
  //color = vec3(v_uv.x);
  
  //step - this is basically like a round function, but you can give it the threshold
  // color = vec3(step(0.25, v_uv.x));

  //mix - this interpolates between the first 2 values, using the 3rd as the percentage (also known as lerm in Microsoft's shader programming language)
  // color = vec3(mix(0.5, 0.0, v_uv.x));
  
  //mix
  // if(v_uv.x < 0.5)
  //   color = vec3(mix(0.5, 0.0, v_uv.x));
  // else
  //   color = vec3(mix(0.0, 0.5, v_uv.x));

  //mix
  // vec3 red = vec3(1.0, 0.0, 0.0);
  // vec3 green = vec3(0.0, 1.0, 0.0);
  // color = vec3(mix(red, green, v_uv.x));

  //replicating smoothstep with mix - not really the same thing, as smoothstep does not seem to interpolate linearly, but it seems smoothed out (hermite interpolation)
  // float edge1 = 0.0, edge2 = 1.0;
  // if(v_uv.x < edge1)
  //   color = vec3(0.0);
  // else if (v_uv.x >= edge1 && v_uv.x <= edge2)
  // {
  //   float edgeRange = edge2 - edge1;

  //   float normalizedPercentage = v_uv.x - edge1;

  //   float calculatedPercentage = normalizedPercentage * 1.0 / edgeRange;

  //   color = vec3(mix(0.0, 1.0, calculatedPercentage));
  // }
  // else
  //   color = vec3(1.0);

  //smoothstep - this acts like step, but the "step" has a width defined between the first 2 parameters
  color = vec3(smoothstep(0.4, 0.6, v_uv.x));

  gl_FragColor = vec4(color, 1);
}