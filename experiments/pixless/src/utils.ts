export function createLUTTexture(gl: WebGL2RenderingContext, data: Uint8Array | Uint8ClampedArray, dimensions: number, x: number, y: number, z: number) {
    const texture = gl.createTexture();
    const target = dimensions === 3 ? gl.TEXTURE_3D : gl.TEXTURE_2D;

    gl.bindTexture(target, texture);
    gl.texParameteri(target, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(target, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    if (dimensions === 3) {
        gl.texParameteri(target, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
    }
    gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

    if (dimensions === 3) {
        gl.texImage3D(target, 0, gl.RGBA, x, y, z, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
    } else {
        gl.texImage2D(target, 0, gl.RGBA, x, y, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
    }

    gl.bindTexture(target, null);
    return texture;
}

export function hexToRgbArray(hexArray: string[]): number[][] {
    return hexArray.map(hex => {
        if (hex.length === 4) {
            hex = `#${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}`;
        }
        const bigint = parseInt(hex.slice(1), 16);
        const r = (bigint >> 16) & 255;
        const g = (bigint >> 8) & 255;
        const b = bigint & 255;
        return [r, g, b];
    });
}