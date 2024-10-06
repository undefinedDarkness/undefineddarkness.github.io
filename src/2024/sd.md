<header>
![Rei on bike](/assets/images/dump/00004-2303370661.png)
# Playing around with Stable Diffusion
</header>

Recently I finally got my hands on a new laptop for college that has a an actual honest to goodness GPU in it!
This allowed me to explore many things that I couldn't do before such as Vulkan, AVX2 SIMD and running AI models locally among others.

Granted my GPU doesn't have the copius amounts of VRAM necessary to have a good experience with Stable Diffussion (gonna call it SD now) but still

==This guide is just a combination of my own thoughts and a small guide to whet your appetite, If you're interested, you can find detailed guides at [stable diffusion art](https://stable-diffusion-art.com/tutorials/)==

## Installation
Getting it running was a pretty simple task, You need to simply follow the instructions from [automatic1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui), Which for Windows anyway involves simply downloading an archive prepackaged with Python and whatever else you need, After that's installed, You'll need to get some Models to actually generate your images and some LORAs to tweak said images, You can think of them this way:

- A model is the thing that actually takes in all your parameters and does its "thing" to generate an image
- A LORA is like a small companion that tweaks the math in a model to increase or introduce the influence of a "concept", Examples of LORAs can be to have a very detailed image, A specific type of clothing, A specific pose, A specific facial expression things like that
- A negative embedding is the same but for things you don't want in your image

You can find these on [CivitAI](https://civitai.com/models)
