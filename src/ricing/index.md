<!-- vim: set nolist: -->
# {🍱} Reference
#PRESERVE-CENTER
**See the other modules:**
[Design](/out/ricing/design.html) - [Useful Information](/out/ricing/useful.html) - [Terminology](/out/ricing/terminology.html)
#END PRESERVE-CENTER
My own take at a ricing guide. - Many people have helped with this, so doesn't make sense to call it my own.
Most of it is useless if you already know, and it only covers the **very** very basics.
List of ricing software you can use: https://github.com/fosslife/awesome-ricing

## How do I use X?

#f Firefox
You can customize the User Interface (Chrome) with Firefox CSS, see the following:
- [Getting started guide](https://www.reddit.com/r/FirefoxCSS/wiki/index/tutorials)
- [How to create & live debug userChrome.css](https://www.reddit.com/r/FirefoxCSS/comments/73dvty/tutorial_how_to_create_and_livedebug_userchromecss/)
- [Collection of resources related to userChrome](https://www.userchrome.org/)

You can use [Stylus](https://add0n.com/stylus.html) to modify the appearance of certain websites.
*NOTE: Does not work on extension (except Stylus) and built-in browser webpages.*

Firefox also supports `userContent.css` for overriding the styles of a site, To use it simply follow the same instructions as for userChrome.css but create this file too in the same directory (chrome),
The structure of the file is usually as follows:
```css
@-moz-document domain("discord.com") {
	/* Your styles go here. */
}
```
You can use any of the selectors available for [@-moz-document](https://developer.mozilla.org/en-US/docs/Web/CSS/@document)
*NOTE: Stylus can also export to this format for easy usage*

#### Start Page
You will need basic knowledge of HTML, CSS & JS.
[MDN](https://developer.mozilla.org/en-US/) is a nice place to learn.

Firefox has quite a few limitations on setting local files as your start page (no external requests or imports of any kind), so it may be easier to host your start page on some static site hosting service (GitHub Pages, Netlify, Surge.sh).

Then use [this extension](https://addons.mozilla.org/en-US/firefox/addon/new-tab-override/) to set the URL.
Chromium users can use [this](https://chrome.google.com/webstore/detail/custom-new-tab-url/mmjbdbjnoablegbkcklggeknkfcjkjia) instead (Chrome places no limitations).
#END f

#f GTK
This is most easily accomplished by forking an existing theme and modifying them. Most themes are open source and
are easily modifiable (if you know CSS). Phocus is a nice one to start with since its code is clean scss and well structured, (https://github.com/phocus/gtk)
*NOTE: Phocus is not a GTK2 theme so it will not show up in `lxappearance`, Set your gtk theme using [settings.ini](https://wiki.archlinux.org/title/GTK#Basic_theme_configuration) instead,
this is because lxappearance expects a legacy gtk2 theme along with a gtk3, which modern themes do not have.*

You can use `gtk-widget-factory` to test your theme, it comes packaged with `gtk-demos` on arch & debian.
GTK CSS reference: https://docs.gtk.org/gtk4/css-properties.html
Using the GTK Debugger: https://elkowar.github.io/eww/working_with_gtk.html#gtk-debugger (This should work anywhere)

#### Uniform Look for GTK & QT Apps

Arch Wiki Link: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications#Theme_engines

By default, you have to apply themes for QT and GTK separately, with most GTK themes not having a QT counterpart.

To achieve a consistent look over both the styles, you can install **theme engines** like QGtkStyle (https://github.com/qt/qtstyleplugins) or QGnomePlatform (https://github.com/FedoraQt/QGnomePlatform).
These theme engines can be used to translate themes between GTK and QT platforms.

#### QGtkStyle
After installing, you have to make changes the following changes

**For QT4:** Edit the /etc/xdg/Trolltech.conf (system-wide) or ~/.config/Trolltech.conf (user-specific) file:

~/.config/Trolltech.conf
```ini
[Qt]
style=GTK+
```

**For QT5:** set the environment variable `QT_QPA_PLATFORMTHEME=gtk2`

*NOTE: This requires that the configured GTK theme supports both GTK 2 and GTK 3*

#### QGnomePlatform
This theme applies the appearance settings of GNOME for QT Applications. It is enabled by default on GNOME since version 3.20.
To enable it on other systems, after installing the qgnomeplatform package, set the environment variable:

```sh
QT_QPA_PLATFORMTHEME=gnome
```
#END f

#f Neovim / Vim
This is an interesting one. If you use a premade colorscheme, chances are, a [base16](https://github.com/chriskempson/base16) or other vim theme already exists for it. Otherwise, you can make a base16 theme or make one from a wide variety of templates. There even exist generators for it. ([Pinto](https://pintovim.dev/), [Vivify](https://bytefluent.com/vivify/))
And, of course, if a colorscheme is similar to yours, you can easily fork it and modify.

Besides colors, in terms of functionality you are free to find / forge whatever to fit your needs.
See more on [vim & neovim](/out/knowledge/vim.html).

How to make a vim colorscheme: [Reddit](https://www.reddit.com/r/vim/comments/8mvc6s/how_to_make_a_color_scheme_for_vim/)
Colorscheme template: [RNB](https://github.com/romainl/vim-rnb)

#### Get highlight group under cursor
Since i've been writing a port for [chocolate](https://gitlab.com/snakedye/chocolate), this is a problem i've encountered, the real basic solution is to do:
```vim
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
```

but this doesnt work that well for treesitter, in which case using [this code from treesitter-playground](https://github.com/nvim-treesitter/playground/blob/master/lua/nvim-treesitter-playground/hl-info.lua) works a fair bit better,
to use them more easily, create a keybinding for `SynStack()` or `require('hl-info').show_hl_captures()` respectivley

#END f

#f Terminal
This is really simple too: popular color schemes usually have been ported for common terminal programs, even if it doesn't, it should still be really simple to implement, it's just 16 colors after all :P

#### Comparison
This is a general comparison of the most common terminal emulators as of October 2021.

#TABLE	NAME	Ligatures	True Color	Fallback Fonts	OTF	Bitmaps	Wayland	Tabs / Splits	Images	Config			GPU		✨
Wezterm			Y			Y			Y				Y		Y		Y		Y			  Y		Lua				Y		10/10
Alacritty		P			Y			N				N		Y		Y		N			  N		Yaml			Y		5/10
Kitty			Y			Y			N				Y		N		Y		Y			  Y		Custom			Y		8/10
Xterm			N			N			N				N		Y		N		N			  N		Xres			N		5/10
St				P			Y			P				N		Y		N		N			  P		C Header		N		8/10
Foot			N			Y			Y				N		Y		Y		N			  Y		INI				N		~
#END TABLE

**Notes:**
OTF = Open Type Features such as stylistic sets and the like
P = With a patch or a fork
Alacritty is the most commonly used terminal, (in the UP discord)
Foot is wayland only.
If you are looking into using st, I highly suggest you use [st-flexipatch](https://github.com/bakkeby/st-flexipatch) instead as it is much easier to use and modify.
<!-- TODO: Add links to the forks / patches here -->

Fork for ligatures in alacritty (super out of date and the alacritty author recommends just using another terminal):
https://github.com/zenixls2/alacritty
st patches: https://st.suckless.org/patches/

[Arch wiki page](https://wiki.archlinux.org/title/List_of_applications#Terminal)

#### Images in the Terminal
This is an often sought after feature and often used with fetch scripts.
Right now there is no standard and each terminal does their own thing, more and more are supporting [sixel](https://en.wikipedia.org/wiki/Sixel), though, so maybe that will end up being the standard.
For terminals without image support entirely, there are hacks using `w3m-img` and `uberzerg` to get them...but they're finicky and don't just work™, so I'd recommend against them.
[Full article](https://github.com/dylanaraps/neofetch/wiki/Images-in-the-terminal)

But here's a overview:
Alacritty doesn't support images and needs a hack;
Wezterm natively supports iterms2's image format & sixel;
Kitty has its own format;
St can support sixel via a [patch](https://gitlab.com/exorcist365/dotfulls/-/blob/master/.local/share/src/st/patches/0001-add-st-sixel.patch) and it needs a patch for the w3m hack to work too.
#END f

#f Picom
*The definition of compositor changes from X11 to Wayland, I am talking about X11 only:*
Compositor is a thing that sits between your window manager and X11 and makes stuff like transparency work. Recently, however, compositors have been used to implement blur, rounded corners and animations for a window manager to behave more like a desktop enviroment.

If the version in your package repositories has the features you want, I'd suggest you use that instead.

#### I just want transparency and or shadow
You're in luck, lots of choice for you. You can use `picom` / `xcompmgr` / `compton`, anything you want and generally it'll just work™™™

I still suggest using picom as it has the latest technology / optimizations, beside being the
most commonly used & most supported one.
⛔: *Forcing application transparency without blur is also fairly shitty.*

#### I want blur too
Just build the latest [master](https://github.com/yshui/picom) and use picom with the --experimental-backends option.
To build picom from source, follow the instructions in the [README](https://github.com/yshui/picom#build)
⛔: *Using blur is cringe and in 99.99% of cases is unnecessary or used in a rather ugly manner.*

#### I want rounded corners too
Again, picom master has the thing for you, picom has implemented rounder corners in the xrender and legacy glx backends.

A few window managers can draw rounded corners out of the box, so you might be able to utilize that.

#### I want animations too
Use one of the popular forks I guess :/, I don't know how well picom animations work, but I don't expect it to be spectacular.
The following are popular as of October 2021:
[jonaburg/picom](https://github.com/jonaburg/picom)    -> slightly buggy sliding animations
[dccsillag/picom](https://github.com/dccsillag/picom)  -> has cool, configurable animations
[pijulius/picom](https://github.com/pijulius/picom)    -> fork of dccsillag, added animations and optimisations
[Tanish2002/picom](https://github.com/Tanish2002/picom)-> also has animations, try if the others do not work

snippet to configure animations on dccsillag or pijulius

```conf
#~ Animations
animations = true;
animation-stiffness = 300.0;
animation-dampening = 22.0;
animation-clamping = true;
animation-mass = 1;
animation-for-open-window = "zoom";
animation-for-menu-window = "slide-down";
animation-for-transient-window = "slide-down";
#~ (requires pijulius)
animation-for-workspace-switch-in = "zoom";
animation-for-workspace-switch-out = "zoom";
```

Example configuration with most of the available options: https://github.com/yshui/picom/blob/next/picom.sample.conf
To get a window class for a exclude / include, use `xwininfo` or `xprop` & click the window you want. Remember to use window classes whenever you can, window titles can be very finicky.

[Arch wiki page](https://wiki.archlinux.org/title/Picom)
#END f

#f Wallpapers

#### Animated Wallpapers
For those who don't know how to set animated walls, here's a command for it (you will need xwinwrap and mpv for video files or gifview for gif files):

`xwinwrap -fs -fdt -ni -b -nf -un -o 1.0 -debug -- mpv -wid WID --loop --no-audio ~/path/to/video.mp4`

If the above doesn't work correctly, use this one:
`xwinwrap -ov -g 1920x1080+0+0 -- mpv -wid WID ~/path/to/video.flv --no-osc --no-osd-bar --loop-file --player-operation-mode=cplayer --no-audio --panscan=1.0 --no-input-default-bindings`

Sources for pixelart animated wallpapers
https://1041uuu.tumblr.com/
https://waneella.tumblr.com/

Googling will also get you a bit of resources .

#### Tiled Wallpapers
These are wallpapers that tiled like tiles in a pattern, [example](https://cdn.discordapp.com/attachments/635625973764849684/898589548999745626/unknown.png) repeated over your entire screen.
Their usage is fairly simple:
`feh --bg-tile |path-to-wallpaper|` or if you have a bitmap you can use `xsetroot -bitmap |path-to-bitmap-wallpaper|`, or manually tile it in your image editor of choice.

You can find a bunch of sources here: https://notes.neeasade.net/tiled-wallpaper-sources.html, Their site has a bunch of cool ricing related stuff too.
#END f

### Credits
Most of the following are members of the r/unixporn discord server.

Animated Wallpaper - Dazai-san#6969
Picom Animations - nuxsh#9338
Uniform Look for GTK & QT Apps, QGtkStyle - Gingka#1796 
Document has been edited by asdadsdafdfdssfd#7660
