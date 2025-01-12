varying vec2 v_uv;

void main() {
  vec3 color;
  vec3 white = vec3(1.0);
  vec3 black = vec3(0.0);
  vec3 red = vec3(1.0, 0.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);

  //3 sections, also adding in step function
  
  //top middle line
  float topMiddleLine = smoothstep(0.0, 0.005, abs(v_uv.y - 0.33));

  //bottom middle line
  float bottomMiddleLine = smoothstep(0.0, 0.005, abs(v_uv.y - 0.66));
  
  //step line
  float distanceStepLine = abs(v_uv.y - mix(0.66, 1.0, step(0.5, v_uv.x)));
  float stepLine = smoothstep(0.0, 0.005, distanceStepLine);

  //linear line
  float distanceLinearLine = abs(v_uv.y - mix(0.33, 0.66, v_uv.x));
  float linearLine = smoothstep(0.0, 0.005, distanceLinearLine);

  //smootstep line
  float distanceToSmoothstepLine = abs(v_uv.y - mix(0.0, 0.33, smoothstep(0.0, 1.0, v_uv.x)));
  float smoothstepLine = smoothstep(0.0, 0.005, distanceToSmoothstepLine);

  if(v_uv.y > 0.66)
  {
    //top 3rd
    vec3 redToBlueStep = mix(red, blue, step(0.5, v_uv.x));
    color = vec3(redToBlueStep);
  }
  else if(v_uv.y < 0.66 && v_uv.y > 0.33)
  {
    //middle 3rd
    vec3 redToBlueLinear = mix(red, blue, v_uv.x);
    color = vec3(redToBlueLinear);
  }
  else
  {
    //bottom 3rd
    vec3 redToBlueHermite = mix(red, blue, smoothstep(0.0, 1.0, v_uv.x));
    color = vec3(redToBlueHermite);
  }
  
  color = mix (white, color, topMiddleLine);
  color = mix (white, color, bottomMiddleLine);
  
  color = mix (white, color, stepLine);
  color = mix (white, color, linearLine);
  color = mix (white, color, smoothstepLine);
    
  gl_FragColor = vec4(color, 1);
}