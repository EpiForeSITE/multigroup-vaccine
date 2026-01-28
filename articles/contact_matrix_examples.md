# Contact Matrix Examples

This vignette demonstrates how to set up contact matrices for age- and
school-structured models using examples.

``` r
library(multigroup.vaccine)
library(socialmixr)
```

First we define the age groups we want to use, and the population sizes
of each group:

``` r
# under 1, 1-4, 5-11, 12-13, 14-17, 18-24, 25-44, 45-69, 70 plus
agelims <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)
agepops <- c(100, 400, 700, 200, 400, 700, 2000, 2400, 1000)
```

Here’s how to generate a contact matrix using Polymod data, which is
contact survey data from the well known “Polymod” study. When including
the second argument to the
[`contactMatrixPolymod()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPolymod.md)
function, the contact matrix will be adjusted to fit the population
distribution defined above in the `agepops` variable.

``` r
cmp <- contactMatrixPolymod(agelims, agepops)
knitr::kable(round(cmp, 2), format = "markdown")
```

|        | under1 | 1to4 | 5to11 | 12to13 | 14to17 | 18to24 | 25to44 | 45to69 |  70+ |
|:-------|-------:|-----:|------:|-------:|-------:|-------:|-------:|-------:|-----:|
| under1 |   0.42 | 0.72 |  0.57 |   0.09 |   0.21 |   0.32 |   2.11 |   1.14 | 0.13 |
| 1to4   |   0.18 | 2.98 |  1.52 |   0.16 |   0.24 |   0.49 |   3.28 |   1.89 | 0.35 |
| 5to11  |   0.08 | 0.87 |  8.79 |   0.82 |   0.46 |   0.46 |   3.35 |   1.88 | 0.37 |
| 12to13 |   0.04 | 0.32 |  2.86 |   7.98 |   2.50 |   0.57 |   2.77 |   2.22 | 0.47 |
| 14to17 |   0.05 | 0.24 |  0.80 |   1.25 |   9.67 |   2.21 |   2.71 |   2.51 | 0.37 |
| 18to24 |   0.05 | 0.28 |  0.46 |   0.16 |   1.26 |   5.72 |   3.68 |   2.87 | 0.37 |
| 25to44 |   0.11 | 0.66 |  1.17 |   0.28 |   0.54 |   1.29 |   5.72 |   3.83 | 0.61 |
| 45to69 |   0.05 | 0.32 |  0.55 |   0.18 |   0.42 |   0.84 |   3.20 |   4.27 | 0.96 |
| 70+    |   0.01 | 0.14 |  0.26 |   0.09 |   0.15 |   0.26 |   1.22 |   2.30 | 1.57 |

The sum of each row represents the relative overall contact rate of each
group:

``` r
knitr::kable(round(rowSums(cmp), 2), format = "markdown", col.names = "total")
```

|        | total |
|:-------|------:|
| under1 |  5.72 |
| 1to4   | 11.11 |
| 5to11  | 17.09 |
| 12to13 | 19.74 |
| 14to17 | 19.82 |
| 18to24 | 14.86 |
| 25to44 | 14.20 |
| 45to69 | 10.78 |
| 70+    |  6.01 |

Those row sums can be factored out to generate the fraction of each
group’s contacts that are with each group: The sum of each row
represents the relative overall contact rate of each group:

``` r
knitr::kable(round(cmp/rowSums(cmp), 2), format = "markdown")
```

|        | under1 | 1to4 | 5to11 | 12to13 | 14to17 | 18to24 | 25to44 | 45to69 |  70+ |
|:-------|-------:|-----:|------:|-------:|-------:|-------:|-------:|-------:|-----:|
| under1 |   0.07 | 0.13 |  0.10 |   0.02 |   0.04 |   0.06 |   0.37 |   0.20 | 0.02 |
| 1to4   |   0.02 | 0.27 |  0.14 |   0.01 |   0.02 |   0.04 |   0.29 |   0.17 | 0.03 |
| 5to11  |   0.00 | 0.05 |  0.51 |   0.05 |   0.03 |   0.03 |   0.20 |   0.11 | 0.02 |
| 12to13 |   0.00 | 0.02 |  0.14 |   0.40 |   0.13 |   0.03 |   0.14 |   0.11 | 0.02 |
| 14to17 |   0.00 | 0.01 |  0.04 |   0.06 |   0.49 |   0.11 |   0.14 |   0.13 | 0.02 |
| 18to24 |   0.00 | 0.02 |  0.03 |   0.01 |   0.08 |   0.38 |   0.25 |   0.19 | 0.03 |
| 25to44 |   0.01 | 0.05 |  0.08 |   0.02 |   0.04 |   0.09 |   0.40 |   0.27 | 0.04 |
| 45to69 |   0.00 | 0.03 |  0.05 |   0.02 |   0.04 |   0.08 |   0.30 |   0.40 | 0.09 |
| 70+    |   0.00 | 0.02 |  0.04 |   0.02 |   0.02 |   0.04 |   0.20 |   0.38 | 0.26 |

Now we show how to split the age groups for elementary school (5-11),
middle school (12-13), and high school (18-24) into two schools each:

``` r
schoolagegroups <- c(3, 3, 4, 4, 5, 5)         #The indices of the age group for each school
schoolpops <- c(350, 350, 100, 100, 200, 200)  #The number of students in each school
```

The `socialmixr` R package includes functions that allow us to see the
number of contacts of school-aged children that occurred overall
vs. just at school:

``` r
cmAll <- suppressMessages(
    suppressWarnings(socialmixr::contact_matrix(socialmixr::polymod,
                                                age.limits = agelims)$matrix))
cmSchool <- suppressMessages(
    suppressWarnings(socialmixr::contact_matrix(socialmixr::polymod,
                                                age.limits = agelims,
                                                filter = list(cnt_school = 1))$matrix))

knitr::kable(round(cmAll, 2), format = "markdown")
```

|          | \[0,1) | \[1,5) | \[5,12) | \[12,14) | \[14,18) | \[18,25) | \[25,45) | \[45,70) |  70+ |
|:---------|-------:|-------:|--------:|---------:|---------:|---------:|---------:|---------:|-----:|
| \[0,1)   |   0.33 |   0.83 |    0.75 |     0.10 |     0.33 |     0.55 |     3.72 |     1.82 | 0.16 |
| \[1,5)   |   0.07 |   2.34 |    1.38 |     0.19 |     0.25 |     0.51 |     3.62 |     1.81 | 0.32 |
| \[5,12)  |   0.03 |   0.64 |    7.43 |     0.86 |     0.45 |     0.44 |     3.68 |     1.76 | 0.30 |
| \[12,14) |   0.03 |   0.17 |    1.99 |     7.14 |     2.47 |     0.63 |     3.35 |     2.03 | 0.35 |
| \[14,18) |   0.01 |   0.17 |    0.65 |     1.07 |     9.10 |     2.11 |     2.98 |     2.15 | 0.21 |
| \[18,25) |   0.01 |   0.21 |    0.41 |     0.13 |     1.22 |     5.64 |     4.14 |     2.63 | 0.29 |
| \[25,45) |   0.04 |   0.53 |    1.03 |     0.23 |     0.53 |     1.29 |     6.55 |     3.52 | 0.44 |
| \[45,70) |   0.02 |   0.26 |    0.50 |     0.18 |     0.46 |     0.91 |     4.01 |     4.34 | 0.74 |
| 70+      |   0.01 |   0.11 |    0.25 |     0.10 |     0.20 |     0.31 |     1.72 |     2.75 | 1.48 |

``` r
knitr::kable(round(cmSchool, 2), format = "markdown")
```

|          | \[0,1) | \[1,5) | \[5,12) | \[12,14) | \[14,18) | \[18,25) | \[25,45) | \[45,70) |  70+ |
|:---------|-------:|-------:|--------:|---------:|---------:|---------:|---------:|---------:|-----:|
| \[0,1)   |   0.14 |   0.09 |    0.03 |     0.00 |     0.14 |     0.02 |     0.31 |     0.01 | 0.00 |
| \[1,5)   |   0.01 |   1.45 |    0.43 |     0.02 |     0.02 |     0.02 |     0.47 |     0.18 | 0.01 |
| \[5,12)  |   0.00 |   0.18 |    5.17 |     0.40 |     0.05 |     0.07 |     0.72 |     0.40 | 0.00 |
| \[12,14) |   0.00 |   0.01 |    0.62 |     5.57 |     1.38 |     0.07 |     0.86 |     0.48 | 0.01 |
| \[14,18) |   0.01 |   0.03 |    0.07 |     0.46 |     6.21 |     0.64 |     0.76 |     0.52 | 0.00 |
| \[18,25) |   0.00 |   0.03 |    0.04 |     0.01 |     0.42 |     2.02 |     0.36 |     0.20 | 0.00 |
| \[25,45) |   0.00 |   0.05 |    0.18 |     0.02 |     0.07 |     0.10 |     0.27 |     0.09 | 0.00 |
| \[45,70) |   0.00 |   0.06 |    0.15 |     0.04 |     0.12 |     0.05 |     0.11 |     0.10 | 0.01 |
| 70+      |   0.00 |   0.00 |    0.01 |     0.00 |     0.01 |     0.00 |     0.00 |     0.01 | 0.00 |

Based on comparing the diagonal elements for the school-aged children
age groups, we have some basis for an assumption that 70% of a student’s
within-age-group contacts occur at their own school:

``` r
schportion <- 0.70
```

Now we use the above ingredients to create a new matrix using the
[`contactMatrixAgeSchool()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixAgeSchool.md)
function. We show the old age-structured model and the new
age-and-school-structured model for comparison:

``` r
cmps <- contactMatrixAgeSchool(agelims, agepops, schoolagegroups, schoolpops, schportion)

knitr::kable(round(cmp,2), format = "markdown")
```

|        | under1 | 1to4 | 5to11 | 12to13 | 14to17 | 18to24 | 25to44 | 45to69 |  70+ |
|:-------|-------:|-----:|------:|-------:|-------:|-------:|-------:|-------:|-----:|
| under1 |   0.42 | 0.72 |  0.57 |   0.09 |   0.21 |   0.32 |   2.11 |   1.14 | 0.13 |
| 1to4   |   0.18 | 2.98 |  1.52 |   0.16 |   0.24 |   0.49 |   3.28 |   1.89 | 0.35 |
| 5to11  |   0.08 | 0.87 |  8.79 |   0.82 |   0.46 |   0.46 |   3.35 |   1.88 | 0.37 |
| 12to13 |   0.04 | 0.32 |  2.86 |   7.98 |   2.50 |   0.57 |   2.77 |   2.22 | 0.47 |
| 14to17 |   0.05 | 0.24 |  0.80 |   1.25 |   9.67 |   2.21 |   2.71 |   2.51 | 0.37 |
| 18to24 |   0.05 | 0.28 |  0.46 |   0.16 |   1.26 |   5.72 |   3.68 |   2.87 | 0.37 |
| 25to44 |   0.11 | 0.66 |  1.17 |   0.28 |   0.54 |   1.29 |   5.72 |   3.83 | 0.61 |
| 45to69 |   0.05 | 0.32 |  0.55 |   0.18 |   0.42 |   0.84 |   3.20 |   4.27 | 0.96 |
| 70+    |   0.01 | 0.14 |  0.26 |   0.09 |   0.15 |   0.26 |   1.22 |   2.30 | 1.57 |

``` r
knitr::kable(round(cmps,2), format = "markdown")
```

|          | under1 | 1to4 | 5to11s1 | 5to11s2 | 12to13s3 | 12to13s4 | 14to17s5 | 14to17s6 | 18to24 | 25to44 | 45to69 |  70+ |
|:---------|-------:|-----:|--------:|--------:|---------:|---------:|---------:|---------:|-------:|-------:|-------:|-----:|
| under1   |   0.42 | 0.72 |    0.28 |    0.28 |     0.04 |     0.04 |     0.11 |     0.11 |   0.32 |   2.11 |   1.14 | 0.13 |
| 1to4     |   0.18 | 2.98 |    0.76 |    0.76 |     0.08 |     0.08 |     0.12 |     0.12 |   0.49 |   3.28 |   1.89 | 0.35 |
| 5to11s1  |   0.08 | 0.87 |    7.47 |    1.32 |     0.41 |     0.41 |     0.23 |     0.23 |   0.46 |   3.35 |   1.88 | 0.37 |
| 5to11s2  |   0.08 | 0.87 |    1.32 |    7.47 |     0.41 |     0.41 |     0.23 |     0.23 |   0.46 |   3.35 |   1.88 | 0.37 |
| 12to13s3 |   0.04 | 0.32 |    1.43 |    1.43 |     6.79 |     1.20 |     1.25 |     1.25 |   0.57 |   2.77 |   2.22 | 0.47 |
| 12to13s4 |   0.04 | 0.32 |    1.43 |    1.43 |     1.20 |     6.79 |     1.25 |     1.25 |   0.57 |   2.77 |   2.22 | 0.47 |
| 14to17s5 |   0.05 | 0.24 |    0.40 |    0.40 |     0.63 |     0.63 |     8.22 |     1.45 |   2.21 |   2.71 |   2.51 | 0.37 |
| 14to17s6 |   0.05 | 0.24 |    0.40 |    0.40 |     0.63 |     0.63 |     1.45 |     8.22 |   2.21 |   2.71 |   2.51 | 0.37 |
| 18to24   |   0.05 | 0.28 |    0.23 |    0.23 |     0.08 |     0.08 |     0.63 |     0.63 |   5.72 |   3.68 |   2.87 | 0.37 |
| 25to44   |   0.11 | 0.66 |    0.59 |    0.59 |     0.14 |     0.14 |     0.27 |     0.27 |   1.29 |   5.72 |   3.83 | 0.61 |
| 45to69   |   0.05 | 0.32 |    0.27 |    0.27 |     0.09 |     0.09 |     0.21 |     0.21 |   0.84 |   3.20 |   4.27 | 0.96 |
| 70+      |   0.01 | 0.14 |    0.13 |    0.13 |     0.05 |     0.05 |     0.07 |     0.07 |   0.26 |   1.22 |   2.30 | 1.57 |
