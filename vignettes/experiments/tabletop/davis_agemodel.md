    library(multigroup.vaccine)
    library(socialmixr)

This vignette demonstrates an age-structured model of transmission
within Davis County, Utah.

First we define the age groups that we want use in our model. We define
the `age_limits` vector using the lower limit (minimum age) of each
group, starting with 0:

    # under 1, 1-4, 5-11, 12-13, 14-17, 18-24, 25-44, 45-69, 70 plus
    age_limits <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)

Next we collect census data from Davis County, Utah, using our custom
age group choice:

    davis_data <- getCensusData(
      state_fips = getStateFIPS("Utah"),
      county_name = "Davis County",
      year = 2024,
      age_groups = age_limits,
      csv_path = getCensusDataPath()
    )

Now we specify immunity levels of our population age groups due to
vaccination and prior infection. Let’s assume no prior immunity to H5N1.

    age_immunity <- rep(0, length(age_limits))

Now we can begin defining the input arguments to our `finalsize`
function so that we can estimate the outbreak size in this county after
an introduction from a 13-year-old.

Initial population size of each disease state:

    popsize <- davis_data$age_pops

    initV <- round(age_immunity * popsize)  # initially immune cases 

    initI <- rep(0, length(popsize))  # initial infectious cases
    initI[4] <- 1                     # assume 1 initial case in the 4th age group (12-13)

    initR <- rep(0, length(popsize))  # no recent prior H5 flu survivors

Transmission matrix ingredients: contact matrix, relative susceptibility
and transmissibility. The contact matrix uses Polymod contact survey
data, adjusted for local population distribution:

    contactmatrix <- contactMatrixPolymod(age_limits, popsize)
    relsusc <- rep(1, length(popsize))      # Assume no age differences in susceptibility
    reltransm <- rep(1, length(popsize))    # or transmissibility per contact

## Basic reproduction number.

H5 flu could have a low level of transmissibility with *R*0 &lt; 1 -
let’s see how outbreak sizes might look:

    outbreak_dist <- function(R0){
      fs <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
                method ="stochastic", nsims = 1000)
      table(rowSums(fs))
    }

    outbreak_dist(R0 = 0.1)
    #> 
    #>   1   2   3   4 
    #> 881  88  25   6
    outbreak_dist(R0 = 0.2)
    #> 
    #>   1   2   3   4   5   6   7   8  11 
    #> 793 133  42  19   9   1   1   1   1
    outbreak_dist(R0 = 0.3)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12 
    #> 701 168  58  24  17  15   6   2   4   1   2   2
    outbreak_dist(R0 = 0.4)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  25 
    #> 656 140  82  37  19  25   8   9   6  10   3   1   1   2   1
    outbreak_dist(R0 = 0.5)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  19  20  23  28  31  33  34  45 
    #> 601 157  88  41  28  21  13  13   4   5   4   7   3   3   1   1   1   1   1   2   1   1   1   1   1
    outbreak_dist(R0 = 0.6)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  24  26  27 
    #> 536 162  94  48  28  21  18  15  10   8  10   6   6   7   7   3   3   2   2   1   1   1   2   1   1 
    #>  30  34  35  40  42  51  54 
    #>   1   1   1   1   1   1   1
    outbreak_dist(R0 = 0.7)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  23  24  25  26 
    #> 495 153  68  44  41  22  17  23  14  12  13   8   7   4   6   5   6   5   2   2   2   2   2   3   1 
    #>  27  28  30  31  32  33  35  37  38  43  44  46  50  54  55  56  58  60  70  72  90 117 120 168 
    #>   4   5   1   4   3   3   2   3   2   1   2   1   1   1   1   1   1   1   1   1   1   1   1   1
    outbreak_dist(R0 = 0.8)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25 
    #> 483 137  61  49  33  25  19  19  16  12  15  15  12   6   4   2   4   5   3   6   2   4   2   3   3 
    #>  26  27  28  29  31  32  33  34  35  36  37  38  39  41  43  44  45  47  48  50  54  57  67  69  71 
    #>   1   1   2   7   1   1   4   3   1   1   3   1   2   2   1   2   2   2   1   2   2   1   2   1   1 
    #>  76  79  80  85  88  91  92 102 108 124 145 161 348 
    #>   1   1   1   1   1   1   1   1   1   1   1   1   1
    outbreak_dist(R0 = 0.9)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25 
    #> 446 125  57  47  32  25  18  22  10  14  12   4   9   6  11   8   6   4   2   2   9   7   4   4   3 
    #>  26  27  28  29  30  32  33  34  35  36  37  38  39  41  42  44  45  48  49  50  53  54  55  56  57 
    #>   5   3   3   2   2   3   3   1   6   2   3   5   1   1   2   1   3   2   1   1   1   2   2   1   1 
    #>  59  60  64  67  68  69  70  72  74  76  77  78  82  86  88  89  94  99 100 102 103 106 109 112 114 
    #>   1   1   3   2   1   1   1   2   1   1   1   4   1   1   1   1   1   1   1   1   2   1   1   2   1 
    #> 119 122 130 142 158 161 166 175 187 201 209 211 213 222 230 236 246 266 292 295 461 691 
    #>   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1

If *R*<sub>0</sub> &gt; 1, there could be a very large outbreak. We can
provide a quick estimate of outbreak sizes using our hybrid model:

    outbreak_dist_hybrid <- function(R0){
      fs <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
                method ="hybrid", nsims = 1000)
      table(rowSums(fs))
    }

    outbreak_dist_hybrid(R0 = 1.1)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   394   125    53    42    22    27    17    16    15     8     6     5     7     5     5     6 
    #>    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32 
    #>     4     5     2     4     1     4     3     1     3     4     3     1     2     2     2     3 
    #>    35    36    37    38    39    40    41    43    44    45    46    47    48    49    55    59 
    #>     1     4     1     1     2     2     3     1     2     1     1     1     1     3     2     2 
    #>    61    63    69    70    72    75    80    90    97   118   119 33400 
    #>     1     2     1     1     1     1     1     1     1     1     1   163
    outbreak_dist_hybrid(R0 = 1.2)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   385    88    43    37    30    33    10     7    10    10     7     5     7     7     4     3 
    #>    17    18    19    20    21    22    23    25    26    27    28    29    31    32    33    34 
    #>     4     2     3     2     3     6     3     1     2     3     2     2     1     2     2     2 
    #>    36    37    38    39    40    42    43    44    45    46    47    48    49    50    51    52 
    #>     1     1     2     3     1     1     2     2     1     1     2     1     1     1     1     1 
    #>    53    55    56    57    77    78    81    87    95   104 65705 
    #>     1     1     1     1     1     1     1     1     1     1   242
    outbreak_dist_hybrid(R0 = 1.3)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   393    85    37    32    14    18     9    11     7     7     6     6     6     3     5     3 
    #>    17    18    19    20    21    22    23    24    25    26    27    28    29    31    33    35 
    #>     7     3     3     3     2     1     3     1     2     1     1     1     1     5     2     1 
    #>    37    38    43    46    47    48    53    54    58    65    67    72   127 95844 
    #>     1     3     1     1     1     1     1     1     1     1     1     1     1   306
    outbreak_dist_hybrid(R0 = 1.4)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    341     82     38     28     18     19     12     10      3      7      2      2      5      4 
    #>     15     16     17     18     19     20     21     22     24     25     26     27     29     30 
    #>      1      2      5      3      1      2      2      4      1      1      2      2      3      1 
    #>     31     32     33     34     37     38     39     42     43     45     47     48     50     53 
    #>      2      3      1      1      1      1      1      2      2      2      1      1      1      1 
    #>     59     70 123308 
    #>      1      1    377
    outbreak_dist_hybrid(R0 = 1.5)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    312     77     48     25     16     16     10      8     12      7      5      6      3      3 
    #>     15     16     17     18     19     22     25     26     29     35     36     38     39     40 
    #>      1      2      2      4      1      1      1      1      1      1      1      1      1      1 
    #>     42 148004 
    #>      1    432
    outbreak_dist_hybrid(R0 = 1.6)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     15 
    #>    327     86     44     27     15     10     12     11      4      4      6      2      2      1 
    #>     16     17     18     19     20     21     22     27     29     31     46     53 170037 
    #>      4      2      5      1      1      3      1      1      1      1      1      1    427
    outbreak_dist_hybrid(R0 = 1.7)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    327     68     24     26      9     16      8      8      4      3      7      3      4      3 
    #>     15     16     22     30     31 189630 
    #>      3      2      1      1      1    482
    outbreak_dist_hybrid(R0 = 1.8)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    304     72     34     21     20     14      9      4      1      3      3      2      4      2 
    #>     15     16     18     20     31     33     34     35 207035 
    #>      3      2      1      3      1      1      1      1    494
    outbreak_dist_hybrid(R0 = 1.9)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    277     74     24     16     15      5      5      7      6      3      5      5      2      1 
    #>     15     17     20     21     24 222498 
    #>      3      1      1      1      1    548
