# TODO: add tests for contactMatrixPropPref function which test actual functionality

test_that("contactMatrixPropPref returns correct dimensions", {
  popsize <- c(100, 150, 200)
  contactrate <- c(1.1, 1.0, 0.9)
  ingroup <- c(0.2, 0.25, 0.22)
  
  result <- contactMatrixPropPref(popsize, contactrate, ingroup)
  
  # Should return a square matrix with dimensions matching number of groups
  expect_equal(nrow(result), length(popsize))
  expect_equal(ncol(result), length(popsize))
  expect_true(is.matrix(result))
})
