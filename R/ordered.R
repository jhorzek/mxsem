#' Add thresholds to the model
#'
#' This function adds thresholds to the model based on the parameter table.
#'
#' @param mxMod The model to which thresholds will be added.
#' @param parameter_table A parameter tableme containing the parameters to be checked.
#' @returns The model with thresholds added.
#' @noRd
add_threshold <- function(
  mxMod,
  parameter_table
) {
  ordered <- parameter_table$ordered
  pt <- parameter_table$parameters
  pt <- pt[pt$op == "|", , drop = FALSE]
  if ((nrow(pt) == 0) && is.null(ordered)) {
    return(mxMod)
  }

  check_ordered_items(pt, ordered)

  for (ord in ordered) {
    n_expected_levels <- length(levels(mxMod$data$observed[[ord]])) - 1
    # Check if we have explicitly defined thresholds
    pt_ord <- pt[pt$lhs == ord, , drop = FALSE]
    threshold_free <- c()
    threshold_value <- c()
    threshold_label <- c()

    if (nrow(pt_ord) != 0) {
      check_thresholds(pt_ord, ord, n_expected_levels)

      for (i in 1:nrow(pt_ord)) {
        threshold_setting <- parse_modifier(pt_ord$modifier[i], pt_ord$free[i])
        threshold_free <- c(threshold_free, threshold_setting$free)
        threshold_value <- c(threshold_value, threshold_setting$value)
        threshold_label <- c(threshold_label, threshold_setting$label)
      }
      threshold_label[is.na(threshold_label)] <- paste0(
        ord,
        " I t",
        1:n_expected_levels
      )[is.na(threshold_label)]

      # Fill in potential NAs in the thresholds
      threshold_value <- create_thresholds(values = threshold_value)
    } else {
      threshold_free <- rep(TRUE, n_expected_levels)
      threshold_value <- OpenMx::mxNormalQuantiles(nBreaks = n_expected_levels)
      threshold_label <- paste0(ord, " I t", 1:n_expected_levels)
    }

    # Add the thresholds to the model
    mxMod <- add_thresholds_to_model(
      mxMod,
      ord,
      n_expected_levels,
      threshold_free,
      threshold_value,
      threshold_label
    )
  }

  return(mxMod)
}

#' Check ordered items
#'
#' Checks the ordered items in the parameter table.
#'
#' @param pt A data frame containing the parameters to be checked.
#' @param ordered A vector of ordered items.
#' @return nothing
#' @noRd
check_ordered_items <- function(pt, ordered) {
  if ((nrow(pt) != 0) && !any(pt$lhs %in% ordered)) {
    stop(
      "You specified thresholds for ",
      paste0(unique(pt$lhs), collapse = ", "),
      " but did not specify that this item is ordered. Please add the item name to ",
      "the 'ordered' vector or remove the threshold from the model syntax."
    )
  }
}

#' Check thresholds
#'
#' Checks the thresholds in the parameter table.
#'
#' @param pt_ord A data frame containing the thresholds to be checked.
#' @param ord The ordered item.
#' @param n_expected_levels The number of expected levels.
#' @returns nothing
#' @noRd
check_thresholds <- function(pt_ord, ord, n_expected_levels) {
  if (nrow(pt_ord) != n_expected_levels) {
    stop(
      "The item ",
      ord,
      " has ",
      n_expected_levels + 1,
      " levels. Expected ",
      n_expected_levels,
      " thresholds, but only ",
      nrow(pt_ord),
      " were defined."
    )
  }
  if (any(pt_ord$rhs != paste0("t", 1:n_expected_levels))) {
    stop(
      "Thresholds must be defined with ",
      paste0(paste0("t", 1:n_expected_levels), collapse = ", "),
      ". Found ",
      paste0(pt_ord$rhs, collapse = ", "),
      " instead."
    )
  }
}

#' add_thresholds_to_model
#'
#' Adds thresholds to a model.
#'
#' @param mxMod The model to which thresholds will be added
#' @param ord The ordered item
#' @param n_expected_levels The number of expected levels
#' @param threshold_free A vector indicating whether the thresholds are free
#' @param threshold_value A vector of threshold values
#' @param threshold_label A vector of threshold labels
#' @returns The model with thresholds added
#' @noRd
add_thresholds_to_model <- function(
  mxMod,
  ord,
  n_expected_levels,
  threshold_free,
  threshold_value,
  threshold_label
) {
  mxMod <- OpenMx::mxModel(
    mxMod,
    OpenMx::mxThreshold(
      vars = ord,
      nThresh = n_expected_levels,
      free = threshold_free,
      values = threshold_value,
      labels = threshold_label
    )
  )
  return(mxMod)
}

#' create_thresholds
#'
#' Creates the thresholds used for ordered items
#'
#' @param values user defined thresholds
#' @returns a vector with theshold values
#' @importFrom stats pnorm
#' @importFrom stats qnorm
#' @noRd
create_thresholds <- function(values) {
  if (all(is.na(values))) {
    return(OpenMx::mxNormalQuantiles(nBreaks = length(values)))
  }
  # we create the thresholds based on the standard normal distribution
  probs <- pnorm(q = values)
  if (is.na(probs[1])) {
    min_prob <- min(c(
      .9 / length(probs),
      .4 * min(probs, na.rm = TRUE)
    ))
  } else {
    min_prob <- probs[1]
  }
  if (is.na(probs[length(probs)])) {
    max_prob <- max(c(
      1 - 1 / length(probs),
      pnorm(q = 1.1 * qnorm(p = max(probs, na.rm = TRUE)))
    ))
  } else {
    max_prob <- probs[length(probs)]
  }

  probs[1] <- min_prob
  probs[length(probs)] <- max_prob

  # interpolate all values
  current_min <- NA
  current_max <- NA
  n_NA <- 0
  for (i in 1:length(probs)) {
    if (is.na(probs[i])) {
      n_NA <- n_NA + 1
    }
    if (!is.na(probs[i]) & is.na(current_min)) {
      current_min <- probs[i]
      next
    }
    if (!is.na(probs[i]) & is.na(current_max)) {
      current_max <- probs[i]
      # fill in the values
      probs[(i - (n_NA + 1)):i] <- seq(
        from = current_min,
        to = current_max,
        length.out = n_NA + 2
      )
      current_min <- current_max
      current_max <- NA
      n_NA <- 0
    }
  }
  # Retranslate the probabilities to values
  return(qnorm(p = probs))
}

#' parameterize_ordered
#'
#' Implements the parameterization of ordered items.
#'
#' @param parameter_table the parameter table object
#' @param ordered vector with the names of the ordered items
#' @param ordered_parameterization string specifying the parameterization used for ordered items
#' @returns updated parameter table
#' @noRd
parameterize_ordered <- function(
  parameter_table,
  ordered,
  ordered_parameterization
) {
  if (ordered_parameterization %in% c("none") | is.null(ordered)) {
    return(parameter_table)
  }
  if (ordered_parameterization == "delta") {
    return(parameterize_ordered_delta(
      parameter_table = parameter_table,
      ordered = ordered
    ))
  }
  if (ordered_parameterization == "theta") {
    return(parameterize_ordered_theta(
      parameter_table = parameter_table,
      ordered = ordered
    ))
  }
  stop(
    "Currenlty only ordered_parameterization = 'none', 'theta' or 'delta' are supported"
  )
}

#' parameterize_ordered_theta
#'
#' Implements the theta-parameterization for ordered items, where the residual
#' variances of the latent variables are set to 1 and the intercepts to 0.
#' @param parameter_table the parameter table object
#' @param ordered vector with the names of the ordered items
#' @returns updated parameter table
#' @noRd
parameterize_ordered_theta <- function(parameter_table, ordered) {
  # we have to constrain the *residual* variances to 1 and the means to 0
  # but we will skip items for which other settings have been defined
  pt <- parameter_table$parameters
  for (ord in ordered) {
    # skip requested delta scaling
    if (
      any(
        pt$lhs == ord &
          pt$op == "~*~" &
          pt$rhs == ord &
          pt$user
      )
    ) {
      warning(
        "Skipping theta parameterization for ",
        ord,
        ". Delta parameterization was requested (using the scaling notation ",
        ord,
        " ~*~ ",
        ord,
        ". Mixing theta and delta parameterization is NOT recommended."
      )
      next
    }

    # scale residual variances
    if (
      !any(
        pt$lhs == ord &
          pt$op == "~~" &
          pt$rhs == ord &
          pt$user
      )
    ) {
      pt <- rbind(
        pt,
        data.frame(
          lhs = ord,
          op = "~~",
          rhs = ord,
          modifier = "1",
          lbound = "",
          ubound = "",
          free = FALSE,
          user = FALSE
        )
      )
    }

    # Scale the means
    if (
      !any(
        pt$lhs == ord &
          pt$op == "~" &
          pt$rhs == "1" &
          pt$user
      )
    ) {
      pt <- rbind(
        pt,
        data.frame(
          lhs = ord,
          op = "~",
          rhs = "1",
          modifier = "0",
          lbound = "",
          ubound = "",
          free = FALSE,
          user = FALSE
        )
      )
    }
  }

  parameter_table$parameters <- pt
  return(parameter_table)
}

#' parameterize_ordered_delta
#'
#' Implements the delta-parameterization for ordered items, where the
#' variances of the latent variables are set to 1 and the intercepts to 0.
#' @param parameter_table the parameter table object
#' @param ordered vector with the names of the ordered items
#' @returns updated parameter table
#' @noRd
parameterize_ordered_delta <- function(parameter_table, ordered) {
  # we have to constrain the *variances* to 1 and the means to 0.
  # This is specified with the x ~*~ x notation.
  # but we will skip items for which other settings have been defined
  pt <- parameter_table$parameters
  for (ord in ordered) {
    # Skip scaling if manually specified variances or intercepts are found
    if (
      any(
        pt$lhs == ord &
          pt$op == "~~" &
          pt$rhs == ord &
          pt$user
      ) |
        any(
          pt$lhs == ord &
            pt$op == "~" &
            pt$rhs == "1" &
            pt$user
        )
    ) {
      warning(
        "Skipping delta parameterization for ",
        ord,
        ". Variances or intercepts for ",
        ord,
        " were specified manually (e.g., x1 ~~ x1). Mixing theta and delta parameterization",
        " is NOT recommended. Consider removing the variances and intercept for the ordered",
        " items from the model syntax."
      )
      next
    }

    if (
      !any(
        pt$lhs == ord &
          pt$op == "~*~" &
          pt$rhs == ord &
          pt$user
      )
    ) {
      pt <- rbind(
        pt,
        data.frame(
          lhs = ord,
          op = "~*~",
          rhs = ord,
          modifier = "1",
          lbound = "",
          ubound = "",
          free = FALSE,
          user = FALSE
        )
      )
    } else if (
      any(
        pt$lhs == ord &
          pt$op == "~*~" &
          pt$rhs == ord &
          (is.na(pt$modifier) || (pt$modifier == "")) &
          pt$user
      )
    ) {
      pt$modifier[
        pt$lhs == ord &
          pt$op == "~*~" &
          pt$rhs == ord &
          (is.na(pt$modifier) || (pt$modifier == "")) &
          pt$user
      ] <- "1"
    }
  }

  parameter_table$parameters <- pt
  return(parameter_table)
}

#' set_ordered_delta_constraints
#'
#' Adds the constraints required for the delta parameterization to the model. These
#' are (1) variances of the latent variables of ordered items are set to 1 and (2)
#' means of the latent variables of ordered items are set to 0. The implementation
#' follows that found in lavaa. See
#' https://github.com/yrosseel/lavaan/blob/66f245e74b1075a002118b7c357261a63962030a/R/lav_representation_lisrel.R#L1865
#'
#' @param mxMod mxModel object
#' @param parameter_table parameter table object
#' @returns updated mxModel
#' @noRd
set_ordered_delta_constraints <- function(mxMod, parameter_table) {
  # Following the approach in lavaan, we will use constraints to implement delta. See
  # https://github.com/yrosseel/lavaan/blob/66f245e74b1075a002118b7c357261a63962030a/R/lav_representation_lisrel.R#L1865

  pt <- parameter_table$parameters
  # We only specify the delta parameterization for those items where it is requested with the ~*~ notation
  ordered_delta_pt <- pt[pt$op == "~*~", , drop = FALSE]

  if (nrow(ordered_delta_pt) == 0) {
    return(mxMod)
  }

  # First, we have to add the predicted means and covariances for all items to the model
  dims <- dim(mxMod$S$values)

  S_final <- mxMod$S
  S_final$name <- "S_final"
  S_final$labels[] <- matrix(
    paste0(
      "S[",
      rep(1:dims[1], each = dims[2]),
      ",",
      rep(1:dims[1], dims[2]),
      "]"
    ),
    nrow = dims[1],
    ncol = dims[2],
    byrow = TRUE
  )
  S_final$labels[upper.tri(S_final$labels)] <- t(S_final$labels)[upper.tri(
    S_final$labels
  )]
  S_final$free <- FALSE

  M_final <- mxMod$M
  M_final$name <- "M_final"
  M_final$labels <- paste0("M[1,", 1:dims[1], "]")
  M_final$free <- FALSE

  mxMod <- OpenMx::mxModel(
    mxMod,
    OpenMx::mxAlgebraFromString(algString = "A %*% t(M)", name = "pred_means"),
    OpenMx::mxAlgebraFromString(
      algString = "A %*% S %*% t(A)",
      name = "pred_cov"
    ),
    S_final,
    M_final
  )

  mxMod$expectation$M <- "M_final"
  mxMod$expectation$S <- "S_final"

  # next, we implement constraints on the variances of the categorical items
  item_names <- colnames(mxMod$S$values)
  for (i in seq_len(nrow(ordered_delta_pt))) {
    ord <- ordered_delta_pt$lhs[i]
    modifier <- ordered_delta_pt$modifier[i]

    item_index <- which(item_names == ord)
    algebra_intercept <- paste0("-pred_means[", item_index, ", 1]")
    algebra_residual_var <- paste0(
      modifier,
      " - pred_cov[",
      item_index,
      ", ",
      item_index,
      "]"
    )
    # Add constraints and also set the respective intercepts and variances to the values found there
    mxMod <- OpenMx::mxModel(
      mxMod,
      OpenMx::mxAlgebraFromString(
        algString = algebra_intercept,
        name = paste0(ord, "_constr_intercept")
      ),
      OpenMx::mxAlgebraFromString(
        algString = algebra_residual_var,
        name = paste0(ord, "_constr_residual_var")
      )
    )

    mxMod$M_final$labels[1, item_index] <- paste0(ord, "_constr_intercept[1,1]")
    mxMod$M$values[1, item_index] <- 0
    mxMod$M$free[1, item_index] <- FALSE
    mxMod$S_final$labels[item_index, item_index] <- paste0(
      ord,
      "_constr_residual_var[1,1]"
    )
    mxMod$S$values[item_index, item_index] <- 0
    mxMod$S$free[item_index, item_index] <- FALSE
  }

  return(mxMod)
}
