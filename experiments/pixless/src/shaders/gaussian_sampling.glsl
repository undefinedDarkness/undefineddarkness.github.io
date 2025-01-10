#version 300 es
precision highp float;

in vec2 vUV;
uniform sampler2D uImage;
uniform vec3 offsets;
uniform int palette_size;
uniform vec3 palette[256];

out vec4 outColor;

vec3 rgb2xyz( vec3 c ) {
    vec3 tmp;
    tmp.x = ( c.r > 0.04045 ) ? pow( ( c.r + 0.055 ) / 1.055, 2.4 ) : c.r / 12.92;
    tmp.y = ( c.g > 0.04045 ) ? pow( ( c.g + 0.055 ) / 1.055, 2.4 ) : c.g / 12.92,
    tmp.z = ( c.b > 0.04045 ) ? pow( ( c.b + 0.055 ) / 1.055, 2.4 ) : c.b / 12.92;
    const mat3x3 mat = mat3x3(
		0.4124, 0.3576, 0.1805,
        0.2126, 0.7152, 0.0722,
        0.0193, 0.1192, 0.9505 
	);
    return 100.0 * (tmp * mat);
}

vec3 xyz2lab( vec3 c ) {
    vec3 n = c / vec3(95.047, 100, 108.883);
    vec3 v;
    v.x = ( n.x > 0.008856 ) ? pow( n.x, 1.0 / 3.0 ) : ( 7.787 * n.x ) + ( 16.0 / 116.0 );
    v.y = ( n.y > 0.008856 ) ? pow( n.y, 1.0 / 3.0 ) : ( 7.787 * n.y ) + ( 16.0 / 116.0 );
    v.z = ( n.z > 0.008856 ) ? pow( n.z, 1.0 / 3.0 ) : ( 7.787 * n.z ) + ( 16.0 / 116.0 );
    return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
}

vec3 rgb2lab( vec3 c ) {
    vec3 lab = xyz2lab( rgb2xyz( c ) );
    return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
}

vec3 lab2xyz( vec3 c ) {
    float fy = ( c.x + 16.0 ) / 116.0;
    float fx = c.y / 500.0 + fy;
    float fz = fy - c.z / 200.0;
    return vec3(
         95.047 * (( fx > 0.206897 ) ? fx * fx * fx : ( fx - 16.0 / 116.0 ) / 7.787),
        100.000 * (( fy > 0.206897 ) ? fy * fy * fy : ( fy - 16.0 / 116.0 ) / 7.787),
        108.883 * (( fz > 0.206897 ) ? fz * fz * fz : ( fz - 16.0 / 116.0 ) / 7.787)
    );
}

vec3 xyz2rgb( vec3 c ) {
	const mat3x3 mat = mat3x3(
        3.2406, -1.5372, -0.4986,
        -0.9689, 1.8758, 0.0415,
        0.0557, -0.2040, 1.0570
	);
    vec3 v = (c / 100.0) * mat;
    vec3 r;
    r.x = ( v.r > 0.0031308 ) ? (( 1.055 * pow( v.r, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.r;
    r.y = ( v.g > 0.0031308 ) ? (( 1.055 * pow( v.g, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.g;
    r.z = ( v.b > 0.0031308 ) ? (( 1.055 * pow( v.b, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.b;
    return r;
}

vec3 lab2rgb( vec3 c ) {
    return xyz2rgb( lab2xyz( vec3(100.0 * c.x, 2.0 * 127.0 * (c.y - 0.5), 2.0 * 127.0 * (c.z - 0.5)) ) );
}


const int iterations = 100;
const float PI = 3.14159265359;

float rand(vec2 co)
{
  // This one-liner can be found in many places, including:
  // http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
  // I can't find any explanation for it, but experimentally it does seem to
  // produce approximately uniformly distributed values in the interval [0,1].
  float r = fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);

  // Make sure that we don't return 0.0
  if(r == 0.0)
    return 0.000000000001;
  else
    return r;
}

vec4 gaussrand(vec2 co)
{
    const  float stddev = 0.1;
    const float mean = 0.0;
  // Box-Muller method for sampling from the normal distribution
  // http://en.wikipedia.org/wiki/Normal_distribution#Generating_values_from_normal_distribution
  // This method requires 2 uniform random inputs and produces 2 
  // Gaussian random outputs.  We'll take a 3rd random variable and use it to
  // switch between the two outputs.

  float U, V, R, Z;
  // Add in the CPU-supplied random offsets to generate the 3 random values that
  // we'll use.
  U = rand(co + vec2(offsets.x, offsets.x));
  V = rand(co + vec2(offsets.y, offsets.y));
  R = rand(co + vec2(offsets.z, offsets.z));
  // Switch between the two random outputs.
  if(R < 0.5)
    Z = sqrt(-2.0 * log(U)) * sin(2.0 * PI * V);
  else
    Z = sqrt(-2.0 * log(U)) * cos(2.0 * PI * V);

  // Apply the stddev and mean.
  Z = Z * stddev + mean;

  // Return it as a vec4, to be added to the input ("true") color.
  return vec4(Z, Z, Z, 0.0);
}

void main() {
    vec3 color = rgb2lab(texture(uImage, vec2(vUV.x, vUV.y)).rgb);
    vec3 mean = vec3(0.0);
    for (int iter = 0; iter < iterations; iter++) {
        vec3 px = color;
        vec2 noise_coord = vUV.xy + PI * float(iter);
        vec4 noise = gaussrand(noise_coord);

        px += noise.rgb;
        px = clamp(px, 0.0, 1.0);

        // nearest neighbour search
        float minDistance = 1000.0;
        vec3 nearestColor = palette[0];
        for (int i = 0; i < palette_size; i++) {
            vec3 paletteColor = rgb2lab(palette[i]);
            float distance = length(px.rgb - paletteColor);
            if (distance < minDistance) {
                minDistance = distance;
                nearestColor = paletteColor;
            }
        }

        mean += nearestColor / float(iterations);
    }
    color.rgb = mean;
    outColor = vec4(lab2rgb(color.rgb), 1.0);
}