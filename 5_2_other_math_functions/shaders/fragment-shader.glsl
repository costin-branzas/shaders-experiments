varying vec2 v_uv;

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  vec3 finalColor = black;

  float lineThikness = 0.0015;
  
  //actual values to plot
  float value1 = v_uv.x;
  // float value2 = pow(v_uv.x, 2.0);
  // float value2 = pow(v_uv.x, 10.0);
  // float value2 = pow(v_uv.x, 0.3);
  float value2 = v_uv.x * (1.0 - v_uv.x) * 3.0;


  // a horizontal line using step
  float horizontalLineIntensity = 1.0 - step(lineThikness, abs(v_uv.y - 0.5));
    
  // mixGraph
  float graph1Intensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.5, 1.0, mix(0.0, 1.0, value1))));

  // smoothstepGraph
  float graph2Intensity = 1.0 - step(lineThikness, abs(v_uv.y - mix(0.0, 0.5, value2)));

  // background color
  if (v_uv.y > 0.5) {
    finalColor = mix(red, blue, value1);
  } else {
    finalColor = mix(red, blue, value2);
  }

  finalColor = mix(finalColor, white, horizontalLineIntensity);
  finalColor = mix(finalColor, white, graph1Intensity);
  finalColor = mix(finalColor, white, graph2Intensity);

  gl_FragColor = vec4(finalColor, 1.0);
}