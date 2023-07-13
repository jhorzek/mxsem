#include <Rcpp.h>
#include "string_operations.h"

//' split_string_all
//'
//' splits a string
//' @param str string to be splitted
//' @param at where to split the string at
//' @return vector of strings
//' @export
// [[Rcpp::export]]
std::vector<std::string> split_string_all(const std::string& str, const std::string& at) {
  // adapted from Vincenzo Pii at https://stackoverflow.com/questions/14265581/parse-split-a-string-in-c-using-string-delimiter-standard-c

  std::string base_string = str;
  std::vector<std::string> splitted_str;

  size_t start = 0;
  while((start = base_string.find(at)) != std::string::npos) {
    splitted_str.push_back(base_string.substr(0, start));
    base_string.erase(0, start + at.length());
  }
  if(base_string.length() != 0)
    splitted_str.push_back(base_string);

  return(splitted_str);
}

