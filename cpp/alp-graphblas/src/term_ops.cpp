#include "alp/term_ops.hpp"
#include <algorithm>
#include <cstdint>
#include <sstream>
#include <unordered_map>

namespace alp {

namespace {
std::size_t hash_combine(std::size_t seed, std::size_t value) {
    seed ^= value + static_cast<std::size_t>(0x9e3779b97f4a7c15ULL) + (seed << 6U) + (seed >> 2U);
    return seed;
}
void metrics(const Term& t, std::size_t depth, TermMetrics& m) {
    ++m.nodes; m.maximum_depth = std::max(m.maximum_depth, depth);
    if (t.is_variable()) { ++m.variables; return; }
    if (t.is_constant()) { ++m.constants; return; }
    ++m.compounds; const auto& c = t.as_compound();
    m.maximum_arity = std::max(m.maximum_arity, c.arguments.size());
    for (const auto& a : c.arguments) metrics(*a, depth + 1, m);
}
void collect_paths(const Term& t, std::vector<std::size_t>& path, std::vector<std::vector<std::size_t>>& out) {
    out.push_back(path);
    if (!t.is_compound()) return;
    const auto& args = t.as_compound().arguments;
    for (std::size_t i = 0; i < args.size(); ++i) {
        path.push_back(i); collect_paths(*args[i], path, out); path.pop_back();
    }
}
Term replace_impl(const Term& t, const std::vector<std::size_t>& path, std::size_t pos, const Term& replacement) {
    if (pos == path.size()) return replacement;
    if (!t.is_compound()) return t;
    auto args = t.as_compound().arguments;
    const auto i = path[pos];
    if (i >= args.size()) return t;
    std::vector<Term> rebuilt;
    rebuilt.reserve(args.size());
    for (std::size_t j = 0; j < args.size(); ++j)
        rebuilt.push_back(j == i ? replace_impl(*args[j], path, pos + 1, replacement) : *args[j]);
    return Term::compound(t.as_compound().functor, std::move(rebuilt));
}
}

bool TermOrder::operator()(const Term& a, const Term& b) const { return compare_terms(a, b) < 0; }

std::size_t TermHash::operator()(const Term& term) const noexcept {
    if (term.is_variable()) return hash_combine(1, std::hash<std::string>{}(term.as_variable().name));
    if (term.is_constant()) return hash_combine(2, std::hash<std::string>{}(term.as_constant().name));
    std::size_t h = hash_combine(3, std::hash<std::string>{}(term.as_compound().functor));
    for (const auto& arg : term.as_compound().arguments) h = hash_combine(h, operator()(*arg));
    return h;
}

std::size_t term_size(const Term& t) { return term_metrics(t).nodes; }
std::size_t term_depth(const Term& t) { return term_metrics(t).maximum_depth; }
std::size_t term_variable_count(const Term& t) { return term_metrics(t).variables; }
std::size_t term_constant_count(const Term& t) { return term_metrics(t).constants; }
std::size_t term_compound_count(const Term& t) { return term_metrics(t).compounds; }
std::size_t term_maximum_arity(const Term& t) { return term_metrics(t).maximum_arity; }
TermMetrics term_metrics(const Term& t) { TermMetrics m; metrics(t, 0, m); return m; }


bool is_linear(const Term& t) { auto occ = variable_occurrences(t); return std::all_of(occ.begin(), occ.end(), [](const auto& p){ return p.second == 1; }); }
bool contains_variable(const Term& t, const std::string& n) { return t.is_variable() ? t.as_variable().name == n : t.is_compound() && std::any_of(t.as_compound().arguments.begin(), t.as_compound().arguments.end(), [&](const TermPtr& p){ return contains_variable(*p, n); }); }
bool contains_functor(const Term& t, const std::string& f) { return t.is_compound() && (t.as_compound().functor == f || std::any_of(t.as_compound().arguments.begin(), t.as_compound().arguments.end(), [&](const TermPtr& p){ return contains_functor(*p, f); })); }
bool contains_constant(const Term& t, const std::string& c) { return t.is_constant() ? t.as_constant().name == c : t.is_compound() && std::any_of(t.as_compound().arguments.begin(), t.as_compound().arguments.end(), [&](const TermPtr& p){ return contains_constant(*p, c); }); }

std::set<std::string> variable_names(const Term& t) { std::set<std::string> out; if(t.is_variable()) out.insert(t.as_variable().name); else if(t.is_compound()) for(auto& a:t.as_compound().arguments){auto child=variable_names(*a);out.insert(child.begin(),child.end());} return out; }
std::set<std::string> functor_names(const Term& t) { std::set<std::string> out; if(t.is_compound()){out.insert(t.as_compound().functor);for(auto&a:t.as_compound().arguments){auto child=functor_names(*a);out.insert(child.begin(),child.end());}} return out; }
std::set<std::string> constant_names(const Term& t) { std::set<std::string> out; if(t.is_constant())out.insert(t.as_constant().name); else if(t.is_compound())for(auto&a:t.as_compound().arguments){auto child=constant_names(*a);out.insert(child.begin(),child.end());} return out; }

std::map<std::string,std::size_t> variable_occurrences(const Term& t) { std::map<std::string,std::size_t> out; if(t.is_variable())++out[t.as_variable().name]; else if(t.is_compound())for(auto&a:t.as_compound().arguments){auto child=variable_occurrences(*a);for(auto&[n,c]:child)out[n]+=c;} return out; }

Term rename_variables(const Term& t, const std::function<std::string(const std::string&)>& rename) {
    if(t.is_variable())return Term::variable(rename(t.as_variable().name));
    if(t.is_constant())return t;
    std::vector<Term> args; for(auto&a:t.as_compound().arguments)args.push_back(rename_variables(*a,rename));
    return Term::compound(t.as_compound().functor,std::move(args));
}
Term freshen_variables(const Term& t, std::size_t serial) { return rename_variables(t,[serial](const std::string& n){return n+"$"+std::to_string(serial);}); }
Term normalize_variables(const Term& t) {
    std::map<std::string,std::string> names; std::size_t next=0;
    return rename_variables(t,[&](const std::string& n){auto it=names.find(n);if(it!=names.end())return it->second;auto v="_V"+std::to_string(next++);names.emplace(n,v);return v;});
}
Term canonicalize(const Term& t) { return normalize_variables(t); }

std::vector<const Term*> preorder(const Term& t) { std::vector<const Term*> out{&t}; if(t.is_compound())for(auto&a:t.as_compound().arguments){auto c=preorder(*a);out.insert(out.end(),c.begin(),c.end());} return out; }
std::vector<const Term*> postorder(const Term& t) { std::vector<const Term*> out; if(t.is_compound())for(auto&a:t.as_compound().arguments){auto c=postorder(*a);out.insert(out.end(),c.begin(),c.end());} out.push_back(&t); return out; }
std::vector<std::vector<std::size_t>> paths(const Term& t) { std::vector<std::vector<std::size_t>> out;std::vector<std::size_t> p;collect_paths(t,p,out);return out; }
const Term* at_path(const Term& t,const std::vector<std::size_t>& p){const Term*cur=&t;for(auto i:p){if(!cur->is_compound()||i>=cur->as_compound().arguments.size())return nullptr;cur=cur->as_compound().arguments[i].get();}return cur;}
Term replace_subterm(const Term&t,const std::vector<std::size_t>&p,const Term&r){return replace_impl(t,p,0,r);}
Term map_terms(const Term&t,const std::function<Term(const Term&)>&mapper){std::vector<Term> children;if(t.is_compound())for(auto&a:t.as_compound().arguments)children.push_back(map_terms(*a,mapper));Term rebuilt=t.is_compound()?Term::compound(t.as_compound().functor,std::move(children)):t;return mapper(rebuilt);}
Term fold_terms(const Term&t,const std::function<Term(const Term&,const std::vector<Term>&)>&folder){std::vector<Term> children;if(t.is_compound())for(auto&a:t.as_compound().arguments)children.push_back(fold_terms(*a,folder));return folder(t,children);}

int compare_terms(const Term&a,const Term&b){if(a.value.index()!=b.value.index())return a.value.index()<b.value.index()?-1:1;if(a.is_variable()){if(a.as_variable().name==b.as_variable().name)return 0;return a.as_variable().name<b.as_variable().name?-1:1;}if(a.is_constant()){if(a.as_constant().name==b.as_constant().name)return 0;return a.as_constant().name<b.as_constant().name?-1:1;}auto&x=a.as_compound();auto&y=b.as_compound();if(x.functor!=y.functor)return x.functor<y.functor?-1:1;if(x.arguments.size()!=y.arguments.size())return x.arguments.size()<y.arguments.size()?-1:1;for(size_t i=0;i<x.arguments.size();++i){int c=compare_terms(*x.arguments[i],*y.arguments[i]);if(c)return c;}return 0;}
bool variant_equal(const Term&a,const Term&b){return normalize_variables(a)==normalize_variables(b);}
std::string skeleton(const Term&t){if(t.is_variable())return "_";if(t.is_constant())return t.as_constant().name;std::ostringstream o;o<<t.as_compound().functor<<"/"<<t.as_compound().arguments.size()<<"(";for(size_t i=0;i<t.as_compound().arguments.size();++i){if(i)o<<",";o<<skeleton(*t.as_compound().arguments[i]);}return o<<")",o.str();}
std::string signature(const Term&t){if(t.is_variable())return "V";if(t.is_constant())return "C:"+t.as_constant().name;return "F:"+t.as_compound().functor+"/"+std::to_string(t.as_compound().arguments.size());}
std::string fingerprint(const Term&t){std::size_t h=TermHash{}(normalize_variables(t));return std::to_string(h)+":"+std::to_string(term_size(t));}

} // namespace alp
