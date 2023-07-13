test_that("parameter_table_to_Rcpp works", {
  library(xsem)

  model <- '
  # latent variable definitions
     ind60 =~ x1 + x2 +
     x3
     dem60 =~
     y1 + a*y2 +
  b*y3 + c*y4
     dem65 =~     -.01*y5 + a*y6 + b*y7 + c*y8

  # regressions
      dem60 ~ data.y*ind60
    dem65 ~ ind60 + dem60

    dem60 ~~ .5*dem60

  # residual correlations
    y1 ~~ y5
    y2 ~~ y4 + y6;  y3 ~
    ~ y7
    y4 ~~ y8
    y6 ~~ y8

    + d; + e; +f
    b := exp(d)
    c := a*b-d+e
a >-2
a <  1

x1 ~ .5*1
'

  parameter_table <- xsem:::parameter_table_rcpp(model,
                                                 add_intercept = TRUE,
                                                 add_variance = TRUE,
                                                 scale_latent_variance = TRUE,
                                                 scale_loading = TRUE)
  parameter_table

})