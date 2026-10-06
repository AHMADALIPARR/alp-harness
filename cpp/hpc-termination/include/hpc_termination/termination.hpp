// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#pragma once
#include "model.hpp"
#include "dependency_graph.hpp"
#include "domain.hpp"
#include "stratification.hpp"
#include "certificate.hpp"
#include <string>

namespace hpc::termination {
TerminationResult certify(const Program& program);
bool rule_can_generate_fresh_terms(const Rule& rule);
bool range_restricted(const Program& program);
}
