#include "alp/abduction.hpp"
#include "alp/graph/bridge.hpp"
#include "alp/parser.hpp"
#include <iostream>
#include <string>
#include <vector>

namespace {

const char* kUsage = R"(usage: alp [options] FILE.alp [FILE.alp ...]

  --query ATOM     print the instances of ATOM that hold, e.g. --query 'reachable(a,X)'
  --abduce ATOM    print minimal explanations of ATOM (hypotheses over abducible predicates
                   that entail it without violating an integrity constraint)
  --all            with --abduce: print every consistent explanation, not only minimal ones
  --proof          with --query: print a derivation tree for each answer
  --graph          execute node/edge/connected/reachable/path with the graph backend
  --backend NAME   with --graph: auto (default), reference or graphblas
  --demo           run the built-in abduction demo
  -h, --help       show this help

Without --query/--abduce, all atoms derivable from the program are printed.
)";

const char* kDemo = R"(% sun is shining; explain why the grass is wet
sun_is_shining.
grass_is_wet <- sprinkler_was_on.
grass_is_wet <- it_rained_last_night.
sprinkler_was_on <- sprinkler_broken, not it_rained_last_night.
pipes_frozen <- cold_last_night.
sprinkler_was_on <- pipes_not_frozen, sprinkler_turned_on.
pipes_not_frozen <- not pipes_frozen.
sprinkler_turned_on <- not sprinkler_off.
abducible(it_rained_last_night).
abducible(sprinkler_broken).
abducible(cold_last_night).
abducible(sprinkler_off).
abducible(sprinkler_turned_on).
false <- it_rained_last_night, sun_is_shining.
false <- cold_last_night, sun_is_shining.
false <- sprinkler_was_on, it_rained_last_night.
false <- sprinkler_turned_on, sprinkler_off.
)";

void print_proof(const alp::Proof& p, int depth = 0) {
    std::cout << std::string(2 * depth + 2, ' ') << alp::to_string(p.conclusion) << "   [" << p.source << "]\n";
    for (const auto& q : p.premises) print_proof(q, depth + 1);
}

void print_models(const std::vector<alp::Model>& models) {
    std::cout << models.size() << " explanation(s)\n";
    for (const auto& m : models) {
        std::cout << "  {";
        for (std::size_t i = 0; i < m.abduced.size(); ++i) std::cout << (i ? ", " : "") << alp::to_string(m.abduced[i]);
        std::cout << "}\n";
    }
}

alp::graph::Backend parse_backend(const std::string& s) {
    if (s == "auto") return alp::graph::Backend::Auto;
    if (s == "reference") return alp::graph::Backend::Reference;
    if (s == "graphblas") return alp::graph::Backend::GraphBLAS;
    throw std::invalid_argument("unknown backend '" + s + "' (expected auto, reference or graphblas)");
}

}  // namespace

int main(int argc, char** argv) {
    std::vector<std::string> files;
    std::string query, abduce, backend = "auto";
    bool all = false, proof = false, use_graph = false, demo = false;

    try {
        for (int i = 1; i < argc; ++i) {
            const std::string a = argv[i];
            auto value = [&]() -> std::string {
                if (i + 1 >= argc) throw std::invalid_argument(a + " needs a value");
                return argv[++i];
            };
            if (a == "-h" || a == "--help") { std::cout << kUsage; return 0; }
            else if (a == "--query") query = value();
            else if (a == "--abduce") abduce = value();
            else if (a == "--backend") backend = value();
            else if (a == "--all") all = true;
            else if (a == "--proof") proof = true;
            else if (a == "--graph") use_graph = true;
            else if (a == "--demo") demo = true;
            else if (!a.empty() && a[0] == '-') throw std::invalid_argument("unknown option " + a);
            else files.push_back(a);
        }
        if (files.empty() && !demo && query.empty() && abduce.empty()) demo = true;

        alp::KnowledgeBase kb;
        if (demo) {
            kb = alp::parse_program(kDemo);
            abduce = "grass_is_wet";
        }
        for (const auto& f : files) kb.merge(alp::parse_file(f));

        if (!abduce.empty()) {
            const auto goal = alp::parse_atom(abduce);
            alp::AbductiveSolver solver(kb);
            std::cout << "goal: " << alp::to_string(goal) << "\n";
            if (all) {
                print_models(solver.solve(goal));
            } else {
                print_models(solver.minimal_explanations(goal));
            }
            return 0;
        }

        const alp::graph::GraphPredicateBridge bridge(parse_backend(backend));
        const alp::FactStore store =
            use_graph ? alp::graph::evaluate_with_graph(kb, bridge) : alp::InferenceEngine(kb).evaluate();
        if (use_graph) std::cout << "graph backend: " << bridge.reachability().backend_name() << "\n";

        if (!query.empty()) {
            const auto goal = alp::parse_atom(query);
            const auto answers = alp::InferenceEngine::solutions(goal, store);
            std::cout << answers.size() << " answer(s)\n";
            for (const auto& a : answers) {
                std::cout << "  " << alp::to_string(a) << "\n";
                if (proof) print_proof(store.proof(a), 1);
            }
            return answers.empty() ? 1 : 0;
        }

        for (const auto& a : store.all()) std::cout << alp::to_string(a) << "\n";
        const auto bad = alp::violations(kb, store);
        for (const auto& v : bad) std::cerr << "constraint violated: " << alp::to_string(v) << "\n";
        return bad.empty() ? 0 : 1;
    } catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << "\n";
        return 2;
    }
}
