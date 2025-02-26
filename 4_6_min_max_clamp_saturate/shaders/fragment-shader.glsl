varying vec2 v_uv;

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  vec3 finalColor = black;

  float lineThikness = 0.0015;
  
  // a horizontal line using step
  float horizontalLineIntensity = 1.0 - step(lineThikness, abs(v_uv.y - 0.5));
    
  // mixGraph
  float mixGraphIntensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.5, 1.0, mix(0.0, 1.0, v_uv.x))));

  // smoothstepGraph
  float smoothstepGraphIntensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.0, 0.5, smoothstep(0.0, 1.0, v_uv.x))));

  // background color
  if (v_uv.y > 0.5) {
    finalColor = mix(red, blue, v_uv.x);
  } else {
    finalColor = mix(red, blue, smoothstep(0.0, 1.0, v_uv.x));
  }

  finalColor = mix(finalColor, white, horizontalLineIntensity);
  finalColor = mix(finalColor, white, mixGraphIntensity);
  finalColor = mix(finalColor, white, smoothstepGraphIntensity);

  gl_FragColor = vec4(finalColor, 1.0);
}