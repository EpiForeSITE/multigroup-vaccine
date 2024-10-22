\name{getFinalSizeAnalytic}
\alias{getFinalSizeAnalytic}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getFinalSizeAnalytic(Rinit, Iinit, Vinit, N, R0, a, eps, q)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Rinit}{
%%     ~~Describe \code{Rinit} here~~
}
  \item{Iinit}{
%%     ~~Describe \code{Iinit} here~~
}
  \item{Vinit}{
%%     ~~Describe \code{Vinit} here~~
}
  \item{N}{
%%     ~~Describe \code{N} here~~
}
  \item{R0}{
%%     ~~Describe \code{R0} here~~
}
  \item{a}{
%%     ~~Describe \code{a} here~~
}
  \item{eps}{
%%     ~~Describe \code{eps} here~~
}
  \item{q}{
%%     ~~Describe \code{q} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or standard data sets, see data().

## The function is currently defined as
function (Rinit, Iinit, Vinit, N, R0, a, eps, q)
{
    if (sum(Iinit) == 0)
        Iinit <- N/sum(N)
    Sinit <- N - Rinit - Iinit - Vinit
    fn <- (1 - eps) * a * N
    f <- fn/sum(fn)
    cij <- diag(eps) + outer((1 - eps), f)
    R0i <- R0/eigen(a * q * cij)$values[1] * a * q
    Zrhs <- function(Z) c(Sinit * (1 - exp(-R0i * cij \%*\% ((Z +
        Iinit)/N))))
    optfn <- function(x) ifelse(all(x > 0), max(abs(x - Zrhs(x))),
        Inf)
    optVal <- Inf
    while (optVal > 1) {
        opt <- optim((0.01 + 0.98 * runif(length(N))) * N, optfn)
        optVal <- opt$value
    }
    opt$par + Iinit + Rinit
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
