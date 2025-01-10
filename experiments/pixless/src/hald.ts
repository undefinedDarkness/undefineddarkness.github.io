import { get, set } from 'idb-keyval'

const generateHaldImage = (level: number) => {
  const cube_size = level*level;
  const image_size = cube_size * level;
  const data = new Uint8ClampedArray(image_size * image_size * 4);
  let p = 0;
  for (let i = 0; i < cube_size; i++) {
    for (let j = 0; j < cube_size; j++) {
      for (let k = 0; k < cube_size; k++) {
        data[p++] = k * 256 / (cube_size - 1);
        data[p++] = j * 256 / (cube_size - 1);
        data[p++] = i * 256 / (cube_size - 1);
        data[p++] = 255;
      }
    }
  }

  return data;
};

export const getHaldImage = async (level: number) => {
  const cacheKey = `haldImage-${level}`;
  const cachedData = await get(cacheKey);
  if (cachedData) {
    return cachedData;
  }
  const data = generateHaldImage(level);
  const cube_size = level * level;
  const imageSize = level * cube_size;
  const imgData = new ImageData(imageSize, imageSize);// ctx.createImageData(imageSize, imageSize);
  imgData.data.set(data);
  await set(cacheKey, imgData);
  return imgData;
};
