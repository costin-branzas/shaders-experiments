varying vec2 v_uv;

void main() {
  vec3 color;
  vec3 white = vec3(1.0);
  vec3 black = vec3(0.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  //i want to draw a line through the middle of the screen

  //first - retarded version - very explicit
  // if(v_uv.y >= 0.49 && v_uv.y<=0.51)
  //   color = white;

  //second
  // color = vec3(v_uv.y); //classic gradient across entire screen
  
  //3rd
  // color = vec3(abs(v_uv.y - 0.5)); // translation - distance to the position we want to draw, distance will be 0, when at the target, so color will be black there
  
  //middle line
  float middleOfScreen = 0.5;
  float pixelDistanceToMiddleOfScreen = abs(v_uv.y - middleOfScreen);
  float colorMiddleLine = smoothstep(0.0, 0.005, pixelDistanceToMiddleOfScreen);
  
  //top line
  float distanceToTopDiagonal = abs(v_uv.y - mix(0.5, 1.0, v_uv.x));
  float colorTopLine = smoothstep(0.0, 0.005, distanceToTopDiagonal);

  //bottom line
  float distanceToBottomGraph = abs(v_uv.y - mix(0.0, 0.5, smoothstep(0.0, 1.0, v_uv.x)));
  float colorBottomLine = smoothstep(0.0, 0.005, distanceToBottomGraph);

  if(v_uv.y > 0.5)
  {
    //top half
    vec3 redToBlueLinear = mix(red, blue, v_uv.x);
    color = vec3(redToBlueLinear);
  }
  else
  {
    //bottom half
    vec3 redToBlueHermite = mix(red, blue, smoothstep(0.0, 1.0, v_uv.x));
    color = vec3(redToBlueHermite);
  }
  
  color = mix (white, color, colorMiddleLine); //this also inverts the line from black to white
  color = mix (white, color, colorTopLine); //this also inverts the line from black to white
  color = mix (white, color, colorBottomLine); //this also inverts the line from black to white
  
  
  gl_FragColor = vec4(color, 1);
}