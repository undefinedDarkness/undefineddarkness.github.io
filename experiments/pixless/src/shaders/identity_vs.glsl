#version 300 es
in vec4 position;
in vec2 texcoord;

out vec2 vUV;

void main() {
  gl_Position = position;
  vUV = texcoord;
}