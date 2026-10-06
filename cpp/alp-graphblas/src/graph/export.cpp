#include "alp/graph/export.hpp"
#include <sstream>
#include <vector>

namespace alp::graph {
namespace {
std::string dot_quote(const std::string& s) {
    std::string out = "\"";
    for (char c : s) {
        if (c == '"' || c == '\\') out += '\\';
        out += c;
    }
    return out + "\"";
}
}  // namespace

std::string to_dot(const Graph& graph){std::ostringstream o;o<<"digraph G {\n";for(size_t i=0;i<graph.index().size();++i)o<<"  "<<dot_quote(graph.index().name(i))<<";\n";for(auto&e:graph.edges())o<<"  "<<dot_quote(graph.index().name(e.source))<<" -> "<<dot_quote(graph.index().name(e.target))<<";\n";o<<"}\n";return o.str();}
std::string to_edge_list(const Graph& graph){std::ostringstream o;for(auto&e:graph.edges())o<<graph.index().name(e.source)<<' '<<graph.index().name(e.target)<<'\n';return o.str();}
std::string to_matrix_market(const Graph& graph){std::ostringstream o;o<<"%%MatrixMarket matrix coordinate pattern general\n";o<<graph.index().size()<<' '<<graph.index().size()<<' '<<graph.edges().size()<<'\n';for(auto&e:graph.edges())o<<e.source+1<<' '<<e.target+1<<'\n';return o.str();}
Graph from_edge_list(const std::string& text){Graph g;std::istringstream in(text);std::string a,b;while(in>>a>>b)g.add_edge(a,b);return g;}
}
