#ifndef PARAMETER_TABLE_H
#define PARAMETER_TABLE_H

class parameter_table{
public:
  std::vector<std::string> lhs, op, rhs, modifier, lbound, ubound;
  void add_line(){
    lhs.push_back("");
    op.push_back("");
    rhs.push_back("");
    modifier.push_back("");
    lbound.push_back("");
    ubound.push_back("");
  }
};

#endif
