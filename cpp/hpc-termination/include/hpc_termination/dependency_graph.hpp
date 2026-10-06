// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#pragma once
#include "model.hpp"
#include <vector>

namespace hpc::termination {
DependencyGraph build_dependency_graph(const Program& program);
std::vector<std::vector<std::string>> strongly_connected_components(const DependencyGraph& graph);
bool has_negative_cycle(const DependencyGraph& graph);
}
