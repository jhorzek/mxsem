#include "find_variables.h"

variables find_variables(const parameter_table& pt){

  variables vars;
  
  // We have to first find all latent variables to be able
  // to skip those when looking at the other variables
  for(unsigned int i = 0; i < pt.op.size(); i++){
    if(pt.op.at(i).compare("=~") == 0){
      vars.latents.insert(pt.lhs.at(i));
    }
  }

  // now we iterate over everything to find the manifest variables
  for(unsigned int i = 0; i < pt.op.size(); i++){
    if(pt.op.at(i).compare("|") == 0){
      // skip thresholds
     continue;
    }

    std::set<std::string> current_variables;
    current_variables.insert(pt.rhs.at(i));
    current_variables.insert(pt.lhs.at(i));
    for(auto var: current_variables){
      if(var.compare("1") == 0)
        continue; // skip intercepts
      if(vars.latents.contains(var))
        continue;
      vars.manifests.insert(var);
    }
  }

  return(vars);
}
