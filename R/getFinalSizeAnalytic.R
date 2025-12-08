#' TODO: Add documentation and @internal flag unless we want it to be exported
#' @internal
getFinalSizeAnalytic <- function(Rinit, Iinit, Vinit, N, R0, a, eps, q) {
  if (sum(Iinit) == 0)
    Iinit <- N / sum(N)

  Sinit <- N - Rinit - Iinit - Vinit
  fn <- (1 - eps) * a * N
  f <- fn / sum(fn)
  cij <- diag(eps) + outer((1 - eps), f)

  R0i <- R0 / eigen(a * q * cij)$values[1] * a * q

  Zrhs <- function(Z)
    c(Sinit * (1 - exp(-R0i * cij %*% ((
      Z + Iinit
    ) / N))))

  optfn <- function(x)
    ifelse(all(x > 0), max(abs(x - Zrhs(x))), Inf)

  optVal <- Inf
  while (optVal > 0.1) {
    opt <- stats::optim((0.01 + 0.98 * stats::runif(length(N))) * N, optfn)
    optVal <- opt$value
  }
  opt$par + Iinit + Rinit
}
