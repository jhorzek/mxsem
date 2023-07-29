
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
for **OpenMx**. You will find similar functions in the following
packages:

- [**metaSEM**](https://github.com/mikewlcheung/metasem) provides a
  `lavaan2RAM` function that can be combined with the `create.mxModel`
  function. This combination offers more features than **mxsem**. For
  instance, constraints of the form `a < b` are supported. In **mxsem**
  such constraints require algebras (e.g., `!diff; a := b - exp(diff)`).
- [**umx**](https://github.com/tbates/umx) provides the `umxRAM` and
  `umxLav2RAM` functions that can parse single **lavaan**-style
  statements (e.g., `eta =~ y1 + y2 + y3`) or an entire **lavaan**
  models to **OpenMx** models.
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
    #> 1     ind60→x2      A    x2 ind60 2.17951969 0.13890273                
    #> 2     ind60→x3      A    x3 ind60 1.81811337 0.15211751                
    #> 3  ind60→dem60      A dem60 ind60 1.44904273 0.38544855                
    #> 4  ind60→dem65      A dem65 ind60 0.60449854 0.24058577                
    #> 5           a1      A    y2 dem60 1.29147133 0.19273354                
    #> 6            b      A    y3 dem60 1.17388110 0.11991187                
    #> 7           c1      A    y4 dem60 1.30214922 0.15716825                
    #> 8  dem60→dem65      A dem65 dem60 0.89849281 0.09209863                
    #> 9           a2      A    y6 dem65 1.13247238 0.15405101                
    #> 10          c2      A    y8 dem65 1.20957807 0.14443543                
    #> 11       y1↔y1      S    y1    y1 1.91458549 0.46801012    1e-06       
    #> 12       y2↔y2      S    y2    y2 7.40452888 1.34562916    1e-06       
    #> 13       y3↔y3      S    y3    y3 4.99236808 0.96375021    1e-06       
    #> 14       y2↔y4      S    y2    y4 1.32053478 0.69918534                
    #> 15       y4↔y4      S    y4    y4 3.15117584 0.75521995    1e-06       
    #> 16       y2↔y6      S    y2    y6 2.17541773 0.72882998                
    #> 17       y6↔y6      S    y6    y6 5.01524082 0.89773033    1e-06       
    #> 18       x1↔x1      S    x1    x1 0.08135247 0.01970040    1e-06       
    #> 19       x2↔x2      S    x2    x2 0.12052866 0.06990806    1e-06       
    #> 20       x3↔x3      S    x3    x3 0.46670049 0.08911867    1e-06       
    #> 21       y1↔y5      S    y1    y5 0.59097044 0.36679629                
    #> 22       y5↔y5      S    y5    y5 2.30230244 0.48307628    1e-06       
    #> 23       y3↔y7      S    y3    y7 0.73134993 0.62154873                
    #> 24       y7↔y7      S    y7    y7 3.52500940 0.73477059    1e-06       
    #> 25       y4↔y8      S    y4    y8 0.35317926 0.45974116                
    #> 26       y6↔y8      S    y6    y8 1.41224936 0.57574745                
    #> 27       y8↔y8      S    y8    y8 3.32140113 0.71106484    1e-06       
    #> 28 ind60↔ind60      S ind60 ind60 0.44863429 0.08674943    1e-06       
    #> 29 dem60↔dem60      S dem60 dem60 3.71721943 0.89611392    1e-06       
    #> 30 dem65↔dem65      S dem65 dem65 0.16448130 0.23830932    1e-06       
    #> 31      one→y1      M     1    y1 5.46466715 0.29605013                
    #> 32      one→y2      M     1    y2 4.25644263 0.44981119                
    #> 33      one→y3      M     1    y3 6.56311026 0.39007812                
    #> 34      one→y4      M     1    y4 4.45253310 0.38385079                
    #> 35      one→y6      M     1    y6 2.97807431 0.38583489                
    #> 36      one→x1      M     1    x1 5.05438392 0.08406042                
    #> 37      one→x2      M     1    x2 4.79219470 0.17326513                
    #> 38      one→x3      M     1    x3 3.55768986 0.16122804                
    #> 39      one→y5      M     1    y5 5.13625262 0.30762959                
    #> 40      one→y7      M     1    y7 6.19626397 0.36757001                
    #> 41      one→y8      M     1    y8 4.04339020 0.37125831                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             41                    784              3096.945
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1528.9445               3178.945                 3283.308
    #> BIC:      -287.9662               3273.962                 3144.740
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 21:24:57 
    #> Wall clock time: 0.4760778 secs 
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
    #>           name matrix   row   col      Estimate  Std.Error A lbound ubound
    #> 1     ind60→x1      A    x1 ind60  6.666681e-01 0.06315415                
    #> 2     ind60→x2      A    x2 ind60  1.454233e+00 0.12397612                
    #> 3     ind60→x3      A    x3 ind60  1.212315e+00 0.12553662                
    #> 4     dem60→y1      A    y1 dem60 -2.246924e+00 0.16319098                
    #> 5           a1      A    y2 dem60  2.767920e-15         NA !     0!       
    #> 6            b      A    y3 dem60 -2.558927e+00 0.17683137                
    #> 7           c1      A    y4 dem60 -2.803486e+00 0.23735741                
    #> 8     dem65→y5      A    y5 dem65 -2.105249e+00 0.19269053                
    #> 9           a2      A    y6 dem65 -2.552435e+00 0.27843635          10.123
    #> 10          c2      A    y8 dem65 -2.714638e+00 0.22649853                
    #> 11       x1↔x1      S    x1    x1  8.172352e-02 0.01983063    1e-06       
    #> 12       x2↔x2      S    x2    x2  1.187231e-01 0.07051475    1e-06       
    #> 13       x3↔x3      S    x3    x3  4.673477e-01 0.08933646    1e-06       
    #> 14       y1↔y1      S    y1    y1  1.760228e+00 0.40668365    1e-06       
    #> 15       y2↔y2      S    y2    y2  1.537209e+01         NA    1e-06       
    #> 16       y3↔y3      S    y3    y3  4.976541e+00 0.92944092    1e-06       
    #> 17       y4↔y4      S    y4    y4  3.244124e+00 0.68666408    1e-06       
    #> 18       y5↔y5      S    y5    y5  2.283258e+00 0.45047898    1e-06       
    #> 19       y6↔y6      S    y6    y6  4.680287e+00 0.88270504    1e-06       
    #> 20       y7↔y7      S    y7    y7  3.468584e+00 0.67373666    1e-06       
    #> 21       y8↔y8      S    y8    y8  2.991984e+00 0.64561178    1e-06       
    #> 22 ind60↔dem60      S ind60 dem60 -4.570298e-01 0.10092255                
    #> 23 ind60↔dem65      S ind60 dem65 -5.536462e-01 0.08755584                
    #> 24 dem60↔dem65      S dem60 dem65  9.748617e-01 0.03020558                
    #> 25      one→x1      M     1    x1  5.054384e+00 0.08376380                
    #> 26      one→x2      M     1    x2  4.792195e+00 0.17258036                
    #> 27      one→x3      M     1    x3  3.557690e+00 0.16071784                
    #> 28      one→y1      M     1    y1  5.464667e+00 0.30133181                
    #> 29      one→y2      M     1    y2  4.256443e+00 0.45271573                
    #> 30      one→y3      M     1    y3  6.563110e+00 0.39202687                
    #> 31      one→y4      M     1    y4  4.452533e+00 0.38480706                
    #> 32      one→y5      M     1    y5  5.136252e+00 0.29925911                
    #> 33      one→y6      M     1    y6  2.978074e+00 0.38638865                
    #> 34      one→y7      M     1    y7  6.196264e+00 0.36548573                
    #> 35      one→y8      M     1    y8  4.043390e+00 0.37172278                
    #> 
    #> Model Statistics: 
    #>                |  Parameters  |  Degrees of Freedom  |  Fit (-2lnL units)
    #>        Model:             35                    790              3187.076
    #>    Saturated:             77                    748                    NA
    #> Independence:             22                    803                    NA
    #> Number of observations/statistics: 75/825
    #> 
    #> Information Criteria: 
    #>       |  df Penalty  |  Parameters Penalty  |  Sample-Size Adjusted
    #> AIC:      1607.0759               3257.076                 3321.691
    #> BIC:      -223.7397               3338.188                 3227.877
    #> To get additional fit indices, see help(mxRefModels)
    #> timestamp: 2023-07-29 21:24:58 
    #> Wall clock time: 0.107224 secs 
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
    #> timestamp: 2023-07-29 21:25:00 
    #> Wall clock time: 0.3505919 secs 
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
    #> 1    xi→x2              A  x2  xi  0.79157858 0.026246184                
    #> 2    xi→x3              A  x3  xi  0.89166108 0.027991673                
    #> 3   eta→y2              A  y2 eta  0.81610411 0.028977474                
    #> 4   eta→y3              A  y3 eta  0.90741889 0.027924346                
    #> 5    x1↔x1              S  x1  x1  0.04060244 0.011022344 !     0!       
    #> 6    x2↔x2              S  x2  x2  0.04519865 0.008621643 !     0!       
    #> 7    x3↔x3              S  x3  x3  0.04647166 0.010143724       0!       
    #> 8    y1↔y1              S  y1  y1  0.03388962 0.008495346 !     0!       
    #> 9    y2↔y2              S  y2  y2  0.04210945 0.007766691 !     0!       
    #> 10   y3↔y3              S  y3  y3  0.03107010 0.007268278       0!       
    #> 11   xi↔xi              S  xi  xi  1.07304552 0.157796861    1e-06       
    #> 12 eta↔eta              S eta eta  0.26127631 0.041232786    1e-06       
    #> 13  one→x1              M   1  x1 -0.14881030 0.105057193                
    #> 14  one→x2              M   1  x2 -0.10969677 0.084338898                
    #> 15  one→x3              M   1  x3 -0.15448454 0.094426293                
    #> 16  one→y1              M   1  y1 -0.05304659 0.089761149                
    #> 17  one→y2              M   1  y2 -0.13040871 0.074578868                
    #> 18  one→y3              M   1  y3 -0.05666275 0.081647174                
    #> 19      a0 new_parameters   1   1  0.78168092 0.069381896                
    #> 20      a1 new_parameters   1   2 -0.19334145 0.107742907                
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
    #> timestamp: 2023-07-29 21:25:00 
    #> Wall clock time: 0.05535007 secs 
    #> optimizer:  SLSQP 
    #> OpenMx version number: 2.21.8 
    #> Need help?  See help(mxSummary)

</details>

Alternatively, the transformations can be defined implicitly by placing
the algebra in curly braces and directly inserting it in the syntax in
place of the parameter label:

``` r
model <- "
  # loadings
     xi =~ x1 + x2 + x3
     eta =~ y1 + y2 + y3
  # regression
     eta ~ {a0 + a1*data.k} * xi
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

    #> Summary of untitled48 
    #>  
    #> free parameters:
    #>       name         matrix row col    Estimate   Std.Error A lbound ubound
    #> 1    xi→x2              A  x2  xi  0.79157858 0.026246184                
    #> 2    xi→x3              A  x3  xi  0.89166108 0.027991673                
    #> 3   eta→y2              A  y2 eta  0.81610411 0.028977474                
    #> 4   eta→y3              A  y3 eta  0.90741889 0.027924346                
    #> 5    x1↔x1              S  x1  x1  0.04060244 0.011022344 !     0!       
    #> 6    x2↔x2              S  x2  x2  0.04519865 0.008621643 !     0!       
    #> 7    x3↔x3              S  x3  x3  0.04647166 0.010143724       0!       
    #> 8    y1↔y1              S  y1  y1  0.03388962 0.008495346 !     0!       
    #> 9    y2↔y2              S  y2  y2  0.04210945 0.007766691 !     0!       
    #> 10   y3↔y3              S  y3  y3  0.03107010 0.007268278       0!       
    #> 11   xi↔xi              S  xi  xi  1.07304552 0.157796861    1e-06       
    #> 12 eta↔eta              S eta eta  0.26127631 0.041232786    1e-06       
    #> 13  one→x1              M   1  x1 -0.14881030 0.105057193                
    #> 14  one→x2              M   1  x2 -0.10969677 0.084338898                
    #> 15  one→x3              M   1  x3 -0.15448454 0.094426293                
    #> 16  one→y1              M   1  y1 -0.05304659 0.089761149                
    #> 17  one→y2              M   1  y2 -0.13040871 0.074578868                
    #> 18  one→y3              M   1  y3 -0.05666275 0.081647174                
    #> 19      a0 new_parameters   1   1  0.78168092 0.069381896                
    #> 20      a1 new_parameters   1   2 -0.19334145 0.107742907                
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
    #> timestamp: 2023-07-29 21:25:01 
    #> Wall clock time: 0.0524981 secs 
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
