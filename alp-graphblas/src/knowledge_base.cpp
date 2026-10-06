#include "alp/knowledge_base.hpp"
#include <stdexcept>

namespace alp {

namespace {

void check_safety(const std::vector<Literal>& body, const Atom* head, const std::string& where) {
    std::set<std::string> positive;
    for (const auto& l : body)
        if (!l.negated) collect_variables(l.atom, positive);

    auto require_bound = [&](const Atom& a, const char* role) {
        std::set<std::string> vars;
        collect_variables(a, vars);
        for (const auto& v : vars)
            if (!positive.contains(v))
                throw std::invalid_argument("unsafe " + where + ": variable " + v + " in " + role +
                                            " " + to_string(a) +
                                            " does not occur in a positive body literal");
    };
    if (head) require_bound(*head, "head");
    for (const auto& l : body)
        if (l.negated) require_bound(l.atom, "negated literal");
}

void collect_constants(const Term& t, std::set<std::string>& out) {
    if (t.is_constant()) {
        out.insert(t.as_constant().name);
    } else if (t.is_compound()) {
        for (const auto& a : t.as_compound().arguments) collect_constants(*a, out);
    }
}

void collect_constants(const Atom& a, std::set<std::string>& out) {
    for (const auto& t : a.arguments) collect_constants(t, out);
}

}  // namespace

void KnowledgeBase::assert_fact(const Atom& a) {
    if (!is_ground(a)) throw std::invalid_argument("fact must be ground: " + to_string(a));
    if (fact_keys_.insert(to_string(a)).second) facts_.push_back(a);
}

void KnowledgeBase::add_rule(const HornClause& r) {
    if (r.body.empty()) {
        assert_fact(r.head);
        return;
    }
    check_safety(r.body, &r.head, "rule '" + to_string(r) + "'");
    rules_.push_back(r);
}

void KnowledgeBase::add_constraint(const IntegrityConstraint& c) {
    if (c.body.empty()) throw std::invalid_argument("integrity constraint with empty body is unsatisfiable");
    check_safety(c.body, nullptr, "constraint '" + to_string(c) + "'");
    constraints_.push_back(c);
}

void KnowledgeBase::add_abducible(const Predicate& p) { abducibles_.insert(p); }

void KnowledgeBase::merge(const KnowledgeBase& o) {
    for (const auto& f : o.facts_) assert_fact(f);
    for (const auto& r : o.rules_) add_rule(r);
    for (const auto& c : o.constraints_) add_constraint(c);
    for (const auto& p : o.abducibles_) add_abducible(p);
}

bool KnowledgeBase::is_abducible(const Predicate& p) const { return abducibles_.contains(p); }

std::vector<Predicate> KnowledgeBase::abducibles() const {
    return {abducibles_.begin(), abducibles_.end()};
}

std::set<std::string> KnowledgeBase::constants() const {
    std::set<std::string> out;
    for (const auto& f : facts_) collect_constants(f, out);
    for (const auto& r : rules_) {
        collect_constants(r.head, out);
        for (const auto& l : r.body) collect_constants(l.atom, out);
    }
    for (const auto& c : constraints_)
        for (const auto& l : c.body) collect_constants(l.atom, out);
    return out;
}

}  // namespace alp
