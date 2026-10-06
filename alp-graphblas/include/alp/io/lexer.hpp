#pragma once
#include <cstddef>
#include <string>
#include <string_view>
#include <vector>

namespace alp::io {

enum class TokenKind { identifier, variable, integer, quoted_atom, lparen, rparen, comma, dot, arrow, not_keyword, false_keyword, abducible_keyword, eof_token, invalid };
struct SourcePosition { std::size_t offset{0}; std::size_t line{1}; std::size_t column{1}; };
struct Token { TokenKind kind{TokenKind::invalid}; std::string text; SourcePosition position; };

class Lexer {
    std::string source_;
    std::size_t offset_{0};
    std::size_t line_{1};
    std::size_t column_{1};
    char peek(std::size_t lookahead=0) const;
    char consume();
    void whitespace_and_comments();
    Token identifier();
    Token quoted_atom();
    Token number();
public:
    explicit Lexer(std::string source);
    Token next();
    std::vector<Token> all();
    const std::string& source() const noexcept;
};

const char* token_kind_name(TokenKind kind) noexcept;

} // namespace alp::io
