# Using Godot For GUI Development
These are the results of my experiment with using the [Godot game engine](https://godotengine.org/) for designing 
[a toy music player](https://github.com/undefinedDarkness/cello),
I have divided them into things I like and things I'd like to see improved, 
I have marked things that would be either entirely or partially fixed by Godot 4 with 🍀,
Many of the proposed solutions to the problems I have mentioned are more than likely really naive as I have not fully thought them through yet
It is also likely that Godot has good reasons for doing things in a particular way that I have not yet noticed  (I am certain they are much smarter people than me)
Or that there are GitHub issues open for some of the problems I found, I have not checked thoroughly

## Things I loved
- The editor preview is bloody amazing coming from GTK where every change in the code required, relaunching the application;
It helps so much with prototyping, You can even preview your entire app from the editor, like so:
![editor preview](https://i.ibb.co/r0gzVHX/image.png)
- The seamlessness between the editor and the scripting was also really nice to see, It made thinking about how things would work rather simple
and features easy to implement
- Godot's well developed & refined node system works amazingly well for designing a user interface, everything can be split up into scenes that can find one another with node paths
and others, its all really comfortable and nice to use
- Continuing from the first 2 points, being able to do everything from one window, (preview, design, scripting) is really amazing
- Being able to mix and match parts from the 2D game system with the UI system (this is what it was made for) makes a few use cases much easier too
- I haven't done this yet but you should be able to in theory use Godot's amazing animation system (with animation player and tweens) to interactively animate parts of your UI in a much simpler way
and since you can preview the animation in the editor, its even better.
- The script editor was much better than I expected, for an editor included in a larger application (instead of being a focused editor), it is very usable! 
And the tight integration it has with the larger engine is really nice to see as well, Would like to see some vim bindings tho :p
- Once I had fixed all the memory leaks :p, The performance in my purely UI application was very good, Granted my app isnt the most complicated UI in the world but I found it sticking to 
50mb of ram usage and 11mb of video memory usage quite serviceable (while playing a .flac read from a .zip file); It is possible a pure UI implementation in GTK would have consumed less but this is already pretty low
- Godot encases you in a bubble of cross platform support which is also really nice so I can expect my app which works entirely in Godot to just work ™ on Linux & MacOS maybe even ARM stuff
- The documentation is amazingly well written (in comparison to the GTK docs, which for the most part teach you how to do the basics then throw the API reference at you) and through, and almost all the parts of the engine are covered to some degree at least.

## Issues I had
### UI System
My experience thus far with UI design has been with GTK & CSS,
GTK works in a pretty similar way to CSS so they're both pretty familiar to me,
Most of these are things that would make me more comfortable using it but all of them are livable with in their current state

- The container / size flags system feels to me a bit more complicated
than it has to be, but its not too bad once you get used to it
- No way to easily use percentage sizes for UI elements
Related to the above issue, you can calculate them yourself in GDScript but that is rather tedious
(By percentage sizes I mean relative to the node's parent or if one chooses, relative to the viewport)
- No overflow wrapping support in the default containers, 
More of a nitpick since solutions like [this one from AnidemDex](https://gist.github.com/AnidemDex/1ab41a1203206ce30063fe72b274eb38) exist to fill the gap
- Tricky to get things like TextureRect's to scale well or even show up to all,
I had often had to resort to setting a node's `rect_min_size` to fix it, related to 1 & 2
- Included (default) font for UI does not support some parts of Unicode which is something I sort of expected as its the only fallback font Godot will use, some behaviour to pick up the system default fonts would go down well too
- Clipping issues with a PanelContainer and TextureRect, The texture rect would not conform to the corner radius I had set on the parent container,
I ended up needing to use a shader to achieve the effect I wanted (rounded corners on an image) 🍀
- Very very small nitpick, the editor does not seem to support ligatures which is a bit of a shame but again really minor thing
- The default bar at the top for the project / editor settings menu should be search instead of adding a new item
![this bar](https://i.ibb.co/hd7HmYW/Screenshot-2021-12-25-103204.png)
- The UI system could use a debug option like the collision system to show parent / children borders in the user interface
- The Theme editor was rather unintuitive to me, I expected to be able to click any of the widgets in the preview and modify their properties
but it does appear to be rather powerful so that's fine by me
![the editor ui](https://i.ibb.co/zX1CPWY/image.png)
- When running any Godot project, Godot opens with a loading screen, while this is fine for most games, it is quite detrimental to a UI application,
I am not exactly sure what Godot is doing in this loading screen but if it is loading resources or anything not directly related to the drawing of the app UI, 
IMO there should be an option where Godot whatever it needs **and then** spawn and draw the window, so the user will notice a delay in app startup time but won't need to wait looking at a loading screen.

### GDScript
I am fairly well versed with Javascript/Typescript, Lua and have experience in C / Python / Rust,
so most of this is from someone who isnt the most familiar with classes or what they are capable / useful for
GDScript does hold your hand in many ways which makes it pretty simple to use as well

Some of these are also complaints of the editor which is a quite integral part to editing GDScript
- GDScript does not make it obvious when something is being copied by value or passed by reference
- The editor which is perfectly capable of editing arbitrary text files requires you to jump through hoops to open one, When using the **Open menu** you need to tell it to
show all file types, only then can you open your markdown file or whatever
![the menu](https://i.ibb.co/x6Pz1S7/image.png)
- The type system is extraordinarily fragile and becomes useless really easily 🍀
- The editor sorts completion items really weirdly, Imo it should be a bit smarter and sort Node specific properties first then parent properties then methods of both
![example of what I mean](https://i.imgur.com/bqVr24c.png)
- No one liner / lambda functions 🍀
The way you pass functions is also really dumb, eg: 
```gdscript
node.connect("signal-name", self, "signal-name-callback", [ 'apple' ])
#~ could be with lambdas
node.connect("signal-name", () => {
	#~ do thing
})
```
- The over reliance of classes,
This is definitely me complaining because I am not very used to classes but I still found it pretty clunky to use classes
when all I wanted to do was have a separate script to store a few functions for a main node script, so I avoided splitting code up as much as I should have
and a lot of code become ugly :/
- When you are prototyping quickly and modify the node structure even a little bit, almost every `get_node()` call in your script will break which becomes really annoying to fix,
especially if you need that script to demonstrate / test the behaviour of the ui. This is because all the node paths get modified which makes sense, to alleviate the issue a bit
a nice thing to see would be a way to link a get_node() call to a certain fixed node, much like how connecting callbacks works (excepts when you move the script and it doesn't but that's more of a minor issue),
This method could be linked to the editor
This is the thing I found most frustrating and would most like to see get fixed or alleviated
- No way to type signal arguments like the C++ source can 🍀

#### Editor / Tool Scripts 
So if you want to run something in the editor (while editing) to show up in the preview of your game you use a tool script by appending `tool` at the top of your script file,
This makes your *entire script* run in the editor, and [the documentation](https://docs.godotengine.org/en/stable/tutorials/misc/running_code_in_the_editor.html) lists how your code can cause errors quite a few times,
All this made me not really want to risk using them unless all the script did was affect the appearance of itself, which wasn't the case in my code for most cases,
What I would like to see, is a way to run / expose only specific functions in the editor, for example:
```gdscript
#[editor-main]
func editor_ready:
	add_dummy_items()
	self.modulate = Color(0, 0, 0)
```
Which imo would yield a neater solution than game code checking to see if its running in the editor
Another thing I encountered was needing to restart the editor every time I wanted to register a new tool script, which can be quite annoying 

Writing small snippets that run directly in the node editor would be nice to see as well

### Other
- I found SCons (Godot's build tool) to be a bit fragile when compiling, It did work but it would break entirely if there was even a single error and it would lose all the compilation it had done so far,
Which simply makes the next build even longer, 
Labels / Sections that properly show you what you are compiling instead of reading from cryptic file names would be nice to see *- Most things don't do that so a really minor nitpick*
and it should have a warning if you don't run it with `-j$(nproc)`, since I did that once and the build took ages longer than it needed to
- ~~Maybe this is because I haven't created ultra optimized export templates yet but I found the resulting executable to be fairly chunky at around 100mb which is around the same for a electron app~~
It was because I hadn't created a optimized build
- IMO In the export template options:
`Embed Pck` should be turned on by default 
& The icon should be by default generated from your project icon (Usually stored at `icon.png`)
- This isn't really an issue just a way where Godot could be smarter by default:
When importing images or sprites, Godot by default filters / anti aliases the image, this as you can imagine destroys any quality in pixel art till you find the 2 buttons you need to press in the import menu to get it to work.
![button in question](https://i.ibb.co/rbf3fPs/image.png)
but if you are importing a image of a size less than say 128x128 pixels, The chances that it is *not* pixel art become really low, so defaulting to pixel art settings in that case make a lot of sense to me
but I can see why they did not want to program a special case for pixel art
*I just noticed you can make this setting the default which alleviates the issue a lot*
- In general the default editor UI to be rather enforced, as in there isn't much you can do to change it other than moving nodes from the left & right panels,
Would be nice to freely move things from place to place & hide panels as I wish but I can see how that would be rather clunky to implement,
as a side effect in its current state, it scales really badly to smaller window sizes,
I would like to be able to open my scene tree and preview (in top bottom layout) vertically split next to my code editor but currently I see no way to go about this.
[this is how I want it](https://i.imgur.com/2iJPw8F.png) 🍀
- Currently no support for reading and writing to zip files, there exists [a module / custom build](https://github.com/flyingpimonster/godot/tree/zip-module-3.4) that I ended up using but I think this functionality is basic enough to be included in the editor itself 