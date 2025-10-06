#' check_lhs_pattern
#'
#' Check if left hand side only has variable names.
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_lhs_pattern <- function(parameter_table) {
  tbl <- parameter_table$parameters
  invalid <- !grepl("^[a-zA-Z0-9_]+$", tbl$lhs)
  if (any(invalid)) {
    stop(
      "The following left hand side does not match the allowed pattern of letters, digits and underscores: ",
      paste0(tbl$lhs[which(invalid)], collapse = ",")
    )
  }
}

#' check_rhs_pattern
#'
#' Check if right hand side only has variable names.
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_rhs_pattern <- function(parameter_table) {
  tbl <- parameter_table$parameters
  invalid <- !grepl("^[a-zA-Z0-9_]+$", tbl$rhs)
  if (any(invalid)) {
    stop(
      "The following right hand side does not match the allowed pattern of letters, digits and underscores: ",
      paste0(tbl$rhs[which(invalid)], collapse = ",")
    )
  }
}

#' check_user_defined_starts
#'
#' Check if user-defined syntax starts with '\{'
#'
#' This function checks if the user-defined syntax in the given parameter table starts with '\{'.
#'
#' @param parameter_table A parameter table containing the parameters to be checked.
#' @returns nothing
#' @noRd
check_user_defined_starts <- function(parameter_table) {
  invalid <- !grepl("^\\{", parameter_table$user_defined)
  if (any(invalid)) {
    stop(
      "The following syntax is not allowed: ",
      paste0(parameter_table$user_defined[which(invalid)], collapse = ",")
    )
  }
}

#' check_user_defined_ends
#' Check if user_defined ends with '\}'
#'
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_user_defined_ends <- function(parameter_table) {
  invalid <- !grepl("\\}$", parameter_table$user_defined)
  if (any(invalid)) {
    stop(
      "The following syntax is not allowed: ",
      paste0(parameter_table$user_defined[which(invalid)], collapse = ",")
    )
  }
}

#' check_scaling_factors
#'
#' Checks if the user specified scaling factors incorrectly.
#'
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_scaling_factors <- function(parameter_table) {
  tbl <- parameter_table$parameters
  idx <- which(tbl$op == "~*~")
  for (i in idx) {
    if (tbl$lhs[i] != tbl$rhs[i]) {
      stop(
        "You specified a scale factor across different items (",
        tbl$lhs[i],
        " ~*~ ",
        tbl$rhs[i],
        "). This is not supported."
      )
    }
    if (
      !is.na(tbl$modifier[i]) &&
        (tbl$modifier[i] != "") &&
        suppressWarnings(is.na(as.numeric(tbl$modifier[i])))
    ) {
      stop(
        "You specified a non-numeric modifier for a scale factor (",
        tbl$lhs[i],
        " ~*~ ",
        tbl$modifier[i],
        "*",
        tbl$rhs[i],
        "). This is not supported."
      )
    }
  }
}

#' remove_thresholds
#'
#' Remove thresholds from parameter table. We don't check the thresholds here;
#' this function is only used to clean the parameter table before checking.
#'
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
remove_thresholds <- function(parameter_table) {
  parameter_table$parameters <-
    parameter_table$parameters[
      parameter_table$parameters$op != "|",
      ,
      drop = FALSE
    ]
  parameter_table
}

#' check_variance_algebras
#'
#' Check if any of the variances are algebras. If so, we will show a warning regarding
#' the use of algebras for variances.
#'
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_variance_algebras <- function(parameter_table) {
  transformed_variances <- (parameter_table$parameters$rhs ==
    parameter_table$parameters$lhs) &
    (parameter_table$parameters$op == "~~") &
    (parameter_table$parameters$is_algebra)
  if (any(transformed_variances)) {
    message(
      "Variances for the variabels [",
      paste0(
        parameter_table$parameters$rhs[transformed_variances],
        collapse = ", "
      ),
      "] are calculated using transformations of parameters.",
      " Ensure these transformations always result in positive values to avoid model",
      " convergence issues. For example, use '",
      parameter_table$parameters$rhs[transformed_variances][1],
      " ~~ {exp(a * data.covariate)} * ",
      parameter_table$parameters$rhs[transformed_variances][1],
      "'",
      " instead of '",
      parameter_table$parameters$rhs[transformed_variances][1],
      " ~~ {a * data.covariate} * ",
      parameter_table$parameters$rhs[transformed_variances][1],
      "'."
    )
  }
}

#' check_all_fields
#'
#' Runs a series of checks on the parameter table to make sure the user set up
#' everything correctly.
#'
#' @param parameter_table the parameter table
#' @returns nothing
#' @noRd
check_all_fields <- function(parameter_table) {
  parameter_table <- remove_thresholds(parameter_table)
  check_lhs_pattern(parameter_table)
  check_rhs_pattern(parameter_table)
  check_user_defined_starts(parameter_table)
  check_user_defined_ends(parameter_table)
  check_scaling_factors(parameter_table)
  check_variance_algebras(parameter_table)
}
