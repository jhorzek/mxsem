test_that("testing latent class model", {

  #' # The following example is adapted from the script provided by Joshua Pritikin at
  #' # https://github.com/OpenMx/OpenMx/blob/master/demo/GrowthMixtureModel_PathRaw.R
  library(mxsem)
  set.seed(1342)
  data(myGrowthMixtureData)
  # residual variances
  resVars      <- mxPath( from=c("x1","x2","x3","x4","x5"), arrows=2,
                          free=TRUE, values = c(1,1,1,1,1),
                          labels=c("residual","residual","residual","residual","residual") )
  # latent variances and covariance
  latVars      <- mxPath( from=c("intercept","slope"), arrows=2, connect="unique.pairs",
                          free=TRUE, values=c(1,.4,1), labels=c("vari1","cov1","vars1") )
  # intercept loadings
  intLoads     <- mxPath( from="intercept", to=c("x1","x2","x3","x4","x5"), arrows=1,
                          free=FALSE, values=c(1,1,1,1,1) )
  # slope loadings
  sloLoads     <- mxPath( from="slope", to=c("x1","x2","x3","x4","x5"), arrows=1,
                          free=FALSE, values=c(0,1,2,3,4) )
  # manifest means
  manMeans     <- mxPath( from="one", to=c("x1","x2", "x3", "x4","x5"), arrows=1,
                          free=FALSE, values=c(0,0,0,0,0) )
  # latent means
  latMeans     <- mxPath( from="one", to=c("intercept","slope"), arrows=1,
                          free=TRUE,  values=c(0,-1), labels=c("meani1","means1") )
  # enable the likelihood vector
  funML        <- mxFitFunctionML(vector=TRUE)
  class1       <- mxModel("Class1", type="RAM",
                          manifestVars=c("x1","x2","x3","x4","x5"),
                          latentVars=c("intercept","slope"),
                          resVars, latVars, intLoads, sloLoads, manMeans, latMeans,
                          funML)


  # latent variances and covariance
  latVars2     <- mxPath( from=c("intercept","slope"), arrows=2, connect="unique.pairs",
                          free=TRUE, values=c(1,.5,1), labels=c("vari2","cov2","vars2") )
  # latent means
  latMeans2    <- mxPath( from="one", to=c("intercept", "slope"), arrows=1,
                          free=TRUE, values=c(5,1), labels=c("meani2","means2") )
  class2       <- mxModel(class1, name="Class2", latVars2, latMeans2)

  classP       <- mxMatrix( type="Full", nrow=2, ncol=1,
                            free=c(FALSE, TRUE), values=1, lbound=0.001,
                            labels = c("p1","p2"), name="Props" )
  mixExp       <- mxExpectationMixture(components=c('Class1', 'Class2'), weights='Props', scale='sum')
  fit          <- mxFitFunctionML()
  dataRaw      <- mxData( observed=myGrowthMixtureData, type="raw" )

  gmm          <- mxModel("Growth Mixture Model",
                          dataRaw, class1, class2, classP, mixExp, fit)

  gmmFit       <- mxTryHard(gmm)

  # same model with mxsem
  model <- "
Intercept =~ 1*x1 + 1*x2 + 1*x3 + 1*x4 + 1*x5
Slope     =~ 0*x1 + 1*x2 + 2*x3 + 3*x4 + 4*x5
x1 ~ 0*1; x2 ~ 0*1; x3 ~ 0*1; x4 ~ 0*1; x5 ~ 0*1
x1 ~~ resid*x1
x2 ~~ resid*x2
x3 ~~ resid*x3
x4 ~~ resid*x4
x5 ~~ resid*x5
Intercept ~ int*1
Slope     ~ slp*1
Intercept ~~ v_int*Intercept + cov*Slope
Slope     ~~ v_slp*Slope
"

  mod <- mxsem(model = model,
               data = myGrowthMixtureData,
               scale_loadings = FALSE) |>
    as_latent_class(n_classes = 2,
                    parameters = c("int", "slp", "v_int", "cov", "v_slp"),
                    use_grepl = FALSE,
                    scale = "sum") |>
    mxTryHard()

  # check mixture proportions

  # Unscaled mixture proportions
  testthat::expect_true(all(abs(mxEval(Props, gmmFit) -
                                  mxEval(raw_weights, mod)) < 1e-2))


  # Scaled mixture proportions
  testthat::expect_true(all(abs(gmmFit$expectation$output$weights -
                                  mod$expectation$output$weights) < 1e-2))

  testthat::expect_true(abs(-2*logLik(gmmFit) - 8739.05) < .1)
  testthat::expect_true(abs(-2*logLik(mod) - 8739.05) < .1)

})
