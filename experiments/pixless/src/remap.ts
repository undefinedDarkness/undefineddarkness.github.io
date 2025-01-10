import * as tw from 'twgl.js';
import vs from './shaders/identity_vs.glsl'
import nn_sampling from './shaders/nn_sampling.glsl'
import gaussian_sampling from './shaders/gaussian_sampling.glsl'

const pad_array = function <T>(arr: T[], len: number, fill: T): T[] {
    return arr.concat(Array(len).fill(fill)).slice(0, len);
}

const shaders = {
    'nn': nn_sampling,
    'gaussian': gaussian_sampling
}

export function remapLUTtoPalette(lut: ImageData, palette: number[][], method: keyof typeof shaders = 'gaussian') {
    const canvas = document.createElement('canvas');
    canvas.width = lut.width;
    canvas.height = lut.height;
    const gl = canvas.getContext('webgl2');
    if (!gl) {
        return;
    }

    const fs = shaders[method];


    const programInfo = tw.createProgramInfo(gl, [vs, fs]);
    const bufferInfo = tw.primitives.createXYQuadBufferInfo(gl, 2);
    gl.useProgram(programInfo.program);
    tw.setBuffersAndAttributes(gl, programInfo, bufferInfo);
    tw.setUniformsAndBindTextures(programInfo, {
        uImage: tw.createTexture(gl, { src: lut }),
        palette_size: palette.length,
        offsets: [Math.random(), Math.random(), Math.random()],
        palette: pad_array(palette.map(c => [c[0] / 255, c[1] / 255, c[2] / 255]), 256, [0, 0, 0]).flat()
    });
    tw.drawBufferInfo(gl, bufferInfo);
    // document.body.appendChild(canvas);

    const imageData = new Uint8Array(canvas.width * canvas.height * 4);
    gl.readPixels(0, 0, canvas.width, canvas.height, gl.RGBA, gl.UNSIGNED_BYTE, imageData);

    const im = new ImageData(canvas.width, canvas.height);
    im.data.set(imageData);

    return im;
}