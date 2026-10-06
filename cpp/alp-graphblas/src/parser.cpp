#include "alp/parser.hpp"
#include <algorithm>
#include <cctype>
#include <fstream>
#include <iterator>

namespace alp {

namespace {

enum class Tok { Ident, Number, LParen, RParen, Comma, Dot, Slash, Arrow, End };

struct Token {
    Tok kind;
    std::string text;
    int line;
    int col;
};

std::vector<Token> tokenize(const std::string& s) {
    std::vector<Token> out;
    int line = 1, col = 1;
    std::size_t p = 0;

    auto advance = [&](std::size_t n = 1) {
        for (std::size_t i = 0; i < n && p < s.size(); ++i, ++p) {
            if (s[p] == '\n') {
                ++line;
                col = 1;
            } else {
                ++col;
            }
        }
    };
    auto is_start = [](char c) { return std::isalpha((unsigned char)c) || c == '_'; };
    auto is_part = [](char c) { return std::isalnum((unsigned char)c) || c == '_'; };

    while (p < s.size()) {
        const char c = s[p];
        if (std::isspace((unsigned char)c)) {
            advance();
            continue;
        }
        if (c == '%') {
            while (p < s.size() && s[p] != '\n') advance();
            continue;
        }
        const int l = line, cl = col;
        if (is_start(c)) {
            std::size_t b = p;
            advance();
            // '-' is allowed inside identifiers when followed by an identifier character
            while (p < s.size() && (is_part(s[p]) || (s[p] == '-' && p + 1 < s.size() && is_part(s[p + 1]))))
                advance();
            out.push_back({Tok::Ident, s.substr(b, p - b), l, cl});
        } else if (std::isdigit((unsigned char)c)) {
            std::size_t b = p;
            while (p < s.size() && std::isdigit((unsigned char)s[p])) advance();
            out.push_back({Tok::Number, s.substr(b, p - b), l, cl});
        } else if (c == '<' && p + 1 < s.size() && s[p + 1] == '-') {
            advance(2);
            out.push_back({Tok::Arrow, "<-", l, cl});
        } else if (c == ':' && p + 1 < s.size() && s[p + 1] == '-') {
            advance(2);
            out.push_back({Tok::Arrow, ":-", l, cl});
        } else if (c == '(') {
            advance();
            out.push_back({Tok::LParen, "(", l, cl});
        } else if (c == ')') {
            advance();
            out.push_back({Tok::RParen, ")", l, cl});
        } else if (c == ',') {
            advance();
            out.push_back({Tok::Comma, ",", l, cl});
        } else if (c == '.') {
            advance();
            out.push_back({Tok::Dot, ".", l, cl});
        } else if (c == '/') {
            advance();
            out.push_back({Tok::Slash, "/", l, cl});
        } else {
            throw ParseError(l, cl, std::string("unexpected character '") + c + "'");
        }
    }
    out.push_back({Tok::End, "", line, col});
    return out;
}

class Parser {
    std::vector<Token> t_;
    std::size_t i_ = 0;
    int anon_ = 0;

    const Token& peek(std::size_t k = 0) const { return t_[std::min(i_ + k, t_.size() - 1)]; }
    const Token& take() { return t_[std::min(i_++, t_.size() - 1)]; }

    [[noreturn]] void fail(const Token& at, const std::string& msg) const {
        throw ParseError(at.line, at.col, msg);
    }
    const Token& expect(Tok k, const char* what) {
        if (peek().kind != k) fail(peek(), std::string("expected ") + what);
        return take();
    }
    bool accept(Tok k) {
        if (peek().kind != k) return false;
        ++i_;
        return true;
    }

    Term term() {
        const Token tok = take();
        if (tok.kind == Tok::Number) return Term::constant(tok.text);
        if (tok.kind != Tok::Ident) fail(tok, "expected a term");
        if (peek().kind == Tok::LParen) {
            take();
            std::vector<Term> args;
            if (!accept(Tok::RParen)) {
                do args.push_back(term());
                while (accept(Tok::Comma));
                expect(Tok::RParen, "')'");
            }
            return Term::compound(tok.text, std::move(args));
        }
        if (tok.text == "_") return Term::variable("_G" + std::to_string(anon_++));
        const unsigned char c0 = tok.text[0];
        if (std::isupper(c0) || c0 == '_') return Term::variable(tok.text);
        return Term::constant(tok.text);
    }

    Atom atom() {
        const Token name = expect(Tok::Ident, "a predicate name");
        std::vector<Term> args;
        if (accept(Tok::LParen) && !accept(Tok::RParen)) {
            do args.push_back(term());
            while (accept(Tok::Comma));
            expect(Tok::RParen, "')'");
        }
        return Atom{Predicate{name.text, args.size()}, std::move(args)};
    }

    Literal literal() {
        // `not` is a keyword only when followed by another predicate name
        const bool neg = peek().kind == Tok::Ident && peek().text == "not" && peek(1).kind == Tok::Ident;
        if (neg) take();
        return Literal{atom(), neg};
    }

    std::vector<Literal> body() {
        std::vector<Literal> b;
        do b.push_back(literal());
        while (accept(Tok::Comma));
        return b;
    }

    void clause(KnowledgeBase& kb) {
        const Token start = peek();
        anon_ = 0;
        try {
            if (start.kind == Tok::Ident && start.text == "abducible" && peek(1).kind == Tok::LParen) {
                take();
                take();
                const Token name = expect(Tok::Ident, "a predicate name");
                std::size_t arity = 0;
                if (accept(Tok::Slash)) arity = std::stoul(expect(Tok::Number, "an arity").text);
                expect(Tok::RParen, "')'");
                expect(Tok::Dot, "'.'");
                kb.add_abducible(Predicate{name.text, arity});
                return;
            }
            const bool bare_arrow = start.kind == Tok::Arrow;
            const bool false_arrow = start.kind == Tok::Ident && start.text == "false" && peek(1).kind == Tok::Arrow;
            if (bare_arrow || false_arrow) {
                if (false_arrow) take();
                take();
                auto b = body();
                expect(Tok::Dot, "'.'");
                kb.add_constraint(IntegrityConstraint{std::move(b)});
                return;
            }
            Atom head = atom();
            if (accept(Tok::Dot)) {
                kb.assert_fact(head);
                return;
            }
            if (!accept(Tok::Arrow)) fail(peek(), "expected '.' or '<-'");
            auto b = body();
            expect(Tok::Dot, "'.'");
            kb.add_rule(HornClause{std::move(head), std::move(b)});
        } catch (const std::invalid_argument& e) {
            fail(start, e.what());
        }
    }

public:
    explicit Parser(const std::string& src) : t_(tokenize(src)) {}

    KnowledgeBase program() {
        KnowledgeBase kb;
        while (peek().kind != Tok::End) clause(kb);
        return kb;
    }

    Atom single_atom() {
        Atom a = atom();
        accept(Tok::Dot);
        if (peek().kind != Tok::End) fail(peek(), "unexpected input after atom");
        return a;
    }
};

}  // namespace

KnowledgeBase parse_program(const std::string& s) { return Parser(s).program(); }

KnowledgeBase parse_file(const std::string& path) {
    std::ifstream f(path);
    if (!f) throw std::runtime_error("cannot open " + path);
    return parse_program(std::string((std::istreambuf_iterator<char>(f)), {}));
}

Atom parse_atom(const std::string& s) { return Parser(s).single_atom(); }

}  // namespace alp
