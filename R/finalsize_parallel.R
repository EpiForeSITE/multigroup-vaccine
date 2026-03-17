#' Validate the Number of Simulations for `finalsize()`
#'
#' Internal helper that checks `nsims` before stochastic simulations are
#' dispatched.
#'
#' @param nsims Number of simulations requested by the caller.
#'
#' @return A scalar integer simulation count.
#'
#' @keywords internal
validateFinalsizeNsims <- function(nsims) {
  if (!is.numeric(nsims) || length(nsims) != 1L || is.na(nsims) ||
      !is.finite(nsims)) {
    stop("nsims must be a single positive integer.")
  }

  nsims_int <- as.integer(nsims)

  if (is.na(nsims_int) || nsims < 1 || nsims != nsims_int) {
    stop("nsims must be a single positive integer.")
  }

  nsims_int
}

#' Validate Optional RNG Seed for `finalsize()`
#'
#' Internal helper that validates an optional user-provided RNG seed used to
#' make stochastic simulations reproducible independent of global RNG state.
#'
#' @param seed Optional seed value provided by the caller.
#'
#' @return `NULL` or a scalar integer seed.
#'
#' @keywords internal
validateFinalsizeSeed <- function(seed) {
  if (is.null(seed)) {
    return(NULL)
  }

  if (!is.numeric(seed) || length(seed) != 1L || is.na(seed) || !is.finite(seed)) {
    stop("seed must be NULL or a single finite integer value.")
  }

  seed_int <- as.integer(seed)

  if (is.na(seed_int) || seed != seed_int) {
    stop("seed must be NULL or a single finite integer value.")
  }

  seed_int
}

#' Sample Per-simulation Seeds for `finalsize()`
#'
#' Internal helper that generates one RNG seed per stochastic simulation. When
#' `seed` is supplied, sampling is performed in a local RNG context so the
#' caller RNG state is not modified.
#'
#' @param nsims Integer simulation count.
#' @param seed Optional integer base seed.
#'
#' @return Integer vector of length `nsims`.
#'
#' @keywords internal
sampleFinalsizeSeeds <- function(nsims, seed = NULL) {
  if (is.null(seed)) {
    return(sample.int(.Machine$integer.max, nsims))
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
  sample.int(.Machine$integer.max, nsims)
}

#' Validate the Number of Threads for `finalsize()`
#'
#' Internal helper that validates the stochastic parallel worker count. Sentinel
#' values `0` and `-1` trigger auto-detection via [parallel::detectCores()].
#'
#' @param nthreads Requested number of workers.
#' @param nsims Integer number of simulations after validation.
#'
#' @return A scalar integer worker count between `1` and `nsims`.
#'
#' @keywords internal
validateFinalsizeThreads <- function(nthreads, nsims) {
  if (!is.numeric(nthreads) || length(nthreads) != 1L || is.na(nthreads)) {
    stop("nthreads must be a single, non-NA numeric value.")
  }

  if (nthreads == 0 || nthreads == -1) {
    nthreads <- parallel::detectCores()
    if (is.na(nthreads)) {
      nthreads <- 1L
    }
  } else if (nthreads < 0 || nthreads != as.integer(nthreads)) {
    stop("nthreads must be a positive integer, or 0/-1 to auto-detect available cores.")
  }

  nthreads <- as.integer(nthreads)
  max(1L, min(nthreads, nsims))
}

#' Get the Loaded `multigroup.vaccine` Shared Library Path
#'
#' Internal helper used to initialize parallel workers during local development,
#' where the package may be loaded from a temporary `pkgload` path rather than an
#' installed library tree.
#'
#' @return The path to the loaded shared library, or `NULL` if the package DLL is
#' not currently loaded.
#'
#' @keywords internal
getFinalsizeDllPath <- function() {
  dll <- getLoadedDLLs()[["multigroup.vaccine"]]

  if (is.null(dll)) {
    return(NULL)
  }

  dll[["path"]]
}

#' Initialize a `finalsize()` Parallel Worker
#'
#' Internal helper that ensures a worker process can execute stochastic
#' `finalsize()` simulations by loading the package namespace or, during local
#' development, the already-built shared library directly.
#'
#' @param dll_path Optional path to the loaded `multigroup.vaccine` shared
#' library.
#'
#' @return `NULL`, invisibly.
#'
#' @keywords internal
initializeFinalsizeWorker <- function(dll_path = NULL) {
  if (!is.null(getLoadedDLLs()[["multigroup.vaccine"]])) {
    return(invisible(NULL))
  }

  namespace_loaded <- tryCatch({
    loadNamespace("multigroup.vaccine")
    TRUE
  }, error = function(e) FALSE)

  if (!namespace_loaded) {
    loadNamespace("Rcpp")

    if (is.null(dll_path) || !file.exists(dll_path)) {
      stop("Could not load multigroup.vaccine on a parallel worker.")
    }

    dyn.load(dll_path)
  }

  invisible(NULL)
}
