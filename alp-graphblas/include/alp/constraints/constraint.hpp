#pragma once
#include "alp/model.hpp"
#include <map>
#include <memory>
#include <string>
#include <vector>

namespace alp::constraints {

class ConstraintContext {
public:
    virtual ~ConstraintContext() = default;
    virtual void assign(const std::string& variable, const Term& value) = 0;
    virtual bool is_assigned(const std::string& variable) const = 0;
    virtual const Term* value(const std::string& variable) const = 0;
};

// A ConstraintContext backed by a map; `assign` overwrites earlier values.
class MapContext final : public ConstraintContext {
    std::map<std::string, Term> values_;
public:
    void assign(const std::string& variable, const Term& value) override;
    bool is_assigned(const std::string& variable) const override;
    const Term* value(const std::string& variable) const override;
};

class Constraint {
public:
    virtual ~Constraint() = default;
    virtual std::string name() const = 0;
    virtual bool satisfied(const ConstraintContext&) const = 0;
    virtual bool can_extend(const ConstraintContext&) const = 0;
};

class ConstraintStore {
    std::vector<std::shared_ptr<const Constraint>> constraints_;
public:
    void add(std::shared_ptr<const Constraint> constraint);
    const auto& constraints() const noexcept { return constraints_; }
    bool consistent(const ConstraintContext&) const;
    std::vector<std::string> violations(const ConstraintContext&) const;
};

class BooleanConstraint final : public Constraint {
    std::string variable_;
    bool expected_;
public:
    BooleanConstraint(std::string variable, bool expected);
    std::string name() const override;
    bool satisfied(const ConstraintContext&) const override;
    bool can_extend(const ConstraintContext&) const override;
};

} // namespace alp::constraints
