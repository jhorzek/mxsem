#include <Rcpp.h>
#include "helpers.h"
using namespace Rcpp;

//' char_in_string
//'
//' checks if a character is contained in a string
//' @param c character
//' @param str string
//' @return bool: true if char is in string
// [[Rcpp::export]]
bool char_in_string(const char c, const std::string& str) {
  for(auto&s: str){
    if(s  == c)
      return(true);
  }
  return(false);
}

