// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// char_in_string
bool char_in_string(const char c, const std::string& str);
RcppExport SEXP _mxsem_char_in_string(SEXP cSEXP, SEXP strSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const char >::type c(cSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type str(strSEXP);
    rcpp_result_gen = Rcpp::wrap(char_in_string(c, str));
    return rcpp_result_gen;
END_RCPP
}
// clean_syntax
std::vector<std::string> clean_syntax(const std::string& syntax);
RcppExport SEXP _mxsem_clean_syntax(SEXP syntaxSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::string& >::type syntax(syntaxSEXP);
    rcpp_result_gen = Rcpp::wrap(clean_syntax(syntax));
    return rcpp_result_gen;
END_RCPP
}
// parameter_table_rcpp
Rcpp::List parameter_table_rcpp(const std::string& syntax, bool add_intercept, bool add_variance, bool scale_latent_variance, bool scale_loading);
RcppExport SEXP _mxsem_parameter_table_rcpp(SEXP syntaxSEXP, SEXP add_interceptSEXP, SEXP add_varianceSEXP, SEXP scale_latent_varianceSEXP, SEXP scale_loadingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::string& >::type syntax(syntaxSEXP);
    Rcpp::traits::input_parameter< bool >::type add_intercept(add_interceptSEXP);
    Rcpp::traits::input_parameter< bool >::type add_variance(add_varianceSEXP);
    Rcpp::traits::input_parameter< bool >::type scale_latent_variance(scale_latent_varianceSEXP);
    Rcpp::traits::input_parameter< bool >::type scale_loading(scale_loadingSEXP);
    rcpp_result_gen = Rcpp::wrap(parameter_table_rcpp(syntax, add_intercept, add_variance, scale_latent_variance, scale_loading));
    return rcpp_result_gen;
END_RCPP
}
// split_string_all
std::vector<std::string> split_string_all(const std::string& str, const std::string& at);
RcppExport SEXP _mxsem_split_string_all(SEXP strSEXP, SEXP atSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::string& >::type str(strSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type at(atSEXP);
    rcpp_result_gen = Rcpp::wrap(split_string_all(str, at));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_mxsem_char_in_string", (DL_FUNC) &_mxsem_char_in_string, 2},
    {"_mxsem_clean_syntax", (DL_FUNC) &_mxsem_clean_syntax, 1},
    {"_mxsem_parameter_table_rcpp", (DL_FUNC) &_mxsem_parameter_table_rcpp, 5},
    {"_mxsem_split_string_all", (DL_FUNC) &_mxsem_split_string_all, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_mxsem(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}