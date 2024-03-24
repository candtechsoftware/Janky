package main

import "core:strings"

Lexer :: struct {
	input:    string,
	position: int,
	next_pos: int,
	ch:       byte,
}


init_lexer :: proc(input: string) -> ^Lexer {
	l: ^Lexer = new(Lexer)
	l.input = input
	l.position = 0
	l.next_pos = 0
	l.ch = input[0]
	read_char(l)
	return l
}

destroy_lexer :: proc(lexer: ^Lexer) {
	free(lexer)
}


skip_white_space :: proc(lexer: ^Lexer) {
	for lexer.ch == ' ' ||
	    lexer.ch == '\t' ||
	    lexer.ch == '\n' ||
	    lexer.ch == '\r' {
		read_char(lexer)
	}
}

peak_char :: proc(lexer: ^Lexer) -> byte {
	if lexer.next_pos >= len(lexer.input) {
		return 0
	}
	return lexer.input[lexer.next_pos]
}

read_char :: proc(lexer: ^Lexer) {
	lexer.ch = peak_char(lexer)
	lexer.position = lexer.next_pos
	lexer.next_pos += 1
}


next_tok :: proc(lexer: ^Lexer) {
	tok: Token

	switch lexer.ch {
	case '=':
		if peak_char(lexer) == '=' {
			ch: byte = lexer.ch
			read_char(lexer)
			literal := "=="
			tok = Token {
				literal = literal,
				type    = .Equal,
			}
		} else {
			tok = {
				literal = "=",
				type    = .Assign,
			}
		}
	}
}
