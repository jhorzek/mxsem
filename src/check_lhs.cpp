#include <Rcpp.h>
#include "string_operations.h"

void check_lhs(const std::string& lhs, const std::string not_allowed){

  for(char c: lhs){
    if(char_in_string(c, not_allowed))
      Rcpp::stop("The following is not allowed: " +
        lhs +
        ". It contains one of the following characters: " +
        not_allowed);
  }
}
