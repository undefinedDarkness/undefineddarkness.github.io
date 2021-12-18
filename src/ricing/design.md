# {🎨} Design
Stuff related to the general design of a rice

#f Colorscheme
Quite possibly the most important part of a rice is the colorscheme you use, for most ricing purposes, they are structured like this:

![structure](/assets/images/colorscheme-structure.png)

This is what most colorschemes will have for a terminal. Of course when making a colorscheme for an editor (vim, emacs etc) a lot more colors are used.
If you are going to make a colorscheme, You should also follow this structure, as in have 8 dim colors and 8 bright colors. (It is quite common to have the dim colors be the same as the bright colors which is fine),
Those 8 should be Red, Green, Blue, Yellow, Cyan, Magenta, White, Black
*Using different shades of one color for each of those is a very bad idea*
While this is enough for most terminals, Adapting this limited amount of colors to other GUI apps is difficult, in which case, having multiple shades of the background color and of other common colors would be useful.
#END f
#f Typography
> The style and appearance of printed matter.

This is one place where you can really stand out and using a good font can make all the difference for both the looks of your rice, as well as its usability.
Generally you will need 3 font faces:
- A sans serif face for general user interface
- A monospace font for code
- A serif fonts for documents

More on the differences between serif, sans-serif and mono space: https://www.canva.com/learn/serif-vs-sans-serif-fonts/

You can find most of them on [Google Fonts](https://fonts.google.com)
Here are the fonts I personally like for each one:

#### Mono space:
#TABLE	.tbl-showcase
![preview](/assets/images/font-previews/Roboto-Mono-Regular.png)	![preview](/assets/images/font-previews/IBM-Plex-Mono-Regular.png)	![preview](/assets/images/font-previews/JetBrains-Mono-Regular.png)	![preview](/assets/images/font-previews/Sarasa-Term-K.png)	![preview](/assets/images/font-previews/JuliaMono-Regular.png)
Roboto Mono															IBM Plex Mono														JetBrains Mono														Iosevka														[JuliaMono](https://juliamono.netlify.app/)
#END TABLE

#### Serif:
#TABLE	.tbl-showcase
![preview](/assets/images/font-previews/ETBembo-RomanLF.png)	![preview](/assets/images/font-previews/Merriweather-Regular.png)	![preview](/assets/images/font-previews/Piazzolla-Regular.png)	![preview](/assets/images/font-previews/Libre-Baskerville.png)
[ET Bembo](https://edwardtufte.github.io/et-book/)				Merriweather														[Piazzolla](https://piazzolla.huertatipografica.com/)			Libre Baskerville
#END TABLE

#### Sans Serif:
#TABLE	.tbl-showcase
![preview](/assets/images/font-previews/Roboto.png)	![preview](/assets/images/font-previews/Ubuntu-Regular.png)	![preview](/assets/images/font-previews/IBM-Plex-Sans-Regular.png)	![preview](/assets/images/font-previews/Lexend-Deca-Regular.png)	![preview](/assets/images/font-previews/Poppins-Regular.png)
Roboto	Ubuntu Sans	IBM Plex Sans	Lexend Deca	Poppins
#END TABLE

🏴‍☠️ [Repository of mostly monospace fonts](https://gitlab.com/exorcist365/fonts)
Compare Different Fonts: [ThemeWiki](https://wooosh.github.io/themewiki/fontindex/)

#### Nerd Fonts
Nerd fonts are patched versions of common fonts you know and love to include a large amount of text icons, these are commonly used in apps that are unable to actually render icons.

Where to get: https://www.nerdfonts.com/font-downloads (Get the one for the font you want)
What icons are there: https://www.nerdfonts.com/cheat-sheet
How to patch your own font:
```sh
#~ Download the nerd fonts patcher and the glyphs it needs.
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
cd nerd-fonts
git sparse-checkout add src/glyphs

#~ Using the patcher
#~ You need fontforge & Python 3 for this to work:
./font-patcher <PATH TO FONT>
```

#### Bitmap Fonts
[What are they?](http://www.cs.ucc.ie/~gavin/cs1050/the_internet/slides/ch07s01s01.html.htm)

Effectively this means,
Bitmaps will not scale outside their designed font size;
They will generally look a lot sharper than vector fonts because they are generally rendered without [AA](https://www.youtube.com/watch?v=hqi0114mwtY);
All of which leads to pretty unique pixilated look that a lot of people like.

##### Using in GUI Applications
Pango (a text library used in most GUI applications on Linux) does not directly support bitmap fonts, but it is still possible to get them to work,
Bitmap fonts can be converted to a truetype (supported by pango) trojan horse which contains the bitmap data, using tools like, fontforge or [fonttosfnt](https://gitlab.freedesktop.org/xorg/app/fonttosfnt),
See more: https://nixers.net/Thread-Bitmap-fonts-PCF-BDF-support-with-Pango

##### Commonly used bitmap fonts:
#TABLE	.tbl-showcase
![preview](/assets/images/font-previews/CozetteVector.png)	![preview](/assets/images/font-previews/Gohu-GohuFont.png)	![preview](/assets/images/font-previews/Terminus.png)	![preview](/assets/images/font-previews/Unifont-Nerd-Font-Complete.png)	~	~
[Cozette](https://github.com/slavfox/Cozette)	[Gohu](https://font.gohu.org/)	[Terminus](http://terminus-font.sourceforge.net/)	[GNU Unifont](https://unifoundry.com/unifont/)	[Cherry](https://github.com/turquoise-hexagon/cherry)	[Scientifica](https://github.com/NerdyPepper/scientifica) / [Curie](https://github.com/nerdypepper/curie)
#END TABLE

[Repository Of Bitmap Fonts](https://github.com/Tecate/bitmap-fonts)
[Upscaling Bitmap Fonts](https://github.com/Francesco149/bdf2x)
<!-- TODO: Add a link on making a bitmap font to vector font
		   Making use of bitmap fonts in pango etc apps -->

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

![Box Model Illustration](/assets/images/box-model.png)
</aside>
#END f


