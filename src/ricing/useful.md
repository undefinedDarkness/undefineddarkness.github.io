# {📚} Useful Ricing Knowledge

#f How to RTFM & Get help

==TLDR: Read documentation before asking questions and if you don't find / can't think of an answer, put effort into asking questions and ask questions in places where they are most likely to answered.==

Read manuals whenever you can, those can be easily accessed for any installed software by doing `man <NAME-OF-SOFTWARE>`, or by searching through a online [repository](https://manpages.debian.org/).
If manpages are too long for you, You can also try using [tldr-pages](https://github.com/tldr-pages/tldr) to get the very basics of an application with some examples

Applications will list all their options there along with addition options specific to the application. Many apps also have GitHub wikis or documentation in the README for their app, kindly refer to those too.

If you're decent at googling - you can find most things you need to relatively easily with maybe a little help. If your question is a something like `can X do Y`, that is a question that should be solved by google and the application's documentation.

Dig deep into the dotfiles of other rices, if you have no idea how they did a thing. Most people are willing to explain how / why they did something in such a way, Which is a great way to learn and understand things.

#### Do not expect a guide / tutorial
I put this here because I see questions like "How do I rice?" or "Is there a tutorial for it?" way more often than I'd like.

Barely any linux software is documented in such a through manner to have documentation like that.
Most of the software isn't trying to hold your hand. Most of it is to fill a need for the developer himself and which he has kindly shared with the community.
Whether you like it or not to rice effectively, you will need to learn the ins and outs of any apps you use and generally you'll need some programming knowledge too. Just being good at programming isn't all you need, You need to have a good eye and have some knowledge of user interface design or just know *what looks good*.
There is a good reason there are not that many good rices, it's a difficult thing to do.

If you can't do that, maybe ricing isn't for you. No harm just using a desktop environment.

#### Getting help
==Found a nice article on the topic, read it:  http://www.catb.org/esr/faqs/smart-questions.html .==

Ask for help in a community related to that one piece of software you want help for. Usually there is at least a GitHub discussion, an IRC chat room or a Matrix space / discord server for most things.
Make good use of them, you'll meet developers of the software and actual users of the software there. Instead of asking in something like the UP server which is only mildly related to that software.

Be nice, and diplomatic,
All of the people helping you are volunteering and spending their time and effort to help you solve your problem. Even if their solution isn't exactly what you wanted, it could still point out the right way to a solution.
Explore properly and don't criticize anyone for giving an answer that did not solve your problem.

See the following: [Don't ask to ask.](https://dontasktoask.com/) & [The X / Y Problem](https://xyproblem.info/)

Stick to the correct channels and follow rules.
If you spam your question in multiple channels, that simply draws ire from the members of the community and doesn't increase the chances of your question being solved.
Do not think you are being ignored if your question isn't answered in a reasonable amount of time (usually a day or 2, other people have lives too, you know).
It's either that no one knows the solution to your problem or no one cares enough to answer it (in which case, write your question out with more effort, and try to see if it has been solved in the documentation or elsewhere already).
Write out your question in overwhelming detail - mention everything you have already tried and what you have found related to your problem.
Upload your configuration files somewhere (like [0x0.st](https://0x0.st) or [paste.rs](https://paste.rs)) and link them in your question, share screenshots of what your problem is.
Try explaining it in simple language.

#END f

#f Most common parts of a rice

<img class="pxl-art" alt="illustration" src="/assets/images/ricing-guide.webp" />

#END f

#f Window Manager Tier list
This is very biased, of course :)
and based on my opinion.
**I HIGHLY RECOMMEND YOU TRY EACH OF THEM AND DECIDE FOR YOURSELF**
Generally, the higher it is up on the list, the more complicated and powerful it is.

#TABLE	.tierlist 
Best	Awesome	
Better	XMonad	FVWM	Qtile
Cool	HLWM	Kiwmi	Wayfire
Simple	i3	Openbox	Bspwm	River
Unremarkable	leftwm	dwm	2bwm	berry
#END TABLE

If you're new to ricing in general, I'd highly recommend i3 since it's very commonly used, has good documentation, and is a relatively good example of a tiling window manager.
* Use i3-gaps if you're planning to use i3, Sway is pretty much i3-gaps for wayland so you can try that too.
* Sway has not been added because it is basically i3 for wayland and if it were added, it would occupy the same rank.

If you don't want to learn how tiling window managers work (I highly recommend you do), Openbox might be a good choice as it's better than i3 for floating.
You can try iceWM too, which is more fully featured out of the box.
* Awesome might be the best window manager for floating too, overall

If you are just looking for outright power at no expense spared, you're looking at either awesome, xmonad or qtile.
XMonad is very good at moving windows around but it's configured in Haskell, which can be relatively difficult to learn and it has no widget system.
Awesome is good at that too but maybe not to the same extent, but it has an excellent widget system, it's configured in Lua which is relatively easy to learn.
Qtile is similar to awesome, but it uses python and I hear has some serious performance issues, but it has a wayland backend so that might be of note.

[Full List & More details](https://wiki.archlinux.org/title/Window_manager#List_of_window_managers)
[Comparison](https://wiki.archlinux.org/title/Comparison_of_tiling_window_managers)
#END f

#f Methodology
This "guide" as I call it, isnt that much of a guide but more of a reference, Because *in my opinion* ricing is a very personal thing and such is very hard to teach,
and since its so flexible trying to document every step on your journey that way would be too much work, so I have just collected useful tidbits of knowledge I found
and tried to make it easier to document applications even I found difficult to theme. I have no attempt to hold anyone's hand through ricing through since if I do that
It will become a how-to-make-a-rice-nes-likes guide; And I have a hard time putting such vague ideas about design and color into words, I am not a designer or artist after all.

Along with that, I never meant for this guide to teach you design, That is something best left to professionals

There is however a method to the madness, as you continue you pick up habits and orders in which to do things. Mine (personally) is to just jump right in and worry about the rest later
so I dont really have much to say here but, as an example to follow:

>>>
This is the "framework" I usually follow:
1) Design/Plan how I want my desktop to look like.
2) Search which kind of enviroment I want (wm/de)
  2.1) If DE I go gnome and don't change anything.
  2.2) If WM I do a little bit of research and balance the pros and cons of each wm have to offer to me.
3) Make colorscheme. (iterate it)
4) Tweak WM and search for 3th party tools (bar/terminal/editor)
5) Repeat steps 3 and 4 until I like the result.
My personal preference nowadays is fvwm because is flexible enough for the things I need... the important part imho is iterating it slowly and having fun 
>>> Caelie

#END f
