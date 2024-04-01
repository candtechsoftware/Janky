package main

Token_Kind :: enum u32 {
    Interface,
	Function,
	Const,
	True,
	False,
	If,
	Else,
	Return,
	Illegal,
	EOF,
	Ident,
	Int,
	Uint,
	Float,
	String,
	Array,
	Record,
	Plus,
	Minus,
	Bang,
	QuestionMark,
    At,
    Period,
	Multiply,
	Divide,
	Equal,
    And,
    Or,
	Assign,
	Comma,
	SemiColon,
	Colon,
	NotEqual,
	LessThan,
	GreaterThan,
	LessThanEq,
	GreaterThanEq,
	LeftParen,
	RightParen,
	LeftBrace,
	RightBrace,
	LeftBracket,
	RightBracket,
	Count,
    NotFound,
}

Keywords_Types :: []string {
    "interface",
	"func",
	"const",
	"true",
	"false",
	"if",
	"else",
	"return",
}


TokenMap :: [Token_Kind.Count]string {
    "interface",
	"func",
	"const",
	"true",
	"false",
	"if",
	"else",
	"return",
	"illegal",
	"EOF",
	"identifier",
	"Int",
	"Uint",
	"Float",
	"String",
	"Array",
	"Record",
	"+",
	"-",
	"!",
	"?",
    "@",
    ".",
	"*",
	"/",
	"==",
	"&",
	"|",
	"=",
	",",
	";",
	":",
	"!=",
	"<",
	">",
	"<=",
	">=",
	"(",
	")",
	"{",
	"}",
	"[",
	"]",
}

calc_end_pos :: proc(token: Token) -> Token_Position {
    pos: Token_Position
    // TODO(Alex): implemnt
    return pos
}

Token :: struct {
	type:    Token_Kind,
	literal: string,
	pos:     Token_Position,
}

Token_Position :: struct {
	file:   string,
	offset: int,
	line:   int,
	col:    int,
}
