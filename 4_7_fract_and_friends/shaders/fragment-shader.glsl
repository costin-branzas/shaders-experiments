varying vec2 v_uv;

uniform vec2 resolution;

void main() {
  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 yellow = vec3(1.0, 1.0, 0.0);

  vec3 finalColor = vec3(0.75);
  
  // finalColor = fract(vec3(v_uv, 0.0)); // display the v_uv coords as red and green
  
  // float verticalLines = abs(fract(v_uv.x * 10.0) - 0.5);
  // float horizontalLines = abs(fract(v_uv.y * 10.0) - 0.5);

  // finalColor = vec3(verticalLines);
  // finalColor = mix(finalColor, vec3(horizontalLines), vec3(horizontalLines));

  //grid
  vec2 center = v_uv - 0.5;
  vec2 cell = fract(center * resolution / 100.0); //this is 0 in the bottom left corner and goes to 1 towards top right
  cell = abs(cell - 0.5); // this moves the 0 point in the "middle" instead of the bottom left
  float distToCell = 1.0 - 2.0 * max(cell.x, cell.y); // this calculates the distance to the cell center, basically making center of cell black, and the margins white
  
  float cellLine = smoothstep(0.0, 0.05, distToCell);

  float xAxis = smoothstep(0.0, 0.002, abs(v_uv.y - 0.5));
  float yAxis = smoothstep(0.0, 0.002, abs(v_uv.x - 0.5));

  //lines
  vec2 pos = center * resolution / 100.0;
  float value1 = pos.x;
  // float value2 = abs(pos.x);
  // float value2 = floor(pos.x);
  // float value2 = ceil(pos.x);
  // float value2 = round(pos.x);
  // float value2 = fract(pos.x);
  float value2 = mod(pos.x, 1.5);

  float functionLine1 = smoothstep(0.0, 0.075, abs(pos.y - value1)); // linear function
  float functionLine2 = smoothstep(0.0, 0.075, abs(pos.y - value2)); //the function defined above

  finalColor = mix(black, finalColor, cellLine);

  finalColor = mix(blue, finalColor, xAxis);
  finalColor = mix(blue, finalColor, yAxis);

  finalColor = mix(yellow, finalColor, functionLine1);
  finalColor = mix(red, finalColor, functionLine2);

  gl_FragColor = vec4(finalColor, 1.0);
}