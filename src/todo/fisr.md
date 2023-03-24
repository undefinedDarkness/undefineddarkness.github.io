![](https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/OpenArena-Rocket.jpg/1024px-OpenArena-Rocket.jpg)
# Fast Inverse Square Root (Quake III Arena)
In 1999, The Source code for the game quake 3 arena was released, containing a rather ingenious algoritm for calculating the inverse square root of a number (\(\frac{1}{\sqrt{x}}\)), In a case, its required to calculate this very often for vector calculations and when quake 3 was being made, it was an expensive calculation that required approximation.

```c
float Q_rsqrt( float number )
{
	int32_t i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = * ( int32_t * ) &y;                       // evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 );               // what the fuck? 
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
//	y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

	return y;
}
```

To understand this bit of trickery, we need to know a few things,
- Binary reprensentation of integers and floating point numbers
- Math behind it
- C trickery

## Binary Reprentation of Numbers
### Integers
A `int32_t` as the name implies is 32 bits long
![](/assets/images/binary.svg)


```math
```
