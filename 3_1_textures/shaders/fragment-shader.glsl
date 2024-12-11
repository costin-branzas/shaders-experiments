varying vec2 varying_uv;

uniform sampler2D diffuse;

uniform vec4 tint;

void main() {
  vec4 difusseSample = texture2D(diffuse, varying_uv);
  //gl_FragColor = difusseSample; //basic

  //gl_FragColor = vec4(difusseSample); //just to point that diffuseSample is a vec4

  //gl_FragColor = vec4(difusseSample.r, difusseSample.g, difusseSample.b, 1); // same as before just mroe explicit

  //gl_FragColor = vec4(vec3(difusseSample.r), 1); //user r channel for all colours=> greyscale image

  gl_FragColor = difusseSample * tint; //with tint (known as mutiplicative blending)
}