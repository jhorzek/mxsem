
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mxsem

<!-- badges: start -->

[![Total
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/mxsem)](https://cranlogs.r-pkg.org/badges/grand-total/mxsem)
[![R-CMD-check](https://github.com/jhorzek/mxsem/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jhorzek/mxsem/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jhorzek/mxsem/branch/main/graph/badge.svg)](https://app.codecov.io/gh/jhorzek/mxsem?branch=main)
<!-- badges: end -->

**mxsem** provides a **lavaan**-like (Rosseel, 2012) syntax to implement
structural equation models (SEM) with **OpenMx** (Boker et al., 2011).
The objective is to simplify fitting basic SEM with **OpenMx**, while
also unlocking some very useful advanced features. For instance,
**mxsem** allows for parameter transformations and definition variables.
However, **mxsem** is intentionally incomplete in order to focus on
simplicity. The main function (`mxsem()`) is similar to **lavaan**’s
`sem()`-function in that it tries to set up parts of the model
automatically (e.g., adding variances automatically or scaling the
latent variables automatically).

> **Warning**: The syntax and settings of **mxsem** may differ from
> **lavaan** in some cases. See `vignette("Syntax", package = "mxsem")`
> for more details on the syntax and the default arguments.

## Alternatives

**mxsem** is not the first package providing a **lavaan**-like syntax
for **OpenMx**. You will find similar functions in the following
packages:

- [**metaSEM**](https://github.com/mikewlcheung/metasem) (Cheung, 2015)
  provides a `lavaan2RAM` function that can be combined with the
  `create.mxModel` function. This combination offers more features than
  **mxsem**. For instance, constraints of the form `a < b` are
  supported. In **mxsem** such constraints require algebras (e.g.,
  `!diff; a := b - exp(diff)`).
- [**umx**](https://github.com/tbates/umx) (Bates et al., 2019) provides
  the `umxRAM` and `umxLav2RAM` functions that can parse single
  **lavaan**-style statements (e.g., `eta =~ y1 + y2 + y3`) or an entire
  **lavaan** models to **OpenMx** models.
- [**tidySEM**](https://github.com/cjvanlissa/tidySEM) (van Lissa, 2023)
  provides the `as_ram` function to translate **lavaan** syntax to
  **OpenMx** and also implements a unified syntax to specify both,
  **lavaan** and **OpenMx** models. Additionally, it works well with the
  **tidyverse**.
- [**ezMx**](https://github.com/OpenMx/ezMx) (Bates, et al. 2014)
  simplifies fitting SEM with **OpenMx** and also provides a translation
  of **lavaan** models to **OpenMx** with the `lavaan.to.OpenMx`
  function.

Because **mxsem** implements the syntax parser from scratch, it can
extend the **lavaan** syntax to account for specific **OpenMx**
features. This enables [implicit transformations](#transformations) with
curly braces.

## Citation

Cite **OpenMx** (Boker et al., 2011) for the modeling and **lavaan** for
the syntax (Rosseel, 2012). To cite **mxsem**, check
`citation("mxsem")`.

## Installation

**mxsem** is available from CRAN:

``` r
install.packages("mxsem")
```

The newest version of the package can be installed from GitHub using the
following commands in R:

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("jhorzek/mxsem", 
                         ref = "main")
```

Because **mxsem** uses Rcpp, you will need a compiler for C++ (e.g., by
installing Rtools on Windows, Xcode on Mac and build-essential on
linux).

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
    #>           name matrix   row   col      Estimate   Std.Error A lbound ubound
    #> 1     ind60→x2      A    x2 ind60  2.012660e+00  0.38891027                
    #> 2     ind60→x3      A    x3 ind60  1.650326e+00  0.36081541                
    #> 3  ind60→dem60      A dem60 ind60  4.091644e+00  0.82825703                
    #> 4  ind60→dem65      A dem65 ind60  4.476238e+01 33.03590013                
    #> 5           a1      A    y2 dem60  1.296343e+00  0.22069102                
    #> 6            b      A    y3 dem60  1.187559e+00  0.13597913                
    #> 7           c1      A    y4 dem60  1.413415e+00  0.18183251                
    #> 8  dem60→dem65      A dem65 dem60 -9.854813e+00  5.74179618                
    #> 9           a2      A    y6 dem65  1.121844e+00  0.16042018                
    #> 10          c2      A    y8 dem65  1.224479e+00  0.14984899                
    #> 11       y1↔y1      S    y1    y1  2.686888e+00  0.59075793    1e-06       
    #> 12       y2↔y2      S    y2    y2  8.576610e+00  1.48229765    1e-06       
    #> 13       y3↔y3      S    y3    y3  5.847195e+00  1.09096957    1e-06       
    #> 14       y2↔y4      S    y2    y4  1.987018e+00  0.78013870                
    #> 15       y4↔y4      S    y4    y4  3.387325e+00  0.74388310    1e-06       
    #> 16       y2↔y6      S    y2    y6  2.385179e+00  0.76306049                
    #> 17       y6↔y6      S    y6    y6  5.129115e+00  0.91213692    1e-06       
    #> 18       x1↔x1      S    x1    x1  3.013521e-01  0.06239685    1e-06       
    #> 19       x2↔x2      S    x2    x2  1.325533e+00  0.27206604    1e-06       
    #> 20       x3↔x3      S    x3    x3  1.326978e+00  0.25275042    1e-06       
    #> 21       y1↔y5      S    y1    y5  7.307489e-01  0.40428182                
    #> 22       y5↔y5      S    y5    y5  2.262309e+00  0.47568663    1e-06       
    #> 23       y3↔y7      S    y3    y7  1.315088e+00  0.74793582                
    #> 24       y7↔y7      S    y7    y7  3.819416e+00  0.79913029    1e-06       
    #> 25       y4↔y8      S    y4    y8  3.442654e-01  0.46177893                
    #> 26       y6↔y8      S    y6    y8  1.438664e+00  0.60291913                
    #> 27       y8↔y8      S    y8    y8  3.402689e+00  0.72529659    1e-06       
    #> 28 ind60↔ind60      S ind60 ind60  2.286328e-01  0.08085603    1e-06       
    #> 29 dem60↔dem60      S dem60 dem60  1.000001e-06          NA !     0!       
    #> 30 dem65↔dem65      S dem65 dem65  1.334856e-01  0.24827033    1e-06       
    #> 31      one→y1      M     1    y1  5.464667e+00  0.29473841                
    #> 32      one→y2      M     1    y2  4.256443e+00  0.44738225                
    #> 33      one→y3      M     1    y3  6.563110e+00  0.38723974                
    #> 34      one→y4      M     1    y4  4.452533e+00  0.38359678                
    #> 35      one→y6      M     1    y6  2.978074e+00  0.38247416                
    #> 36      one→x1      M     1    x1  5.054383e+00  0.08406584                
    #> 37      one→x2      M     1    x2  4.792195e+00  0.17327643                
    #> 38      one→x3      M     1    x3  3.557690e+00  0.16123756                
    #> 39      one→y5      M     1    y5  5.136252e+00  0.30340241                
    #> 40      one→y7      M     1    y7  6.196264e+00  0.37176597                
    #> 41      one→y8      M     1    y8  4.043390e+00  0.37170879                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             41                    784              3274.152
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       1706.152               3356.152                 3460.515
    #> BIC:       -110.759               3451.169                 3321.947
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:05 
    #> Wall clock time: 0.1211722 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
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
    #>           name matrix   row   col    Estimate  Std.Error A lbound ubound
    #> 1     ind60→x1      A    x1 ind60 -0.66602168 0.06402911                
    #> 2     ind60→x2      A    x2 ind60 -1.45290840 0.12615652                
    #> 3     ind60→x3      A    x3 ind60 -1.21127230 0.12698816                
    #> 4     dem60→y1      A    y1 dem60  2.21018030 0.24806182                
    #> 5           a1      A    y2 dem60  2.98303646 0.39464650        0       
    #> 6            b      A    y3 dem60  2.52119429 0.27195610                
    #> 7           c1      A    y4 dem60  2.86625955 0.31512659                
    #> 8     dem65→y5      A    y5 dem65  2.08192035 0.25256395                
    #> 9           a2      A    y6 dem65  2.61417796 0.33067157          10.123
    #> 10          c2      A    y8 dem65  2.72104603 0.30578894                
    #> 11       x1↔x1      S    x1    x1  0.08176774 0.01979715    1e-06       
    #> 12       x2↔x2      S    x2    x2  0.11868552 0.07038039    1e-06       
    #> 13       x3↔x3      S    x3    x3  0.46717050 0.08933577    1e-06       
    #> 14       y1↔y1      S    y1    y1  1.92282818 0.40072499    1e-06       
    #> 15       y2↔y2      S    y2    y2  6.51159526 1.20284012    1e-06       
    #> 16       y3↔y3      S    y3    y3  5.31392061 0.95937939    1e-06       
    #> 17       y4↔y4      S    y4    y4  2.88902582 0.63409911    1e-06       
    #> 18       y5↔y5      S    y5    y5  2.38176160 0.45553891    1e-06       
    #> 19       y6↔y6      S    y6    y6  4.36051128 0.82332444    1e-06       
    #> 20       y7↔y7      S    y7    y7  3.58248880 0.68191696    1e-06       
    #> 21       y8↔y8      S    y8    y8  2.95767562 0.62791664    1e-06       
    #> 22 ind60↔dem60      S ind60 dem60 -0.43953545 0.10490002                
    #> 23 ind60↔dem65      S ind60 dem65 -0.54935145 0.09041729                
    #> 24 dem60↔dem65      S dem60 dem65  0.97753003 0.02697925                
    #> 25      one→x1      M     1    x1  5.05438406 0.08369988                
    #> 26      one→x2      M     1    x2  4.79219545 0.17243259                
    #> 27      one→x3      M     1    x3  3.55769028 0.16060761                
    #> 28      one→y1      M     1    y1  5.46466541 0.30131941                
    #> 29      one→y2      M     1    y2  4.25644008 0.45333817                
    #> 30      one→y3      M     1    y3  6.56310968 0.39450506                
    #> 31      one→y4      M     1    y4  4.45253268 0.38484200                
    #> 32      one→y5      M     1    y5  5.13625169 0.29928682                
    #> 33      one→y6      M     1    y6  2.97807303 0.38639154                
    #> 34      one→y7      M     1    y7  6.19626363 0.36407370                
    #> 35      one→y8      M     1    y8  4.04338969 0.37174814                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             35                    790              3130.995
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1550.9954               3200.995                 3265.611
    #> BIC:      -279.8202               3282.107                 3171.797
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:07 
    #> Wall clock time: 0.2666872 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
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
      data  = dataset) |>
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
    #> 1  y1↔y1      S  y1  y1  0.02578029 0.014488230       0!       
    #> 2  y2↔y2      S  y2  y2  0.04010524 0.008389744       0!       
    #> 3  y3↔y3      S  y3  y3  0.04008175 0.006984929       0!       
    #> 4  y4↔y4      S  y4  y4  0.01752572 0.006930952 !     0!       
    #> 5  y5↔y5      S  y5  y5  0.05936968 0.016067405    1e-06       
    #> 6    I↔I      S   I   I  1.02593614 0.148068976    1e-06       
    #> 7    I↔S      S   I   S -0.14724710 0.110019557                
    #> 8    S↔S      S   S   S  1.13050977 0.160502645    1e-06       
    #> 9    int      M   1   I  0.93112329 0.102209132                
    #> 10   slp      M   1   S  0.48442608 0.106476404                
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
    #> timestamp: 2024-06-26 21:48:09 
    #> Wall clock time: 0.6023481 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
    #> Need help?  See help(mxSummary)

</details>

## Transformations

Sometimes, one may want to express one parameter as a function of other
parameters. In moderated non-linear factor analysis, for example, model
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

**mxsem** currently supports two ways of specifying such
transformations. First, they can be specified explicitly. To this end,
the parameters $a_0$ and $a_1$ must fist be initialized with `!a0` and
`!a1`. Additionally, the transformation must be defined with
`a := a0 + a1*data.k`.

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

fit_mx <- mxsem(model = model,
                data  = dataset) |>
  mxTryHard()

summary(fit_mx)

# get just the value for parameter a:
mxEval(expression = a, model = fit_mx)
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled20 
    #>  
    #> free parameters:
    #>       name         matrix row col    Estimate   Std.Error A lbound ubound
    #> 1    xi→x2              A  x2  xi  0.79157856 0.026246030                
    #> 2    xi→x3              A  x3  xi  0.89166084 0.027991530                
    #> 3   eta→y2              A  y2 eta  0.81610417 0.028977422                
    #> 4   eta→y3              A  y3 eta  0.90741898 0.027924339                
    #> 5    x1↔x1              S  x1  x1  0.04060218 0.011022272       0!       
    #> 6    x2↔x2              S  x2  x2  0.04519854 0.008621602       0!       
    #> 7    x3↔x3              S  x3  x3  0.04647176 0.010143713       0!       
    #> 8    y1↔y1              S  y1  y1  0.03388953 0.008495337       0!       
    #> 9    y2↔y2              S  y2  y2  0.04210954 0.007766716 !     0!       
    #> 10   y3↔y3              S  y3  y3  0.03107018 0.007268297 !     0!       
    #> 11   xi↔xi              S  xi  xi  1.07304573 0.157790632    1e-06       
    #> 12 eta↔eta              S eta eta  0.26127595 0.041232498    1e-06       
    #> 13  one→x1              M   1  x1 -0.14881004 0.105059830                
    #> 14  one→x2              M   1  x2 -0.10969640 0.084340983                
    #> 15  one→x3              M   1  x3 -0.15448448 0.094428639                
    #> 16  one→y1              M   1  y1 -0.05304588 0.089763143                
    #> 17  one→y2              M   1  y2 -0.13040824 0.074580498                
    #> 18  one→y3              M   1  y3 -0.05666192 0.081649015                
    #> 19      a0 new_parameters   1   1  0.78168122 0.069380240                
    #> 20      a1 new_parameters   1   2 -0.19334116 0.107739139                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             20                      7              475.3822
    #>    Saturated:             27                      0                    NA
    #> Independence:             12                     15                    NA
    #> Number of observations/statistics: 100/27
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       461.3822               515.3822                 526.0151
    #> BIC:       443.1460               567.4856                 504.3206
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:10 
    #> Wall clock time: 0.08016205 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
    #> Need help?  See help(mxSummary)
    #>           [,1]
    #> [1,] 0.7816812

</details>

Alternatively, the transformations can be defined implicitly by placing
the algebra in curly braces and directly inserting it in the syntax in
place of the parameter label. This is inspired by the approach in
**metaSEM** (Cheung, 2015).

``` r
model <- "
  # loadings
     xi =~ x1 + x2 + x3
     eta =~ y1 + y2 + y3
  # regression
     eta ~ {a0 + a1*data.k} * xi
"

mxsem(model = model,
      data  = dataset) |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled48 
    #>  
    #> free parameters:
    #>       name         matrix row col    Estimate   Std.Error A lbound ubound
    #> 1    xi→x2              A  x2  xi  0.79157856 0.026246030                
    #> 2    xi→x3              A  x3  xi  0.89166084 0.027991530                
    #> 3   eta→y2              A  y2 eta  0.81610417 0.028977422                
    #> 4   eta→y3              A  y3 eta  0.90741898 0.027924339                
    #> 5    x1↔x1              S  x1  x1  0.04060218 0.011022272       0!       
    #> 6    x2↔x2              S  x2  x2  0.04519854 0.008621602       0!       
    #> 7    x3↔x3              S  x3  x3  0.04647176 0.010143713       0!       
    #> 8    y1↔y1              S  y1  y1  0.03388953 0.008495337       0!       
    #> 9    y2↔y2              S  y2  y2  0.04210954 0.007766716 !     0!       
    #> 10   y3↔y3              S  y3  y3  0.03107018 0.007268297 !     0!       
    #> 11   xi↔xi              S  xi  xi  1.07304573 0.157790632    1e-06       
    #> 12 eta↔eta              S eta eta  0.26127595 0.041232498    1e-06       
    #> 13  one→x1              M   1  x1 -0.14881004 0.105059830                
    #> 14  one→x2              M   1  x2 -0.10969640 0.084340983                
    #> 15  one→x3              M   1  x3 -0.15448448 0.094428639                
    #> 16  one→y1              M   1  y1 -0.05304588 0.089763143                
    #> 17  one→y2              M   1  y2 -0.13040824 0.074580498                
    #> 18  one→y3              M   1  y3 -0.05666192 0.081649015                
    #> 19      a0 new_parameters   1   1  0.78168122 0.069380240                
    #> 20      a1 new_parameters   1   2 -0.19334116 0.107739139                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             20                      7              475.3822
    #>    Saturated:             27                      0                    NA
    #> Independence:             12                     15                    NA
    #> Number of observations/statistics: 100/27
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       461.3822               515.3822                 526.0151
    #> BIC:       443.1460               567.4856                 504.3206
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:10 
    #> Wall clock time: 0.07873321 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
    #> Need help?  See help(mxSummary)

</details>

You can also provide custom names for the algebra results:

``` r
model <- "
  # loadings
     xi  =~ x1 + x2 + x3
     eta =~ y1 + y2 + y3
  # regression
     eta ~ {a := a0 + a1*data.k} * xi
"

fit_mx <- mxsem(model = model,
                data  = dataset) |>
  mxTryHard()

summary(fit_mx)

# get just the value for parameter a:
mxEval(expression = a, 
       model      = fit_mx)
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled76 
    #>  
    #> free parameters:
    #>       name         matrix row col    Estimate   Std.Error A lbound ubound
    #> 1    xi→x2              A  x2  xi  0.79157856 0.026246030                
    #> 2    xi→x3              A  x3  xi  0.89166084 0.027991530                
    #> 3   eta→y2              A  y2 eta  0.81610417 0.028977422                
    #> 4   eta→y3              A  y3 eta  0.90741898 0.027924339                
    #> 5    x1↔x1              S  x1  x1  0.04060218 0.011022272       0!       
    #> 6    x2↔x2              S  x2  x2  0.04519854 0.008621602       0!       
    #> 7    x3↔x3              S  x3  x3  0.04647176 0.010143713       0!       
    #> 8    y1↔y1              S  y1  y1  0.03388953 0.008495337       0!       
    #> 9    y2↔y2              S  y2  y2  0.04210954 0.007766716 !     0!       
    #> 10   y3↔y3              S  y3  y3  0.03107018 0.007268297 !     0!       
    #> 11   xi↔xi              S  xi  xi  1.07304573 0.157790632    1e-06       
    #> 12 eta↔eta              S eta eta  0.26127595 0.041232498    1e-06       
    #> 13  one→x1              M   1  x1 -0.14881004 0.105059830                
    #> 14  one→x2              M   1  x2 -0.10969640 0.084340983                
    #> 15  one→x3              M   1  x3 -0.15448448 0.094428639                
    #> 16  one→y1              M   1  y1 -0.05304588 0.089763143                
    #> 17  one→y2              M   1  y2 -0.13040824 0.074580498                
    #> 18  one→y3              M   1  y3 -0.05666192 0.081649015                
    #> 19      a0 new_parameters   1   1  0.78168122 0.069380240                
    #> 20      a1 new_parameters   1   2 -0.19334116 0.107739139                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             20                      7              475.3822
    #>    Saturated:             27                      0                    NA
    #> Independence:             12                     15                    NA
    #> Number of observations/statistics: 100/27
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:       461.3822               515.3822                 526.0151
    #> BIC:       443.1460               567.4856                 504.3206
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:11 
    #> Wall clock time: 0.07708836 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
    #> Need help?  See help(mxSummary)
    #>           [,1]
    #> [1,] 0.7816812

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

Another point of failure are the default labels used by **mxsem** to
indicate directed and undirected effects. These are based on unicode
characters. If you see parameter labels similar to `"eta\u2192y1"` in
your output, this indicates that your editor cannot display unicode
characters. In this case, you can customize the labels as follows:

``` r
library(mxsem)
model <- '
  # latent variable definitions
     ind60 =~ x1 + x2 + x3
     dem60 =~ y1 + a1*y2 + b*y3 + c1*y4
     dem65 =~ y5 + a2*y6 + b*y7 + c2*y8
'

mxsem(model      = model,
      data       = OpenMx::Bollen, 
      directed   = "_TO_", 
      undirected = "_WITH_") |>
  mxTryHard() |>
  summary()
```

<details>
<summary>
Show summary
</summary>

    #> Summary of untitled90 
    #>  
    #> free parameters:
    #>                name matrix   row   col   Estimate  Std.Error A lbound ubound
    #> 1       ind60_TO_x2      A    x2 ind60 2.18115702 0.13928666                
    #> 2       ind60_TO_x3      A    x3 ind60 1.81852890 0.15228797                
    #> 3                a1      A    y2 dem60 1.40364256 0.18390038                
    #> 4                 b      A    y3 dem60 1.17009172 0.10871747                
    #> 5                c1      A    y4 dem60 1.34853386 0.14637663                
    #> 6                a2      A    y6 dem65 1.20074512 0.14855357                
    #> 7                c2      A    y8 dem65 1.25031848 0.13637438                
    #> 8        x1_WITH_x1      S    x1    x1 0.08169539 0.01979123    1e-06       
    #> 9        x2_WITH_x2      S    x2    x2 0.11895803 0.07035954    1e-06       
    #> 10       x3_WITH_x3      S    x3    x3 0.46715652 0.08931226    1e-06       
    #> 11       y1_WITH_y1      S    y1    y1 1.96249145 0.40675153 !  1e-06       
    #> 12       y2_WITH_y2      S    y2    y2 6.49922273 1.20251628    1e-06       
    #> 13       y3_WITH_y3      S    y3    y3 5.32559112 0.95894588    1e-06       
    #> 14       y4_WITH_y4      S    y4    y4 2.87950917 0.63665763    1e-06       
    #> 15       y5_WITH_y5      S    y5    y5 2.37088343 0.45487035    1e-06       
    #> 16       y6_WITH_y6      S    y6    y6 4.37313277 0.82251242    1e-06       
    #> 17       y7_WITH_y7      S    y7    y7 3.56699590 0.68171379    1e-06       
    #> 18       y8_WITH_y8      S    y8    y8 2.96557681 0.62443800 !  1e-06       
    #> 19 ind60_WITH_ind60      S ind60 ind60 0.44829143 0.08675629    1e-06       
    #> 20 ind60_WITH_dem60      S ind60 dem60 0.63807497 0.19920187                
    #> 21 dem60_WITH_dem60      S dem60 dem60 4.50351167 1.00616960    1e-06       
    #> 22 ind60_WITH_dem65      S ind60 dem65 0.81413650 0.21697272                
    #> 23 dem60_WITH_dem65      S dem60 dem65 4.52636825 0.93243049                
    #> 24 dem65_WITH_dem65      S dem65 dem65 4.75141153 1.04835747    1e-06       
    #> 25        one_TO_x1      M     1    x1 5.05438446 0.08405796                
    #> 26        one_TO_x2      M     1    x2 4.79219580 0.17325941                
    #> 27        one_TO_x3      M     1    x3 3.55769067 0.16122376                
    #> 28        one_TO_y1      M     1    y1 5.46466750 0.29359270                
    #> 29        one_TO_y2      M     1    y2 4.25644400 0.45268169                
    #> 30        one_TO_y3      M     1    y3 6.56311167 0.39140003                
    #> 31        one_TO_y4      M     1    y4 4.45253335 0.38413637                
    #> 32        one_TO_y5      M     1    y5 5.13625263 0.30813153                
    #> 33        one_TO_y6      M     1    y6 2.97807393 0.38680848                
    #> 34        one_TO_y7      M     1    y7 6.19626358 0.36642683                
    #> 35        one_TO_y8      M     1    y8 4.04339058 0.37222072                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             35                    790              3131.168
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1551.1683               3201.168                 3265.784
    #> BIC:      -279.6473               3282.280                 3171.970
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2024-06-26 21:48:12 
    #> Wall clock time: 0.1935849 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.11 
    #> Need help?  See help(mxSummary)

</details>

## References

- Bates, T. C., Maes, H., & Neale, M. C. (2019). umx: Twin and
  Path-Based Structural Equation Modeling in R. Twin Research and Human
  Genetics, 22(1), 27–41. <https://doi.org/10.1017/thg.2019.2>
- Bates, T. C., Prindle, J. J. (2014). ezMx.
  <https://github.com/OpenMx/ezMx>
- Boker, S. M., Neale, M., Maes, H., Wilde, M., Spiegel, M., Brick, T.,
  Spies, J., Estabrook, R., Kenny, S., Bates, T., Mehta, P., & Fox, J.
  (2011). OpenMx: An Open Source Extended Structural Equation Modeling
  Framework. Psychometrika, 76(2), 306–317.
  <https://doi.org/10.1007/s11336-010-9200-6>
- Cheung, M. W.-L. (2015). metaSEM: An R package for meta-analysis using
  structural equation modeling. Frontiers in Psychology, 5.
  <https://doi.org/10.3389/fpsyg.2014.01521>
- Rosseel, Y. (2012). lavaan: An R package for structural equation
  modeling. Journal of Statistical Software, 48(2), 1–36.
  <https://doi.org/10.18637/jss.v048.i02>
- van Lissa, C. J. (2023). tidySEM: Tidy Structural Equation Modeling. R
  package version 0.2.4, <https://cjvanlissa.github.io/tidySEM/>.
