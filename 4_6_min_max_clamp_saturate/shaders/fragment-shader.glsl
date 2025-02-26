varying vec2 v_uv;

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  vec3 finalColor = black;

  float lineThikness = 0.0015;
  
  // float interpolationControlForMix = v_uv.x;
  float interpolationControlForMix = min(v_uv.x, 0.25);
  // float interpolationControlForMix = max(v_uv.x, 0.25);
  // float interpolationControlForMix = clamp(v_uv.x, 0.25, 0.75);
  
  // float interpolationControlForSmoothstep = v_uv.x;
  float interpolationControlForSmoothstep = clamp(v_uv.x, 0.25, 0.75);

  // a horizontal line using step
  float horizontalLineIntensity = 1.0 - step(lineThikness, abs(v_uv.y - 0.5));
    
  // mixGraph
  float mixGraphIntensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.5, 1.0, mix(0.0, 1.0, interpolationControlForMix))));

  // smoothstepGraph
  float smoothstepGraphIntensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.0, 0.5, smoothstep(0.0, 1.0, interpolationControlForSmoothstep))));

  // background color
  if (v_uv.y > 0.5) {
    finalColor = mix(red, blue, interpolationControlForMix);
  } else {
    finalColor = mix(red, blue, smoothstep(0.0, 1.0, interpolationControlForSmoothstep));
  }

  finalColor = mix(finalColor, white, horizontalLineIntensity);
  finalColor = mix(finalColor, white, mixGraphIntensity);
  finalColor = mix(finalColor, white, smoothstepGraphIntensity);

  gl_FragColor = vec4(finalColor, 1.0);
}