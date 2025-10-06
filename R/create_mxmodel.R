#' create_mxmodel_from_parameter_table
#'
#' Uses the parameter table to set up the OpenMx model.
#'
#' @param parameter_table parameter table object
#' @param mx_data data set
#' @param directed symbol used for directed effects
#' @param undirected symbol used for undirected effects
#' @param fitfunction fitfunction usd in the model. When set to "auto" and ordered items are included,
#' mxsem will switch to DWLS
#' @returns the OpenMx model
#' @noRd
create_mxmodel_from_parameter_table <- function(
  parameter_table,
  mx_data,
  directed,
  undirected,
  fitfunction
) {
  mxMod <- initialize_mx_model(
    model_name = parameter_table$model_name,
    parameter_table = parameter_table,
    mx_data = mx_data
  ) |>
    add_path(
      mxMod = _,
      parameter_table = parameter_table,
      directed = directed,
      undirected = undirected
    ) |>
    add_threshold(
      mxMod = _,
      parameter_table = parameter_table
    ) |>
    add_algebra(
      mxMod = _,
      parameter_table = parameter_table
    ) |>
    add_user_defined(mxMod = _, parameter_table = parameter_table) |>
    add_fitfunction(
      mxMod = _,
      fitfunction = fitfunction,
      ordered = parameter_table$ordered
    ) |>
    set_ordered_delta_constraints(mxMod = _, parameter_table = parameter_table)

  return(mxMod)
}

#' initialize_mx_model
#'
#' Sets up the basic model without any effects
#'
#' @param model_name (string) name of the model
#' @param parameter_table parameter table object
#' @param mx_data data set
#' @returns the OpenMx model
#' @noRd
initialize_mx_model <- function(
  model_name,
  parameter_table,
  mx_data
) {
  mxMod <- OpenMx::mxModel(
    model = ifelse(
      test = model_name == "",
      NA,
      model_name
    ),
    type = "RAM",
    manifestVars = parameter_table$variables$manifests,
    latentVars = parameter_table$variables$latents,
    mx_data
  )

  return(mxMod)
}

#' add_path
#'
#' Adds directed and undirected effects to the model.
#'
#' @param mxMod mxModel object
#' @param parameter_table parameter table object
#' @param directed symbol used for directed effects
#' @param undirected symbol used for undirected effects
#' @returns the OpenMx model
#' @noRd
add_path <- function(
  mxMod,
  parameter_table,
  directed,
  undirected
) {
  pt <- parameter_table$parameters

  is_directed_effect <- function(pt, i) {
    return(pt$op[i] == "~")
  }
  is_undirected_effect <- function(pt, i) {
    return(pt$op[i] == "~~")
  }
  is_intercept <- function(pt, i) {
    return(pt$rhs[i] == "1")
  }

  is_free_variance <- function(from, to, arrows, free) {
    return(
      (from == to) &&
        (arrows == 2) &&
        free
    )
  }

  for (i in 1:nrow(pt)) {
    if (pt$op[i] %in% c("=~", "~~", "~")) {
      parameter_setting <- parse_modifier(pt$modifier[i], pt$free[i])
      free <- parameter_setting$free
      value <- parameter_setting$value
      label <- parameter_setting$label
      lbound <- parse_bounds(pt$lbound[i])
      ubound <- parse_bounds(pt$ubound[i])

      if (is_directed_effect(pt = pt, i = i)) {
        if (is_intercept(pt = pt, i = i)) {
          from <- "one"
        } else {
          from <- pt$rhs[i]
        }

        to <- pt$lhs[i]
      } else {
        from <- pt$lhs[i]
        to <- pt$rhs[i]
      }

      if (is_undirected_effect(pt = pt, i = i)) {
        arrows <- 2
      } else {
        arrows <- 1
      }

      if (
        is_free_variance(from = from, to = to, arrows = arrows, free = free) &
          is.na(value)
      ) {
        # starting value for variances
        value <- .1
      }

      if (is.na(label)) {
        if (arrows == 1) {
          label <- paste0(from, directed, to)
        } else {
          label <- paste0(from, undirected, to)
        }
      }

      mxMod <- OpenMx::mxModel(
        mxMod,
        OpenMx::mxPath(
          from = from,
          to = to,
          arrows = arrows,
          free = free,
          values = value,
          labels = label,
          lbound = lbound,
          ubound = ubound
        )
      )
    }
  }
  return(mxMod)
}

#' parse_modifier
#'
#' Parses the modifier to identify if it is a parameter label, a value, and if it is
#' freely estimated.
#'
#' @param modifier modifier string
#' @param free logical: is it freely estimated
#' @returns data.frame with label, value, and free fields.
#' @noRd
parse_modifier <- function(modifier, free) {
  parameter_setting <- data.frame(label = NA, value = NA, free = free)

  if (modifier == "") {
    return(parameter_setting)
  }
  if (suppressWarnings(!is.na(as.numeric(modifier)))) {
    # the modifier is a parameter value
    parameter_setting$value <- as.numeric(modifier)
    parameter_setting$free <- FALSE
    return(parameter_setting)
  }

  if (grepl(pattern = "^data\\.+[a-zA-Z0-9\\.-_]+$", x = modifier)) {
    # the modifier is a definition variable
    parameter_setting$label <- modifier
    parameter_setting$free <- FALSE
    return(parameter_setting)
  }

  if (
    grepl(
      pattern = paste0(
        "^[a-zA-Z]+[a-zA-Z0-9\\.-_",
        unicode_directed(),
        unicode_undirected(),
        "]*$"
      ),
      x = modifier,
      perl = TRUE
    )
  ) {
    # the modifier is a label
    parameter_setting$label <- modifier
    return(parameter_setting)
  }

  stop("The following modifier is not allowed: ", modifier)
}

#' parse_bounds
#'
#' Parses the boundaries set on parameters.
#'
#' @param bound bound string
#' @returns either NA (if no bound is set) or the numeric value of the bound
#' @noRd
parse_bounds <- function(bound) {
  if (bound == "") {
    return(NA)
  }
  if (is.numeric(bound)) {
    return(bound)
  }

  if (suppressWarnings(!is.na(as.numeric(bound)))) {
    # the modifier is a parameter value
    return(as.numeric(bound))
  }

  stop("Invalid bound", bound)
}

#' add_algebra
#'
#' Adds user defined algebras to the model.
#'
#' @param mxMod mxModel object
#' @param parameter_table parameter table object
#' @returns the mxModel object
#' @noRd
add_algebra <- function(
  mxMod,
  parameter_table
) {
  algebras <- parameter_table$algebras
  new_parameters <- parameter_table$new_parameters
  new_parameters_free <- parameter_table$new_parameters_free

  if (nrow(algebras) == 0) {
    return(mxMod)
  }

  if (length(new_parameters) > 0) {
    # add the new parameters:
    labels <- new_parameters
    labels[!new_parameters_free] <- paste0(
      labels[!new_parameters_free],
      "[1,1]"
    )
    mxMod <- OpenMx::mxModel(
      mxMod,
      mxMatrix(
        type = "Full",
        values = rep(.01, length(new_parameters)),
        nrow = 1,
        ncol = length(new_parameters),
        free = new_parameters_free,
        labels = labels,
        name = "new_parameters"
      )
    )
  }

  for (i in 1:nrow(algebras)) {
    if (!is.null(mxMod$A)) {
      mxMod$A$labels[mxMod$A$labels == algebras$lhs[i]] <- paste0(
        algebras$lhs[i],
        "[1,1]"
      )
    }
    if (!is.null(mxMod$S)) {
      mxMod$S$labels[mxMod$S$labels == algebras$lhs[i]] <- paste0(
        algebras$lhs[i],
        "[1,1]"
      )
    }
    if (!is.null(mxMod$M)) {
      mxMod$M$labels[mxMod$M$labels == algebras$lhs[i]] <- paste0(
        algebras$lhs[i],
        "[1,1]"
      )
    }
    if (!is.null(mxMod$Thresholds)) {
      mxMod$Thresholds$labels[
        mxMod$Thresholds$labels == algebras$lhs[i]
      ] <- paste0(
        algebras$lhs[i],
        "[1,1]"
      )
    }

    if (!is.null(mxMod$new_parameters)) {
      mxMod$new_parameters$free[
        mxMod$new_parameters$labels == algebras$lhs[i]
      ] <- FALSE
      mxMod$new_parameters$labels[
        mxMod$new_parameters$labels == algebras$lhs[i]
      ] <- paste0(algebras$lhs[i], "[1,1]")
    }
    mxMod <- OpenMx::mxModel(
      mxMod,
      OpenMx::mxAlgebraFromString(
        algString = algebras$rhs[i],
        name = algebras$lhs[i]
      )
    )
  }

  return(mxMod)
}

#' add_user_defined
#'
#' Adds user defined elements to the model.
#'
#' @param mxMod mxModel object
#' @param parameter_table parameter table object
#' @returns the mxModel object
#' @noRd
add_user_defined <- function(mxMod, parameter_table) {
  if (length(parameter_table$user_defined) != 0) {
    warning(
      "User defined elements using curly braces can be problematic. Make sure to check the model thoroughly"
    )
  }
  for (user_def in parameter_table$user_defined) {
    mxMod <- OpenMx::mxModel(
      mxMod,
      eval(parse(text = user_def))
    )
  }
  return(mxMod)
}

#' add_fitfunction
#'
#' Adds user defined elements to the model.
#'
#' @param mxMod mxModel object
#' @param fitfunction fitfunction usd in the model. When set to "auto" and ordered items are included,
#' mxsem will switch to DWLS
#' @param ordered vector with the names of the ordered items
#' @returns the mxModel object
#' @noRd
add_fitfunction <- function(mxMod, fitfunction, ordered) {
  if (is.character(fitfunction) && fitfunction == "auto") {
    if (!is.null(ordered)) {
      if ((!imxHasDefinitionVariable(mxMod))) {
        message(
          "Model will be estimated with DWLS. It is recommended to use OpenMx::mxTryHardOrdinal(model) to estimate the model."
        )
        return(OpenMx::mxModel(mxMod, OpenMx::mxFitFunctionWLS(type = "DWLS")))
      } else {
        message(
          "Model will be estimated with ML because it has definition variables. It is recommended to use OpenMx::mxTryHardOrdinal(model) to estimate the model."
        )
      }
    }
    # keep default otherwise
    return(mxMod)
  }
  OpenMx::mxModel(mxMod, fitfunction)
}
