# Optimizing for size

I was wondering how small it was possible to make could get a non trivial program, without actually changing the code itself, ie: mostly compiler flags and such.

I might be using "non trivial" wrongly here but I mean a program that can actually do something.

Well, let us start with a non trivial program and go from there,
For this I will make use of the wonderful [tigr graphics library](https://github.com/erkkah/tigr)

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
Compiling with `cc app.c tigr.c -o app -lGl -lX11` gives us our executable, whose size is 76kb.

For such a simple program, surely we can do better right?

## Compiler Flags

### -Os
How about telling the compiler to optimize for size with the `-Os` flag?
With it, The new binary is 68kb, a decrease of 10.52%, Not bad if I say so myself.
However in my experience this doesnt always happen, quite often the decrease is so small, that it won't even be measured.

You can find out what it does by starting from here, https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#Optimize-Options

### -s
Despite adding `-Os`, the compiler still adds in a bunch of debug information that we don't really need, so if we ask we can `strip` it from the binary.

Adding it via the compiler flag `-s`, We get a binary 26% smaller than the 76kb original, not bad.
(Instead of the compiler flag, you can use `-s` on a compiled binary.)

You can sort of see this with the `strings` utility, initially our binary contained 1363 strings, after stripping it contained 339.

Following the saying, "Good artists create, Great artists steal", Consulting https://github.com/johnthagen/min-sized-rust , We find one thing of interest, Link Time Optimization (LTO)..

### -flto
Basically this tells the linker to apply optimizations during linking time. It's more complicated than that but I don't understand it.

So what does it do for us?
Quite a bit, Using it we have shaved off 16kb to reach 40kb, so in total (with -Os and -s) a 47% decrease of our initial 76kb, not bad at all.

**NOTE**: Enabling `-flto` sometimes caused me a segfault at program start with clang, but this didnt occur with GCC, so it seems like GCC has a more mature implementation.

## Executable Packing
If you wanted to go even furthur you could try [UPX](https://upx.github.io/), Which actually compresses your biniary and this works since
the decompression code + compressed data ends up smaller than the initial binary.

Although some would consider this cheating, It is still a legtimate method and does work,
Running it with the highest compression level (-9) on our 40kb binary yields a binary size of 24kb, A decrease of 60% which is undeniably really impressive.

**NOTE:** Since upx is often used in malware, There are chances it might get flagged by an antivirus,
But running through virus total shows only [results](https://is.gd/MtqIMG) from Google & Ikarus(?)

**NOTE:** In a web enviroment, files are usually transferred while being gzip-compressed, UPX would be negligible for .wasm files and it doesnt support it anyway.

![](/assets/images/size-chart.svg) 
## Conclusion
So in total we managed to decrease our binary by **68%** without changing a single line of code, Less than half of its original size
I am very pleased with that..

Of course, even this isn't anything compared to marvellous feats of engineering like [.kkreiger](https://en.wikipedia.org/wiki/.kkrieger), A entire 3d fps game demo in a extremely impressive 95kb,
When code is *actually written* to be small, and optimized to the limit towards that purpose.
More on why:
- https://fgiesen.wordpress.com/2012/02/13/debris-opening-the-box/
- https://fgiesen.wordpress.com/2012/04/08/metaprogramming-for-madmen/
- https://www.youtube.com/watch?v=bD1wWY1YD-M
