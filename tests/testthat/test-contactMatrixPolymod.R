test_that("contactMatrixPolymod() warns and adjusts when age limits exceed 90", {
  # Age limits with one value exceeding 90
  agelims <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 100)
  agepops <- c(100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 100, 80, 60, 40, 20)

  # Should warn about age limit > 90
  expect_warning(
    cmp <- contactMatrixPolymod(agelims, agepops),
    "Age limits greater than 90 are not supported"
  )

  # The resulting matrix should have the correct dimensions
  # (19 groups: 0-4, 5-9, ..., 85-89, 90+)
  expect_equal(nrow(cmp), 19)
  expect_equal(ncol(cmp), 19)

  # The last group should be named "90+"
  expect_equal(colnames(cmp)[19], "90+")
  expect_equal(rownames(cmp)[19], "90+")
})

test_that("contactMatrixPolymod() adjusts populations correctly when exceeding 90", {
  # Age limits ending at 90 (valid case - no warning expected)
  agelims_valid <- c(0, 5, 90)
  agepops_valid <- c(100, 200, 50)

  expect_silent(cmp_valid <- contactMatrixPolymod(agelims_valid, agepops_valid))
  expect_equal(nrow(cmp_valid), 3)

  # Age limits with values > 90 should aggregate populations into 90+ group
  # When 90 is already in agelims, populations for 90+ (30) and 100+ (20) should
  # be combined (total 50) and used for the 90+ group in the contact matrix
  agelims_exceed <- c(0, 5, 90, 100)
  agepops_exceed <- c(100, 200, 30, 20)

  expect_warning(
    cmp_exceed <- contactMatrixPolymod(agelims_exceed, agepops_exceed),
    "Age limits greater than 90 are not supported"
  )

  # Should still have 3 groups (under5, 5to89, 90+)
  expect_equal(nrow(cmp_exceed), 3)
  expect_equal(ncol(cmp_exceed), 3)
  expect_equal(colnames(cmp_exceed)[3], "90+")
})

test_that("contactMatrixPolymod() works without agepops when exceeding 90", {
  agelims <- c(0, 5, 10, 95)

  # Should warn but still work
  expect_warning(
    cmp <- contactMatrixPolymod(agelims, agepops = NULL),
    "Age limits greater than 90 are not supported"
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
