#include <Rcpp.h>
#include "check_syntax.h"

void check_labels(const parameter_table pt){

  for(auto l: pt.modifier){
    if(l.compare("NA"))
      Rcpp::warning(
        "NA found as modifier (e.g., label) for one of the parameters.",
        "Note that this does not set a loading to being freely estimated in mxsem.",
        "Use the argument scale_loadings = FALSE to freely estimate all loadings and",
        "scale_latent_variances = TRUE to set latent variances to 1."
        );
  }

}
