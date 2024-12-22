varying vec2 varying_uv;

uniform sampler2D diffuse; // this is basically the texture data, but saved in a "smart" way, it's more than just an array... for ex, when getting a texel at a float point, from the sampler, we can actually get blended values between 2 pixels in the original texture... i think
uniform sampler2D overlay;
uniform sampler2D brickTexture;

uniform vec4 tint;

void main() {
  vec4 diffuseSample = texture(brickTexture, varying_uv);

  gl_FragColor = diffuseSample;
}