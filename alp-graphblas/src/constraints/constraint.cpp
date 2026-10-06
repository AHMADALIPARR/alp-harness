#include "alp/constraints/constraint.hpp"
#include <stdexcept>

namespace alp::constraints {

void MapContext::assign(const std::string& variable, const Term& value) {
    values_.insert_or_assign(variable, value);
}

bool MapContext::is_assigned(const std::string& variable) const { return values_.contains(variable); }

const Term* MapContext::value(const std::string& variable) const {
    auto it = values_.find(variable);
    return it == values_.end() ? nullptr : &it->second;
}

void ConstraintStore::add(std::shared_ptr<const Constraint> constraint) {
    if (!constraint) throw std::invalid_argument("null constraint");
    constraints_.push_back(std::move(constraint));
}

bool ConstraintStore::consistent(const ConstraintContext& context) const {
    for (const auto& constraint : constraints_) if (!constraint->can_extend(context)) return false;
    return true;
}

std::vector<std::string> ConstraintStore::violations(const ConstraintContext& context) const {
    std::vector<std::string> out;
    for (const auto& constraint : constraints_)
        if (!constraint->satisfied(context)) out.push_back(constraint->name());
    return out;
}

BooleanConstraint::BooleanConstraint(std::string variable, bool expected)
    : variable_(std::move(variable)), expected_(expected) {}

std::string BooleanConstraint::name() const { return "boolean(" + variable_ + ")"; }

bool BooleanConstraint::satisfied(const ConstraintContext& context) const {
    const auto* value = context.value(variable_);
    if (!value) return true;
    if (!value->is_constant()) return false;
    if (value->as_constant().name == "true") return expected_;
    if (value->as_constant().name == "false") return !expected_;
    return false;
}

bool BooleanConstraint::can_extend(const ConstraintContext& context) const {
    const auto* value = context.value(variable_);
    return !value || satisfied(context);
}

} // namespace alp::constraints
