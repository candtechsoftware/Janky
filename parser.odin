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
	is_eof(p)
	return prev
}
parse_unary_expr :: proc(p: ^Parser, lhs: bool) -> ^Expr {
	#partial switch p.current_token.type {
	case .Add, .Sub, .And:
		op := next_token(p)
		expr := parse_unary_expr(p, lhs)
		ue := new_ast_item(Unary_Expr, op.pos, expr)
		return ue
	}

	return parser_atom_expr(p, parse_operand(p, lhs), lhs)
}

parse_operand :: proc(p: ^Parser, lhs: bool) -> ^Expr {
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


parse_lhs_expr_list :: proc(p: ^Parser) -> []^Expr {
	return parse_expr_list(p, true)
}

parse_rhs_expr_list :: proc(p: ^Parser) -> []^Expr {
	return parse_expr_list(p, false)
}

parse_simple_stmt :: proc(p: ^Parser) -> ^Stmt {
	start := p.current_token

	lhs := parse_lhs_expr_list(p)
	op := p.current_token

	switch {
	case is_assignment_operator(op.type):
		next_token(p)
		rhs := parse_rhs_expr_list(p)
		if len(rhs) == 0 {
			handle_error(p.lexer, "no right hand side for assignment")
			return new_ast_item(Illegal_Stmt, start.pos, end_pos(start))
		}
		stmt := new_ast_item(Assign_Stmt, lhs[0].pos, rhs[len(rhs) - 1])
		stmt.lhs = lhs
		stmt.op = op
		stmt.rhs = rhs
		return stmt
	case op.type == .Colon:
		expect_token_after(p, .Colon, "identifier_list")
		if len(lhs) == 1 {
			#partial switch p.current_token.type {
			case .Open_Brace, .If, .For, .Switch:
				label := lhs[0]
				stmt := parse_stmt(p)
				if stmt != nil {
					#partial switch n in stmt.derived_stmt {
					case ^Block_Stmt:
						n.label = label
					case ^If_Stmt:
						n.label = label
					case ^For_Stmt:
						n.label = label
					case ^Switch_Stmt:
						n.label = label
					case ^Type_Switch_Stmt:
						n.label = label
					case ^Range_Stmt:
						n.label = label

					}
				}
			}
		}
	}
	unimplemented()
}

expect_token_after :: proc(p: ^Parse, kind: Token_Kind, msg: string) -> Token {
	prev: Token = p.current_token
	if prev.type != kind {
		handle_error(p.lexer, msg)
	}
	return next_token(p)
}

parse_stmt :: proc(p: ^Parser) -> ^Stmt {
	tok := next_token(p)
	#partial switch p.current_token.type {
	case .Ident, .Integer, .Bin_Integer, .Float, .Unsigned_Integer, .String:
		return parse_simple_stmt(p)
	}
	return new_ast_item(Illegal_Stmt, tok.pos, calc_end_pos(tok))
}


parse_file :: proc(p: ^Parser, file: ^Ast_File) -> bool {
	p.file = file^
	p.lexer = init_lexer(p.file.src, p.file.name)
	if p.lexer.ch <= 0 {
		return true
	}

	next_token(p)
	p.file.decls = make([dynamic]^Stmt)

	for p.current_token.type != .EOF {
		stmt := parse_stmt(p)
		if stmt != nil {
			if _, ok := stmt.derived.(^Empty_Stmt); !ok {
				append(&p.file.decls, stmt)
				if es, es_ok := stmt.derived.(^Expr_Stmt); es_ok && es.expr != nil {
					if _, f_ok := es.expr.derived.(^Func_Lit); f_ok {
						handle_error(p.lexer, "function literal was evaluated but not used")
					}
				}
			}
		}
		unimplemented()
	}
	return true
}
