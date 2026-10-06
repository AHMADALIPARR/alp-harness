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

int main(){
    running_example();
    positive_recursion_is_finite();
    negative_cycle_rejected();
    function_generation_rejected();
    unsafe_head_rejected();
    std::cout << "ALL I5 TESTS PASSED\n";
}
