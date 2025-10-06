#ifndef ADD_ELEMENTS_H
#define ADD_ELEMENTS_H
#include "parameter_table.h"
#include <Rcpp.h>

void add_variances(parameter_table& pt);
void add_intercepts(parameter_table& pt);
void add_covariances(std::set<std::string> variables,
                     parameter_table& pt);

#endif
