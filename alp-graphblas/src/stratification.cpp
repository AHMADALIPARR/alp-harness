#include "alp/stratification.hpp"
#include <algorithm>
#include <map>
#include <stdexcept>

namespace alp {

Stratification stratify(const KnowledgeBase& kb) {
    std::map<Predicate, std::size_t> level;
    for (const auto& r : kb.rules()) {
        level.try_emplace(r.head.predicate, 0);
        for (const auto& l : r.body) level.try_emplace(l.atom.predicate, 0);
    }
    const std::size_t limit = level.size();

    for (bool changed = true; changed;) {
        changed = false;
        for (const auto& r : kb.rules()) {
            std::size_t& head = level[r.head.predicate];
            for (const auto& l : r.body) {
                const std::size_t need = level[l.atom.predicate] + (l.negated ? 1 : 0);
                if (need > head) {
                    head = need;
                    changed = true;
                    if (head > limit)
                        throw std::invalid_argument(
                            "program is not stratified: negation through recursion involving " +
                            r.head.predicate.name + "/" + std::to_string(r.head.predicate.arity));
                }
            }
        }
    }

    Stratification s;
    for (std::size_t i = 0; i < kb.rules().size(); ++i) {
        const std::size_t lv = level.at(kb.rules()[i].head.predicate);
        if (s.rule_strata.size() <= lv) s.rule_strata.resize(lv + 1);
        s.rule_strata[lv].push_back(i);
    }
    return s;
}

}  // namespace alp
