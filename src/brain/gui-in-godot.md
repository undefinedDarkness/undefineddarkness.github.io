# Using Godot for GUI
So I have been making a small music player called Cello, in the [Godot Game Engine](https://godotengine.org/),
This is what it looks like so far:

So far my experiance has been really good, Things I particularly liked were that I could preview my application in the editor,
and the whole editing / creating experiance felt rather cohesive since I did'nt need to switch windows and could develop, debug & run my app all in one window.

Minor gripes I have with the UI system is that it isnt all that simple to make it look pretty, there is no CSS (no problem with that)
and even something fairly basic like rounded corners were pretty tricky to pull off, Although it doesnt do very well compared to GTK (which is what I am coming from / are used to), 
It does do rather well compared to other GL based UI systems.

The editor is mostly fairly cut & dry to use once you're used to Godot in general, I found containers a tiny bit confusing but it's not too bad, and the many
subcategories of options a widget can have is a bit daunting if you don't know what you're looking for

Really like the way the node system makes it really simple to visualize what is a child of what and the access to all your usual 2d tools is rather neat as well

## Scripting
I don't have any particular complaints about GDScript other than it takes a bit to understand that all files are classes and you can't "simply" import and use them.
Connecting signals to pass data between parent and child works really well.
Oh also that the static typing is disconnected at best, pretty sporatic at worst, I know that is not what it was designed with but still - Seems to fixed in godot 4

Really wish using modules didnt need you to re-compile *EVERYTHING*, but too late to complain now, GDNative already solves that
Speaking of compiling everything, It would be nice if I could use the feature disabling flags while keeping my editor intact but that's not too bad I guess.

A couple of weird things I found,
`load()` does not recognize mp3's or any of the media formats I tried
When I was trying to re-create the [Audio Spectrum example](https://github.com/godotengine/godot-demo-projects/tree/3.4-585455e/audio/spectrum),
This line of code was not working because I did not have the `default_bus_layout.tres` file, and the error I recieved was not related to that at all for the most part

## Conclusion 
I am really impressed by what is already possible, if you're after a specific look like I was a few roadblocks might get in your way but most can be solved by inguenity
I find the grid / anchor system pretty confusing but its not too bad, same goes for not using percentages while building your app.
