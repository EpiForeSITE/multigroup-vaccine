library(vaccine.equity)


test_that("final size calculation works", {
  ret <- vaccine.equity::getFinalSize(0, c(0.1, 0.1), c(80000, 20000), 1.5, 1 / 7, 1.7, c(0.4, 0.4), 1)
  expect_vector(ret, 2)

  ret1 <- ret[1]
  ret2 <- ret[2]

  expect_gte(ret1, 23270)
  expect_lte(ret1, 23271)
  expect_gte(ret2, 10238)
  expect_lte(ret2, 10239)
})
