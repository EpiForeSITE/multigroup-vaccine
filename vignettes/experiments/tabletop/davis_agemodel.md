    library(multigroup.vaccine)
    library(socialmixr)

This vignette demonstrates an age-structured model of transmission
within a Davis County, Utah.

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

    #age_immunity <- c(0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1)
    age_immunity <- rep(0, length(age_limits))

Now we can begin defining the input arguments to our `finalsize`
function so that we can estimate the outbreak size in this county after
an introduction.

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
    #>   1   2   3   4   5 
    #> 894  85  12   7   2
    outbreak_dist(R0 = 0.2)
    #> 
    #>   1   2   3   4   5   6   7   8  10 
    #> 750 150  62  21   4   8   3   1   1
    outbreak_dist(R0 = 0.3)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  12 
    #> 723 154  46  36  14  14   5   3   3   1   1
    outbreak_dist(R0 = 0.4)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  13  14  16  17  19  21  28 
    #> 655 145  70  39  32  21  10   5   2   7   2   3   2   2   2   1   1   1
    outbreak_dist(R0 = 0.5)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  20  21  22  25  35 
    #> 606 154  68  35  30  21  18   7   8  12   6   9   4   4   8   3   1   2   1   2   1
    outbreak_dist(R0 = 0.6)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  23  24  25  27 
    #> 557 152  74  45  26  24  18  20   5   8   8   8   3   9   4   2   6   4   1   1   7   1   1   2   2 
    #>  28  29  30  31  32  33  34  37  39  47  48 
    #>   1   1   1   1   2   1   1   1   1   1   1
    outbreak_dist(R0 = 0.7)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  26 
    #> 484 160  74  59  33  32  28  16   6  12  13   8   7  10   4   5   3   5   4   3   3   4   3   3   1 
    #>  27  28  29  30  32  33  35  37  44  49  54  58  61  63  71  87 118 
    #>   1   1   1   3   1   1   1   1   1   1   1   2   1   1   1   1   1
    outbreak_dist(R0 = 0.8)
    #> 
    #>   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25 
    #> 487 146  73  45  28  21  14  11  22  16   3   7   7   6   5   4   2   7   3   5   7   6   3   2   5 
    #>  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  43  44  48  51  52  53  55  56  60 
    #>   2   3   1   3   1   2   2   1   1   1   2   1   1   1   2   1   5   2   3   1   1   2   1   2   1 
    #>  61  63  67  69  70  72  73  88  92  93  95 103 105 118 165 172 181 196 237 262 279 
    #>   1   1   2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
    outbreak_dist(R0 = 0.9)
    #> 
    #>    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20 
    #>  465  121   64   32   40   23   23   16   13    8   11    9    8    8    3    4    6    7    3    5 
    #>   21   22   23   24   26   27   28   29   30   31   32   33   35   36   37   38   39   40   41   42 
    #>    4    4    6    3    3    5    3    2    2    2    5    2    1    3    3    1    1    2    1    2 
    #>   44   45   47   49   51   53   56   58   60   63   64   65   66   67   69   70   73   79   80   81 
    #>    1    1    2    2    1    1    1    1    1    2    1    1    1    1    1    1    2    1    1    1 
    #>   84   89   91   92   93   95   99  105  108  110  111  112  118  120  124  134  135  138  150  153 
    #>    1    1    2    1    1    2    2    4    1    1    1    1    1    1    1    1    1    1    1    1 
    #>  161  171  173  174  175  213  222  224  233  255  256  263  290  303  358  365  372  383  422  475 
    #>    2    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1 
    #>  505  540  700  706 1434 
    #>    1    1    1    1    1

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
    #>   390   120    51    47    28    29    21    15    12     7     4    10     7     5     8     9 
    #>    17    18    19    20    21    22    23    24    25    26    27    29    31    32    33    34 
    #>     6     3     4     4     4     2     4     2     2     4     2     2     1     3     1     2 
    #>    35    36    38    39    40    41    43    47    49    51    54    57    62    68    70    72 
    #>     3     2     1     1     1     3     4     2     2     1     1     1     1     2     1     2 
    #>    75    76    82    84    88    89    91   105   118 33400 
    #>     1     2     1     1     1     1     1     1     1   153
    outbreak_dist_hybrid(R0 = 1.2)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   398    94    51    37    25    20    14     4     8     7     8     4     6     5     6     5 
    #>    17    18    19    20    21    22    23    24    25    27    28    29    30    32    33    34 
    #>     1     5     3     4     6     4     2     3     2     2     2     2     1     2     4     2 
    #>    35    36    37    38    40    42    43    48    50    51    60    64    72    74    78 65705 
    #>     1     2     2     2     2     2     1     1     3     1     1     1     1     1     1   241
    outbreak_dist_hybrid(R0 = 1.3)
    #> 
    #>     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16 
    #>   373    94    44    38    18    15    15     9    15     4     3     3     4     7     3     2 
    #>    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32 
    #>     5     3     2     3     1     3     2     1     1     2     5     1     2     1     1     2 
    #>    36    37    42    44    45    48    51    54    59    73    78 95844 
    #>     1     1     1     1     1     1     1     1     1     1     1   307
    outbreak_dist_hybrid(R0 = 1.4)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    358     91     44     24     24     17     17     13      3     11      9      6      1      6 
    #>     15     16     18     19     22     23     24     25     27     29     30     33     38     39 
    #>      5      1      3      1      2      2      1      4      1      4      2      1      1      1 
    #>     40     51     52     58     73 123308 
    #>      1      1      1      1      1    342
    outbreak_dist_hybrid(R0 = 1.5)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    338     73     48     33     18      7      9     13      2      5      5      3      6      2 
    #>     15     16     17     18     19     20     21     24     25     27     32     47     48     64 
    #>      3      5      1      2      4      1      3      1      2      1      1      1      1      1 
    #> 148004 
    #>    411
    outbreak_dist_hybrid(R0 = 1.6)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    293     67     44     25     25     12      8      6      8      4      4      5      4      6 
    #>     15     16     17     19     20     21     23     25     27     29     31     32     37     38 
    #>      6      2      2      2      3      3      3      1      1      1      1      1      1      1 
    #>     39     42 170037 
    #>      1      1    459
    outbreak_dist_hybrid(R0 = 1.7)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    283     84     41     23      6     12      6      7      8      6      4      1      3      2 
    #>     17     18     19     20     23     24     25     26     27     28     32     35 189630 
    #>      1      1      2      2      1      1      1      1      1      1      1      1    500
    outbreak_dist_hybrid(R0 = 1.8)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     12     13     14     15 
    #>    304     68     29     18     12      6     10      4      7      4      3      3      3      3 
    #>     16     18     19     21     24     26     27 207035 
    #>      3      1      1      4      1      1      1    514
    outbreak_dist_hybrid(R0 = 1.9)
    #> 
    #>      1      2      3      4      5      6      7      8      9     10     11     12     13     14 
    #>    288     68     38     16     16      8      5      3      2      4      3      1      3      1 
    #>     15     17     19     26 222498 
    #>      2      1      2      1    538
