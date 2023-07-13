test_that("definition variable works", {
  set.seed(1234)
  dataset <- simulate_latent_growth_curve(N = 100)
  model <- "
  I =~ 1*y1 + 1*y2 + 1*y3 + 1*y4 + 1*y5
  S =~ data.t_1 * y1 + data.t_2 * y2 + data.t_3 * y3 + data.t_4 * y4 + data.t_5 * y5

  I ~ int*1
  S ~ slp*1
  "

  mod <- mxsem(model = model,
               data = dataset,
               add_intercepts = FALSE) |>
    mxTryHard()

  testthat::expect_true(abs(omxGetParameters(mod)["int"] - 1) < .2)
  testthat::expect_true(abs(omxGetParameters(mod)["slp"] - .4) < .1)
  testthat::expect_true(abs(omxGetParameters(mod)["I_with_I"] - 1) < .2)
  testthat::expect_true(abs(omxGetParameters(mod)["S_with_S"] - 1) < .2)

})
