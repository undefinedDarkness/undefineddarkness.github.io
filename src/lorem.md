# Lorem Ipsum: Test Page
<!-- 
This page documents my own additions to GFM Markdown
Centered around being really easy to remember
and simple to use while writing.
New syntax is mainly added where writing it out in HTML would be either tedious or break the flow of the document;
Sometimes a new transformer is added, they work like this:
'''
#transformer
Content to be passed to transformer
#END transformer
'''
Transformer content is then substitiuted into the document,
Current transformers are: TABLE, f

I call it nesdown

Nesdown due to implementation limitations won't handle any very complex structure, eg: nested lists
This is where you use HTML if markdown fails you

Nesdown tries its best to output valid HTML whenever possible

TODO: Nested markdown inlines
-->
<!-- You can use markdown in HTML blocks, no problem  -->
<div class='txt-c'>[View Page Source](/src/lorem.md)</div>

<!-- These are as you'd expect -->
Testing Inlines:
Normal text - *italic text* - **bold text**
I am a [link](https://example.com)
f(..x..) = ..x.. + 10 <!-- ..<thing>.. gives it in a serif italic font, for extra highlighting  -->


==This page is responsive, try it on a phone! ==

`1 * 2 * 3 = 3!`
https://www.youtube.com/watch?v=dQw4w9WgXcQ - Link is automatically generated
> A quote
Newlines should intuitively
be preserved...

---

Testing list
- Pumpkin
- Milk
- Eggs
- Flowers
- Carrots
- [Coriander](https://en.wikipedia.org/wiki/Coriander)
is a spice.

Checking for Syntax Highlighting:
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
//    y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

    return y;
}

int main () {
    printf("Hello world\n");
}
```
<!-- Folds can be created with the 'f'old transformer -->
#f Do folds work?
I guess they do :)

==Gotta check if new lines work==

#END f

<!-- IM:... will add `...` to the article margin -->
I should be next to a percent sign IM:%

What about tables?
<!-- 
My own table syntax:
Rows are separated by lines
Columns are seperated by any amount of spaces and at least 1 tab.
-->
#TABLE	Fruits	Vegetables
		Apple	Carrot
		Orange	Tomato
		Banana	Eggplant
#END TABLE

Block Quotes & Captions:
<!-- Pretty simple here too, the last line automatically becomes the caption -->
>>>
John wore clothing made of camel’s hair, with a leather belt around his waist,
and he ate locusts and wild honey. 
And this was his message: “After me comes the one more powerful than I, the straps of whose sandals I am not worthy to stoop down and untie.  I baptize you with water, but he will baptize you with the Holy Spirit.”
>>> Mark 1:6-8

The design of the site was havily inspired by: https://www.kunisch.info/
~~and some of the fonts were chosen with the help of cae~~

I have deliberated on which fonts to use to fix the design appropriately and have finally settled on Redaction for headings, IBM Plex Sans / Mono for body text and code respectivley

## Edge Cases
Inline in code sections:
```sh
export __OPENGL__=1
printf '%d' $(( 2 * 3 * 5 ))
```

Inline in code inline:
`Hello **world** - I hope I dont trigger any edge *cases*`

## Testing Classes

`.txt-c`
<div class="txt-c">Same as &lt;center&gt;, Legacy basically</div>

`.reset`
<b>I am bold, I am <span class="reset">RESET</span> but without breaking the bold tag, Workaround for generation limitations</b>


`.pxl`, `.pxl-art`
Render image as if it were pixel art
<div class="horizontal">
<img width="256" height="256" class="pxl" src="https://pixeljoint.com/files/icons/full/agentcrow1.png" />
<img width="256" height="256"  src="https://pixeljoint.com/files/icons/full/agentcrow1.png" />
<div>
    <img src="https://pixeljoint.com/files/icons/full/agentcrow1.png" />
    <a href="https://pixeljoint.com/pixelart/145581.htm">Original</a>
</div>
</div>

`.in-margin`
Show arbitrary text in the article margin, used in the generator

I love chess IM:♞

<section class="demo">

`.split`
<div class="split">
<div>It would appear I have been sliced</div>
<div>in twain</div>
</div>

`.split-e`
Variant of split that uses 19em columns, seems to split stuff neatly
Falls back to `1fr 1fr` when on mobile

<div class="split-e">
<div>It would appear I have been sliced</div>
<div>in twain</div>
</div>

`.quad`
19em flexible grid with 2 rows
Breaks on mobile

<div class="quad">
<div>Responsive</div>
<div>grid</div>
<div>layout</div>
<div>as</div>
<div>you</div>
<div>expect</div>
</div>

`.horizontal` same as quad but no longer a fixed size / amount of columns, uses flexbox
`.ovr-x` simply hides any X axis overflow

`.linklist`
<div class="linklist">
<a>A</a>
<a>bunch</a>
<a>of</a>
<a>links</a>
</div>

</section>
