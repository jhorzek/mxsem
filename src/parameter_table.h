#ifndef PARAMETER_TABLE_H
#define PARAMETER_TABLE_H
#include <Rcpp.h>

struct algebra{
  std::vector<std::string> new_parameters;
  std::vector<bool> new_parameters_free;
  std::vector<std::string> lhs, op, rhs;
};

struct variables{
  std::set<std::string> manifests;
  std::set<std::string> latents;
};

class parameter_table{
public:
  std::vector<std::string> lhs, op, rhs, modifier, lbound, ubound;
  std::vector<std::string> user_defined;
  std::vector<bool> free, user;
  algebra alg;
  variables vars;

  void add_line(){
    lhs.push_back("");
    op.push_back("");
    rhs.push_back("");
    modifier.push_back("");
    lbound.push_back("");
    ubound.push_back("");
    free.push_back(true);
    user.push_back(false);
  }
};

#endif
