// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include "hpc_termination/certificate.hpp"
#include <sstream>

namespace hpc::termination {
std::string certificate_kind_name(TerminationCertificate::Kind k) {
    switch (k) {
        case TerminationCertificate::Kind::NonRecursive: return "NonRecursive";
        case TerminationCertificate::Kind::Stratified: return "Stratified";
        case TerminationCertificate::Kind::Rejected: return "Rejected";
    }
    return "Rejected";
}

std::string render_certificate(const TerminationCertificate& c) {
    std::ostringstream o;
    o << "Certificate = " << certificate_kind_name(c.kind) << "\n";
    if (!c.reason.empty()) o << "Reason = " << c.reason << "\n";
    if (c.bound) o << "Bound = " << c.bound << "\n";
    for (const auto& s : c.strata) {
        o << "Stratum " << s.index << ": ";
        for (std::size_t i=0;i<s.topological_order.size();++i) {
            if (i) o << ", ";
            o << s.topological_order[i];
        }
        o << (s.recursive ? " [recursive]" : " [non-recursive]") << "\n";
    }
    return o.str();
}
} // namespace hpc::termination
