<header>
```
                  ,____
                   |---.\
           ___     |    `
          / .-\  ./=)
         |  |"|_/\/|
         ;  |-;| /_|
        / \_| |/ \ |
       /      \/\( |
       |   /  |` ) |
       /   \ _/    |
      /--._/  \    |
      `/|)    |    /
        /     |   |
      .'      |   |
     /         \  |
    (_.-.__.__./  /
```
Got a display server to kill
<h1>My experience with wayland</h1>
</header>
This is intended to chronicle my adventures using Wayland
The primary reason being terrible performance in X11 but that was later resolved. :)
The journey continues tho 📔

## Window Manager (Compositor) 
<i>I know its called a compositer but I am going to call it a window manager >:(</i>
To fulfill this purpose I chose <a href="https://swaywm.org/">sway</a> as its the one I felt I could most get used to
since I had used its Xorg brother (i3) for a long while

And..
It works really well! It's performance is very impressive compared to what I am used to
I have a few scruples with its configuration format and its refusal to add features i3 lacks but oh well..,
not like I'm gonna be writing my own compositor any time soon

Coming from awesomewm, I would have liked to find something similar 
and that sort of exists in the form of <a href="https://taiwins.org/index.html">Taiwins</a> but its very different from what I am used to 
and I am not keen on using it as it is rather unstable and documentation is lacking

### Screenshots
What is the point of making a epic rice if there is no way to showcase it!
Wayland seems a bit more fiddly compared to the centralized xorg in terms of recording 
but its not that bad. I had to use <a href="https://github.com/emersion/grim">grim</a> along with this <a href="https://github.com/swaywm/sway/blob/master/contrib/grimshot">script</a> from sway to get
Nothing particularly difficult but not as cohesive as id like :/

## Moving from Xorg 
This is a bit of a generic header but oh well

Much to my surprise this wasnt as bad as I thought it would be,
rofi, wezterm, firefox & dunst - all programs I am used to from Xorg could work 
natively (without Xwayland) on wayland

Although most of them required tweaking in some form or another

<b>ROFI:</b> This does use a fork
```sh
git clone --recurse-submodules https://github.com/lbonn/rofi
cd rofi
meson setup build -Dwayland=enabled --prefix=/usr/local
ninja -C build
ninja -C build install
```
<p></p>
<b>FIREFOX:</b> Might need to modify some desktop files to get it to work right
```
MOZ_ENABLE_WAYLAND=1 firefox
```
** Wezterm has issues with the wayland clipboard. I think using <a href="https://codeberg.org/dnkl/foot">foot</a> would be a better idea
** Firefox crashed more often for me in wayland but that may or may not happen to you

### Bars
Compared to the choice on X11, bars in wayland are a bit ehhhh ig
There are only 2 that I found:

- Yambar:
	https://codeberg.org/dnkl/yambar
- Waybar:
	https://github.com/Alexays/Waybar

Since I couldn't compile yambar even tho it seems pretty nice :/ I was forced to use waybar
Both of them take after polybar very much which I personally am not much a fan off
but ig it makes sense, If I were to revisit the topic of bars I will definitely look into using
The one and only <a href="https://github.com/elkowar/eww/">eww</a> for this purpose.

---
🚧 This has been archived since I have not had the time to give a proper look at wayland, I do plan on looking at it again at some point,
since whether I like it or not, it seems to be the future of Linux Desktop
