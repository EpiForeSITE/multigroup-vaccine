#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector sir_finalsize_cpp(
    NumericVector init,       // length 3*g
    NumericVector beta,       // length g*g (column-major: i,j)
    double gamma
) {
  RNGScope scope;

  int g = beta.size() == 0 ? 0 : std::sqrt(beta.size());
  if (g * g != beta.size())
    stop("beta must have length g*g");

  if (init.size() != 3 * g)
    stop("initial state must have length 3g");

  NumericVector state = clone(init);

  // Temporary storage (allocated once)
  NumericVector infection_rate(g);
  NumericVector recovery_rate(g);

  bool not_done = true;
  while (not_done) {

    double total_rate = 0.0;

    for (int i = 0; i < g; ++i) {

      double Si = state[i];
      double Ii = state[g + i];

      // Recovery
      double rec = gamma * Ii;
      recovery_rate[i] = rec;
      total_rate += rec;

      // Infection force of infection
      double lambda = 0.0;
      for (int j = 0; j < g; ++j) {
        lambda += beta[j * g + i] * state[g + j];
      }

      double inf = lambda * Si;
      infection_rate[i] = inf;
      total_rate += inf;
    }

    if (total_rate <= 0.0)
      break;

    // --- Select event ---
    double r = R::runif(0.0, total_rate);
    double cumulative = 0.0;

    bool event_done = false;

    // Infection events first
    for (int i = 0; i < g && !event_done; ++i) {
      cumulative += infection_rate[i];
      if (r < cumulative) {
        state[i] -= 1;           // S_i--
        state[g + i] += 1;       // I_i++
        event_done = true;
      }
    }

    // Recovery events
    for (int i = 0; i < g && !event_done; ++i) {
      cumulative += recovery_rate[i];
      if (r < cumulative) {
        state[g + i] -= 1;       // I_i--
        state[2*g + i] += 1;     // R_i++
        event_done = true;
      }
    }
  }

  return(state);
}

