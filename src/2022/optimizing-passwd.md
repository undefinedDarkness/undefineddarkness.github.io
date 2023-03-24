# Improving runtime by 8x

== 🚧 This is not a large program, It does something very specific, So is not representative of any large programs so gains will not be the same==

So recently, I contributed to [einheit/passwd-shell-benchmarks](https://github.com/einheit/passwd-shell-benchmarks) and managed to improve the performance by 8x.
The goal is simple, Read in a file like
```
root:x:0:0::/root:/sbin/csh
bin:x:1:1::/:/usr/bin/sh
daemon:x:2:2::/:/usr/bin/zsh
mail:x:8:12::/var/spool/mail:/bin/csh
ftp:x:14:11::/srv/ftp:/bin/pdksh
http:x:33:33::/srv/http:/sbin/csh
nobody:x:65534:65534:Nobody:/:/bin/fish
dbus:x:81:81:System Message Bus:/:/sbin/ksh
systemd-coredump:x:981:981:systemd Core Dumper:/:/sbin/bash
systemd-network:x:980:980:systemd Network Management:/:/sbin/pdksh
```
and count the number of unique shells.

This is all the stuff I found when improving the program performance.

### mmap()
On linux (not sure about windows), It is possible to ask the kernel to map a file into memory allowing the contents to be accessed much faster.
The basic call goes like this
```c
// For mmap()
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>


int main() {
int fd = open("passwd", O_RDONLY);
  struct stat s;
  fstat(fd, &s);
  char *buffer = mmap(0, s.st_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);

	// process buffer here

	unmap(buffer, s.st_size);
	close(fd);
}
```
I would to add that this isnt a magic trick to make stuff faster, but reading the file like from a string may be faster than going through the stdlib to do it, It has benefits & disadvantages compared to read(), as detailed on this [SO answer](https://stackoverflow.com/a/41419353); In general the cost for larger files is quite a bit but I'm not dealing with that here so it's fine.

==Try to process IO in as large chunks as you possibly can, smaller chunks simply take up more CPU cycles==

### stdlib is faster than you
In my inital implementations, I tried to do everything myself! ie, rely as little as possible on the stdlib, That wasn't a great idea. When I tried replacing my parsing code with `memchr()` and friends,
It speed up a decent bit, Turns out things like searching for the line ending aren't expensive as all that, not that you shouldnt avoid them if you can but my previous solution looped over each byte trying to find it...
That wasn't good..

I finally realized, that people a lot smarter than me have written the libc methods to be as fast as possible, for example: when compiled correctly, glibc emits CPU specfic SIMD instructions for memchr() allowing it to process leaps and bounds faster than any naive implementation. So it's better to use the libc functions when you can instead of your worse code.
Learn More: https://gms.tf/stdfind-and-memchr-optimizations.html#glibc-memchr

### Perfect Hash Functions
*Perfect hash functions are functions which do not have any collisions and are tuned for some dataset*
Inspired by [this wonderful video](https://www.youtube.com/watch?v=DMQ_HcNSOAI) on hash tables by @strager, I tried to find some kind of neat operation to map my shell string to a index in an array, and this is what I came up with
```c
// @crumbtoo suggested replacing modulus with & operation
int id = (colon[shellSize - 3] ^ (shellSize + colon[shellSize-4])) & 0xabcdff;
```
Of course, you should tailor something particular to the data you're processing, or use another generic function like [FNV-1a](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function) or [Jenkins](https://en.wikipedia.org/wiki/Jenkins_hash_function),
I also run it through `gperf`, a GNU tool that automates generating perfect hash functions for given dataset, But I ended up using my worse solution since it was far fewer operations.

And if you're using full proper hashtables, using Google's Swiss Tables (Rust uses this by default) might help somewhat. 


