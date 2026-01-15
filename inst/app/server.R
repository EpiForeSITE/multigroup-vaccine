library(shiny)
library(multigroup.vaccine)



server <- function(input, output, session) {
  getTable <- function(input) {
    popSize <- c(as.numeric(input$popsize_a), as.numeric(input$popsize_b))
    R0 <- as.numeric(input$R0)
    recoveryRate <- as.numeric(input$recoveryRate)
    contactRatio <- as.numeric(input$contactRatio)
    contactWithinGroup <- c(as.numeric(input$contactWithinGroup_a), as.numeric(input$contactWithinGroup_b))
    suscRatio <- as.numeric(input$suscRatio)
    transmRatio <- as.numeric(input$transmRatio)
    vacPortion <- c(as.numeric(input$vacPortion_a), as.numeric(input$vacPortion_b))
    vacTime <- as.numeric(input$vacTime)
    hospProb <- c(input$hospProb_a, input$hospProb_b)
    hospDeath <- c(input$hospDeathProb_a, input$hospDeathProb_b)
    nonHospDeath <- c(input$nonHospDeathProb_a, input$nonHospDeathProb_b)

    # input validation
    validate(
      need(all(vacPortion >= 0 & vacPortion <= 1), "Vaccination portion must be between 0 and 1"),
      need(all(hospProb >= 0 & hospProb <= 1), "Hospitalization probability must be between 0 and 1"),
      need(all(hospDeath >= 0 & hospDeath <= 1), "Hospitalization death probability must be between 0 and 1"),
      need(all(nonHospDeath >= 0 & nonHospDeath <= 1), "Non-hospitalization death probability must be between 0 and 1")
    )

    relcontact <- c(1, contactRatio)
    relsusc <- c(1, suscRatio)
    reltransm <- c(1, transmRatio)

    Isim1 <- popSize / sum(popSize)
    Rsim1 <- rep(0, length(popSize))
    Vsim1 <- rep(0, length(popSize))

    contactmatrix <- contactMatrixPropPref(popSize, relcontact, contactWithinGroup)
    transmrates <- transmissionRates(R0,
                                     1 / recoveryRate,
                                     relsusc * t(reltransm * t(contactmatrix)))

    if (vacTime > 0) {
      sizeAtVacTime <- getSizeAtTime(vacTime, transmrates, recoveryRate, popSize, Rsim1, Isim1, Vsim1)
      Isim1 <- sizeAtVacTime$activeSize
      Rsim1 <- sizeAtVacTime$totalSize - Isim1
    }

    fs <- getFinalSizeAnalytic(
      transmrates = transmrates,
      recoveryrate = recoveryRate,
      popsize = popSize,
      initR = Rsim1,
      initI = Isim1,
      initV = popSize * vacPortion
    )

    hosp <- hospProb * fs
    death <- hosp * hospDeath + (1 - hosp) * nonHospDeath

    numVax <- vacPortion * popSize
    tblVax <- c(sum(numVax), numVax)
    tblVaxCov <- tblVax / c(sum(popSize), popSize)
    tblInf <- c(sum(fs), fs)
    tblInfPrev <- tblInf / c(sum(popSize), popSize)
    tblHosp <- c(sum(hosp), hosp)
    tblHospPrev <- tblHosp / c(sum(popSize), popSize)
    tblDeath <- c(sum(death), death)
    tblDeathPrev <- tblDeath / c(sum(popSize), popSize)

    tbl <- rbind(
      vaccines = tblVax, vaccinationPercentage = 100 * tblVaxCov,
      infections = tblInf,
      infectionPercentage = 100 * tblInfPrev,
      hospitalizations = tblHosp,
      hospitalizationPercentage = 100 * tblHospPrev,
      deaths = tblDeath, deathPercentage = 100 * tblDeathPrev
    )

    colnames(tbl) <- c("Total", "GroupA", "GroupB")
    as.data.frame(tbl)
  }

  output$table <- renderTable(getTable(input), rownames = TRUE, digits = 2)
}
