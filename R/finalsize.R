#' Calculate final outbreak size or distribution of a multigroup transmission model for a given basic
#' reproduction number, contact/transmission assumptions, and initial conditions
#' @param popsize the population size of each group
#' @param R0 the basic reproduction number
#' @param contactmatrix matrix of group-to-group contact rates
#' @param relsusc relative susceptibility to infection per contact of each group
#' @param reltransm relative transmissibility per contact of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @param method the method of final size calculation or simulation to use
#' @param nsims the number of simulations to run for stochastic methods
#' @param nthreads the number of threads (parallel workers) to use for
#' stochastic simulations. Defaults to 1 (single-threaded). Set to 0 or -1 to
#' automatically use all available cores. Ignored for `method = "hybrid"`.
#' @param cluster an optional \code{\link[parallel:makeCluster]{parallel cluster}} object
#' to use for stochastic simulations. When supplied, \code{nthreads} is ignored,
#' allowing callers to provide PSOCK, FORK, MPI, or scheduler-managed clusters.
#' Ignored for `method = "hybrid"`.
#' @param seed optional integer base random seed for stochastic methods. When
#' supplied, `finalsize()` is reproducible for that seed regardless of
#' `nthreads` and independent of caller RNG state.
#' @returns a vector (nsims = 1) or matrix (nsims > 1) with the final number infected from each group (column) in each simulation (row)
#' @examples
#' popsize <- c(800, 200)
#' R0 <- 2
#' contactmatrix <- contactMatrixPropPref(popsize = popsize, contactrate = c(1, 1),
#' ingroup = c(0.2, 0.2))
#' relsusc <- c(1, 1)
#' reltransm <- c(1, 1)
#' initR <- c(0, 0)
#' initI <- c(1, 0)
#' initV <- 0.2 * popsize
#' # Default method "ODE" numerical solves ordinary differential equations until infectious count
#' # is close to 0
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "analytic")
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "stochastic", nsims = 10)
#' # All "escaped" outbreaks set to deterministic final size:
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "hybrid", nsims = 10)
#' # Stochastic runs can be reproduced directly with seed:
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "stochastic", nsims = 10, nthreads = 2, seed = 2026)
#' # Parallel stochastic simulations are available for interactive use, but are
#' # omitted from examples to avoid spawning worker processes during R CMD check.
#' @export
finalsize <- function(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
                      method = "ODE", nsims = 1, nthreads = 1, cluster = NULL,
                      seed = NULL) {

  #Use generic recovery rate; final size is independent of recovery rate when R0 is specified
  recoveryrate <- 1
  g <- length(popsize)

  transmmatrix <- transmissionRates(R0, 1 / recoveryrate, relsusc * t(reltransm * t(contactmatrix)))

  if(method == "ODE"){
    return(getFinalSizeODE(transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if(method == "analytic"){
    return(getFinalSizeAnalytic(transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if (method == "hybrid") {
    nsims <- validateFinalsizeNsims(nsims)
    seed <- validateFinalsizeSeed(seed)

    if (is.null(seed)) {
      return(getFinalSizeDistEscape(nsims, transmmatrix, recoveryrate, popsize, initR, initI, initV))
    }

    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (had_seed) {
      old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    }

    on.exit({
      if (had_seed) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    }, add = TRUE)

    set.seed(seed)
    return(getFinalSizeDistEscape(nsims, transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if (method != "stochastic") {
    stop("Unknown method")
  }

  nsims <- validateFinalsizeNsims(nsims)
  seed <- validateFinalsizeSeed(seed)
  initS <- popsize - initR - initV
  betaoverNj <- c(t(t(transmmatrix) / popsize))
  init <- c(initS, initI, initR)
  names(init) <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))

  sim_fun <- function(seed) {
    seed <- as.integer(seed)

    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (had_seed) {
      old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    }

    on.exit({
      if (had_seed) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    })

    set.seed(seed)
    fs <- .Call(
      "_multigroup_vaccine_sir_finalsize_cpp",
      init,
      betaoverNj,
      recoveryrate,
      PACKAGE = "multigroup.vaccine"
    )
    fs[(2 * g + 1):(3 * g)]
  }

  seeds <- as.list(sampleFinalsizeSeeds(nsims, seed))

  if (is.null(cluster)) {
    nthreads <- validateFinalsizeThreads(nthreads, nsims)

    if (nthreads <= 1L) {
      return(do.call(rbind, lapply(seeds, sim_fun)))
    }

    cluster <- parallel::makeCluster(nthreads)
    on.exit(parallel::stopCluster(cluster), add = TRUE)
  } else if (!inherits(cluster, "cluster")) {
    stop("cluster must inherit from 'cluster'.")
  }

  parallel::clusterCall(cluster, initializeFinalsizeWorker, getFinalsizeDllPath())
  results <- parallel::parLapply(cluster, seeds, sim_fun)

  do.call(rbind, results)
}
