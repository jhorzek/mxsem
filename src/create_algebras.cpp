#include <Rcpp.h>
#include "string_operations.h"
#include "clean_syntax.h"
#include "create_algebras.h"

void make_algebras(const std::vector<std::string>& equations,
                   parameter_table& pt){

  algebra alg;

  // find newly created variables
  for(std::string eq: equations){
    if(eq.at(0) == '!'){
      // remove exclamation mark
      eq.erase(eq.begin());
      // check_lhs can be used to check for disallowed elements:
      check_lhs(eq, "!+*=~: ");
      alg.new_parameters.push_back(eq);
      alg.new_parameters_free.push_back("TRUE");
    }
  }

  equation_elements eq_elem;

  for(std::string eq: equations){

    std::vector<std::string> check_for = {":="};

    for(std::string c_for: check_for){

      if(eq.find(c_for) != std::string::npos){

        eq_elem = split_string_once(eq, c_for);

        check_lhs(eq_elem.lhs);

        alg.lhs.push_back(eq_elem.lhs);
        alg.op.push_back(c_for);
        alg.rhs.push_back(eq_elem.rhs);

        // If an element is on the left hand side of an equation, it is no longer free:
        for(unsigned int i = 0; i < pt.modifier.size(); i++){
          if(pt.modifier.at(i).compare(eq_elem.lhs) == 0)
            pt.free.at(i) = "FALSE";
        }
        for(unsigned int i = 0; i < alg.new_parameters_free.size(); i++){
          if(alg.new_parameters.at(i).compare(eq_elem.lhs) == 0)
            alg.new_parameters_free.at(i) = "FALSE";
        }

        // we don't check the subsequent elements
        break;
      }

    }
  }

  pt.alg = alg;
}
