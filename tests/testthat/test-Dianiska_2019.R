test_that("path analysis works", {

  # lavaan model by Rachel E. Dianiska
  # at https://osf.io/6yxde

  library(lavaan)
  library(mxsem)

  set.seed(123)

  model <- '
Disclosure ~ Cooperation + PosRapport + SelfDiscloseDis + SelfDiscloseSim + Verification
Cooperation ~ PosRapport + SelfDiscloseDis + SelfDiscloseSim + Verification
PosRapport ~ SelfDiscloseDis + SelfDiscloseSim + Verification
'

  suppressWarnings(data <- lavaan::simulateData(model))

  fit_lavaan <- cfa(model,
                    data = data,
                    missing = "ml",
                    fixed.x = FALSE)

  fit_mx  <- mxsem(model = model,
                   data = data) |>
    mxTryHard()

  testthat::expect_true(length(coef(fit_lavaan)) == length(omxGetParameters(fit_mx)))

  testthat::expect_true(abs(-2*logLik(fit_lavaan) -
                              fit_mx$fitfunction$result[[1]]) < 1e-4)
})
