# Lorem Ipsum: Test Page

Testing Inlines:
Normal text - *italic text* - **bold text**
I am a [link](https://example.com)
https://www.youtube.com/watch?v=dQw4w9WgXcQ - Automatically generated

Testing list
- Pumpkin
- Milk
- Eggs
- Flowers
- Carrots

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

#f Do folds work?
I guess they do :)
#END f
