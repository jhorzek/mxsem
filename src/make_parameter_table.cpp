#include <Rcpp.h>
#include "parameter_table.h"
#include "split_string.h"

parameter_table make_parameter_table(const std::vector<std::string>& equations){

  equation_elements eq_elem;
  parameter_table pt;

  for(std::string eq: equations){

    std::vector<std::string> check_for = {"=~", "~~", "~"};

    for(std::string c_for: check_for){

      if(eq.find(c_for) != std::string::npos){

        eq_elem = split_string_once(eq, c_for);

        std::vector<str_rhs_elem> rhs_elems = split_eqation_rhs(eq_elem.rhs);

        for(auto& rhs_elem: rhs_elems){

          pt.add_line();

          pt.lhs.at(pt.lhs.size()-1) = eq_elem.lhs;
          pt.modifier.at(pt.lhs.size()-1) = rhs_elem.modifier;
          pt.op.at(pt.lhs.size()-1) = c_for;
          pt.rhs.at(pt.lhs.size()-1) = rhs_elem.rhs;

        }
        // we don't check the subsequent elements
        break;
      }

    }
  }

  // we now check for bounds. These should be added to parameters which is
  // why we first looked for the loadings, etc.
  for(std::string eq: equations){

    std::vector<std::string> check_for = {">", "<"};

    for(std::string c_for: check_for){

      if(eq.find(c_for) != std::string::npos){

        equation_elements eq_elem = split_string_once(eq, c_for);

        bool was_found = false;
        for(int i = 0; i < pt.modifier.size(); i++){

          if(pt.modifier.at(i).compare(eq_elem.lhs) == 0){
            was_found = true;
            if(c_for.compare(">") == 0)
              pt.lbound.at(i) = eq_elem.rhs;
            if(c_for.compare("<") == 0)
              pt.ubound.at(i) = eq_elem.rhs;
          }

        }

        if(!was_found)
          Rcpp::stop("Found a constraint on the following parameter: " + eq_elem.lhs +
            ", but could not find this parameter in your model.");
      }
    }

  }

  // Now add transformations (mxAlgebra)
  Rcpp::warning("Algebras not yet implemented");

  return(pt);
}

//' parameter_table_to_Rcpp
//'
//' creates a parameter table from equations
//' @param equations vector with equations
//' @return parameter table
//' @export
// [[Rcpp::export]]
Rcpp::DataFrame parameter_table_to_Rcpp(const std::vector<std::string>& equations){
  parameter_table pt = make_parameter_table(equations);

  Rcpp::DataFrame pt_Rcpp = Rcpp::DataFrame::create(Rcpp::Named("lhs") = pt.lhs,
                                                    Rcpp::Named("op") = pt.op,
                                                    Rcpp::Named("rhs") = pt.rhs,
                                                    Rcpp::Named("modifier") = pt.modifier,
                                                    Rcpp::Named("ubound") = pt.ubound,
                                                    Rcpp::Named("lbound") = pt.lbound);

  return(pt_Rcpp);
}
