#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]#include <Rcpp.h>
#include <vector>
#include <cmath>

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector sir_finalsize_cpp(NumericVector init,
                                 NumericVector beta,
                                 double gamma) {
  RNGScope scope;

  const int m = beta.size();
  const int g = static_cast<int>(std::sqrt(static_cast<double>(m)));

  if (g * g != m)
    stop("beta must have length g*g");

  if (init.size() != 2 * g)
    stop("initial state must have length 2g");

  NumericVector state = clone(init);
  double* x = REAL(state);
  const double* B = REAL(beta);

  // Cached quantities
  std::vector<double> lambda(g, 0.0);   // force of infection in each group
  std::vector<double> prop(2 * g, 0.0);  // [infection | recovery] propensities

  // Exact integer stopping variable
  int infected_total = 0;
  for (int i = 0; i < g; ++i) {
    infected_total += static_cast<int>(x[g + i]);
  }

  // Initial lambda = B %*% I
  for (int j = 0; j < g; ++j) {
    const double Ij = x[g + j];
    if (Ij == 0.0) continue;

    const double* col = B + j * g;
    for (int i = 0; i < g; ++i) {
      lambda[i] += col[i] * Ij;
    }
  }

  double total_rate = 0.0;
  for (int i = 0; i < g; ++i) {
    prop[i] = lambda[i] * x[i];       // infection rates
    prop[g + i] = gamma * x[g + i];   // recovery rates

    total_rate += prop[i] + prop[g + i];
  }

  while (infected_total > 0) {
    const double r = R::runif(0.0, total_rate);
    double cum = 0.0;
    int event = -1;

    for (int k = 0; k < 2 * g; ++k) {
      cum += prop[k];
      if (r < cum) {
        event = k;
        break;
      }
    }

    if (event < 0) {
      stop("No event selected: r=%f, total_rate=%f, cum=%f",
           r, total_rate, cum);
    }

    if (event < g) {
      // Infection in group i
      const int i = event;

      x[i] -= 1.0;        // S_i--
      x[g + i] += 1.0;    // I_i++

      infected_total += 1;

      // Recovery propensity for group i increases by gamma
      prop[g + i] += gamma;
      total_rate += gamma;

      // I_i increased by 1, so lambda[j] increases by beta[j, i]
      const double* col = B + i * g;
      for (int j = 0; j < g; ++j) {
        lambda[j] += col[j];

        const double new_inf = x[j] * lambda[j];
        total_rate += new_inf - prop[j];
        prop[j] = new_inf;
      }

    } else {
      // Recovery in group i
      const int i = event - g;

      x[g + i] -= 1.0;      // I_i--

      infected_total -= 1;

      // Recovery propensity for group i decreases by gamma
      prop[g + i] -= gamma;
      total_rate -= gamma;

      // I_i decreased by 1, so lambda[j] decreases by beta[j, i]
      const double* col = B + i * g;
      for (int j = 0; j < g; ++j) {
        lambda[j] -= col[j];

        const double new_inf = x[j] * lambda[j];
        total_rate += new_inf - prop[j];
        prop[j] = new_inf;
      }
    }
  }

  return state;
}
