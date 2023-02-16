# Approximating sin(x)
We all know calculating \(\sin(x)\) for anything other than simple multiples of \(\pi\) is a pain in the neck.
Even for something like \(\sin(\pi/12)\),


```math
\begin{aligned}
\tan(\frac{\pi}{6}) = \frac{1}{\sqrt{3}} = \frac{2\tan(\theta)}{1+\tan^2(\theta)} \\
1 + \tan^2(\theta) - 2\sqrt{3}\tan(\theta) = 0 \\
\tan(\theta) = \frac{1 + \sqrt{3}}{1 - \sqrt{3}}
\end{aligned}
```

Fortunatley, many brilliant mathematicians have come with approximations for these functions, Some which we humans can use and some which we cant.
  
<div class="split">
![](/assets/images/taylor.svg)
![](/assets/images/taylor-error.svg)
</div>
## Taylor Series
Probably the one most are familiar with, This is a really understandable way of expressing sin(x) in terms of a polynomial
```math
\sin(x) = \frac{x}{1!} - \frac{x^3}{3!} + \frac{x^5}{5!} \cdots
```
In the above graph, you can visually compare the accuracy of the approximation with the sine function for increasing number of terms.

It shows that even for 4 or 3 terms, you can get a very viable approximation for \(x \in [-\pi/2,\pi/2]\)

In the way I understand it, The polynomial aims to match the nth derivative of the function with its own derivative, at a **certain point**
From its error graph, we can also see that its error sharply increases at the ends
This nature of the graph remains even when the interval is cut to \([-\pi/8,\pi/8]\)

Taking the general form of the polynomial to be \(P(x) = C_0x^0 + C_1x^1 + C_2x^2 \cdots \)

<div class="split">
<div>
\[
\begin{gathered}
\sin(x) = 0 \\
\frac{d\sin(x)}{dx} = \cos(x) = 1 \\
\frac{d^2\sin(x)}{dx^2} = -\sin(x) = 0 \\
\frac{d^3\sin(x)}{dx^2} = -\cos(x) = -1
\end{gathered}
\]
</div>
<div>
\[
\begin{gathered}
P(0) = C_0 = 0 \\
\frac{dP}{dx} = C_1 = 1 \\
\frac{d^2P}{dx^2} = C_2 = 0 \\
\frac{d^3P}{dx^3} = C_3 = -1
\end{gathered}
\]
</div>
</div>

While taylor series are extremely useful and a variant is used to calculate sin(x) even in the C standard library.

There is a wonderful video by 3blue1brown, visually demonstrating this: https://youtu.be/3d6DsjIBzJ4

![](/assets/images/error-baskara.svg)
## Bhaskara's Approximation
This is a formula for calculating sin(x) discovered by 7th centuary Indian mathematician Baskara,
$$\sin(\theta) \approx \frac{16x(\pi-x)}{5\pi^2-4x(\pi-x)}$$ And it's so accurate in the range [0,pi] that its graph is *coincident* with sin(x).

The plot above is of the **error** of this function w/ sin(x), which as you can infer is pretty low

And it should be faster than calculating using Taylor's series

[A derivation for the function](https://scholarworks.umt.edu/cgi/viewcontent.cgi?article=1313&context=tme)
[Wikipedia Article](https://en.wikipedia.org/wiki/Bhaskara_I%27s_sine_approximation_formula)

## Minmax Polynomial
A minmax polynomail gives a approximation of a function while minimizing the maximum error as much as possible.

Exactly how its obtained via the Remez Algorithm, is something I haven't really understood yet so I can't say anything more

An implementation in C is given here:
```c
static double minimaxsin(double x)
{
    static const
    double a0 =  1.0,
           a1 = -1.666666666640169148537065260055e-1,
           a2 =  8.333333316490113523036717102793e-3,
           a3 = -1.984126600659171392655484413285e-4,
           a4 =  2.755690114917374804474016589137e-6,
           a5 = -2.502845227292692953118686710787e-8,
           a6 =  1.538730635926417598443354215485e-10;
    double x2 = x * x;
    /*
        a0x + a1x^3 + a2x^5 + a3x^7...
    */
    return x * (a0 + x2 * (a1 + x2 * (a2 + x2
             * (a3 + x2 * (a4 + x2 * (a5 + x2 * a6))))));
}
```

It functions very similarly to the taylor polynomial, except the constants have been replaced to achieve greather accuracy,
Which it does, achieving some 10^4 times smaller error in comparison (for 7 terms each)

[Wikipedia Article](https://en.wikipedia.org/wiki/Minimax_approximation_algorithm)
[Original Source](http://lolengine.net/blog/2011/12/21/better-function-approximations)

#f Standard sin(x) - How does it work
Looking at the implementation of sin in musl, We get:
```c

/*
 *      3. sin(x) is approximated by a polynomial of degree 13 on
 *         [0,pi/4]
 *                               3            13
 *              sin(x) ~ x + S1*x + ... + S6*x
 *         where
 *
 *      |sin(x)         2     4     6     8     10     12  |     -58
 *      |----- - (1+S1*x +S2*x +S3*x +S4*x +S5*x  +S6*x   )| <= 2
 *      |  x                                               |
 *
 *      4. sin(x+y) = sin(x) + sin'(x')*y
 *                  ~ sin(x) + (1-x*x/2)*y
 *         For better accuracy, let
 *                   3      2      2      2      2
 *              r = x *(S2+x *(S3+x *(S4+x *(S5+x *S6))))
 *         then                   3    2
 *              sin(x) = x + (S1*x + (x *(r-y/2)+y))
*/

static const double
S1  = -1.66666666666666324348e-01, /* 0xBFC55555, 0x55555549 */
S2  =  8.33333333332248946124e-03, /* 0x3F811111, 0x1110F8A6 */
S3  = -1.98412698298579493134e-04, /* 0xBF2A01A0, 0x19C161D5 */
S4  =  2.75573137070700676789e-06, /* 0x3EC71DE3, 0x57B1FE7D */
S5  = -2.50507602534068634195e-08, /* 0xBE5AE5E6, 0x8A2B9CEB */
S6  =  1.58969099521155010221e-10; /* 0x3DE5D93A, 0x5ACFD57C */

double __sin(double x, double dx, int is_dx_not_zero)
{
	double_t x2,x3,x4,r;

	x2 = x*x;
	x4 = x2*x2;
	r = S2 + x2*(S3 + x2*S4) + x2*x4*(S5 + x2*S6);
	x3 = x2*x;
	if (is_dx_not_zero == 0)
        // This unwraps to a taylor expansion of 6 terms
		return x + x3*(S1 + x2*r);
	else
        
		return x - ((x2*(0.5*dx - x3*r) - dx) - x3*S1);
}
```

Although I am not sure what is happening in the 2nd if branch, It seems to use a polynomial approximation of degree 13 to get results for x in the range \([-\pi/4, +\pi/4]\), Which is obtained in the parent sin(x) function with argument reduction (dividing by \(\pi/2\) and getting the remainder), And the final result from said sin(x) is obtained with a combination of __sin(x) and similarly __cos(x) depending on the quadrant of the function (there is also a case for sin x ~= x for small x).

Source for __sin(x): https://git.musl-libc.org/cgit/musl/tree/src/math/__sin.c
Source for   sin(x): https://git.musl-libc.org/cgit/musl/tree/src/math/sin.c

**NOTE:** If you couldn't tell, this code really confuses me and I cant fully tell whats happening, The glibc source is even more confounded.

#END f

## Conclusion
The results from my very naive implementation are as follows, This is without any effort made to optimize the code and most is copied from here and there so the comparison isn't entirely fair.

---
https://git.musl-libc.org/cgit/musl/tree/src/math/sin.c - sin(x) implementation in musl std c lib
https://www.youtube.com/watch?v=yV52TMdGkng
https://allenchou.net/2014/02/game-math-faster-sine-cosine-with-polynomial-curves/
http://users.ece.utexas.edu/~adnan/comm/fast-trigonometric-functions-using.pdf
