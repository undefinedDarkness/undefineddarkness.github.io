# {🎨} Design
Stuff related to the general design of a rice

#f Typography
> The style and appearance of printed matter.

This is one place where you can really stand out and using a good font can make all the difference for both the looks of your rice, as well as its usability.
Generally you will need 3 font faces:
- A sans serif face for general user interface
- A monospace font for code
- A serif fonts for documents

More on the differences between serif, sans-serif and mono space: https://www.canva.com/learn/serif-vs-sans-serif-fonts/

You can find most of them on [Google Fonts](https://fonts.google.com);
More on fonts: https://github.com/wooosh/themewiki/blob/master/guide/fonts.md
Here are the fonts I personally like for each one:

#### Mono space:
<div class="horizontal showcase">
![Roboto Mono](/assets/images/font-previews/Roboto-Mono-Regular.webp)
![IBM Plex Mono](/assets/images/font-previews/IBM-Plex-Mono-Regular.webp)
![JetBrains Mono](/assets/images/font-previews/JetBrains-Mono-Regular.webp)
![Sarasa Term K](/assets/images/font-previews/Sarasa-Term-K.webp)
[![Julia Mono](/assets/images/font-previews/JuliaMono-Regular.webp)](https://juliamono.netlify.app/)
</div>

#### Serif:
<div class="horizontal showcase">
[![Redaction](/assets/images/font-previews/Redaction.webp)](https://www.redaction.us/)
[![ET Bembo](/assets/images/font-previews/ETBembo-RomanLF.webp)](https://edwardtufte.github.io/et-book/)
[![Piazzolla](/assets/images/font-previews/Piazzolla-Regular.webp)](https://fonts.google.com/specimen/Piazzolla)
</div>

#### Sans Serif:
<div class="horizontal showcase">
![Roboto](/assets/images/font-previews/Roboto.webp)
![Ubuntu Sans](/assets/images/font-previews/Ubuntu-Regular.webp)
![IBM Plex Sans](/assets/images/font-previews/IBM-Plex-Sans-Regular.webp)
![Poppins](/assets/images/font-previews/Poppins-Regular.webp)
</div>

🏴‍☠️ [Repository of mostly monospace fonts](https://gitlab.com/exorcist365/fonts)
Compare Different Fonts: [ThemeWiki](https://wooosh.github.io/themewiki/fontindex/)

#### Nerd Fonts
Nerd fonts are patched versions of common fonts you know and love to include a large amount of text icons, these are commonly used in apps that are unable to actually render icons.

Where to get: https://www.nerdfonts.com/font-downloads (Get the one for the font you want)
What icons are there: https://www.nerdfonts.com/cheat-sheet
You then copy the icons from the site (^^) and use them in whatever text application you so choose.
How to patch your own font:
```sh
# Download the nerd fonts patcher and the glyphs it needs.
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
cd nerd-fonts
git sparse-checkout add src/glyphs

# Using the patcher
# You need fontforge & Python 3 for this to work:
./font-patcher <PATH TO FONT>
```

#### Bitmap Fonts

<div class="split">
<img height="400" class='pxl' src="/assets/images/bitmap-eg.webp" title="Without AA" alt="Without AA" />
<img height="400" class='pxl' src="/assets/images/aa-eg.webp" title="With AA" alt="With AA" />
</div>

[What are they?](http://www.cs.ucc.ie/~gavin/cs1050/the_internet/slides/ch07s01s01.html.htm)

Effectively this means,
Bitmaps will not scale outside their designed font size;
They will generally look a lot sharper than vector fonts because they are generally rendered without [AA](https://www.youtube.com/watch?v=hqi0114mwtY);
All of which leads to pretty unique pixilated look that a lot of people like.

##### Using in GUI Applications
Pango (a text library used in most GUI applications on Linux) does not directly support bitmap fonts, but it is still possible to get them to work,
Bitmap fonts can be converted to a truetype (supported by pango) trojan horse which contains the bitmap data, using tools like, fontforge or [fonttosfnt](https://gitlab.freedesktop.org/xorg/app/fonttosfnt),
See more: https://nixers.net/Thread-Bitmap-fonts-PCF-BDF-support-with-Pango

You can also get GTK applications (this includes most browsers) to not antialias by using: `Xft.antialias: 0` in xresources.

Some distributions have disabled bitmap fonts by default, but you can fix it by following these steps:
```sh
cd /etc/fonts/conf.d/
sudo rm -rf 70-no-bitmaps.conf && sudo ln -s ../conf.avail/70-yes-bitmaps.conf .
```
##### 
Commonly used bitmap fonts:
<div class='showcase horizontal'>
[![Cozette](/assets/images/font-previews/CozetteVector.png)](https://github.com/slavfox/Cozette)
[![GohuFont](/assets/images/font-previews/Gohu-GohuFont.webp)](https://font.gohu.org)
[![Terminus](/assets/images/font-previews/Terminus.png)](https://terminus-font.sourceforge.net)	
[![Unifont](/assets/images/font-previews/Unifont-Nerd-Font-Complete.png)](https://unifoundry.com/unifont/)
<span>Cherry</span>
<span>Scientifica</span>
</div>

[Repository Of Bitmap Fonts](https://github.com/Tecate/bitmap-fonts)
[Upscaling Bitmap Fonts](https://github.com/Francesco149/bdf2x)
<!-- TODO: Add a link on making a bitmap font to vector font
		   Making use of bitmap fonts in pango etc apps -->

#### Installing Fonts
Once you have your font files (usually in .ttf or .otf), You can install them by simply moving them to `~/.local/share/fonts`

#END f

## Conventions
#f CSS Box Model
<aside>
<p>This is important in many parts of ricing,
and is the general method to define spacing in most applications.

Content is your text, image whatever
Padding is spacing around the content but still within the box
Border is a border around the box
Margin is spacing between the box and its siblings / parent box.

[Better explanation](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Box_Model/Introduction_to_the_CSS_box_model)
</p>

![Box Model Illustration](/assets/images/box-model.webp)
</aside>
#END f
