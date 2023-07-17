#include <Rcpp.h>
#include <regex>
#include "string_operations.h"
#include "clean_syntax.h"

//' check_cleaned
//'
//' checks cleaned syntax
//' @param cleaned_syntax lavaan style syntax
//' @return throws error in case of disallowed syntax
void check_cleaned(const std::vector<std::string> cleaned_syntax){

  // check if line starts are correct
  std::regex regex_cmp("^[a-zA-Z_!]+");
  std::string cmp_to;

  for(std::string s: cleaned_syntax){
    cmp_to = s[0];
    if(!std::regex_match(cmp_to, regex_cmp)){
      Rcpp::Rcout << s << std::endl;
      Rcpp::stop("The following syntax is not allowed:" +
        s +
        ". Each line must start with the name of a variable (e.g., y1) or parameter (e.g., a > .4)");
    }
  }

}

