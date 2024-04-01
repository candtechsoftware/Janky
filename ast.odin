package main

import "base:intrinsics"
import "core:mem"


Node :: struct {
	start:   Token_Position,
	end:     Token_Position,
	derived: Any_Node,
}

Any_Node :: union {}


Expr :: struct {
	using base:   Node,
	derived_expr: Any_Expr,
}

Unary_Expr :: struct {
    using node: Expr,
    op: Token,
    expr: ^Expr,
}
Ident :: struct {
	using node: Expr,
	name:       string,
}

Any_Expr :: union {
	^Ident,
}

Ast_File :: struct {
	using node: Node,
	id:         int,
	name:       string,
	fullpath:   string,
	src:        string,
}


Illegal_Stmt :: struct {}

Stmt :: union {
	Illegal_Stmt,
}


Ast_Stmt :: struct {
	using node:   Node,
	derived_stmt: Stmt,
}

create_statment :: proc(tok: Token, stmt: Stmt) -> Ast_Stmt {
	node: Node = {
		start = tok.pos,
		end   = calc_end_pos(tok),
	}
	return Ast_Stmt{node = node, derived_stmt = stmt}
}

new_end_node :: proc($T: typeid, pos: Token_Position, end: ^Node) -> ^T {
	return new(T, pos, end != nil ? end.end : pos)
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
