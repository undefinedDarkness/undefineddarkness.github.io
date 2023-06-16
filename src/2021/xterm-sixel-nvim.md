# A day of fixing neovim terminal behaviour

One day while fine tweaking my colourscheme, I noticed that my neovim wasn't displaying any italics
like I had specified in it. After double checking that everything was fine from my configuration side, I resolved it to be
something between neovim and the terminal.

An hour of googling and trying a bunch of different fixes ensue, But most nothing happens till I try running neovim through the `env` program, forcibly overriding the `XTERM_VERSION` variable to be empty, This finally gave the correct behaviour.
Seems like some kind of bug?, Maybe its because my xterm is run in vt340 mode to allow sixel support (Yes, xterm has sixel!!!)
