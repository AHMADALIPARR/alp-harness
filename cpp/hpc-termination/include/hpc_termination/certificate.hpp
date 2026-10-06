// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#pragma once
#include "model.hpp"
#include <string>

namespace hpc::termination {
std::string certificate_kind_name(TerminationCertificate::Kind kind);
std::string render_certificate(const TerminationCertificate& certificate);
}
