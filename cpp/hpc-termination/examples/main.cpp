// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include <iostream>
#include "hpc_termination/termination.hpp"
using namespace hpc::termination;

static Term C(const char* s){ return Term::constant(s); }
static Term V(const char* s){ return Term::variable(s); }
static Atom A(const char* p, std::initializer_list<Term> xs){ return Atom{p,std::vector<Term>(xs),Sign::Positive}; }

int main() {
    Program p;
    p.facts = {
        A("temperature", {C("A17"), C("96")}),
        A("fan", {C("A17"), C("off")})
    };
    p.rules = {
        {"R1", A("overheated", {V("X")}), {
            A("temperature", {V("X"),V("T")}),
            A("gt", {V("T"),C("90")})}},
        {"R2", A("dangerous", {V("X")}), {
            A("overheated", {V("X")}),
            A("fan", {V("X"),C("off")})}}
    };

    std::cout << "[ HPC — Horn Predicate Compiler ]\n";
    std::cout << "I5 — TERMINATION CERTIFIER\n\n";
    const auto g = build_dependency_graph(p);
    std::cout << "DEPENDENCY GRAPH\n";
    for (const auto& e : g.edges)
        std::cout << "  " << e.from << " -> " << e.to << (e.sign==Sign::Positive?" (+)":" (-)") << "\n";

    const auto r = certify(p);
    std::cout << "\nI5 VERDICT: " << (r.established ? "TERMINATION ESTABLISHED" : "REJECTED") << "\n";
    std::cout << render_certificate(r.certificate);
    return r.established ? 0 : 1;
}
