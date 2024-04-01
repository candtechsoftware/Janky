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

parse_stmt :: proc(p:^Parser) -> Ast_Stmt{
    tok := next_token(p)
    // TODO(Alex): implement
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
        //TODO(Alex): implement
    }
    return true
}
