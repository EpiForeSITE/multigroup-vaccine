\name{getFinalSize}
\alias{getFinalSize}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getFinalSize(vacTime, vacPortion, popSize, R0, recoveryRate, contactRatio, contactWithinGroup, suscRatio)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{vacTime}{
%%     ~~Describe \code{vacTime} here~~
}
  \item{vacPortion}{
%%     ~~Describe \code{vacPortion} here~~
}
  \item{popSize}{
%%     ~~Describe \code{popSize} here~~
}
  \item{R0}{
%%     ~~Describe \code{R0} here~~
}
  \item{recoveryRate}{
%%     ~~Describe \code{recoveryRate} here~~
}
  \item{contactRatio}{
%%     ~~Describe \code{contactRatio} here~~
}
  \item{contactWithinGroup}{
%%     ~~Describe \code{contactWithinGroup} here~~
}
  \item{suscRatio}{
%%     ~~Describe \code{suscRatio} here~~
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
function (vacTime, vacPortion, popSize, R0, recoveryRate, contactRatio,
    contactWithinGroup, suscRatio)
{
    Isim1 <- c(0, 0)
    Rsim1 <- c(0, 0)
    if (vacTime > 0) {
        sim1 <- sim.exposure.SIR(Rinit = c(0, 0), Iinit = c(0,
            0), Vinit = c(0, 0), tm = vacTime, N = popSize, R0 = R0,
            gam = recoveryRate, a = c(1, contactRatio), eps = contactWithinGroup,
            q = c(1, suscRatio))
        Isim1 <- as.numeric(sim1[nrow(sim1), c("I1", "I2")])
        Rsim1 <- as.numeric(sim1[nrow(sim1), c("R1", "R2")])
    }
    getFinalSizeAnalytic(Rinit = Rsim1, Iinit = Isim1, Vinit = popSize *
        vacPortion, N = popSize, R0 = R0, a = c(1, contactRatio),
        eps = contactWithinGroup, q = c(1, suscRatio))
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
