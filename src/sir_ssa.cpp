#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
List sir_ssa_cpp(NumericVector state,
                 NumericVector beta,
                 double gamma,
                 double tmax) {

  int g = state.size() / 3;

  NumericVector S = state[Range(0, g-1)];
  NumericVector I = state[Range(g, 2*g-1)];
  NumericVector R = state[Range(2*g, 3*g-1)];

  double t = 0.0;

  std::vector<double> times;
  std::vector< NumericVector > states;

  times.push_back(t);
  states.push_back(clone(state));

  RNGScope scope;

  while (t < tmax) {

    // Compute propensities
    NumericVector prop(2*g);

    for (int i = 0; i < g; ++i) {

      double force = 0.0;

      for (int j = 0; j < g; ++j) {
        force += beta[i*g + j] * I[j];
      }

      prop[i]     = S[i] * force;     // infection
      prop[g + i] = gamma * I[i];     // recovery
    }

    double a0 = sum(prop);

    if (a0 <= 0.0) break;

    double r1 = R::runif(0.0, 1.0);
    double r2 = R::runif(0.0, 1.0);

    double tau = -log(r1) / a0;
    t += tau;

    double threshold = r2 * a0;

    double cumulative = 0.0;
    int reaction = 0;

    for (int k = 0; k < 2*g; ++k) {
      cumulative += prop[k];
      if (cumulative >= threshold) {
        reaction = k;
        break;
      }
    }

    if (reaction < g) {
      // infection i
      int i = reaction;
      S[i] -= 1;
      I[i] += 1;
    } else {
      // recovery i
      int i = reaction - g;
      I[i] -= 1;
      R[i] += 1;
    }

    for (int i = 0; i < g; ++i) {
      state[i]       = S[i];
      state[g+i]     = I[i];
      state[2*g+i]   = R[i];
    }

    times.push_back(t);
    states.push_back(clone(state));
  }

  int n = times.size();
  NumericMatrix out_states(n, state.size());

  for (int i = 0; i < n; ++i)
    out_states(i, _) = states[i];

  return List::create(
    Named("time") = times,
    Named("state") = out_states
  );
}
