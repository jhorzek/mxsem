#include "scale_latent_variables.h"

void scale_latent_variances(parameter_table& pt){
  std::vector<std::string> latents = pt.vars.latents;

  for(std::string& latent: latents){

    for(int i = 0; i < pt.lhs.size(); i++){
      if((pt.lhs.at(i).compare(latent) == 0) &&
         (pt.op.at(i).compare("~~") == 0) &&
         (pt.rhs.at(i).compare(latent) == 0) &&
         (pt.modifier.at(i).compare("") == 0)
      ){
        pt.modifier.at(i) = "1.0";
        break;
      }
    }
  }
}

void scale_loadings(parameter_table& pt){
  std::vector<std::string> latents = pt.vars.latents;

  for(std::string& latent: latents){

    for(int i = 0; i < pt.lhs.size(); i++){
      if((pt.lhs.at(i).compare(latent) == 0) &&
         (pt.op.at(i).compare("=~") == 0) &&
         (pt.modifier.at(i).compare("") == 0)
      ){
        // set the first loading of each latent variable to 1
        pt.modifier.at(i) = "1.0";
        break;
      }
    }
  }
}
