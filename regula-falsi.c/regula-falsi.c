#include <math.h>
#include <stdio.h>

double f(double x) { return x - cos(x); }
double regula_falsi(double (*f)(double x), double xl, double xr, double tol,
                    int maxiter);

int main(void) {
  printf("Solving x - cos(x) = 0 using Regula Falsi iteration method\n");
  printf("x = %lf\n", regula_falsi(&f, 0.0, 1.0, 1e-8, 100));
  return 0;
}

double regula_falsi(double (*f)(double x), double xl, double xr, double tol,
                    int maxiter) {
  double xc;

  for (int n = 0; n <= maxiter; n++) {
    // xc = xr - (*f)(xr) * (xr - xl) / ((*f)(xr) - (*f)(xl));
    xc = ((*f)(xr)*xl - (*f)(xl)*xr) / ((*f)(xr) - (*f)(xl));
    if (fabs((*f)(xc)) < tol) {
      break;
    }
    if ((*f)(xc) * (*f)(xr) < 0) {
      xl = xc;
    }
    if ((*f)(xc) * (*f)(xl) < 0) {
      xr = xc;
    }
  }
  return xc;
}
