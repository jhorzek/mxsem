#include <Rcpp.h>
#include <cctype>
#include "check_syntax.h"

bool check_equation_chars(const std::string& equation){
  std::vector<char> allowed_special = {
    '_',
    '=',
    '~',
    '*',
    '+',
    '-',
    '.'
  };

  for(char c: equation){
    // checking each character
    if (isalpha(c) || isdigit(c)){
      continue; // no need to check further -> all letters and numbers are allowed
    }

    // check special symbols
    bool is_special = false;
      // check all special symbols
      for(char a: allowed_special){
        if(a == c){
          is_special = true;
          break;
          }
      }
      if(is_special)
        continue;
      // neither letter/number nor allowed special character:
      return false;

  }
  // everything was allowed:
  return true;
}

void check_equation(const std::string equation){

  if(!check_equation_chars(equation))
    Rcpp::stop(
      "The following equation contains unsupported symbols: " +
      equation + "."
    );

}
