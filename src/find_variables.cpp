#include "find_variables.h"

variables find_variables(const parameter_table& pt){

  variables vars;
  std::vector<std::string> manifests;
  std::vector<std::string> latents;

  for(unsigned int i = 0; i < pt.op.size(); i++){
    if(pt.op.at(i).compare("=~") == 0){
      manifests.push_back(pt.rhs.at(i));
      latents.push_back(pt.lhs.at(i));
    }
  }

  add_unique(vars.manifests, manifests);
  add_unique(vars.latents, latents);

  return(vars);
}
