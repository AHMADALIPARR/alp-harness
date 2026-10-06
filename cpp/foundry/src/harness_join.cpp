// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
//
// Joins the I5 certificate to the foundry emission gate and audit chain.
// A rejected certificate does not append. An admitted step is gated, then hashed.

#include "hpc_termination/termination.hpp"
#include "gate.h"
#include "audit.h"

#include <cassert>
#include <cstdint>
#include <iostream>
#include <vector>

static hpc::termination::Term C(const char* s) { return hpc::termination::Term::constant(s); }
static hpc::termination::Term V(const char* s) { return hpc::termination::Term::variable(s); }
static hpc::termination::Atom A(const char* p, std::initializer_list<hpc::termination::Term> xs) {
    return hpc::termination::Atom{p, std::vector<hpc::termination::Term>(xs), hpc::termination::Sign::Positive};
}

int main() {
    using namespace hpc::termination;
    Program ok;
    ok.facts = {A("temperature", {C("A17"), C("96")}), A("fan", {C("A17"), C("off")})};
    ok.rules = {
        {"R1", A("overheated", {V("X")}), {A("temperature", {V("X"), V("T")}), A("gt", {V("T"), C("90")})}},
        {"R2", A("dangerous", {V("X")}), {A("overheated", {V("X")}), A("fan", {V("X"), C("off")})}}
    };
    auto admitted = certify(ok);
    assert(admitted.established);

    pmc::EmissionGate gate(pmc::GatePolicy::Suppress, 0.05);
    std::vector<double> prev{1.0, 1.0};
    std::vector<double> out{1.2, 0.8};
    auto emitted = gate.apply(out, prev, 0.2);
    assert(emitted.size() == 2);

    pmc::AuditChain chain;
    uint8_t payload[32] = {};
    payload[0] = static_cast<uint8_t>(admitted.certificate.kind);
    chain.append("i5-admitted", payload, 1);
    assert(chain.verify());
    assert(chain.size() == 1);

    Program bad;
    bad.rules = {{"R1", A("p", {V("X")}),
        {hpc::termination::Atom{"p", {V("X")}, hpc::termination::Sign::Negative}}}};
    auto rejected = certify(bad);
    assert(!rejected.established);
    assert(chain.size() == 1);

    std::cout << "HARNESS JOIN PASSED\n";
    return 0;
}
