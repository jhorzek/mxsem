#' @useDynLib mxsem, .registration = TRUE
#' @importFrom Rcpp sourceCpp
NULL

#' mxsem
#'
#' create an extended SEM with OpenMx using a lavaan like syntax.
#'
#' @param model model syntax similar to lavaan's syntax
#' @param data raw data used to fit the model
#' @param scale_loadings should the first loading of each latent variable be used for scaling?
#' @param scale_latent_variances should the latent variances be used for scaling
#' @param add_intercepts should intercepts for manifest variables be added automatically?
#' @param add_variances should variances for manifest and latent variables be added automatically?
#' @param lbound_variances should the lower bound for variances be set to 0.000001?
#' @return mxModel object that can be fitted with mxRun or mxTryHard
#' @export
#' @import OpenMx
#' @examples
#' # THE FOLLOWING EXAMPLE IS ADAPTED FROM LAVAAN
#' model <- '
#'   # latent variable definitions
#'      ind60 =~ x1 + x2 + x3
#'      dem60 =~ y1 + a1*y2 + b*y3 + c1*y4
#'      dem65 =~ y5 + a2*y6 + b*y7 + c2*y8
#'
#'   # regressions
#'     dem60 ~ ind60
#'     dem65 ~ ind60 + dem60
#'
#'   # residual correlations
#'     y1 ~~ y5
#'     y2 ~~ y4 + y6
#'     y3 ~~ y7
#'     y4 ~~ y8
#'     y6 ~~ y8
#' '
#'
#' fit <- mxsem(model = model,
#'             data  = OpenMx::Bollen) |>
#'   mxTryHard()
#' omxGetParameters(fit)
#'
#'
#' model_transformations <- '
#'   # latent variable definitions
#'      ind60 =~ x1 + x2 + x3
#'      dem60 =~ y1 + a1*y2 + b1*y3 + c1*y4
#'      dem65 =~ y5 + a2*y6 + b2*y7 + c2*y8
#'
#'   # regressions
#'     dem60 ~ ind60
#'     dem65 ~ ind60 + dem60
#'
#'   # residual correlations
#'     y1 ~~ y5
#'     y2 ~~ y4 + y6
#'     y3 ~~ y7
#'     y4 ~~ y8
#'     y6 ~~ y8
#'
#' # create new parameters:
#' +delta_a
#' +delta_b
#'
#' # use the model parameters and the new parameters for transformations:
#' a2 := a1 + delta_a
#' # let us also add an overly complicated equality constraint...
#' delta_b := 0
#' b2 := b1 + delta_b
#' '
#'
#' fit <- mxsem(model = model_transformations,
#'             data  = OpenMx::Bollen) |>
#'   mxTryHard()
#' omxGetParameters(fit)
mxsem <- function(model,
                 data,
                 scale_loadings = TRUE,
                 scale_latent_variances = FALSE,
                 add_intercepts = TRUE,
                 add_variances = TRUE,
                 lbound_variances = TRUE){

  parameter_table <- parameter_table_rcpp(syntax = model,
                                          add_intercept = add_intercepts,
                                          add_variance = add_variances,
                                          scale_latent_variance = scale_latent_variances,
                                          scale_loading = scale_loadings)

  mxMod <- OpenMx::mxModel(type = "RAM",
                           manifestVars = parameter_table$variables$manifests,
                           latentVars = parameter_table$variables$latents,
                           OpenMx::mxData(data, type = "raw"))

  mxMod <- add_path(mxMod,
                    parameter_table,
                    lbound_variances)
  mxMod <- add_algebra(mxMod,
                       parameter_table = parameter_table,
                       parameter_table$algebras,
                       parameter_table$new_parameters,
                       parameter_table$new_parameters_free)

  return(mxMod)

}

add_path <- function(mxMod,
                     parameter_table,
                     lbound_variances){
  pt <- parameter_table$parameter_table
  for(i in 1:nrow(pt)){

    if(pt$op[i] %in% c("=~", "~~", "~")){
      # directed effect
      if(pt$op[i]  == "~"){
        from <- pt$rhs[i]
        to <- pt$lhs[i]

        if(from == "1"){
          from <- "one"
        }

      }else{
        from <- pt$lhs[i]
        to <- pt$rhs[i]
      }

      if(pt$op[i] == "~~"){
        arrows <- 2
      }else{
        arrows <- 1
      }

      parameter_setting <- parse_modifier(pt$modifier[i],
                                          pt$free[i])
      free <- parameter_setting$free
      value <- parameter_setting$value
      label <- parameter_setting$label
      lbound <- parse_bounds(pt$lbound[i])
      ubound <- parse_bounds(pt$ubound[i])

      if((from == to) &&
         (arrows == 2) &&
         free){
        # is variance
        # starting value for variances
        if(is.na(value))
          value <- .1

        if(lbound_variances && is.na(lbound))
          lbound <- 0.000001
      }

      if(is.na(label)){
        if(arrows == 1){
          label <- paste0(from, "_to_", to)
        }else{
          label <- paste0(from, "_with_", to)
        }
      }

      mxMod <- OpenMx::mxModel(mxMod,
                               OpenMx::mxPath(from = from,
                                              to = to,
                                              arrows = arrows,
                                              free = free,
                                              values = value,
                                              labels = label,
                                              lbound = lbound,
                                              ubound = ubound
                               ))
    }

  }
  return(mxMod)
}

parse_modifier <- function(modifier, free){

  parameter_setting <- data.frame(label = NA,
                                  value = NA,
                                  free  = NA)
  if(free == "FALSE"){
    parameter_setting$free <- FALSE
  }else{
    parameter_setting$free <- TRUE
  }

  if(modifier == ""){
    return(parameter_setting)
  }
  if(grepl(pattern = "^[0-9\\.-]+$", x = modifier)){
    # the modifier is a parameter value
    parameter_setting$value <- as.numeric(modifier)
    parameter_setting$free  <- FALSE
    return(parameter_setting)
  }

  if(grepl(pattern = "^data\\.+[a-zA-Z0-9\\.-_]+$", x = modifier)){
    # the modifier is a definition variable
    parameter_setting$label <- modifier
    parameter_setting$free  <- FALSE
    return(parameter_setting)
  }

  if(grepl(pattern = "^[a-zA-Z]+[0-9\\.-_]*$", x = modifier)){
    # the modifier is a label
    parameter_setting$label <- modifier
    return(parameter_setting)
  }

  stop("The following modifier is not allowed:", modifier)
}

parse_bounds <- function(bound){
  if(bound == "")
    return(NA)

  if(grepl(pattern = "^[0-9\\.-]+$", x = bound)){
    # the modifier is a parameter value
    return(as.numeric(bound))
  }

  stop("Invalid bound", bound)
}


add_algebra <- function(mxMod,
                        parameter_table,
                        algebras,
                        new_parameters,
                        new_parameters_free){

  if(nrow(algebras) == 0)
    return(mxMod)

  if(length(new_parameters) > 0){
    # add the new parameters:
    labels <- new_parameters
    labels[new_parameters_free != "TRUE"] <- paste0(labels[new_parameters_free != "TRUE"], "[1,1]")
    mxMod <- OpenMx::mxModel(mxMod,
                    mxMatrix(type = "Full",
                             values = rep(.01, length(new_parameters)),
                             nrow = 1,
                             ncol = length(new_parameters),
                             free = new_parameters_free == "TRUE",
                             labels = labels,
                             name = "new_parameters"))

  }

  for(i in 1:nrow(algebras)){
    mxMod$A$labels[mxMod$A$labels == algebras$lhs[i]] <- paste0(algebras$lhs[i], "[1,1]")
    mxMod$S$labels[mxMod$S$labels == algebras$lhs[i]] <- paste0(algebras$lhs[i], "[1,1]")
    mxMod$M$labels[mxMod$M$labels == algebras$lhs[i]] <- paste0(algebras$lhs[i], "[1,1]")
    mxMod <- OpenMx::mxModel(mxMod,
                             OpenMx::mxAlgebraFromString(algString = algebras$rhs[i],
                                                         name = algebras$lhs[i]))
  }

  return(mxMod)
}
