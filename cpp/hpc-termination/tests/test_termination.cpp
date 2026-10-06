// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include <cassert>
#include <iostream>
#include "hpc_termination/termination.hpp"
using namespace hpc::termination;
static Term C(const char* s){ return Term::constant(s); }
static Term V(const char* s){ return Term::variable(s); }
static Atom A(const char* p, std::initializer_list<Term> xs, Sign s=Sign::Positive){ return Atom{p,std::vector<Term>(xs),s}; }

void running_example() {
    Program p;
    p.facts={A("temperature",{C("A17"),C("96")}),A("fan",{C("A17"),C("off")})};
    p.rules={
      {"R1",A("overheated",{V("X")}),{A("temperature",{V("X"),V("T")}),A("gt",{V("T"),C("90")})}},
      {"R2",A("dangerous",{V("X")}),{A("overheated",{V("X")}),A("fan",{V("X"),C("off")})}}
    };
    auto r=certify(p);
    assert(r.established);
    assert(r.certificate.kind==TerminationCertificate::Kind::NonRecursive);
    assert(r.certificate.bound>0);
}

void positive_recursion_is_finite() {
    Program p;
    p.facts={A("parent",{C("alice"),C("bob")})};
    p.rules={
      {"R1",A("ancestor",{V("X"),V("Y")}),{A("parent",{V("X"),V("Y")})}},
      {"R2",A("ancestor",{V("X"),V("Z")}),{A("parent",{V("X"),V("Y")}),A("ancestor",{V("Y"),V("Z")})}}
    };
    auto r=certify(p);
    assert(r.established);
    assert(r.certificate.kind==TerminationCertificate::Kind::Stratified);
}

void negative_cycle_rejected() {
    Program p;
    p.rules={
      {"R1",A("a",{V("X")}),{A("b",{V("X")},Sign::Negative)}},
      {"R2",A("b",{V("X")}),{A("a",{V("X")})}}
    };
    auto r=certify(p);
    assert(!r.established);
    assert(r.certificate.reason=="UnstratifiedProgram");
}

void function_generation_rejected() {
    Program p;
    p.facts={A("seed",{C("a")})};
    p.rules={{"R1",A("p",{Term::function("s",{V("X")})}),{A("p",{V("X")})}}};
    auto r=certify(p);
    assert(!r.established);
    assert(r.certificate.reason.find("InfiniteHerbrandUniverse")!=std::string::npos);
}

void unsafe_head_rejected() {
    Program p;
    p.rules={{"R1",A("p",{V("X")}),{A("q",{C("a")})}}};
    auto r=certify(p);
    assert(!r.established);
    assert(r.certificate.reason=="UnsafeOrUngroundedRule");
}

void empty_program_is_nonrecursive() {
    Program p;
    auto r = certify(p);
    assert(r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::NonRecursive);
    assert(r.certificate.bound == 0);
    assert(r.certificate.reason.empty());
}

void facts_only_bound_is_active_domain() {
    Program p;
    p.facts = {A("edge", {C("a"), C("b")}), A("edge", {C("b"), C("c")})};
    auto r = certify(p);
    assert(r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::NonRecursive);
    // one predicate, arity 2, three constants: 3^2
    assert(r.certificate.bound == 9);
}

void stratified_negation_is_admitted() {
    // The negative atom does not bind X. The positive atom does.
    Program p;
    p.facts = {A("q", {C("a")}), A("r", {C("b")})};
    p.rules = {{"R1", A("p", {V("X")}),
        {A("q", {V("X")}), A("r", {V("X")}, Sign::Negative)}}};
    auto r = certify(p);
    assert(r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::NonRecursive);
}

void self_negative_cycle_rejected() {
    Program p;
    p.rules = {{"R1", A("p", {V("X")}), {A("p", {V("X")}, Sign::Negative)}}};
    auto r = certify(p);
    assert(!r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::Rejected);
    assert(r.certificate.reason == "UnstratifiedProgram");
}

void negative_body_does_not_bind() {
    Program p;
    p.rules = {{"R1", A("p", {V("X")}), {A("q", {V("X")}, Sign::Negative)}}};
    auto r = certify(p);
    assert(!r.established);
    assert(r.certificate.reason == "UnsafeOrUngroundedRule");
}

void comparison_atom_counts_as_a_binder() {
    // gt is Sign::Positive, so the first walk inserts U before the
    // comparison check. The check does not reject this rule.
    Program p;
    p.rules = {{"R1", A("hot", {V("X")}),
        {A("temperature", {V("X"), V("T")}), A("gt", {V("U"), C("90")})}}};
    auto r = certify(p);
    assert(r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::NonRecursive);
}

void function_only_in_body_is_not_rejected() {
    // certify looks for a function term in the head, and the domain walk
    // skips a non-constant body argument. This is the current rule, not a
    // claim that a body function is safe.
    Program p;
    p.facts = {A("seed", {C("a")})};
    p.rules = {{"R1", A("p", {V("X")}), {A("seed", {Term::function("s", {V("X")})})}}};
    auto r = certify(p);
    assert(r.established);
    assert(r.certificate.kind == TerminationCertificate::Kind::NonRecursive);
}

void function_fact_rejected_without_rule_id() {
    Program p;
    p.facts = {A("p", {Term::function("s", {C("a")})})};
    auto r = certify(p);
    assert(!r.established);
    assert(r.certificate.reason == "InfiniteHerbrandUniverse");
}

void second_rule_names_the_function_rejection() {
    Program p;
    p.facts = {A("seed", {C("a")})};
    p.rules = {
        {"R1", A("q", {V("X")}), {A("seed", {V("X")})}},
        {"R2", A("p", {Term::function("s", {V("X")})}), {A("q", {V("X")})}}
    };
    auto r = certify(p);
    assert(!r.established);
    assert(r.certificate.reason == "InfiniteHerbrandUniverse(R2)");
}

int main(){
    running_example();
    positive_recursion_is_finite();
    negative_cycle_rejected();
    function_generation_rejected();
    unsafe_head_rejected();
    empty_program_is_nonrecursive();
    facts_only_bound_is_active_domain();
    stratified_negation_is_admitted();
    self_negative_cycle_rejected();
    negative_body_does_not_bind();
    comparison_atom_counts_as_a_binder();
    function_only_in_body_is_not_rejected();
    function_fact_rejected_without_rule_id();
    second_rule_names_the_function_rejection();
    std::cout << "ALL I5 TESTS PASSED\n";
}
