
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mxsem

**mxsem** provides a **lavaan**-like (Rosseel, 2012) syntax to implement
structural equation models (SEM) with **OpenMx** (Boker et al., 2011).
The objective is to simplify fitting basic SEM with **OpenMx**, while
also unlocking some very useful advanced features. For instance,
**mxsem** allows for parameter transformations and definition variables.
However, **mxsem** is intentionally incomplete in order to focus on
simplicity. The main function (`mxsem()`) is similar to **lavaan**’s
`sem()`-function in that it tries to set up parts of the model
automatically (e.g., add variances automatically or scale the latent
variables automatically).

> **Warning**: The syntax and settings of **mxsem** may differ from
> **lavaan** in some cases. See `vignette("Syntax", package = "mxsem")`
> for more details on the syntax and the default arguments.

## Alternatives

**mxsem** is not the first package providing a **lavaan**-like syntax
for **OpenMx**. The following packages provide similar (or even more)
functionality:

- [**metaSEM**](https://github.com/mikewlcheung/metasem) provides a
  `lavaan2RAM` function that can be combined with the `create.mxModel`
  function. This combination offers more features than **mxsem**. For
  instance, constraints of the form `a < b` are supported. In **mxsem**
  such constraints require algebras (e.g., `!diff; a := b - exp(diff)`).
- [**umx**](https://github.com/tbates/umx) provides a `umxLav2RAM`
  function that can be used to parse single **lavaan**-style statements
  (e.g., `eta =~ y1 + y2 + y3`) or an entire **lavaan** model.
- [**tidySEM**](https://github.com/cjvanlissa/tidySEM) provides a
  unified syntax to specify both, **lavaan** and **OpenMx** models.
  Additionally, it works well with the **tidyverse**.
- [**ezMx**](https://github.com/OpenMx/ezMx) simplifies fitting SEM with
  **OpenMx** and also provides a translation of **lavaan** models to
  **OpenMx** with the `lavaan.to.OpenMx` function.

## Installation

The newest version of the package can be installed from GitHub using the
following commands in R:

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("jhorzek/mxsem", 
                         ref = "main")
```

## Example

The following example is directly adapted from **lavaan**:

``` r
library(mxsem)
model <- '
  # latent variable definitions
     ind60 =~ x1 + x2 + x3
     dem60 =~ y1 + a1*y2 + b*y3 + c1*y4
     dem65 =~ y5 + a2*y6 + b*y7 + c2*y8

  # regressions
    dem60 ~ ind60
    dem65 ~ ind60 + dem60

  # residual correlations
    y1 ~~ y5
    y2 ~~ y4 + y6
    y3 ~~ y7
    y4 ~~ y8
    y6 ~~ y8
'

mxsem(model = model,
      data  = OpenMx::Bollen) |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled2 
    #>  
    #> free parameters:
    #>           name matrix   row   col   Estimate  Std.Error A lbound ubound
    #> 1     ind60→x2      A    x2 ind60  0.9663289 0.02067705                
    #> 2     ind60→x3      A    x3 ind60  0.7207321 0.02288154                
    #> 3  ind60→dem60      A dem60 ind60  1.4614056 0.36428364                
    #> 4  ind60→dem65      A dem65 ind60  0.6136040 0.15669003                
    #> 5           a1      A    y2 dem60  0.8373740 0.06057033                
    #> 6            b      A    y3 dem60  1.1932225 0.04046971                
    #> 7           c1      A    y4 dem60  0.8679559 0.04642138                
    #> 8  dem60→dem65      A dem65 dem60  0.8651870 0.07089586                
    #> 9           a2      A    y6 dem65  0.6541761 0.05452645                
    #> 10          c2      A    y8 dem65  0.8395270 0.04811118                
    #> 11       y1↔y1      S    y1    y1  1.4778594 0.46283388    1e-06       
    #> 12       y2↔y2      S    y2    y2  8.4224191 1.35634437    1e-06       
    #> 13       y3↔y3      S    y3    y3  4.6555509 0.96603773    1e-06       
    #> 14       y2↔y4      S    y2    y4  2.0499539 0.82988480                
    #> 15       y4↔y4      S    y4    y4  4.4407883 0.78889346    1e-06       
    #> 16       y2↔y6      S    y2    y6  2.5035691 0.85356742                
    #> 17       y6↔y6      S    y6    y6  6.2170505 0.98613130    1e-06       
    #> 18       x1↔x1      S    x1    x1  0.0000010         NA !     0!       
    #> 19       x2↔x2      S    x2    x2  0.8665316 0.13465864    1e-06       
    #> 20       x3↔x3      S    x3    x3  1.0611238 0.15496068    1e-06       
    #> 21       y1↔y5      S    y1    y5  0.2782277 0.37107672                
    #> 22       y5↔y5      S    y5    y5  1.9104642 0.48364855    1e-06       
    #> 23       y3↔y7      S    y3    y7  0.6990970 0.67630217                
    #> 24       y7↔y7      S    y7    y7  3.5815840 0.83172715    1e-06       
    #> 25       y4↔y8      S    y4    y8  0.8860011 0.53970790                
    #> 26       y6↔y8      S    y6    y8  2.1377391 0.69994308                
    #> 27       y8↔y8      S    y8    y8  4.2105398 0.73621149    1e-06       
    #> 28 ind60↔ind60      S ind60 ind60  0.5299874         NA    1e-06       
    #> 29 dem60↔dem60      S dem60 dem60  4.4621853 0.83711051    1e-06       
    #> 30 dem65↔dem65      S dem65 dem65  0.3433671 0.31667329    1e-06       
    #> 31   one→ind60      M     1 ind60  5.0543837 0.07972659                
    #> 32   one→dem60      M     1 dem60 -1.9681618 1.86473723                
    #> 33   one→dem65      M     1 dem65 -2.6908590 0.83819456                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             33                    792              3224.919
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1640.9194               3290.919                 3345.651
    #> BIC:      -194.5312               3367.397                 3263.389
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 17:10:11 
    #> Wall clock time: 0.05496693 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.8 
    #> Need help?  See help(mxSummary)

</details>

## Adding bounds

Lower and upper bounds can be added to any of the parameters in the
model. The following demonstrates bounds on a loading:

``` r
library(mxsem)
model <- '
  # latent variable definitions
     ind60 =~ x1 + x2 + x3
     dem60 =~ y1 + a1*y2 + b*y3 + c1*y4
     dem65 =~ y5 + a2*y6 + b*y7 + c2*y8
     
  # lower bound on a1
     a1 > 0
  # upper bound on a2
     a2 < 10.123
'

mxsem(model = model,
      data  = OpenMx::Bollen, 
      # use latent variances to scale the model
      scale_loadings = FALSE, 
      scale_latent_variances = TRUE) |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled4 
    #>  
    #> free parameters:
    #>           name matrix   row   col   Estimate  Std.Error A lbound ubound
    #> 1     ind60→x1      A    x1 ind60 -0.7262677         NA                
    #> 2     ind60→x2      A    x2 ind60 -0.7018134         NA                
    #> 3     ind60→x3      A    x3 ind60 -0.5234445         NA                
    #> 4     dem60→y1      A    y1 dem60  2.4419679 0.22529664                
    #> 5           a1      A    y2 dem60  2.0709021 0.23269451        0       
    #> 6            b      A    y3 dem60  2.8899476 0.26038799                
    #> 7           c1      A    y4 dem60  2.1332557 0.21578839                
    #> 8     dem65→y5      A    y5 dem65  2.3971831 0.22429844                
    #> 9           a2      A    y6 dem65  1.6038608 0.19206424          10.123
    #> 10          c2      A    y8 dem65  2.0456258 0.21081295                
    #> 11       x1↔x1      S    x1    x1  0.0000010         NA !     0!       
    #> 12       x2↔x2      S    x2    x2  0.8665321 0.13394326    1e-06       
    #> 13       x3↔x3      S    x3    x3  1.0611235 0.15288660    1e-06       
    #> 14       y1↔y1      S    y1    y1  1.6032104 0.39642918    1e-06       
    #> 15       y2↔y2      S    y2    y2  8.2847440 1.42030326    1e-06       
    #> 16       y3↔y3      S    y3    y3  4.9988569 0.95738530    1e-06       
    #> 17       y4↔y4      S    y4    y4  4.1491111 0.75326563    1e-06       
    #> 18       y5↔y5      S    y5    y5  2.0367292 0.42276739    1e-06       
    #> 19       y6↔y6      S    y6    y6  6.1803190 1.04727724    1e-06       
    #> 20       y7↔y7      S    y7    y7  3.6002482 0.74079990    1e-06       
    #> 21       y8↔y8      S    y8    y8  4.1107037 0.73502530    1e-06       
    #> 22 ind60↔dem60      S ind60 dem60 -0.4480355 0.07423820                
    #> 23 ind60↔dem65      S ind60 dem65 -0.5692026         NA                
    #> 24 dem60↔dem65      S dem60 dem65  0.9853879 0.03017133                
    #> 25   one→ind60      M     1 ind60 -6.9593951         NA                
    #> 26   one→dem60      M     1 dem60  2.2086650 0.23410110                
    #> 27   one→dem65      M     1 dem65  2.0993396 0.22628135                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             27                    798              3282.676
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1686.6764               3336.676                 3368.847
    #> BIC:      -162.6791               3399.249                 3314.152
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 17:10:12 
    #> Wall clock time: 0.03299713 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.8 
    #> Need help?  See help(mxSummary)

</details>

**mxsem** adds lower bounds to any of the variances by default. To
remove these lower bounds, set `lbound_variances = FALSE` when calling
`mxsem()`.

## Definition Variables

Definition variables are, for instance, used in latent growth curve
models when the time intervals between observations are different for
the subjects in the data set. Here is an example, where the variables
`t_1`-`t_5` indicate the person-specific times of observation:

``` r
library(mxsem)
set.seed(3489)
dataset <- simulate_latent_growth_curve(N = 100)
head(dataset)
#>             y1       y2       y3        y4         y5 t_1       t_2      t_3
#> [1,] 1.2817946 5.159870 7.178191  8.950046 11.4822306   0 1.5792322 2.304777
#> [2,] 1.1796379 3.588279 5.927219  8.381157 10.4640667   0 1.6701976 3.530621
#> [3,] 0.2196010 0.763441 2.499564  3.672995  4.4505868   0 0.6452145 2.512730
#> [4,] 0.5688185 1.440709 1.523483  1.416965  1.9674847   0 1.7171826 3.245522
#> [5,] 3.4928919 2.620657 1.753159  1.080701 -0.4436508   0 1.4055839 2.024568
#> [6,] 0.3520293 5.126854 7.390669 10.721785 12.6363472   0 1.5249299 2.400432
#>           t_4      t_5
#> [1,] 3.120797 4.217403
#> [2,] 5.004695 6.408367
#> [3,] 3.761189 4.729461
#> [4,] 4.331997 6.145424
#> [5,] 3.570780 5.517224
#> [6,] 3.654230 4.222212
```

In **OpenMx**, parameters can be set to the values found in the columns
of the data set with the `data.` prefix. This is used in the following
to fix the loadings of a latent slope variable on the observations to
the times recorded in `t_1`-`t_5`:

``` r
library(mxsem)
model <- "
  # specify latent intercept
     I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
  # specify latent slope
     S =~ data.t_1 * y1 + data.t_2 * y2 + data.t_3 * y3 + data.t_4 * y4 + data.t_5 * y5
    
  # specify means of latent intercept and slope
     I ~ int*1
     S ~ slp*1
  
  # set intercepts of manifest variables to zero
     y1 ~ 0*1; y2 ~ 0*1; y3 ~ 0*1; y4 ~ 0*1; y5 ~ 0*1;
  "

mxsem(model = model,
      data = dataset) |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled6 
    #>  
    #> free parameters:
    #>     name matrix row col    Estimate   Std.Error A lbound ubound
    #> 1  y1↔y1      S  y1  y1  0.02578029 0.014488264       0!       
    #> 2  y2↔y2      S  y2  y2  0.04010524 0.008389750       0!       
    #> 3  y3↔y3      S  y3  y3  0.04008174 0.006984929       0!       
    #> 4  y4↔y4      S  y4  y4  0.01752572 0.006930941       0!       
    #> 5  y5↔y5      S  y5  y5  0.05936966 0.016067358    1e-06       
    #> 6    I↔I      S   I   I  1.02593601 0.148058876    1e-06       
    #> 7    I↔S      S   I   S -0.14724742 0.110045416                
    #> 8    S↔S      S   S   S  1.13051032 0.160486387    1e-06       
    #> 9    int      M   1   I  0.93112322 0.102209199                
    #> 10   slp      M   1   S  0.48442624 0.106475815                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             10                     10              841.2609
    #>    Saturated:             20                      0                    NA
    #> Independence:             10                     10                    NA
    #> Number of observations/statistics: 100/20
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       821.2609               861.2609                 863.7328
    #> BIC:       795.2092               887.3126                 855.7301
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 17:10:13 
    #> Wall clock time: 0.2435241 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.8 
    #> Need help?  See help(mxSummary)

</details>

## Transformations

Sometimes, one may want to express one parameter as a function of other
parameters. For instance, in moderated non-linear factor analysis, model
parameters are often expressed in terms of a covariate k. For instance,
the effect $a$ of $\xi$ on $\eta$ could be expressed as
$a = a_0 + a_1\times k$.

``` r
library(mxsem)
set.seed(9820)
dataset <- simulate_moderated_nonlinear_factor_analysis(N = 100)
head(dataset)
#>              x1         x2         x3          y1         y2            y3 k
#> [1,] -1.2166034 -1.2374549 -1.3731943 -1.01018683 -0.8296293 -1.2300555484 0
#> [2,]  1.1911346  0.9971499  1.0226322  0.86048030  0.4509088  0.6052786392 1
#> [3,] -0.7777169 -0.4725291 -0.8507347 -1.09582848 -0.5035753 -0.8048378456 0
#> [4,]  1.0027847  1.2351709  0.6951317  0.94040287  0.6684979  0.6596891858 0
#> [5,]  0.4387896  0.3919877  0.3260557 -0.58188691 -0.3614349 -0.4901022121 0
#> [6,] -1.4951549 -0.8834637 -1.1715535  0.01173845 -0.4697865 -0.0006475256 0
```

``` r
model <- "
  # loadings
     xi =~ x1 + x2 + x3
     eta =~ y1 + y2 + y3
  # regression
     eta ~ a*xi
  
  # we need two new parameters: a0 and a1. These are created as follows:
     !a0
     !a1
  # Now, we redefine a to be a0 + k*a1, where k is found in the data
     a := a0 + data.k*a1
"

mxsem(model = model,
      data = dataset) |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled20 
    #>  
    #> free parameters:
    #>       name         matrix row col    Estimate   Std.Error A lbound ubound
    #> 1    xi→x2              A  x2  xi  0.79066645 0.026101331                
    #> 2    xi→x3              A  x3  xi  0.89421471 0.027911320                
    #> 3   eta→y2              A  y2 eta  0.82005478 0.030604711                
    #> 4   eta→y3              A  y3 eta  0.90861275 0.028074637                
    #> 5    x1↔x1              S  x1  x1  0.04076157 0.011050596       0!       
    #> 6    x2↔x2              S  x2  x2  0.04538983 0.008643772       0!       
    #> 7    x3↔x3              S  x3  x3  0.04679238 0.010235632 !     0!       
    #> 8    y1↔y1              S  y1  y1  0.03475428 0.008822579 !     0!       
    #> 9    y2↔y2              S  y2  y2  0.04878645 0.008739692       0!       
    #> 10   y3↔y3              S  y3  y3  0.03051652 0.007428528 !     0!       
    #> 11   xi↔xi              S  xi  xi  1.07098664 0.157370378    1e-06       
    #> 12 eta↔eta              S eta eta  0.26292238 0.041545811    1e-06       
    #> 13  one→xi              M   1  xi -0.12468606 0.104384206                
    #> 14 one→eta              M   1 eta  0.02895977 0.054349190                
    #> 15      a0 new_parameters   1   1  0.77020821 0.069465915                
    #> 16      a1 new_parameters   1   2 -0.16456572 0.106037632                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             16                     11              489.3892
    #>    Saturated:             27                      0                    NA
    #> Independence:             12                     15                    NA
    #> Number of observations/statistics: 100/27
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       467.3892               521.3892                 527.9434
    #> BIC:       438.7323               563.0719                 512.5399
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 17:10:13 
    #> Wall clock time: 0.03321195 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.8 
    #> Need help?  See help(mxSummary)

</details>

## Adapting the Model

`mxsem` returns an `mxModel` object that can be adapted further by users
familiar with **OpenMx**.

## Trouble shooting

Sometimes things may go wrong. One way to figure out where **mxsem**
messed up is to look at the parameter table generated internally. This
parameter table is not returned by default. See
`vignette("create_parameter_table", package = "mxsem")` for more
details.

## References

- Boker, S. M., Neale, M., Maes, H., Wilde, M., Spiegel, M., Brick, T.,
  Spies, J., Estabrook, R., Kenny, S., Bates, T., Mehta, P., & Fox, J.
  (2011). OpenMx: An Open Source Extended Structural Equation Modeling
  Framework. Psychometrika, 76(2), 306–317.
  <https://doi.org/10.1007/s11336-010-9200-6>
- Rosseel, Y. (2012). lavaan: An R package for structural equation
  modeling. Journal of Statistical Software, 48(2), 1–36.
  <https://doi.org/10.18637/jss.v048.i02>
