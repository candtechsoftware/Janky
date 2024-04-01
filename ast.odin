package main


Node :: struct {
	start: Token_Position,
	end:   Token_Position,
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
	using node: Node,
	stmt:       Stmt,
}

create_statment :: proc(tok: Token, stmt: Stmt) -> Ast_Stmt {
	node: Node = {
		start = tok.pos,
		end   = calc_end_pos(tok),
	}
	return Ast_Stmt{node = node, stmt = stmt}
}
