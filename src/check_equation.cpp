#include <Rcpp.h>
#include <regex>
#include "check_syntax.h"

void check_equation(const std::string equation){

  std::regex regex_cmp("[a-zA-Z_=~\\.*\\+0-9\\-]+");

  if(!std::regex_match(equation, regex_cmp))
    Rcpp::stop(
      "The following equation contains unsupported symbols:" +
      equation + "."
    );

}
