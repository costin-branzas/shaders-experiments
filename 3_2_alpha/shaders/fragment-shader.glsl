varying vec2 varying_uv;

uniform sampler2D diffuse; // this is basically the texture data, but saved in a "smart" way, it's more than just an array... for ex, when getting a texel at a float point, from the sampler, we can actually get blended values between 2 pixels in the original texture... i think
uniform sampler2D overlay;

uniform vec4 tint;

void main() {
  vec4 diffuseSample = texture(diffuse, varying_uv);  
  vec4 overlaySample = texture(overlay, varying_uv);  
  
  //gl_FragColor = difusseSample;

  //gl_FragColor = difusseSample * overlaySample;  //mutiplies the textures toghether - not functionaing as actual overlay
  
  gl_FragColor = mix(diffuseSample, overlaySample, overlaySample.w);
}