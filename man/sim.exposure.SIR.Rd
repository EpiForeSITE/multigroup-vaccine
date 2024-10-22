\name{sim.exposure.SIR}
\alias{sim.exposure.SIR}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
sim.exposure.SIR(Rinit, Iinit, Vinit, tm, N, R0, gam, a, eps, q)
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
  \item{tm}{
%%     ~~Describe \code{tm} here~~
}
  \item{N}{
%%     ~~Describe \code{N} here~~
}
  \item{R0}{
%%     ~~Describe \code{R0} here~~
}
  \item{gam}{
%%     ~~Describe \code{gam} here~~
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
function (Rinit, Iinit, Vinit, tm, N, R0, gam, a, eps, q)
{
    Ntot <- sum(N)
    beta <- (1 - eps) * outer(a, a)/sum(N * a) + eps * a/(N) *
        diag(2)
    scaling.factor <- rescale.R0(beta = beta, gam = gam, pop.p = N/Ntot,
        N = Ntot, R0.value = R0)
    pars <- list(N = Ntot, N1 = N[1], N2 = N[2], activities = a,
        epsilon = eps, gam = gam, scaling.factor = scaling.factor)
    times <- c(0, tm)
    S.init <- c(S1 = N[1] - Rinit[1] - Iinit[1] - Vinit[1], S2 = N[2] -
        Rinit[2] - Iinit[2] - Vinit[2])
    I.init <- c(I1 = Iinit[1], I2 = Iinit[2])
    R.init <- c(R1 = Rinit[1], R2 = Rinit[2])
    if (sum(I.init) == 0) {
        I.init <- c(I1 = N[1]/Ntot, I2 = N[2]/Ntot)
        S.init <- S.init - I.init
    }
    y0 <- c(S.init, I.init, R.init)
    simulation <- as.data.frame(ode(y0, times, exposure.SIR,
        pars))
    simulation
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
