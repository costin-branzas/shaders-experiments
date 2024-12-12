varying vec2 varying_uv;

uniform sampler2D diffuse; // this is basically the texture data, but saved in a "smart" way, it's more than just an array... for ex, when getting a texel at a float point, from the sampler, we can actually get blended values between 2 pixels in the original texture... i think

uniform vec4 tint;

void main() {
  vec4 difusseSample = texture(diffuse, vec2(varying_uv.x, varying_uv.y)); //this was texture2D before in glsl 2.0, not it's jus ttexture
  
  //gl_FragColor = difusseSample; //basic

  gl_FragColor = vec4(difusseSample); //just to point that diffuseSample is a vec4

  //gl_FragColor = vec4(difusseSample.r, difusseSample.g, difusseSample.b, 1); // same as before just mroe explicit

  //gl_FragColor = vec4(vec3(difusseSample.r), 1); //user r channel for all colours=> greyscale image

  //gl_FragColor = difusseSample * tint; //with tint (known as mutiplicative blending)
}