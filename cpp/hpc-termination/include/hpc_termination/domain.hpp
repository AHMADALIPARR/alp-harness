// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#pragma once
#include "model.hpp"
#include <cstddef>

namespace hpc::termination {
ActiveDomain compute_active_domain(const Program& program);
std::size_t herbrand_base_bound(const Program& program, const ActiveDomain& domain);
}
