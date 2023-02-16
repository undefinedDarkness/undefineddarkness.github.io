#define _GNU_SOURCE
#include <cmath>
#include <chrono>
#include <iostream>

// Taking 4 terms
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

float hwSin(float x) {
    float result;

    asm(R"(flds %1
           fsin
           fstps %0)"
        : "=m"(result)
        : "m"(x));

    return result;
}

template <typename T> void benchmark(const char* label, T (*sin_f)(T), double errorStart, double errorEnd) {
    using std::chrono::duration;
    using std::chrono::duration_cast;
    using std::chrono::high_resolution_clock;
    using std::chrono::milliseconds;

    // == SPEED TEST ==
    auto t1 = high_resolution_clock::now();
    for (int i = 0; i < 1000000; i += 1)
    {
        for (T i = 0; i < M_PI; i += 0.01)
        {
            sin_f(i);
        }
    }
    auto t2 = high_resolution_clock::now();
    duration<float, std::milli> ms = t2 - t1;

    std::cout << label << "\nTime: " << ms.count() << "ms\n";

    // == ACCURACY TEST ==
    T maxError = 0;
    for (T i = errorStart; i < errorEnd; i += 0.01) {
        T error = fabs(sin(i) - sin_f(i));
        if (error > maxError)
            maxError = error;
    }
    std::cout << "Highest Error: " << maxError << "\n\n";

}

int main(int argc, char **argv)
{
    benchmark<double>("Standard Library:", sin, -M_PI_2, +M_PI_2);
    benchmark<double>("Taylor Series (7T):", taylorsin, -M_PI_2, +M_PI_2);
    benchmark<double>("Bhaskara Formula:", bhaskara, 0, M_PI);
    benchmark<double>("Minmax Polynomial (7T):", minimaxsin, -M_PI_2, +M_PI_2);
    benchmark<float>("x87 Hardware Sin (FLOAT):", hwSin, 0, +M_PI_2);
}