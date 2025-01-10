#version 300 es
    // Fragment shader for Bayer dithering
precision highp float;

in vec2 vUV;
out vec4 outColor;

uniform sampler2D uImage;    // Input texture

const float BAYER_8x8[64] = float[64](
    0.0, 32.0, 8.0, 40.0, 2.0, 34.0, 10.0, 42.0,
    48.0, 16.0, 56.0, 24.0, 50.0, 18.0, 58.0, 26.0,
    12.0, 44.0, 4.0, 36.0, 14.0, 46.0, 6.0, 38.0,
    60.0, 28.0, 52.0, 20.0, 62.0, 30.0, 54.0, 22.0,
    3.0, 35.0, 11.0, 43.0, 1.0, 33.0, 9.0, 41.0,
    51.0, 19.0, 59.0, 27.0, 49.0, 17.0, 57.0, 25.0,
    15.0, 47.0, 7.0, 39.0, 13.0, 45.0, 5.0, 37.0,
    63.0, 31.0, 55.0, 23.0, 61.0, 29.0, 53.0, 21.0
);

float getBayerValue(ivec2 coord) {
    int x = coord.x % 8;
    int y = coord.y % 8;
    return BAYER_8x8[y * 8 + x] / 64.0;
}

void main() {
    vec2 fuv = vec2(vUV.x, 1.0 - vUV.y);
    vec4 color = texture(uImage, fuv);
    
    // Convert to grayscale using luminance weights
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Get the Bayer matrix value for this pixel

    ivec2 imgSize = textureSize(uImage, 0);
    ivec2 pixelCoord = ivec2(floor(fuv * vec2(imgSize)));

    float threshold = getBayerValue(pixelCoord);
    
    // Apply dithering
    float dithered = threshold > luminance ? 0.0 : 1.0;
    
    outColor = vec4(vec3(dithered), 1.0);
}
