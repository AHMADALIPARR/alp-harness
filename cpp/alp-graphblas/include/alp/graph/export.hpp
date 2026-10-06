#pragma once
#include "alp/graph/graph.hpp"
#include <string>

namespace alp::graph {
std::string to_dot(const Graph& graph);
std::string to_edge_list(const Graph& graph);
std::string to_matrix_market(const Graph& graph);
Graph from_edge_list(const std::string& text);
}
