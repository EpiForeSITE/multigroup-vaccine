\name{exposure.SIR}
\alias{exposure.SIR}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
A Capitalized Title (ideally limited to 65 characters)
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
exposure.SIR(Time, state, Pars)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Time}{
%%     ~~Describe \code{Time} here~~
}
  \item{state}{
%%     ~~Describe \code{state} here~~
}
  \item{Pars}{
%%     ~~Describe \code{Pars} here~~
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
function (Time, state, Pars)
{
    with(as.list(c(Time, state, Pars)), {
        S <- c(S1, S2)
        I <- c(I1, I2)
        R <- c(R1, R2)
        N <- c(N1, N2)
        beta <- (1 - epsilon) * outer(activities, activities)/sum(c(N1,
            N2) * activities) + epsilon * activities/c(N1, N2) *
            diag(2)
        beta <- beta/scaling.factor
        dS <- -(beta \%*\% I) * S
        dI <- (beta \%*\% I) * S - gam * I
        dR <- gam * I
        return(list(c(dS, dI, dR)))
    })
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
