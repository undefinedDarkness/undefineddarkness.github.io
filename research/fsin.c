#include <math.h>
#include <stdio.h>
#include <immintrin.h>
#include <time.h>
// Taking 4 terms
// taken from lol engine or somewhere I dont remember exacatly
static double taylorsin(double x)
{
    static const 
    double a0 =  1.0,
           a1 = -1.666666666666666666666666666666e-1,  /* -1/3! */
           a2 =  8.333333333333333333333333333333e-3,  /*  1/5! */
           a3 = -1.984126984126984126984126984126e-4,  /* -1/7! */
           a4 =  2.755731922398589065255731922398e-6,  /*  1/9! */
           a5 = -2.505210838544171877505210838544e-8,  /* -1/11! */
           a6 =  1.605904383682161459939237717015e-10; /*  1/13! */
    double x2 = x * x;
    return x * (a0 + x2 * (a1 + x2 * (a2 + x2
             * (a3 + x2 * (a4 + x2 * (a5 + x2 * a6))))));
}

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
    return x * (a0 + x2 * (a1 + x2 * (a2 + x2
             * (a3 + x2 * (a4 + x2 * (a5 + x2 * a6))))));
}

double bhaskara(double x)
{
    return (16 * x * (M_PI - x)) / (5 * M_PI * M_PI - 4 * x * (M_PI - x));
}

// stolen from some gh repo
// I dont feel like finding it sorry
double hwSin(double x) {
    float result;

    asm("flds %1\n"
        "fsin\n"
        "fstps %0"
        : "=m"(result)
        : "m"(x));

    return (double)result;
}

__m256d _ZGVdN4v_sin(__m256d x);  
void benchmarkSimd(const char* label, double errorStart, double errorEnd) {

	printf("%s:\n",label);
    // == SPEED TEST ==
    clock_t start = clock();
    for (int i = 0; i < 1000000; i += 1)
    {
        double s = 0;
        for (double j = 0; j < M_PI; j += 0.04)
        {
			__m256d a = {j,j+0.01,j+0.02,j+0.03};	
			/* __m256d b = {i+0.04,i+0.05,i+0.06,i+0.07}; */	
        	 /* _ZGVdN4v_sin(a); */
			 __m256d v = _ZGVdN4v_sin(a);
             __asm__ volatile ("" : "+g" (i), "+g" (j), "+g" (v) : :);
		}
    }
    clock_t end = clock();
	
	printf("\ttook %lu ms\n", ((end-start)*1000)/CLOCKS_PER_SEC);

    // == ACCURACY TEST ==
	
    // double maxError = 0;
    // for (double i = errorStart; i < errorEnd; i += 0.01) {
    //     double error = fabs(sin_f(i) - sin(i));
    //     if (error > maxError)
    //         maxError = error;
    // }
	// printf("\thighest Error: %f\n", maxError);
	
}

void benchmark(const char* label, double (*sin_f)(double), double errorStart, double errorEnd) {
	printf("%s\n",label);


    // == SPEED TEST ==
    clock_t start = clock();
	for (int i = 0; i < 1000000; i += 1)
    {
        for (double j = 0; j < M_PI; j += 0.01)
        {
            double v = sin_f(j);
			__asm__ volatile ("" : "+g" (i), "+g" (j), "+g" (v) : :);
        }
    }
    clock_t end = clock();

	printf("\ttook %lu ms\n", ((end-start)*1000)/CLOCKS_PER_SEC);

    // == ACCURACY TEST ==
    // double maxError = 0;
    // for (double i = errorStart; i < errorEnd; i += 0.01) {
    //     double error = fabs(sin(i) - sin_f(i));
    //     if (error > maxError)
    //         maxError = error;
    // }
	// printf("\tHighest Error: %f\n", maxError); 
    //std::cout << "Highest Error: " << maxError << "\n\n";

}

int main(int argc, char **argv)
{
    benchmark("Standard Library:", sin, -M_PI_2, +M_PI_2);
    benchmark("Taylor Series (7T):", taylorsin, -M_PI_2, +M_PI_2);
    benchmark("Bhaskara Formula:", bhaskara, -M_PI_2, M_PI_2);
    benchmark("Minmax Polynomial (7T):", minimaxsin, -M_PI_2, +M_PI_2);
    // benchmark("x87 Hardware Sin (FLOAT):", hwSin, -M_PI_2, +M_PI_2);
	benchmarkSimd("Libmvec (4xD)", -M_PI_2, M_PI_2);
}
