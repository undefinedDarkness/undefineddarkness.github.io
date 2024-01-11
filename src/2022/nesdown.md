<header>
<img src="https://imgs.xkcd.com/comics/standards.png" />

# My custom markdown flavour
</header>

Markdown is nearly ubquitious now-a-days. Anytime you need a simple text format for documentation or formatting,
It is at the ready.

I like it's simplicity a lot too but how strict some of the syntax rules end up being, They kind of rub me the wrong way.
So when making this site, I decided I would finally fix it myself, Of course, It wouldn't do if it was written in a "normal" language like Python or C or Rust or something, No It had to be different, and so it was written in Bash. (Not posix cause writing something perfectly in posix makes me pine for bash builtins)

The result is ~600 lines of barely unreadable sphagetti, Even I can't read what
it's doing sometimes. But as the old adeage goes, What's not broken don't fix, and believe me I've tried to replace it entirely but then give up because of how much effort it would be.

So here are some of the things I added to *nesdown*:
You can find it here, https://github.com/undefinedDarkness/undefineddarkness.github.io/tree/master/.tooling

### Markdown in HTML blocks
Since I couldn't be bothered to implement the correct logic and this works just as well,

It just barely colliding into inline HTML markup but processes any markdown it finds within.

So now something like this
```
<div class='txt-c'>[View Page Source](/src/2022/nesdown.md)</div>
```
will generate:
<div class='txt-c'>[View Page Source](/src/2022/nesdown.md)</div>

### Block Quotes
This isn't anything new either, but I cant ever remember the syntax for other flavours

```
>>>
Be the change you want to see in the world.
>>> Mahtma Gandhi
```
becomes
>>>
Be the change you want to see in the world.
>>> Mahtma Gandhi

### Inlines
Because I could, I barely use these...
```
==Pay attention to me==
```

==You better==

### Syntax Highlighting
This is nothing new, but the neat part is that its done entirely in the markdown generation step.
So no javascript library is required later.

```c
#include <stdio.h>

float Q_rsqrt( float number )
{
    long i;
    float x2, y;
    const float threehalfs = 1.5F;

    x2 = number * 0.5F;
    y  = number;
    i  = * ( long * ) &y;                       // evil floating point bit level hacking
    i  = 0x5f3759df - ( i >> 1 );               // what the fuck? 
    y  = * ( float * ) &i;
    y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
//  y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

    return y;
}

int main () {
    printf("Hello world\n");
}
```

## Transformers
I built it initially around the idea of these, but essentially they're like functions that take raw text as input and output html.
The raw text can really be anything, which is where I find them really useful.

And making a transformer is as simply as creating a new bash function.

### Table Transformer
Markdown table syntax is just painful. Sure, it's readable in text form but thats only if you don't have a mess of differently sized columns and data values. (which is really easy) And if you do, its painful to edit manually,
you always gotta delegate to some tool which is a whole mess

Since of course I could do a better job than all the bright people that have spent a lot of time thinking about the markdown syntax, This was what I came up with and to be entirely honestly, I'm quite happy with it, It's not very clear but it's decently readable and fortunatley easy to modify as well.

```
#TABLE Fruits   Vegetables
       Apple    Carrot
       Orange   Tomato
       Banana   Eggplant
#END TABLE
```
becomes
#TABLE	Fruits	Vegetables
		Apples	Carrot
		Orange	Tomato
		Banana	Eggplant
#END TABLE

where columns are seperated by exactly 1 tab and any amount of spaces (for alignment)
This syntax pretty much breaks the moment you want something really long though, but at that point, I think just using HTML Tables directly is the best idea.

### Verbatim Transformer 
A crutch to deal with nesdown not having any idea of what its doing when transforming markdown syntax, Just spits out the input its given and ~sort of~ guarrentes that it wont be changed in any way.

### (f) Fold Transformer
A slight syntactic sugar over `<detail>` & `<summary>`

```
#f It's a secret
I said it was a secret >:(
#END f
```
becomes
#f It's a secret
I said it was a secret >:(
#END f

## Problems
Currently to make new lines break like I want, A lot of `<br>`s are scattered throughout the output.

Besides that, the output is really quite ugly, I know its not meant for a person to read but still...

Performance isn't a problem since it is plenty fast for my mediocre needs.

---

I know my little toy isn't remarkable in any particular way but I was hoping to showcare it since over the years, Ive spent a decent chunk of time on it.
