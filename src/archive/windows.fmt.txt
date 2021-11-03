# Using Windows

This is gonna document my time, using the one and only Windows 10 :/
Mostly because nvidia forced me to but oh well...

## Colemak
After installing the [exe](https://colemak.com/Windows) from the colemak website...
You can easily enough change the language while using windows but it presents a problem while being 
logging in (it uses the QWERTY layout at that time.),
The detailed solution can be found [here](https://forum.colemak.com/topic/494-howto-set-colemak-as-windows-xp-login-screen-layout-and-more/).
// I dunno why I felt like this was worth writing here. 

## WSL2
I was honestly surprised how good it was, it is amazing how well WSL works!
Installation is a bit murky because the docs are spread out (I am just dumb.) but basically all you need to do is follow the steps here:
https://docs.microsoft.com/en-us/windows/wsl/install-win10#manual-installation-steps

After that you can install a distribution from the microsoft store which is simple enough, you can install any distro of your choosing but
I think thats a fair bit more tricky.

#- Terminal
The choice should be obvious (I hope): The [windows terminal](https://github.com/microsoft/terminal) works ootb with WSL and will even automatically add Distro profiles.
From there its just a few clicks and you're up and running with a almost perfect command line linux experience!

#### Clipboard 
Just right clicking to paste should work well for most things, but vim has a few issues with it, if you are using neovim though and you should be
This can be easily remedied with the instructions here: https://0x0.st/N0sx

The rest should just work

#### Graphical Environment 
WSL-G is a work in progress and right now only available for windows insiders so I haven't got a chance to use it although it seems pretty slick.
You can however get X11 to work amazingly well via XRDP (X11 remote display ig ?)

- Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
- Run `XLaunch`
- Select 'Multiple Windows' if you want applications to behave like regular applications in windows or
one large screen if you want to work within a linux de / wm
- Start with no client
- Tick disable access control !IMPORTANT!
- Add any additional arguments you may want from https://0x0.st/N0sO 
- Run

& Add the following to SHELL-rc file and do `exec $SHELL`:
```sh
case "$(uname -r)" in
	*microsoft-standard-WSL2)
		# For WSL (Windows Subsystem For Linux)
		export DISPLAY="$(grep nameserver /etc/resolv.conf | sed 's/nameserver //'):0"
		export DISPLAY="$(sed -n 's/nameserver //p' /etc/resolv.conf):0"
		export DISPLAY=$(ip route|awk '/^default/{print $3}'):0.0
		export LIBGL_ALWAYS_INDIRECT=1
		;;
esac
```

Now just run any graphical program (like say `xterm`) and bam! it should show up in windows,
long as VcXsrv is running.

#### Filesystem 
Accessing the linux file system from windows & vice versa

In Linux, accessing the Windows filesystem is as simple as navigating to `/mnt/c`
which represents the C: drive in windows

From windows, typing `\\wsl$` in the file explorer search box or the run box will navigate to a directory
with each distribution's `/` directory.

* Probably useful to setup shortcuts to these.

#### Web Servers 
Since I got confused a bit here, they work exactly how you would expect,
You can access linux web servers from windows so
`localhost:5000` can be accessed as `localhost:5000` on windows too

#- De bloating Windows
This powershell script works rather well: https://github.com/Sycnex/Windows10Debloater for most of the obvious things anyway.
