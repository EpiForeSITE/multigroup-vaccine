\name{rescale.R0}
\alias{rescale.R0}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
rescale.R0(beta, gam, pop.p, N, R0.value)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{beta}{
%%     ~~Describe \code{beta} here~~
}
  \item{gam}{
%%     ~~Describe \code{gam} here~~
}
  \item{pop.p}{
%%     ~~Describe \code{pop.p} here~~
}
  \item{N}{
%%     ~~Describe \code{N} here~~
}
  \item{R0.value}{
%%     ~~Describe \code{R0.value} here~~
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
function (beta, gam, pop.p, N, R0.value)
{
    NGM.unscaled <- N * pop.p * beta * 1/gam
    dom.eigen <- as.numeric(eigen(NGM.unscaled)$values[1])
    NGM.scaled <- NGM.unscaled/dom.eigen * R0.value
    scaling.factor <- beta/(NGM.scaled/(N * pop.p) * gam)
    return(scaling.factor)
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
