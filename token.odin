package main

Token_Kind :: enum u32 {
	Invalid,
	EOF,
	Comment,
	B_Literal_Begin,
	Ident, // main
	Integer, // 12345
	Bin_Integer, // 12345
	Unsigned_Integer, //  > 0
	Float, // 123.45
	String, // "abc"
	B_Literal_End,
	B_Operator_Begin,
	Eq, // =
	Not, // !
	At, // @
	Dollar, // $
	Question, // ?
	Add, // +
	Sub, // -
	Mul, // *
	Quo, // /
	Mod, // %
	And, // &
	Or, // |
	Cmp_And, // &&
	Cmp_Or, // ||
	B_Assign_Op_Begin,
	Add_Eq, // +=
	Sub_Eq, // -=
	Mul_Eq, // *=
	Quo_Eq, // /=
	Mod_Eq, // %=
	And_Eq, // &=
	B_Assign_Op_End,
	B_Comparison_Begin,
	Cmp_Eq, // ==
	Not_Eq, // !=
	Lt, // <
	Gt, // >
	Lt_Eq, // <=
	Gt_Eq, // >=
	B_Comparison_End,
	Open_Paren, // (
	Close_Paren, // )
	Open_Bracket, // [
	Close_Bracket, // ]
	Open_Brace, // {
	Close_Brace, // }
	Colon, // :
	Semicolon, // ;
	Period, // .
	Comma, // ,
	B_Operator_End,
	B_Keyword_Begin,
	Import, // import
	Where, // where
	If, // if
	Else, // else
	For, // for
	Switch, // switch
	Case, // case
	Break, // break
	Continue, // continue
	Defer, // defer
	Return, // return
	Type, // type
	Func, // func
	Interface, // interface
	Union, // union
	Enum, // enum
	Record, // record
	B_Keyword_End,
	COUNT,
	B_Custom_Keyword_Begin = COUNT + 1,
	// ... Custom keywords
}

Keywords_Types :: []string{"interface", "func", "const", "true", "false", "if", "else", "return"}


TokenMap :: [Token_Kind.COUNT]string {
	"invalid",
	"EOF",
	"Comment",
	"",
	"identifier",
	"int",
	"bigint",
	"uint",
	"float",
	"string", // "abc"
	"",
	"",
	"=",
	"!",
	"@",
	"$",
	"?",
	"+",
	"-",
	"*",
	"/",
	"%",
	"&",
	"|",
	"&&",
	"||",
	"",
	"+=",
	"-=",
	"*=",
	"/=",
	"%=",
	"&=",
	"",
	"",
	"++",
	"!=",
	"<",
	">",
	"<=",
	">=",
	"",
	"(",
	")",
	"[",
	"]",
	"{",
	"}",
	":",
	";",
	".",
	",",
	"",
	"",
	"import",
	"where",
	"if",
	"else",
	"for",
	"switch",
	"case",
	"break",
	"continue",
	"defer",
	"return",
	"type",
	"fn",
	"interface",
	"union", // union
	"enum", // enum
	"record", // record
	"",
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


is_assignment_operator :: proc(type: Token_Kind) -> bool {
	return .B_Assign_Op_Begin < type && type < .B_Assign_Op_End || type == .Eq
}
