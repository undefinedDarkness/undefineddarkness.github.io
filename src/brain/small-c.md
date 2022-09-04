# Making a small working C binary

So out of curiosity, I was wondering how small I could get a non trivial program
without actually changing the code itself.

I might be using "non trivial" wrongly here but I mean a program that can actually do something.

For a really extreme devlve into getting a teensy tiny binary, see: https://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

Well, let us start with a non trivial program and go from there,
For this I will make use of the wonderful [tigr graphics library](https://github.com/erkkah/tigr)

The compiler I am using is clang.

I wrote a little demo work that'll do for now.
```c
#include <stdlib.h>
#include "tigr.h"
#include <time.h>
#include <stdio.h>

int randomNo(int min, int max) {
  return min + rand() / (RAND_MAX / (max - min + 1) + 1);
}

int main() {

  srand(time(NULL));

  Tigr *screen = tigrWindow(320, 240, "Hello", 0);
  int x, y;
  char *fmt = malloc(100);
  while (!tigrClosed(screen)) {
    tigrClear(screen, tigrRGB(0x11, 0x11, 0x11));

    tigrPrint(screen, tfont, 120, 110, tigrRGB(0xf0, 0xf0, 0xf0),
              "Hello, world.");
	snprintf(fmt, 100, "%d, %d", x, y);
	tigrPrint(screen, tfont, 120, 110 + 16, tigrRGB(0xf0, 0xf0, 0xf0), fmt);

    tigrMouse(screen, &x, &y, NULL);
    tigrFillCircle(screen, x, y, 8, tigrRGB(0xff, 0x00, 0x00));

    for (int i = 0; i < 100; i++) {
      int x = randomNo(0, 320);
      int y = randomNo(0, 240);
      tigrLine(screen, x, y, x, y + 10, tigrRGB(0x00, 0x00, 0xff));
    }

    tigrUpdate(screen);
  }
  free(fmt);
  tigrFree(screen);
  return 0;
}
```
Nothing flashy, it just opens a window, draws some text and some rain.
Compiling with `cc app.c tigr.c -o app -lGl -lX11` gives us the executable.

`du -sh` tells us the file is 76kb, We can do better than that.

## Compiler Flags
How about telling the compiler to optimize for size with the `-Os` flag?
I was really expecting a negligible change but I was happily suprised, The new binary is 68kb,
a decrease of 10.52%, Not bad if I say so myself.
However in my experience this doesnt always happen, quite often the decrease is so small that du wont even measure it

You can find out what it does by starting from here, https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#Optimize-Options
But I don't find it all that interesting.

Let's go further, On searching google on ways to decrease binary size, You'll come across the `-s` flag, But what does this do?
The gcc docs give us the answer,

**-s:** Remove all symbol table and relocation information from the executable.

But what does that mean?

[Wikipedia](https://en.wikipedia.org/wiki/Symbol_table) tells us that it is a table of identifiers from the source and where they are in the binary (reloc info).
Useful in some instances sure but we don't care about this, how bad is it?

Using `nm` we can print out the symbol table in its entirety,
```
                 U __assert_fail@GLIBC_2.2.5
0000000000405546 t begin
0000000000405bb0 t bits
0000000000405c2d t block
0000000000405f9a t border
000000000040e414 B __bss_start
0000000000408131 t build
                 U calloc@GLIBC_2.2.5
000000000040e420 b completed.0
00000000004080f6 t copy
000000000040a6e0 r cp1252
000000000040a940 r crctable
// 255 lines in total
```

This means a lot of data is sitting in our binary doing nothing, so when we add the `-s` flag we can get rid of it,
This gets us to `56kb`, so 26% smaller than our original 76kb binary, not bad

The rust folks seem to always have trouble with binary size 😉, Maybe they have some ideas?
Consulting https://github.com/johnthagen/min-sized-rust , We find one thing of interest, Link Time Optimization (LTO)..

### What is LTO?
Link Time Optimization (LTO) gives GCC the capability of dumping its internal representation (GIMPLE) to disk, so that all the different compilation units that make up a single executable can be optimized as a single module. This expands the scope of inter-procedural optimizations to encompass the whole program (or, rather, everything that is visible at link time). 

Learn More: https://en.wikipedia.org/wiki/Interprocedural_optimization#WPO_and_LTO

It's enabled with `-flto`
Okay, but what does it do for us?

Quite a bit, Using it we have shaved off 16kb to reach 40kb, so in total a 47% decrease of our initial 76kb, not bad at all
**NOTE**: Enabling -flto sometimes caused me a segfault at program start with clang, but this didnt occur with gcc, so
YMMV

## Executable Packing
If you wanted to go even furthur you could try [UPX](https://upx.github.io/), Which actually compresses your biniary and this works since
the decompression code + compressed data ends up smaller than the initial binary.

I am not a big fan of such an approach, feels like cheating but it is an actual approach so how much does it help?
Running it with the highest compression level (-9) on our 40kb binary yields a binary size of 24kb...
Wow that is actually amazing, I didnt think it would reduce the size that much..
I should use this more.. wow, I should've tried this earlier...
NOTE: Since upx is often used in malware, There are chances it might get flagged by an antivirus,
But running through virus total shows only [results](https://is.gd/MtqIMG) from Google & Ikarus(?)

```
76K     min
68K     min-Os
56K     min-Os-s
40K     min-Os-s-flto
24K     min-Os-s-flto-upx
```

So in total we managed to decrease our binary by **68%**, Less than half of its original size
I am very pleased with that..

Of course, even this isn't enough to achieve feats like .kkrieger, A entire 3d fps game demo is a extremely impressive 95kb,
When code is *actually written* to be small, and optimized to the limit towards that purpose.
Learn more about how it's so small:
https://fgiesen.wordpress.com/2012/04/08/metaprogramming-for-madmen/
https://www.youtube.com/watch?v=bD1wWY1YD-M

Since in a web enviroment, files are usually transferred while being gzip-compressed, UPX would be negligible for .wasm files and it doesnt support it anyway.
