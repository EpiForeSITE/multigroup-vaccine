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

H5 flu could have a low level of transmissibility with
*R*<sub>0</sub> &lt; 1 - let’s see how outbreak sizes might look for a
range of 0.1 to 0.9. The results are from 1,000 simulations and show how
many of those simulations resulted in each number of total infections
(including the first one).

    outbreak_dist <- function(R0){
      fs <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
                method ="stochastic", nsims = 1000)
      table(rowSums(fs))
    }

    outbreak_dist(R0 = 0.1)
    #> 
    #>   1   2   3   4   5   6 
    #> 894  83  16   2   4   1
    outbreak_dist(R0 = 0.2)
    #> 
    #>   1   2   3   4   5   6   8  10 
    #> 803 122  47  18   4   4   1   1
    outbreak_dist(R0 = 0.3)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12 
    #> 725 154  72  25   6   8   4   2   1   1   1   1
    outbreak_dist(R0 = 0.4)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  15  16  18 
    #> 646 151  78  33  25  25  13   7   5   7   1   3   1   1   2   2
    outbreak_dist(R0 = 0.5)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  27  29 
    #> 589 174  63  43  33  19  14  12  15   9   4   5   8   2   1   1   1   1   1   2   1   1   1
    outbreak_dist(R0 = 0.6)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  25  26 
    #> 582 124  79  41  30  24  19   9  13   5   7   8   5   6   3   6   2   3   2   2   5   2   1   3   2 
    #>  27  28  31  32  34  41  45  46  50  53  55 
    #>   4   3   1   1   1   1   2   1   1   1   1
    outbreak_dist(R0 = 0.7)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25 
    #> 512 118  78  52  35  25  25  15  15  14   7   9   9   7   3   8   8   8   3   2   2   3   1   4   1 
    #>  26  27  28  29  30  31  32  34  35  36  37  41  42  44  45  46  47  50  52  53  60  64  65  67  76 
    #>   1   3   1   2   1   2   2   1   1   1   1   1   1   1   1   3   2   1   1   1   1   1   1   1   1 
    #>  80 100 122 
    #>   1   1   1
    outbreak_dist(R0 = 0.8)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  24  25  26 
    #> 471 133  72  59  42  21  18  16  13  16  12   9   1  11  11   2   4   8   1   3   6   2   1   5   3 
    #>  27  28  29  31  32  33  34  36  37  40  41  48  49  51  52  53  54  60  63  64  68  70  71  72  73 
    #>   3   1   3   1   2   1   2   4   3   1   1   2   1   2   2   2   1   1   1   1   1   1   1   1   1 
    #>  74  76  78  84  88  89  95 103 107 111 123 127 134 152 157 176 190 191 278 
    #>   1   1   1   2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
    outbreak_dist(R0 = 0.9)
    #> 
    #>    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   20   21   22 
    #>  460  120   81   53   24   23   23   17   21    7   11    8   10    6    3    6    3    6    4    2 
    #>   23   24   25   26   27   28   29   30   31   32   34   35   36   37   38   39   40   41   43   44 
    #>    3    3    4    2    2    3    2    2    1    2    1    4    2    1    2    1    1    2    2    1 
    #>   45   46   48   49   50   53   55   56   57   58   60   61   62   64   67   68   69   71   72   73 
    #>    1    1    1    1    1    2    1    1    1    2    1    1    1    2    1    2    1    1    1    1 
    #>   75   78   81   86   94   97   99  102  103  105  108  111  115  116  131  137  142  143  161  167 
    #>    1    1    2    1    1    2    2    1    1    1    1    1    1    2    1    1    1    1    1    1 
    #>  171  178  183  190  204  208  212  221  271  281  282  291  325  369  401  448  460  477  554  614 
    #>    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1 
    #>  643  675 1520 
    #>    1    1    1

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
    #>   436    74    56    39    16    30    21    10     9     9     9     5    10     8     9     6 
    #>    17    18    19    20    21    23    24    25    26    28    29    30    31    33    34    35 
    #>     5     4     3     5     6     3     5     4     3     4     2     1     2     4     1     3 
    #>    39    40    41    42    43    44    46    47    51    53    56    57    59    60    61    62 
    #>     1     3     4     1     1     1     2     1     1     2     1     1     2     1     1     2 
    #>    66    70    87   103   108   134 33400 
    #>     1     1     1     1     1     1   167
    outbreak_dist_hybrid(R0 = 1.2)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   387    89    47    28    22    13    17    12     7     9     5    12     8     5     5     4 
    #>    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    33 
    #>     2     4     6     2     4     6     1     2     3     2     2     2     2     3     1     2 
    #>    35    37    38    40    41    42    45    47    50    51    55    58    59    61    82    91 
    #>     1     2     2     2     1     1     2     1     5     1     1     1     2     1     1     1 
    #> 65705 
    #>   261
    outbreak_dist_hybrid(R0 = 1.3)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   359   117    48    29    19    14    10    13     8     7     7     6     4     4     1     2 
    #>    17    18    19    20    21    22    23    24    25    27    28    32    34    39    40    42 
    #>     2     1     4     1     3     3     1     2     6     2     1     1     4     1     1     3 
    #>    44    46    48    58    59    61    64    67    69    93   104   134 95844 
    #>     1     1     2     1     1     1     1     1     1     1     1     1   303
    outbreak_dist_hybrid(R0 = 1.4)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    386     77     49     23     16     13     12     13      4      8      3      8      3      3 
    #>     15     16     17     19     20     21     22     23     24     25     26     27     28     29 
    #>      1      2      4      3      3      1      3      2      2      1      2      1      5      1 
    #>     31     32     34     35     36     37     40     41     42     44     45     46     48     49 
    #>      1      4      3      1      3      1      1      1      1      1      2      1      1      1 
    #>     56     65     97 123308 
    #>      1      1      1    326
    outbreak_dist_hybrid(R0 = 1.5)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     13     14     15 
    #>    335     80     35     28     16     15     10      5      5      3      3      6      4      5 
    #>     16     18     19     20     22     24     25     26     28     30     31     35     79 148004 
    #>      5      5      4      1      1      2      2      1      1      2      1      1      1    423
    outbreak_dist_hybrid(R0 = 1.6)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    304     75     43     19     16     14     10     10      6      4      7      1      3      7 
    #>     15     16     17     18     19     22     26     27     33     35     38     42 170037 
    #>      2      3      2      2      2      4      1      2      1      1      1      1    459
    outbreak_dist_hybrid(R0 = 1.7)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    316     79     29     19     13     11      9      8      5      3      7      1      3      1 
    #>     15     16     17     18     20     21     23     24     28     34 189630 
    #>      5      1      2      1      1      2      1      1      1      2    479
    outbreak_dist_hybrid(R0 = 1.8)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     16 
    #>    293     83     26     18     16     14      2      3      7      4      1      3      2      1 
    #>     17     19     20     21     33     40 207035 
    #>      1      2      2      3      1      1    517
    outbreak_dist_hybrid(R0 = 1.9)
    #> 
    #>      1      2      3      4      5      6      7      8      9     11     12     14     17     18 
    #>    292     69     28     20     11      8      3      3      2      5      2      1      1      1 
    #>     22     24     26     31     32 222498 
    #>      1      2      1      1      1    548
