#include "alp/io/lexer.hpp"
#include <cctype>

namespace alp::io {

Lexer::Lexer(std::string source):source_(std::move(source)){}
char Lexer::peek(std::size_t n) const{return offset_+n<source_.size()?source_[offset_+n]:'\0';}
char Lexer::consume(){if(offset_>=source_.size())return '\0';char c=source_[offset_++];if(c=='\n'){++line_;column_=1;}else ++column_;return c;}
void Lexer::whitespace_and_comments(){for(;;){while(std::isspace(static_cast<unsigned char>(peek())))consume();if(peek()!='%')break;while(peek()&&peek()!='\n')consume();}}
Token Lexer::identifier(){SourcePosition p{offset_,line_,column_};std::string s;while(std::isalnum(static_cast<unsigned char>(peek()))||peek()=='_'||peek()=='-')s+=consume();TokenKind k=TokenKind::identifier;if(s=="not")k=TokenKind::not_keyword;else if(s=="false")k=TokenKind::false_keyword;else if(s=="abducible")k=TokenKind::abducible_keyword;else if(!s.empty()&&std::isupper(static_cast<unsigned char>(s[0])))k=TokenKind::variable;return{k,std::move(s),p};}
Token Lexer::quoted_atom(){SourcePosition p{offset_,line_,column_};consume();std::string s;while(peek()&&peek()!='\''){char c=consume();if(c=='\\'&&peek()){s+=consume();}else s+=c;}if(peek()=='\'')consume();return{TokenKind::quoted_atom,std::move(s),p};}
Token Lexer::number(){SourcePosition p{offset_,line_,column_};std::string s;while(std::isdigit(static_cast<unsigned char>(peek())))s+=consume();return{TokenKind::integer,std::move(s),p};}
Token Lexer::next(){whitespace_and_comments();SourcePosition p{offset_,line_,column_};char c=peek();if(!c)return{TokenKind::eof_token,"",p};if(std::isalpha(static_cast<unsigned char>(c))||c=='_')return identifier();if(std::isdigit(static_cast<unsigned char>(c)))return number();if(c=='\'')return quoted_atom();if(c=='('){consume();return{TokenKind::lparen,"(",p};}if(c==')'){consume();return{TokenKind::rparen,")",p};}if(c==','){consume();return{TokenKind::comma,",",p};}if(c=='.'){consume();return{TokenKind::dot,".",p};}if(c=='<'&&peek(1)=='-'){consume();consume();return{TokenKind::arrow,"<-",p};}consume();return{TokenKind::invalid,std::string(1,c),p};}
std::vector<Token> Lexer::all(){std::vector<Token>r;for(;;){auto t=next();r.push_back(t);if(t.kind==TokenKind::eof_token)break;}return r;}
const std::string& Lexer::source()const noexcept{return source_;}
const char* token_kind_name(TokenKind k)noexcept{switch(k){case TokenKind::identifier:return"identifier";case TokenKind::variable:return"variable";case TokenKind::integer:return"integer";case TokenKind::quoted_atom:return"quoted_atom";case TokenKind::lparen:return"lparen";case TokenKind::rparen:return"rparen";case TokenKind::comma:return"comma";case TokenKind::dot:return"dot";case TokenKind::arrow:return"arrow";case TokenKind::not_keyword:return"not";case TokenKind::false_keyword:return"false";case TokenKind::abducible_keyword:return"abducible";case TokenKind::eof_token:return"eof";default:return"invalid";}}
}
