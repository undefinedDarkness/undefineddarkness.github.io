# A day of fixing bitmap fonts on Linux/X11

Bitmap fonts are something I have always been very interested in,
They do not offer much or any of the flexibility vector fonts have made common place but
In return you recieve a simple thing, pixel perfect text, that is without any anti aliasing whatsoever.

However, It has been a pain point for me to get them working as I wish as many of the text rendering software on linux at least expects vector fonts and is configured as such.

To get started, I wanted to install the [cherry](https://github.com/turquoise-hexagon/cherry) font, handily it comes with a install script that wouldnt you know it, *doesnt work* :<
While it builds to Opentype Bitmap Font files just fine, `fc-list` just doesnt find them.

*NOTE*: This behaviour tends to be very inconsistent across distros, it *just* works in some distributions, but for context, I am writing from an Debian machine, I expect much of it to apply to Ubuntu distros too

Why would that be? well even though there is support for them implemented for both font config and xft; Debian has disabled them, for a pretty good reason.
Bitmap looks like shit for almost every case in modern UI and only works in some very specific contexts, Besides that it can look even worse on some high resolution displays as they don't contain a lot of detail and can't be scaled up much.

Besides that pango techically removed support for them when it switched to harfbuzz for its text shaping, though in some configurations, you can get it to work.

But, not all hope is lost, if you are determined enough, it is possible to renable them.

## Reenabling
Font config configurations are stored in xml files and debian ships with several pre made ones installed / available to be installed.

Any installed configurations can be found in `/etc/fonts/conf.d`
And available configurations can be found in `/etc/fonts/avail.d` & `/usr/share/fontconfig/conf.avail`

You can verify any installed configurations  with `$ fc-conflist`

You'll notice a `70-no-bitmaps.conf` file that is the culprit for our bitmap starvation.
to disable it, you can simply remove the symlink with `rm`.

Once this is done however, you will notice text in your web browser (firefox in my case, might apply to chromium too, idk) becoming a shitshow.
This happens because sites can use system fonts which it expects to be installed on every system, eg: sans-serif, serif, monospace to avoid loading custom fonts or to fit in more with the rest of the operating system.
You can notice this effect rather prominently on Github & Wikipedia.

On a fresh debian install,
`sans-serif` will be matched to `DejaVu Sans`
`monospace` will be matched to `Liberation Mono`
`serif` will be matched to `DejaVu Serif`
I am guessing these from memory, it might be something else, you can find out with `fc-match`

After our little wrench was thrown in the works, all the X11 core fonts are now available for font-config to choose from (about 814 fonts in total),
This would be all within expectations, if some for god given reason, many of the X11 fonts are bitmap variants of fonts that are common use today as vectors, eg: Helvetica, Times New Roman, ...
With this much choice (bitmaps + vectors), FC gets very confused and tends to prefer picking bitmaps, ruining our good UI design.

I am not certain why it is this way, but I also don't want to dig deep into FC configuration to find out, and my current hack that seems to have worked in most cases that I have personally encountered is to create a different FC config with a higher priority and setup aliases for common font names
so that they will point to modern vector fonts.

My current alias file: 
```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <description>
  	Alias common font names to vectors, to avoid bitmaps messing it up
  </description>

  <alias binding="same">
    <family>Helvetica</family>
    <prefer>
      <family>Liberation Sans</family>
    </prefer>
  </alias>

</fontconfig>
```

hopefully its workings are visible to you, this file can be placed as `~/.config/fontconfig/conf.d/01-alias.conf` or in one of the other places font config will look.
And there you go, kinda working bitmap fonts!

To use them, `fc-list` can find the xft font description to string and their font names.
`xfontsel` can also be used but iirc thats only in the case of .pcf.gz fonts installed directly into X11
