#version 300 es
precision highp float;

in vec2 vUV;

uniform sampler2D uImage;
uniform mediump sampler3D uLUT;

out vec4 outColor;

void main() {
  vec4 color = texture(uImage, vec2(vUV.x, 1.0 - vUV.y));
  vec4 lutColor = texture(uLUT, vec3(color.r, color.g, color.b));
  outColor = vec4(lutColor.rgb, color.a);
}