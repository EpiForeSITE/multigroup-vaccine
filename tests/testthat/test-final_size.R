library(multigroup.vaccine)


test_that("final size calculation works", {
  ret <- multigroup.vaccine::getFinalSize(0, c(0.1, 0.1), c(80000, 20000), 1.5, 1 / 7, 1.7, c(0.4, 0.4), 1)
  expect_equal(length(ret), 2)

  ret1 <- ret[1]
  ret2 <- ret[2]

  expect_equal(ret1, 23270, tolerance = 1)
  expect_equal(ret2, 10238, tolerance = 1)
})
