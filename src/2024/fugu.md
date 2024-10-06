<header>
# 2024, What can the web do? 🐡
</header>

Lately, I've been really interested in PWAs and how the web platform keeps becoming a platform for a very wide array of apps, removing much of the reason people use things like Electron or Tauri and decoupling web apps from the user's system & exposing powerful capabilities from within the sandbox.

## 📂 File System Access
This is one of the most exciting ones for me, With this API, a user can grant access to a specified directory in their local file system, This API also encompasses a save file API to replace the standard hidden download button trick and an API for easily opening a system file picker to allow the web app access to a specific file.

This can be very useful in an app like Photopea and it might even be enough for many electron applications to be only web apps, for example Obsidian comes to mind, you could grant it access to a VAULT folder and (to my belief) it could function almost entirely as a website

To use it, you need to run [`window.showOpenFilePicker`](https://developer.mozilla.org/en-US/docs/Web/API/Window/showOpenFilePicker) or [`window.showOpenDirectoryPicker`](https://developer.mozilla.org/en-US/docs/Web/API/Window/showDirectoryPicker) on button activation, If it's to save a single file you can instead use [`window.showSaveFilePicker`](https://developer.mozilla.org/en-US/docs/Web/API/Window/showSaveFilePicker), From there you get a File or Directory Handle which can be used to read / write to the file / directory.

Unfortunatley, This hasn't been implemented by Mozilla ([Mozilla's Position](https://mozilla.github.io/standards-positions/#native-file-system)) & WebKit ([WebKit's Position](https://github.com/WebKit/standards-positions/issues/28)) :/, Which is reasonable since most websites don't need access to a user's file system and careless users could easily cause irreparable harm, I think it's still quite useful :P

Here's an example:
<iframe src='/experiments/fsa.html'></iframe>

- [WhatWG Standard](https://fs.spec.whatwg.org/)
- [Chrome Documentation](https://developer.chrome.com/docs/capabilities/web-apis/file-system-access)

## Compression Streams
These recently added streams allow you to read and write compressed data to streams (think blobs / files), Right now only `gzip`, `deflate` or `deflate-raw` are supported options, But I'm keeping my fingers crossed for brotli or zstd to be added 🤞

In the meantime, people have been compressing [their web pages by storing it inside a WebP image](https://purplesyringa.moe/blog/webp-the-webpage-compression-format/), I wonder what result's one would get with AVIF though I don't imagine them to be *too* different 

<iframe class='nb' src='https://bcd-table.neswk.workers.dev/?style=true&key=api.CompressionStream'></iframe>

- [Issue for zstd](https://github.com/whatwg/compression/issues/54)
- [Issue for brotli](https://github.com/whatwg/compression/issues/54)
- [WhatWG Standard](https://compression.spec.whatwg.org/#compressionstream)
- [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Compression_Streams_API)

## 🗃️ Real Time Communication 
Ever wanted to easily connect 2 instances of your website and transfer arbitrary data between them or even Audio / Video streams? Well with WebRTC, you can, you only need a signalling server for some initial communication between the clients, which can be easily done with a library like ~~[peer.js](https://peerjs.com/)~~ [feross/simple-peer](https://github.com/feross/simple-peer),

Once the connection is established, data can be transferred in [RTCDataChannels](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel) or a media (video / auto) stream can be mostly handled by the browser itself and then rendered in a canvas.

This is what powers stuff like [WebTorrent](https://webtorrent.io/) & [ShareDrop](https://github.com/szimek/sharedrop)

<iframe class='nb' src='https://bcd-table.neswk.workers.dev/?style=true&key=api.RTCPeerConnection'></iframe>

- [Firebase course for WebRTC](https://fireship.io/lessons/webrtc-firebase-video-chat/)
- [MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)

## PWA: Share, URL Scheme, Custom titlebar
This is just a few of the *many* PWA APIs that I find especially cool or useful

[A full list from web.dev](https://web.dev/learn/pwa/capabilities)
[Project Fugu Showcase](https://developer.chrome.com/docs/capabilities/fugu-showcase)

### Share Target
Essentially this lets you add an entry to your system's share menu, you'd be most familiar with this on mobile devices, where you want to share a file, a url or anything to a friend through this menu

A few notes on usage, this API allows your app to recieve both files and textual data like links and what not, but if you're dealing with a file, it must be a **POST** request to an endpoint in your app, *Hint: Making this a service worker will make your life a lot easier I promise* otherwise if it's a GET request, any binary data is discarded and textual data are inserted as URL query parameters as per what's defined in your `manifest.json`

This one is quite useful on mobile devices, kinda mid on desktop, but the real pity is it seems to be pretty inconsistent, I've used this with a personal PWA I've made to make file sharing friction-less (Goodbye, slow af notion uploads) and when I tried installing it on my Android phone through the Brave browser (My usual browser), It doesn't work :/, After some research I discovered the cause to be that as brave is a user installed application, It can't register *new* share targets of it's own, Chrome being a system installed app has the appropriate permissions to do so and works without a hitch, Even then behaviour was a little off, on my development Windows 10 machine, The share target worked just fine but on my friend's Windows 11 machine, It installed fine but the app was missing from the share menu, I'm not entirely sure why and I haven't had time to research since right now the PWA fulfills exactly what I wanted to do.

<iframe class='nb' src='https://bcd-table.neswk.workers.dev/?style=true&key=html.manifest.share_target'></iframe>

- [Chrome Article](https://developer.chrome.com/docs/capabilities/web-apis/web-share-target)

### Custom titlebar
I remember seeing this in one the issues for [gluon](https://github.com/gluon-framework/gluon/issues/13), It's an API that allows the PWA to draw on the "titlebar" of it's application window with the browser just providing window controls (close/minimize/maximize).

Again seems to only be implemented by Chromium though :/

![Custom titlebar example](/assets/images/image.png)

<iframe class='nb' src='https://bcd-table.neswk.workers.dev/?style=true&key=api.WindowControlsOverlay'></iframe>

[Web.dev Article](https://web.dev/articles/window-controls-overlay)
