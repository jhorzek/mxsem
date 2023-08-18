
group_mxsem_by <- function(mxModel,
                           grouping_variables,
                           parameters = c(mxsem::unicode_directed(),
                                          mxsem::unicode_undirected())){

  if(!is(mxModel, "MxRAMModel"))
    stop("mxModel must be of class MxRAMModel.")
  if(mxModel$data$type != "raw")
    stop("The data of mxModel must be of type 'raw'")

  parameters <- OpenMx::omxGetParameters(mxModel)

  splitted_data <- mxModel$data$observed |>
    dplyr::group_by(dplyr::vars(dplyr::one_of(grouping_variables))) |>
    dplyr::group_split()

  names(splitted_data) <- paste0("group_", seq_len(n_groups))

  n_groups <- length(splitted_data)

  mg_model <- OpenMx::mxModel()

  for(gr in seq_len(n_groups)){
    current_model <- OpenMx::mxModel(mxModel,
                                     OpenMx::mxData(splitted_data[[gr]], type = "raw")
    )
    current_parameter_labels <- names(parameters)
    for(p in parameters){
      current_parameter_labels[grepl(p, current_parameter_labels)] <- paste0(
        current_parameter_labels[grepl(p, current_parameters)],
        "_group_", m
      )
    }

    current_model <- OpenMx::omxSetParameters(model = current_model,
                                              labels = names(parameters),
                                              values = parameters,
                                              newlabels = current_parameter_labels)
    mg_model <- OpenMx::mxModel(
      mg_model,
      current_model
    )
  }

  attr(mg_model, which = "groups") <- splitted_data

  return(mg_model)
}
