package main


Error_Data :: struct {
	node:     ^Node,
	token:    ^Token,
	position: Token_Position,
}

Parser :: struct {
	file:          Ast_File,
	lexer:         ^Lexer,
	prev_token:    Token,
	current_token: Token,
	errors:        [dynamic]Error_Data,
}


init_parser :: proc() -> Parser {
	return Parser{errors = make([dynamic]Error_Data)}
}


is_eof :: proc(p: ^Parser) -> bool {
	p.current_token = read(p.lexer)
	if p.current_token.type == .EOF {
		return false
	}
	return true
}
next_token :: proc(p: ^Parser) -> Token {
	p.prev_token = p.current_token
	prev := p.prev_token
	return prev
}
parse_unary_expr :: proc(p: ^Parser, lhs: bool) -> ^Expr {
	#partial switch p.current_token.type {
	case .Plus, .Minus, .And:
		op := next_token(p)
		expr := parse_unary_expr(p, lhs)
		ue := new_ast_item(Unary_Expr, op.pos, expr)
		return ue
	}

	return parser_atom_expr(p, parse_operand(p, lhs), lhs)
}

parse_operand :: proc(p: ^Parser, lhs: bool)-> ^Expr {
    unimplemented()
}
parser_atom_expr :: proc(p: ^Parser, value: ^Expr, lhs: bool) -> ^Expr {
	operand := value
	if operand == nil {
		handle_error(p.lexer, "expected an operand")
		// TODO(Alex): should try to fix and advance
		return nil
	}

    is_lhs := lhs
    for {
    }
    return operand
}

parse_binary_expr :: proc(p: ^Parser, lhs: bool, prec_in: int) -> ^Expr {
	start := p.current_token.pos
	expr := parse_unary_expr(p, lhs)

    unimplemented()
}

parse_expr :: proc(p: ^Parser, lhs: bool) -> ^Expr {
	return parse_binary_expr(p, lhs, 0 + 1)
}

parse_expr_list :: proc(p: ^Parser, lhs: bool) -> []^Expr {
	list: [dynamic]^Expr
	for {
		expr := parse_expr(p, lhs)
		append(&list, expr)
		if p.current_token.type != .Comma || p.current_token.type == .EOF {
			break
		}
		next_token(p)
	}
	return list[:]
}

parse_simple_stmt :: proc(p: ^Parser) -> Ast_Stmt {
	start := p.current_token
    unimplemented()
}

parse_stmt :: proc(p: ^Parser) -> Ast_Stmt {
	tok := next_token(p)
	#partial switch p.current_token.type {
	case .Ident, .Int, .Float, .Uint, .String:
		return parse_simple_stmt(p)
	}
	return create_statment(tok, Illegal_Stmt{})
}


parse_file :: proc(p: ^Parser, file: ^Ast_File) -> bool {
	p.file = file^
	p.lexer = init_lexer(p.file.src, p.file.name)
	if p.lexer.ch <= 0 {
		return true
	}

	next_token(p)

	for p.current_token.type != .EOF {
		stmt := parse_stmt(p)
        unimplemented()
	}
	return true
}
