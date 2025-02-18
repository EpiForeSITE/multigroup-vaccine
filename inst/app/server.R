library(shiny)

source("global.R")

server <- function(input, output, session) {

  getTable <- function(input){
    popSize <- c(as.numeric(input$popsize_a), as.numeric(input$popsize_b))
    R0 <- as.numeric(input$R0)
    recoveryRate <- as.numeric(input$recoveryRate)
    contactRatio <- as.numeric(input$contactRatio)
    contactWithinGroup <- c(as.numeric(input$contactWithinGroup_a), as.numeric(input$contactWithinGroup_b))
    suscRatio <- as.numeric(input$suscRatio)
    vacP <- c(as.numeric(input$vacPortion_a), as.numeric(input$vacPortion_b))
    vacTime <- as.numeric(input$vacTime)
    hospProb <- c(input$hospProb_a, input$hospProb_b)
    hospDeath <- c(input$hospDeathProb_a, input$hospDeathProb_b)
    nonHospDeath <- c(input$nonHospDeathProb_a, input$nonHospDeathProb_b)

    # input validation
    validate(
      need(all(vacP >= 0 & vacP <= 1), "Vaccination portion must be between 0 and 1"),
      need(all(hospProb >= 0 & hospProb <= 1), "Hospitalization probability must be between 0 and 1"),
      need(all(hospDeath >= 0 & hospDeath <= 1), "Hospitalization death probability must be between 0 and 1"),
      need(all(nonHospDeath >= 0 & nonHospDeath <= 1), "Non-hospitalization death probability must be between 0 and 1")
    )

    fs <- getFinalSize(vacTime = vacTime, vacPortion = vacP, popSize = popSize, R0 = R0,
                       recoveryRate = recoveryRate, contactRatio = contactRatio,
                       contactWithinGroup = contactWithinGroup, suscRatio = suscRatio)

    hosp <- hospProb * fs
    death <- hosp*hospDeath + (1-hosp)*nonHospDeath

    numVax <- vacP*popSize
    tblVax <- c(sum(numVax),numVax)
    tblVaxCov <- tblVax/c(sum(popSize),popSize)
    tblInf <- c(sum(fs),fs)
    tblInfPrev <- tblInf/c(sum(popSize),popSize)
    tblHosp <- c(sum(hosp),hosp)
    tblHospPrev <- tblHosp/c(sum(popSize),popSize)
    tblDeath <- c(sum(death),death)
    tblDeathPrev <- tblDeath/c(sum(popSize),popSize)

    tbl <- rbind(vaccines = tblVax, vaccinationPercentage = 100*tblVaxCov,
                 infections = tblInf,
                 infectionPercentage = 100*tblInfPrev
                 ,hospitalizations = tblHosp,
                 hospitalizationPercentage = 100*tblHospPrev
                 ,deaths = tblDeath, deathPercentage = 100*tblDeathPrev
    )

    colnames(tbl) <- c('Total','GroupA','GroupB')
    as.data.frame(tbl)
  }

  output$table <- renderTable(getTable(input),rownames=TRUE,digits=2)
}

#  output$plot <- renderPlot(
#    {
#      popSize <- c(as.numeric(input$popsize_a), as.numeric(input$popsize_b))
#      R0 <- as.numeric(input$R0)
#      recoveryRate <- as.numeric(input$recoveryRate)
#      contactRatio <- as.numeric(input$contactRatio)
#      contactWithinGroup <- c(as.numeric(input$contactWithinGroup_a), as.numeric(input$contactWithinGroup_b))
#      suscRatio <- as.numeric(input$suscRatio)
#      vacP <- c(as.numeric(input$vacPortion_a), as.numeric(input$vacPortion_b))
#      vacTime <- as.numeric(input$vacTime)
#      amountToSpend <- as.numeric(input$amountToSpend)
#      vaccineCostRatio <- as.numeric(input$vaccineCostRatio)
## function using variables stored in environment
#      getFS0 <- function(vacP) getFinalSize(vacTime = vacTime, vacPortion = vacP, popSize = popSize, R0 = R0,
#        recoveryRate = recoveryRate, contactRatio = contactRatio,
#        contactWithinGroup = contactWithinGroup, suscRatio = suscRatio)

## get baseline (needed to be in environment for following functions to run?)
# fsNoVax <- getFS0(vacP = c(0,0))
## just embeded getFS0 in the getStats function below, instead
#      getStats <- function(vacP) {
#        fs <- getFS0(vacP)
#        infPrev <- getFS0(vacP = c(0, 0)) - fs

#        list(finalSize = fs, finalSizeProportion = fs / popSize, infectionsPrevented = infPrev)
#      }

#     getstatsout <- try(getStats(vacP))
# getstatsout<-""

#      if (any(grepl("Error", getstatsout))) {
#        plot(1, 1, main = "Error!")
#      } else {
#        plotStatsCost <- function(amountToSpend, vaxCosts) {

#          spend2max <- min(amountToSpend, popSize[2] * vaxCosts[2])
#          spend2 <- seq(0, spend2max, len = 100)
#          spend1 <- amountToSpend - spend2

#          v1 <- spend1 / vaxCosts[1]
#          v2 <- spend2 / vaxCosts[2]

#          fs <- matrix(0, 100, 2)
#          fsp <- fs
#          ip <- fs
#          ipPerCost <- fs
#          equityIndex <- rep(0, 100)

#          for (i in 1:100) {
#            stats <- getStats(c(v1[i], v2[i]) / popSize)
#            fs[i, ] <- stats$finalSize
#            fsp[i, ] <- stats$finalSizeProportion
#            ip[i, ] <- stats$infectionsPrevented

#            equityIndex[i] <- min(fsp[i, ]) / max(fsp[i, ])
#          }
#          par(mfrow = c(1, 2))
#          plot(spend2 / amountToSpend, ip[, 1] + ip[, 2], type = "l", ylim = c(0, max(ip[, 1] + ip[, 2])), lwd = 2,
#            xlab = "Proportion of spending to minority group",
#            ylab = "Infections prevented (red maj, green min)")
#          lines(spend2 / amountToSpend, ip[, 1], col = "red", lwd = 2)
#          lines(spend2 / amountToSpend, ip[, 2], col = "green", lwd = 2)

#          plot(spend2 / amountToSpend, equityIndex, type = "l", xlab = "Proportion of spending to minority group",
#            ylim = c(0, 1), lwd = 2, ylab = "maj prev (red); min prev (green); equity (black)")

#          lines(spend2 / amountToSpend, fsp[, 1], col = "red", lty = 2, lwd = 2)
#          lines(spend2 / amountToSpend, fsp[, 2], col = "green", lty = 2, lwd = 2)

#          list(majFS = fs[, 1], minFS = fs[, 2], majSpend = spend1, minSpend = spend2)
#          par(mfrow = c(1, 1))

#        }
        ## now run

## now run

#        plotStatsCost(amountToSpend,
#          c(1,
#            vaccineCostRatio))

#      }
      # ticks<-signif(seq(0,signif(max(getFSout),3),length.out=10),2)
      # axis(side = 2, at = ticks,las=1)
# ticks<-signif(seq(0,signif(max(getFSout),3),length.out=10),2)
# axis(side = 2, at = ticks,las=1)

#    },
#    res = 96)
#}
# }

