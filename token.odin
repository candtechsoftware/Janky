package main

TokenKind :: enum {
	Function,
	const,
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
	Plus,
	Minus,
	Bang,
	QuestionMark,
	Asterisk,
	Slash,
	Equal,
    Assign,
	NotEqual,
	LessThan,
	GreaterThan,
	LeftParen,
	RightParen,
	LeftBrace,
	RightBrace,
	LeftBracket,
	RightBracket,
}

TokenMap :: []string{"func", "const", "true", "false", "if", "else", "return"}

Token :: struct {
	type:    TokenKind,
	literal: string,
}
