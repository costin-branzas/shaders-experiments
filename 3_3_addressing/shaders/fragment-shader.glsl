varying vec2 varying_uv;

uniform sampler2D diffuse; // this is basically the texture data, but saved in a "smart" way, it's more than just an array... for ex, when getting a texel at a float point, from the sampler, we can actually get blended values between 2 pixels in the original texture... i think
uniform sampler2D overlay;

uniform vec4 tint;

void main() {
  //vec2 varying_uv_mutiplied = varying_uv * 2.0;
  //vec2 varying_uv_mutiplied = varying_uv * vec2(2.0, 3.0);
  vec2 varying_uv_mutiplied = varying_uv * -1.0; // inverting values does not do anything when wraping strategy is mirrored repeat, when just repeating it inverts the image
  vec4 diffuseSample = texture(diffuse, varying_uv_mutiplied);  
    
  gl_FragColor = diffuseSample;
}