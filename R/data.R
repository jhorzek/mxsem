#' get_mx_data
#'
#' Translates the data to an mxData object.
#' @param data data set
#' @param add_intercepts should intercepts be estimated? Will result in raw data being used
#' @returns mxData object
#' @noRd
get_mx_data <- function(data, add_intercepts, parameter_table) {
  if (is(data, "MxDataStatic")) {
    mx_data <- data
  } else {
    if (!add_intercepts) {
      mx_data <- OpenMx::mxData(
        observed = stats::cov(as.matrix(data[,
          parameter_table$variables$manifests
        ])),
        type = "cov",
        numObs = nrow(data)
      )
    } else {
      mx_data <- OpenMx::mxData(
        observed = data,
        type = "raw"
      )
    }
  }
}

#' check_data
#'
#' Checks that all ordered items are also ordered in the data set
#' @param data data set
#' @param ordered vector with names of ordered items
#' @returns nothing
#' @noRd
check_data <- function(data, ordered) {
  for (i in ordered) {
    if (!is.ordered(data[[i]])) {
      stop(
        i,
        " must be an ordered factor. Use factor(",
        i,
        ", ordered = TRUE)."
      )
    }
  }
}
