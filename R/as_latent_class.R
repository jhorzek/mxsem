#' as_latent_class
#'
#' creates a latent class model from an OpenMx model. The OpenMx model
#' can be created with mxsem
#' @param mxModel mxModel
#' @param n_classes number of latent classes
#' @param parameters the parameters that should be class specific. By default
#' all parameters are class specific.
#' @param use_grepl if set to TRUE, grepl is used to check which parameters are
#' class specific. For instance, if parameters = "a" and use_grepl = TRUE, all parameters
#' whose label contains the letter "a" will be class specific. If use_grep = FALSE
#' only the parameter that has the label "a" is class specific.
#' @param scale which scale should be used to make sure that the sum of class probabilities
#' do not exceed 1? Available are "sum" and "softmax". See ?OpenMx::mxExpectationMixture
#' for more details.
#' @return mxModel with multiple classes.
#' @export
#' @examples
#' # The following example is adapted from the script provided by Joshua Pritikin at
#' # https://github.com/OpenMx/OpenMx/blob/master/demo/GrowthMixtureModel_PathRaw.R
#'
#' # Step 1: Define a single group model:
#' model <- "
#' Intercept =~ 1*x1 + 1*x2 + 1*x3 + 1*x4 + 1*x5
#' Slope     =~ 0*x1 + 1*x2 + 2*x3 + 3*x4 + 4*x5
#' x1 ~ 0*1; x2 ~ 0*1; x3 ~ 0*1; x4 ~ 0*1; x5 ~ 0*1
#' x1 ~~ r*x1; x2 ~~ r*x2; x3 ~~ r*x3; x4 ~~ r*x4;x5 ~~ r*x5
#'
#' Intercept ~  int*1
#' Slope     ~  slp*1
#' Intercept ~~ v_int*Intercept + cov*Slope
#' Slope     ~~ v_slp*Slope
#' "
#'
#'
#' mixture_model <- mxsem(model = model,
#'                        data = OpenMx::myGrowthMixtureData,
#'                        scale_loadings = FALSE) |>
#'   as_latent_class(n_classes = 2,
#'                   # we want the int, slp, v_int, cov, and v_slp parameters
#'                   # to be class-specific
#'                   parameters = c("int", "slp", "v_int", "cov", "v_slp"),
#'                   use_grepl = FALSE) |>
#'   mxRun()
#'
#' summary(mixture_model)
#'
#' # Mixture proportions:
#' mod$expectation$output$weights
as_latent_class <- function(mxModel,
                            n_classes,
                            parameters = c(".*"),
                            use_grepl = TRUE,
                            scale = "sum"){

  warning("This function is very experimental and may not yet work properly. Use with caution.")

  if(!is(mxModel, "MxRAMModel"))
    stop("mxModel must be of class MxRAMModel.")
  if(mxModel$data$type != "raw")
    stop("The data of mxModel must be of type 'raw'")
  if(!scale %in% c("sum", "softmax"))
    stop("scale must be either 'sum' or 'softmax'")

  class_specific_parameters <- c()
  parameter_labels <- names(OpenMx::omxGetParameters(mxModel))
  for(p in parameters){
    if(use_grepl){
      class_specific_parameters <- c(class_specific_parameters,
                                     parameter_labels[grepl(p, parameter_labels)])
    }else{
      class_specific_parameters <- c(class_specific_parameters,
                                     parameter_labels[parameter_labels == p]
      )
    }
  }
  common_parameters <- parameter_labels[!parameter_labels %in% class_specific_parameters]

  message(paste0("The following parameters will be the same across classes: ",
                 paste0(common_parameters, collapse = ", ")))
  message(paste0("The following parameters will be class specific: ",
                 paste0(class_specific_parameters, collapse = ", ")))

  mc_models <- list()
  for(cl in seq_len(n_classes)){

    current_model <- OpenMx::mxModel(
      name = paste0(mxModel$name, "_cl_", cl),
      mxModel,
      OpenMx::mxFitFunctionML(vector = TRUE)
    )
    current_model$data <- NULL

    current_parameter_labels <- names(OpenMx::omxGetParameters(mxModel))

    for(p in parameters){
      if(use_grepl){
        current_parameter_labels[grepl(p, current_parameter_labels)] <- paste0(
          current_parameter_labels[grepl(p, current_parameter_labels)],
          "_class_", cl
        )
      }else{
        current_parameter_labels[current_parameter_labels == p] <- paste0(
          current_parameter_labels[current_parameter_labels == p],
          "_class_", cl
        )
      }
    }

    current_model <- OpenMx::omxSetParameters(model = current_model,
                                              labels = names(OpenMx::omxGetParameters(mxModel)),
                                              values = OpenMx::omxGetParameters(mxModel),
                                              newlabels = current_parameter_labels)
    mc_models[[cl]] <- current_model
  }

  # adapted from https://github.com/OpenMx/OpenMx/blob/master/demo/GrowthMixtureModel_PathRaw.R
  # define class probabilities
  mc_model <- OpenMx::mxModel(
    name = mxModel$name,
    mc_models,
    mxMatrix(type = "Full",
             nrow = n_classes,
             ncol = 1,
             # first class is reference class
             free = c(FALSE,
                      rep(TRUE, n_classes-1)),
             values = c(ifelse(scale == "sum", 1, 0), rep(1, n_classes-1)),
             lbound = 0.001,
             labels = paste0("weight", 1:n_classes),
             name   = "raw_weights"),
    OpenMx::mxFitFunctionML(),
    OpenMx::mxExpectationMixture(components = paste0(mxModel$name, "_cl_", 1:n_classes),
                                 weights    = "raw_weights",
                                 scale      = scale),
    mxModel$data
  )


  attr(mc_model, which = "common_parameters") <- common_parameters
  attr(mc_model, which = "class_specific_parameters") <- class_specific_parameters

  return(mc_model)
}
