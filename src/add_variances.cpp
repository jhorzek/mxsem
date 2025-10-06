#include "add_elements.h"

void add_variances(parameter_table& pt) {
    
    std::set<std::string> variables;
    variables.insert(pt.vars.latents.begin(), pt.vars.latents.end());
    variables.insert(pt.vars.manifests.begin(), pt.vars.manifests.end());

    for (const auto& var : variables) {
        if (var == "1") {
            // Skip intercepts
            continue;
        }
        
        bool has_variance = false;

        for (unsigned int j = 0; j < pt.lhs.size(); j++) {
            if (pt.lhs[j] == var && pt.op[j] == "~~" && pt.lhs[j] == pt.rhs[j]) {
                // Check if it's a variance
                has_variance = true;
                break;
            }
        }

        if (!has_variance) {
            pt.add_line();
            pt.lhs.at(pt.lhs.size() - 1) = var;
            pt.rhs.at(pt.rhs.size() - 1) = var;
            pt.op.at(pt.op.size() - 1) = "~~";
        }
    }
}
