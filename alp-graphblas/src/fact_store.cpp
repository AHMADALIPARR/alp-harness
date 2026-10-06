#include "alp/fact_store.hpp"
#include <stdexcept>

namespace alp {

bool FactStore::add(const Atom& a, std::string source, std::vector<Atom> premises,
                    std::vector<Atom> failed_negations) {
    auto [it, inserted] = derivations_.try_emplace(
        to_string(a), Derivation{std::move(source), std::move(premises), std::move(failed_negations)});
    if (!inserted) return false;
    atoms_.push_back(a);
    by_predicate_[a.predicate].push_back(a);
    if (!a.arguments.empty()) by_first_argument_[first_key(a.predicate, a.arguments[0])].push_back(a);
    return true;
}

bool FactStore::contains(const Atom& a) const { return derivations_.contains(to_string(a)); }

const std::vector<Atom>& FactStore::with_predicate(const Predicate& p) const {
    static const std::vector<Atom> empty;
    auto it = by_predicate_.find(p);
    return it == by_predicate_.end() ? empty : it->second;
}

std::string FactStore::first_key(const Predicate& p, const Term& first) {
    return p.name + "/" + std::to_string(p.arity) + "|" + to_string(first);
}

const std::vector<Atom>& FactStore::with_first_argument(const Predicate& p, const Term& first) const {
    static const std::vector<Atom> empty;
    auto it = by_first_argument_.find(first_key(p, first));
    return it == by_first_argument_.end() ? empty : it->second;
}

const FactStore::Derivation* FactStore::derivation(const Atom& a) const {
    auto it = derivations_.find(to_string(a));
    return it == derivations_.end() ? nullptr : &it->second;
}

Proof FactStore::proof(const Atom& a) const {
    const Derivation* d = derivation(a);
    if (!d) throw std::out_of_range("no derivation for " + to_string(a));
    Proof p{a, d->source, {}};
    for (const auto& prem : d->premises) p.premises.push_back(proof(prem));
    for (const auto& n : d->failed_negations) p.premises.push_back(Proof{n, "not derivable", {}});
    return p;
}

std::vector<Proof> FactStore::derivation_steps() const {
    std::vector<Proof> out;
    for (const auto& a : atoms_) {
        const Derivation& d = derivations_.at(to_string(a));
        if (d.source == "fact" || d.source == "assumption") continue;
        Proof p{a, d.source, {}};
        for (const auto& prem : d.premises) {
            const Derivation* pd = derivation(prem);
            p.premises.push_back(Proof{prem, pd ? pd->source : "fact", {}});
        }
        for (const auto& n : d.failed_negations) p.premises.push_back(Proof{n, "not derivable", {}});
        out.push_back(std::move(p));
    }
    return out;
}

}  // namespace alp
