library(multigroup.vaccine)
library(socialmixr)

agelims <- c(0, 1, 5, 12, 18, 25, 45, 70)
R0 <- 11

agepops1 <- c(2354, 9418, 19835, 17001, 19219, 47701, 53956, 32842)
agecovr1 <- c(0, 0.83, 0.852, 0.879, 0.9, 0.925, 0.95, 1)

agepops2 <- c(11981, 47922, 86718, 77302, 120132, 199914, 136997, 38206)
agecovr2 <- c(0, 0.86, 0.899, 0.933, 0.95, 0.95, 0.95, 1)

agepops3 = c(14527, 58108, 114156, 106006, 118837, 367597, 310945, 95637)
agecovr3 = c(0, 0.89, 0.949, 0.950, 0.95, 0.95, 0.95, 1)

fh1 <- multigroup.vaccine:::getFullHistogram(
  R0 = R0,
  agelims = agelims,
  agepops = agepops1,
  agecovr = agecovr1,
  ageveff = ageveff,
  initgrp = initgrp
)
d1 <- rowSums(fh1)
#Rv1 <- multigroup.vaccine:::vaxrepnum(meaninf, agepops1, betaij, initR, agecovr1 * agepops1, ageveff)

fh2 <- multigroup.vaccine:::getFullHistogram(
  R0 = R0,
  agelims = agelims,
  agepops = agepops2,
  agecovr = agecovr2,
  ageveff = ageveff,
  initgrp = initgrp
)
d2 <- rowSums(fh2)
#Rv2 <- multigroup.vaccine:::vaxrepnum(meaninf, agepops2, betaij, initR, agecovr2 * agepops2, ageveff)

fh3 <- multigroup.vaccine:::getFullHistogram(
  R0 = R0,
  agelims = agelims,
  agepops = agepops3,
  agecovr = agecovr3,
  ageveff = ageveff,
  initgrp = initgrp
)
d3 <- rowSums(fh3)
#Rv3 <- multigroup.vaccine:::vaxrepnum(meaninf, agepops3, betaij, initR, agecovr3 * agepops3, ageveff)

#hist(log(d1), breaks = 100, xaxt = 'n', xlab = 'total measles cases in simulation',
#     ylab = 'number of simulations',
#     main = 'Washington County, R0 = 12')
#labticks <- c(1, 10, 100, 1000, 10000, 100000)
#smticks <- c(1:10, seq(20, 100, 10), seq(200, 1000, 100), seq(2000, 10000, 1000),
#             seq(20000, 100000, 10000))
#axis(side = 1, at = log(labticks), labels = labticks)
#axis(side = 1, at = log(smticks), tck=-0.016, labels = rep('', length(smticks)))


plotHists <- function(d, Rv){
  if(Rv > 1){
    lab1 <- paste0(min(d), " to ", max(d[d<2000]), " infections")
    lab2 <- paste0(min(d[d>2000]), " to ", max(d), " infections")
    layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
    barplot(height = c(sum(d<2000),sum(d>2000)), names.arg=c(lab1,lab2),
            main = "non-escaped vs. escaped outbreak frequency", ylab = "number of simulations")
    hist(d[d<2000], breaks=50, main = "non-escaped outbreaks", xlab = "total infections",
         ylab = "number of simulations")
    hist(d[d>2000], breaks=50, main = "escaped outbreaks", xlab = "total infections",
         ylab = "number of simulations")
  }else{
    lab1 <- paste0(min(d), " to ", max(d), " infections")
    layout(matrix(c(1,2), 2, 1, byrow = TRUE))
    barplot(height = length(d), names.arg = lab1,
            main = "non-escaped outbreak frequency", ylab = "number of simulations")
    hist(d, breaks=50, main = "non-escaped outbreaks", xlab = "total infections",
         ylab = "number of simulations")
  }
}

x11()
plotHists(d1, 1.32)
x11()
plotHists(d2, 1.1)
x11()
plotHists(d3, 0.8)
