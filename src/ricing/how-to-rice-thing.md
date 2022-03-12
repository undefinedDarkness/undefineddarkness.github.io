# How do I rice THING?

#f Emacs
The youtube channel [System Crafters](https://www.youtube.com/c/systemcrafters) has already created a significant amount of resources regarding getting starting with emacs, 
You can find them [here](https://wiki.systemcrafters.cc/emacs/) - See the Emacs From Scratch series for an indepth series of writinig your own configuraton,
But as usual, Do not follow them word for word, Experiment your own and try to understand what each and every setting does :D

Customizing emacs is 90% about your own passion, There is a lot you can do

#### How to make it fast
A pretty useless pursuit since emacs comes with its daemon mode which ought to take care of most people's need for speed,
But this is kinda fun so a few basic tips are here to make it faster at starting up:

>>>
Some of these techniques for fast startup I've documented in our [FAQ](https://github.com/hlissner/doom-emacs/blob/develop/docs/faq.org#how-does-doom-start-up-so-quickly).

The highlights are:

- I suppress garbage collection during startup,
- I lazy load our package manager. This means avoiding package-initialize or, if you use straight like Doom does, bootstrapping straight. It also means no 200+ package-installed-p checks on startup.
- Package autoloads files are concatenated into one, large file. This saves on hundreds of file reads at startup (assuming you have hundreds of packages installed). I byte-compile it too.
- Almost all our packages are lazy loaded (iirc, 2-3 out of 300 are not).

The biggest gains come from lazy loading packages. Especially the big ones, like org, helm, and magit. Doom goes a bit further with this. A couple examples:

- Dozens of packages (like recentf, savehist, autorevert, etc) are deferred until your first input (pre-command-hook) or the first file is opened (:before after-find-file).
- Org's babel packages aren't loaded all at once with org-babel-do-load-languages, but on demand when their src blocks are encountered (fontified) or executed. Same with its export backends.
- Doom loads some larger packages incrementally while it is idle. i.e. After 2s afk, it loads one of dash, f, s, with-editor, git-commit, package, eieio, lv, then transient every second, before finally loading magit (these are its dependencies). This process bows out when it detects user activity, and continues later when Emacs has been idle again for 2s. This helps with that first-time-load delay when starting magit. org and helm get similar treatment.
- If you use the daemon, the incremental-loader just loads them all immediately.

Besides that, I've collected tidbits of elisp over the years that appear to help startup time, sometimes inexplicably. Here are a couple off the top of my head:

    (add-to-list 'default-frame-alist '(font . "Fira Code-14")) instead of (set-frame-font "Fira Code-14" t t). The latter does more work than the former, under the hood.

    (setq frame-inhibit-implied-resize t) -- Emacs resizes the (GUI) frame when your newly set font is larger (or smaller) than the system default. This seems to add 0.4-1s to startup.

    (setq initial-major-mode 'fundamental-mode) -- I don't need the scratch buffer at startup. I have it a keybind away if I do. Starting text-mode at startup circumvents a couple startup optimizations (by eager-loading a couple packages associated with text modes, like flyspell), so starting it in fundamental-mode instead helps a bit.

    An odd one: tty-run-terminal-initialization adds a couple seconds to startup for tty Emacs users when it is run too early. After deferring it slightly, this doesn't appear to be an issue anymore. Not a big tty Emacs user, so YMMV.
>>>hlissner - Author of DOOM Emacs
(check the FAQ linked, it has a few more useful tricks)

There are also a few useful tricks documented [in f2k's emacs](github.com/fortuneteller2k/.emacs.d) config as well.

#END f

#f Chromium
Most chromium based browers do not support anything more than marginal theming,
It is possible to affect a few changes by your gtk theme [[example](https://github.com/phocus/gtk/blob/master/scss/gtk-3.0/applications/_chromium.scss)]

You can also make your own Chromium theme tho again, these are quite limited in scope: https://developer.chrome.com/docs/extensions/mv3/themes/

Vivaldi however allows injecting CSS into the browser UI, I found a few links on it but your mileage may vary
https://www.reddit.com/r/vivaldibrowser/comments/gso6bx/questions_about_css_customisations/
https://forum.vivaldi.net/topic/10629/vivaldi-ui-customisations
#END f

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

How to make a vim colorscheme: [Reddit](https://www.reddit.com/r/vim/comments/8mvc6s/how_to_make_a_color_scheme_for_vim/)
Colorscheme template: [RNB](https://github.com/romainl/vim-rnb)
See more on [Vim & Neovim](/out/knowledge/vim.html).

Vim has good documentation on what most of the highlight groups are for, avail yourself of it.

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
Moved section to [terminal](terminal.html)
#END f

#f Picom
*The definition of compositor changes from X11 to Wayland, I am talking about X11 only:*
Compositor is a thing that sits between your window manager and X11 and makes stuff like transparency work. Recently, however, compositors have been used to implement blur, rounded corners and animations for a window manager to behave more like a desktop enviroment.

If the version in your package repositories has the features you want, I'd suggest you use that instead.

#### I just want transparency and or shadow
You're in luck, lots of choice for you. You can use `picom` / `xcompmgr` / `compton`, anything you want and generally it'll just work™

I still suggest using picom as it has the latest technology / optimizations, beside being the
most commonly used & most supported one.
*Forcing application transparency has very little purpose in most cases however, and most user interface's are not designed with that in mind (eg: nvim)* IM:⛔

#### I want blur too
Just build the latest [master](https://github.com/yshui/picom) and use picom with the --experimental-backends option.
To build picom from source, follow the instructions in the [README](https://github.com/yshui/picom#build)
*Be very caution when using blur, excessive blur can make a rice look bad very easily.* IM:⛔

#### I want rounded corners too
Again, picom master has the thing for you, picom has implemented rounder corners in the xrender and legacy glx backends.

A few window managers can draw rounded corners out of the box, so you might be able to utilize that. (afaik awesome can)

#### I want animations too
Use one of the popular forks I guess :/, I don't know how well picom animations work, but I don't expect it to be spectacular.
The following are popular as of October 2021:
[jonaburg/picom](https://github.com/jonaburg/picom)    -> slightly buggy sliding animations
[dccsillag/picom](https://github.com/dccsillag/picom)  -> has cool, configurable animations
[pijulius/picom](https://github.com/pijulius/picom)    -> fork of dccsillag, added animations and optimisations

[Tanish2002/picom](https://github.com/Tanish2002/picom)-> also has animations, try if the others do not work

snippet to configure animations on dccsillag or pijulius

```conf
# Animations
animations = true;
animation-stiffness = 300.0;
animation-dampening = 22.0;
animation-clamping = true;
animation-mass = 1;
animation-for-open-window = "zoom";
animation-for-menu-window = "slide-down";
animation-for-transient-window = "slide-down";
# (requires pijulius)
animation-for-workspace-switch-in = "zoom";
animation-for-workspace-switch-out = "zoom";
```

Example configuration with most of the available options: https://github.com/yshui/picom/blob/next/picom.sample.conf
To get a window class for a exclude / include, use `xwininfo` or `xprop` & click the window you want.
Remember to use window classes whenever you can, window titles can be very finicky.
The 2nd part of the window class is the relevant bit, for example: 
For `Application.Navigator`, You would put `class_g = 'Navigator'` in your picom config

[Arch wiki page](https://wiki.archlinux.org/title/Picom)

#END f

#f Wallpapers
Good places to look for wallpapers are:
- https://images.google.com/
Includes a search by colour and resolution, so you can find a wallpaper matching your screen size.
- https://subtlepatterns.com/
Tiling wallpapers that are provided as backgrounds for websites.
- https://unsplash.com/
A source of free quality high res photos, all released under creative commons licensing so are free to use.
- https://wallhaven.cc/
A clone of wallbase after that was shut down, has searches by colour, resolution.
- https://web.archive.org/web/20130708152642/http://squidfingers.com/patterns
158 tiling wallpapers. [archive link because normal page is dead]
- http://simpledesktops.com/
Wonderful sets of minimal wallpapers.

Source: https://www.reddit.com/r/unixporn/wiki/ricing#wiki_wallpapers

A few personal repositories of wallpapers (usually high quality and categorized):
- Oblivousofcrap's: https://app.box.com/s/tsq119oyh0o0wagqx4a4nx74hyggvvxc 
- BlueJive's: https://github.com/Blu3Jive001/Wallpapers
- Exo's: https://gitlab.com/exorcist365/wallpapers (This one is good if you use gruvbox)
- Kraken's: https://mega.nz/folder/PpohCIpT#tII4Q60AFpgfnEYFywwlow (the biggest by far)
- Frenzy's: https://github.com/FrenzyExists/wallpapers

You could try the distro wallpaper competitions / repositories too, for example:
here's Ubuntu's competition for 21.10: https://discourse.ubuntu.com/t/wallpaper-competition-for-impish-indri-ubuntu-21-10/22852/8
Xubuntu's competition for 16.04: https://xubuntu.org/news/xubuntu-16-04-wallpaper-competition-winners/
PopOS's repository: https://github.com/pop-os/wallpapers/tree/master/original

I like [the /wg/ board too](https://boards.4chan.org/wg/) but that one is definatley very **NSFW**
[Their catalog of threads](https://boards.4chan.org/wg/catalog)

Really depends on what you're doing and looking for tho..

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
These are wallpapers that tiled like tiles in a pattern, [example](/assets/images/dump/e038c16d-6663-40b9-8b21-82ad64927848.webp) repeated over your entire screen.
Their usage is fairly simple:
`feh --bg-tile |path-to-wallpaper|` or if you have a bitmap you can use `xsetroot -bitmap |path-to-bitmap-wallpaper|`, or manually tile it in your image editor of choice.

You can find a bunch of sources here: https://notes.neeasade.net/tiled-wallpaper-sources.html, Their site has a bunch of cool ricing related stuff too.
#END f

### 
