package main

import "base:intrinsics"
import "core:mem"


Node :: struct {
	start:   Token_Position,
	end:     Token_Position,
	derived: Any_Node,
}

Any_Node :: union {
	// Stmts
	^Illegal_Stmt,
	^Expr_Stmt,
	^Empty_Stmt,

	// Expr
    ^Unary_Expr,
	^Func_Lit,
}


Expr :: struct {
	using base:   Node,
	derived_expr: Any_Expr,
}

Unary_Expr :: struct {
	using node: Expr,
	op:         Token,
	expr:       ^Expr,
}
Ident :: struct {
	using node: Expr,
	name:       string,
}

Any_Expr :: union {
	^Ident,
	^Unary_Expr,
}

Ast_File :: struct {
	using node: Node,
	id:         int,
	name:       string,
	fullpath:   string,
	src:        string,
}


Illegal_Stmt :: struct {
	using node: Stmt,
}


Any_Stmt :: union {
	^Illegal_Stmt,
	^Empty_Stmt,
	^Stmt,
}


Stmt :: struct {
	using stmt_base: Node,
	derived_stmt:    Any_Stmt,
}

Empty_Stmt :: struct {
	using node: Node,
	semicolon:  Token_Position,
}

Expr_Stmt :: struct {
	using node: Stmt,
	expr:       ^Expr,
}

Field :: struct {}

Field_List :: struct {
	using node: Node,
	open:       Token_Position,
	list:       []^Field,
	close:      Token_Position,
}
Proc_Type :: struct {
	using node: Expr,
	tok:        Token,
	params:     Field_List,
}

Func_Lit :: struct {
	using node: Expr,
	type:       ^Proc_Type,
	body:       Stmt,
}


new_end_node :: proc($T: typeid, pos: Token_Position, end: ^Node) -> ^T {
	return new_ast_item(T, pos, end != nil ? end.end : pos)
}

new_from_positions :: proc($T: typeid, pos, end: Token_Position) -> ^T {
	n, _ := mem.new(T)
	n.start = pos
	n.end = end
	n.derived = n
	when intrinsics.type_has_field(T, "derived_stmt") {
		n.derived_stmt = n
	}
	when intrinsics.type_has_field(T, "derived_expr") {
		n.derived_expr = n
	}
	return n
}

new_ast_item :: proc {
	new_end_node,
	new_from_positions,
}
