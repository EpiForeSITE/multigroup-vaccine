test_that("contactMatrixPolymod() warns and adjusts when age limits exceed 70", {
  # Age limits with one value exceeding 70
  agelims <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 100)
  agepops <- c(100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 50)

  # Should warn about age limit > 70
  expect_warning(
    cmp <- contactMatrixPolymod(agelims, agepops),
    "Age limits greater than 70 are not supported"
  )

  # The resulting matrix should have the correct dimensions
  # (15 groups: 0-4, 5-9, ..., 65-69, 70+)
  expect_equal(nrow(cmp), 15)
  expect_equal(ncol(cmp), 15)

  # The last group should be named "70+"
  expect_equal(colnames(cmp)[15], "70+")
  expect_equal(rownames(cmp)[15], "70+")
})

test_that("contactMatrixPolymod() adjusts populations correctly when exceeding 70", {
  # Age limits ending at 70 (valid case - no warning expected)
  agelims_valid <- c(0, 5, 70)
  agepops_valid <- c(100, 200, 50)

  expect_silent(cmp_valid <- contactMatrixPolymod(agelims_valid, agepops_valid))
  expect_equal(nrow(cmp_valid), 3)

  # Age limits with values > 70 should aggregate populations
  agelims_exceed <- c(0, 5, 70, 100)
  agepops_exceed <- c(100, 200, 30, 20)  # 30 + 20 = 50 should aggregate into 70+

  expect_warning(
    cmp_exceed <- contactMatrixPolymod(agelims_exceed, agepops_exceed),
    "Age limits greater than 70 are not supported"
  )

  # Should still have 3 groups
  expect_equal(nrow(cmp_exceed), 3)
})

test_that("contactMatrixPolymod() works without agepops when exceeding 70", {
  agelims <- c(0, 5, 10, 80)

  # Should warn but still work
  expect_warning(
    cmp <- contactMatrixPolymod(agelims, agepops = NULL),
    "Age limits greater than 70 are not supported"
  )

  # Should return a valid matrix with adjusted age limits
  expect_true(is.matrix(cmp))
  expect_equal(nrow(cmp), ncol(cmp))
})

test_that("contactMatrixPolymod() works correctly with valid age limits", {
  agelims <- c(0, 5, 18, 65)
  agepops <- c(100, 200, 500, 200)

  # Should not warn
  expect_silent(cmp <- contactMatrixPolymod(agelims, agepops))

  # Check dimensions match
  expect_equal(nrow(cmp), 4)
  expect_equal(ncol(cmp), 4)

  # Check group names
  expect_equal(colnames(cmp)[1], "under5")
  expect_equal(colnames(cmp)[4], "65+")
})
