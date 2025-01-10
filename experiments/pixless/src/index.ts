/// <reference lib="dom" />
// @ts-check
import { intBufferFromCanvas, GRAY8 } from "@thi.ng/pixel";
import { ditherWith, ATKINSON } from "@thi.ng/pixel-dither";
import { getHaldImage } from "./hald";
import { createLUTTexture, hexToRgbArray } from "./utils";
import { remapLUTtoPalette } from "./remap";
import vs from './shaders/identity_vs.glsl';
import bayer_dithering from './shaders/bayer_dithering.glsl'
import apply_lut from './shaders/apply_lut.glsl'
import { get, set } from 'idb-keyval'
import * as tw from 'twgl.js';

let video: HTMLVideoElement | HTMLImageElement = document.getElementById("video-source") as HTMLVideoElement;
const videoElement = document.getElementById("video-source") as HTMLVideoElement;


document.querySelector('#switch-btn')?.addEventListener('click', async () => {
    const devices = await navigator.mediaDevices.enumerateDevices();
    const videoDevices = devices.filter(device => device.kind === 'videoinput');
    if (videoDevices.length > 1) {
        const currentStream = videoElement.srcObject as MediaStream;
        currentStream.getTracks().forEach(track => track.stop());

        const currentDeviceId = (videoElement.srcObject as MediaStream).getVideoTracks()[0].getSettings().deviceId;
        const secondCamera = videoDevices.find(device => device.deviceId !== currentDeviceId);
        if (!secondCamera) {
            return;
        }
        const newStream = await navigator.mediaDevices.getUserMedia({
            video: { deviceId: secondCamera.deviceId },
            audio: false
        });

        videoElement.srcObject = newStream;
        videoElement.play();
    }
});

const screenshot = async () => {
    const canvas = document.querySelector('#lut-preview') as HTMLCanvasElement
    canvas.toBlob((blob) => {
        if (!blob) {
            return;
        }
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'lut.png';
        a.click();
        URL.revokeObjectURL(url);
    });
}

function main() {
    if (!video) return;

    // video is the id of video tag
    navigator.mediaDevices.getUserMedia({ video: true, audio: false })
        .then(async function (stream) {
            // @ts-ignore
            videoElement.srcObject = stream;
            // @ts-ignore
            videoElement.play();

            await new Promise((resolve) => videoElement.onplaying = resolve);

            startViewfinder();
            startHaldPreview();
        })
        .catch(function (err) {
            console.log("An error occurred! " + err);
        });

    document.querySelector('#shutter-btn')?.addEventListener('click', screenshot);

    const dialog = document.querySelector('#palette-dialog') as HTMLDialogElement;
    document.querySelector('#palette-btn')?.addEventListener('click', () => {
        dialog.showModal();
    })

    dialog.addEventListener('click', e => {
        // @ts-ignore
        if (e.target?.id == 'palette-dialog') {
            dialog.close();
        }
    })

    dialog.addEventListener('close', async () => {
        const input = dialog.querySelector('textarea')?.value;
        if (input) {
            const hexCodes = [...input.matchAll(/#[0-9a-fA-F]{6}/g)].map(m => m[0]);
            if (hexCodes) {
            console.log(hexCodes);
            await set('current-palette', hexCodes)
            window.location.reload();
            } else {
            console.log("No hex codes found.");
            }
        }
    })

    document.querySelector('#frame')?.addEventListener('drop', async (evt) => {
        evt.preventDefault();
        const dt: DataTransfer | undefined = evt.dataTransfer;
        if (!dt) return;
        const file = dt.files[0];
        if (!file) return;

        const fr = new FileReader();
        fr.onload = ev => {
            const img = new Image();
            img.src = ev.target?.result as string;
            video = img;
            console.log(`updated video`, video)
        }
        fr.readAsDataURL(file);
    })

    get('current-palette').then((palette: string[]) => {
        const disp = document.querySelector('#paletteDisplay')!
        disp.innerHTML = palette.map(r => `<div style="background-color: ${r}; font-size: 2em; color: ${r}">A</div>`).join('')
    })
}

/**
 * Image Processing: 
 * The image is processed line by line to conserve RAM.
 * First, it’s resampled using a custom 4-64 color palette,
 * which can be user-defined and uploaded to the SD card. 
 * The image is then enlarged by a factor of 8 (making each pixel 8x8 pixels) to avoid blurriness on various devices. 
 * Finally, it’s encoded as a PNG file for easy handling, as PNG offers lossless compression without artifacts, unlike JPG. We are also experimenting with custom compression algorithms for both PNG and JPG to optimize them for images with large areas of identical pixels.
 */



async function startHaldPreview() {
    const lutSize = 8;
    const identity_lut = await getHaldImage(lutSize);
    const lut = remapLUTtoPalette(identity_lut, hexToRgbArray(await get('current-palette') || [
        "#282828",
        "#3c3836",
        "#2e3440",
        "#3b4252",
        "#434c5e",
        "#4c566a",
        "#cccccc",
        "#ededed",
        "#fefefe",
        "#ffffff",
        "#b48ead",
        "#81a1c1",
        "#8fbcbb",
        "#5e81ac",
        "#d8dee9",
        "#e5e9f0",
        "#eceff4",
        "#a3be8c",
        "#88c0d0",
        "#bf616a",
        "#d08770",
        "#ebcb8b",
        "#ef476f",
        "#e55934",
        "#06d6a0",
        "#ffd166",
        "#feffff"
      ]));

    const lutCanvas = document.getElementById('lut-display') as HTMLCanvasElement;
    if (!lut) {
        return;
    }
    lutCanvas.width = lut.width;
    lutCanvas.height = lut.height;
    if (lutCanvas) {
        const lutContext = lutCanvas.getContext('2d');
        lutContext?.putImageData(lut, 0, 0);
    }

    setupWebGL(lut, lutSize);
}

function startViewfinder() {
    const canvas = document.getElementById('viewfinder') as HTMLCanvasElement;
    if (!canvas) {
        return;
    }
    
    const gl = canvas.getContext('webgl2');

    if (!gl) {
        return;
    }

    const srcTex = tw.createTexture(gl, { src: video });
    const fs = bayer_dithering;
    
    const programInfo = tw.createProgramInfo(gl, [vs, fs]);
    const bufferInfo = tw.primitives.createXYQuadBufferInfo(gl, 2);
    gl.useProgram(programInfo.program);

    tw.setBuffersAndAttributes(gl, programInfo, bufferInfo);
    tw.setUniformsAndBindTextures(programInfo, {
        uImage: srcTex,
    }); 

    function render() {
        tw.setTextureFromElement(gl!, srcTex, video);
        tw.drawBufferInfo(gl!, bufferInfo);
        requestAnimationFrame(render);
    }

    render();
}

function setupWebGL(lut: ImageData, lut_size: number) {
    const canvas = document.getElementById('lut-preview') as HTMLCanvasElement;
    /** @type {WebGL2RenderingContext} */
    const gl = canvas.getContext("webgl2");
    if (!gl) {
        console.error("WebGL2 not supported");
        return;
    }

    const fs = apply_lut;

    const imgTex = tw.createTexture(gl, { src: video });

    const progInfo = tw.createProgramInfo(gl, [vs, fs]);
    const bufInfo = tw.primitives.createXYQuadBufferInfo(gl, 2);

    gl.useProgram(progInfo.program);

    tw.setBuffersAndAttributes(gl, progInfo, bufInfo);

    // Load CLUT texture
    gl.activeTexture(gl.TEXTURE0 + 1);

    const lutTex = createLUTTexture(gl, lut.data, 3, lut_size * lut_size, lut_size * lut_size, lut_size * lut_size);


    tw.setUniformsAndBindTextures(progInfo, {
        uImg: imgTex,
        uLUT: lutTex,
    })

    tw.drawBufferInfo(gl, bufInfo);

    function render() {
        tw.setTextureFromElement(gl!, imgTex, video);
        tw.drawBufferInfo(gl!, bufInfo);
        setTimeout(render, 1000 / 30);
    }

    render();

}

main();
