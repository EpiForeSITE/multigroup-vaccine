test_that("contactMatrixPropPref returns correct dimensions and values", {
  popsize <- c(100, 150, 200)
  contactrate <- c(1.1, 1.0, 0.9)
  ingroup <- c(0.2, 0.25, 0.22)

  result <- contactMatrixPropPref(popsize, contactrate, ingroup)

  # Should return a square matrix with dimensions matching number of groups
  expect_equal(nrow(result), length(popsize))
  expect_equal(ncol(result), length(popsize))
  expect_true(is.matrix(result))

  # Row sums of matrix should equal the contactrate values
  rs <- rowSums(result)
  for(i in 1:3){
    expect_equal(rs[i], contactrate[i])
  }

  #scaled result: fraction of each group's contacts that are with each other group
  sres <- result / rs

  # Scaled contact matrix values should be as expected
  f <- (1 - ingroup) * contactrate * popsize
  expect_equal(sres[1, 1], ingroup[1] + (1 - ingroup[1]) * f[1] / sum(f))
  expect_equal(sres[1, 2], (1 - ingroup[1]) * f[2] / sum(f))
  expect_equal(sres[1, 3], (1 - ingroup[1]) * f[3] / sum(f))
  expect_equal(sres[2, 1], (1 - ingroup[2]) * f[1] / sum(f))
  expect_equal(sres[2, 2], ingroup[2] + (1 - ingroup[2]) * f[2] / sum(f))
  expect_equal(sres[2, 3], (1 - ingroup[2]) * f[3] / sum(f))
  expect_equal(sres[3, 1], (1 - ingroup[3]) * f[1] / sum(f))
  expect_equal(sres[3, 2], (1 - ingroup[3]) * f[2] / sum(f))
  expect_equal(sres[3, 3], ingroup[3] + (1 - ingroup[3]) * f[3] / sum(f))
})
