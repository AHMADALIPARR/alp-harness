#include "alp/analysis/validation.hpp"
#include "alp/term_ops.hpp"
#include <map>
#include <set>

namespace alp::analysis {

namespace {

void append(ValidationReport& to, const ValidationReport& from) {
    to.diagnostics.insert(to.diagnostics.end(), from.diagnostics.begin(), from.diagnostics.end());
}

Diagnostic make(DiagnosticSeverity s, const char* code, std::string msg, const Predicate& p = {}) {
    return Diagnostic{s, code, std::move(msg), p};
}

std::set<std::string> positive_variables(const std::vector<Literal>& body) {
    std::set<std::string> vars;
    for (const auto& l : body)
        if (!l.negated) collect_variables(l.atom, vars);
    return vars;
}

// Variables that occur exactly once in a clause (and are not written `_...`).
void check_singletons(ValidationReport& r, const Atom* head, const std::vector<Literal>& body, const Predicate& where) {
    std::map<std::string, std::size_t> count;
    auto visit = [&](const Atom& a) {
        for (const auto& t : a.arguments)
            for (const auto& [name, n] : variable_occurrences(t)) count[name] += n;
    };
    if (head) visit(*head);
    for (const auto& l : body) visit(l.atom);
    for (const auto& [name, n] : count)
        if (n == 1 && name[0] != '_')
            r.diagnostics.push_back(make(DiagnosticSeverity::warning, "RULE_SINGLETON_VARIABLE",
                                         "variable " + name + " occurs only once; write _ if it is intentional", where));
}

}  // namespace

bool ValidationReport::valid() const { return errors() == 0; }

std::size_t ValidationReport::errors() const {
    std::size_t n = 0;
    for (const auto& d : diagnostics) n += d.severity == DiagnosticSeverity::error;
    return n;
}

std::size_t ValidationReport::warnings() const {
    std::size_t n = 0;
    for (const auto& d : diagnostics) n += d.severity == DiagnosticSeverity::warning;
    return n;
}

ValidationReport validate_atom(const Atom& atom) {
    ValidationReport r;
    if (atom.predicate.name.empty())
        r.diagnostics.push_back(make(DiagnosticSeverity::error, "ATOM_EMPTY_PREDICATE", "atom predicate name is empty", atom.predicate));
    if (atom.arguments.size() != atom.predicate.arity)
        r.diagnostics.push_back(make(DiagnosticSeverity::error, "ATOM_ARITY_MISMATCH",
                                     "atom argument count does not match predicate arity", atom.predicate));
    return r;
}

ValidationReport validate_rule(const HornClause& rule) {
    ValidationReport r = validate_atom(rule.head);
    for (const auto& l : rule.body) append(r, validate_atom(l.atom));

    // range restriction: what bottom-up and top-down evaluation both rely on
    const auto bound = positive_variables(rule.body);
    std::set<std::string> head_vars;
    collect_variables(rule.head, head_vars);
    for (const auto& v : head_vars)
        if (!bound.contains(v))
            r.diagnostics.push_back(make(DiagnosticSeverity::error, "RULE_UNSAFE_HEAD_VARIABLE",
                                         "head variable " + v + " does not occur in a positive body literal", rule.head.predicate));
    for (const auto& l : rule.body) {
        if (!l.negated) continue;
        std::set<std::string> vars;
        collect_variables(l.atom, vars);
        for (const auto& v : vars)
            if (!bound.contains(v))
                r.diagnostics.push_back(make(DiagnosticSeverity::error, "RULE_UNSAFE_NEGATION",
                                             "variable " + v + " of a negated literal does not occur in a positive body literal",
                                             l.atom.predicate));
    }
    check_singletons(r, &rule.head, rule.body, rule.head.predicate);
    return r;
}

ValidationReport validate_constraint(const IntegrityConstraint& constraint) {
    ValidationReport r;
    if (constraint.body.empty())
        r.diagnostics.push_back(make(DiagnosticSeverity::error, "EMPTY_CONSTRAINT",
                                     "an integrity constraint with an empty body is violated by every model"));
    for (const auto& l : constraint.body) append(r, validate_atom(l.atom));
    const auto bound = positive_variables(constraint.body);
    for (const auto& l : constraint.body) {
        if (!l.negated) continue;
        std::set<std::string> vars;
        collect_variables(l.atom, vars);
        for (const auto& v : vars)
            if (!bound.contains(v))
                r.diagnostics.push_back(make(DiagnosticSeverity::error, "CONSTRAINT_UNSAFE_NEGATION",
                                             "variable " + v + " of a negated literal does not occur in a positive body literal",
                                             l.atom.predicate));
    }
    check_singletons(r, nullptr, constraint.body, constraint.body.empty() ? Predicate{} : constraint.body[0].atom.predicate);
    return r;
}

ValidationReport validate_program(const KnowledgeBase& kb) {
    ValidationReport r;
    for (const auto& f : kb.facts()) {
        append(r, validate_atom(f));
        if (!is_ground(f))
            r.diagnostics.push_back(make(DiagnosticSeverity::error, "FACT_NOT_GROUND", "fact " + to_string(f) + " is not ground", f.predicate));
    }
    for (const auto& rule : kb.rules()) append(r, validate_rule(rule));
    for (const auto& c : kb.constraints()) append(r, validate_constraint(c));

    DependencyGraph graph;
    graph.build(kb);
    if (!graph.stratified)
        r.diagnostics.push_back(make(DiagnosticSeverity::error, "UNSTRATIFIED_NEGATION", "program contains a negative dependency cycle"));

    // a body predicate that nothing defines can never hold (usually a typo)
    std::set<Predicate> defined;
    for (const auto& f : kb.facts()) defined.insert(f.predicate);
    for (const auto& rule : kb.rules()) defined.insert(rule.head.predicate);
    for (const auto& p : kb.abducibles()) defined.insert(p);
    std::set<Predicate> reported;
    auto check_use = [&](const Atom& a) {
        if (!defined.contains(a.predicate) && reported.insert(a.predicate).second)
            r.diagnostics.push_back(make(DiagnosticSeverity::warning, "UNDEFINED_PREDICATE",
                                         "predicate " + to_string(a.predicate) + " is used but has no facts, rules or abducible declaration",
                                         a.predicate));
    };
    for (const auto& rule : kb.rules())
        for (const auto& l : rule.body) check_use(l.atom);
    for (const auto& c : kb.constraints())
        for (const auto& l : c.body) check_use(l.atom);
    return r;
}

}  // namespace alp::analysis
