#include "alp/atom.hpp"
namespace alp { std::string to_string(const Atom&a){std::string s=a.predicate.name;if(!a.arguments.empty()){s+="(";for(size_t i=0;i<a.arguments.size();++i){if(i)s+=",";s+=alp::to_string(a.arguments[i]);}s+=")";}return s;} std::string Atom::to_string()const{return alp::to_string(*this);} bool structurally_equal(const Atom&a,const Atom&b){return a==b;} 
bool is_ground(const Atom& a) {
    for (const auto& t : a.arguments)
        if (!is_ground(t)) return false;
    return true;
}

void collect_variables(const Atom& a, std::set<std::string>& out) {
    for (const auto& t : a.arguments) collect_variables(t, out);
}

}
