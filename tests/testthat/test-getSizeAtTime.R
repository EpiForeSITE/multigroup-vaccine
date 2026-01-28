test_that("getSizeAtTime returns correct dimensions", {
  time <- 30
  transmrates <- matrix(0.2, 2, 2)
  recoveryrate <- 0.3
  popsize <- c(100, 150)
  initR <- c(0, 0)
  initI <- c(1, 0)
  initV <- c(10, 10)
  
  result <- getSizeAtTime(time, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should return a list with two elements
  expect_type(result, "list")
  expect_equal(length(result), 2)
  expect_named(result, c("totalSize", "activeSize"))
  
  # Each element should be a vector with length matching number of groups
  expect_equal(length(result$totalSize), length(popsize))
  expect_equal(length(result$activeSize), length(popsize))
  expect_type(result$totalSize, "double")
  expect_type(result$activeSize, "double")
})
