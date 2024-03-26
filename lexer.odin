package main

import "core:fmt"
import "core:unicode/utf8"

Lexer :: struct {
	path:        string,
	src:         string,
	ch:          rune,
	offset:      int,
	read_offest: int,
	line_offest: int,
	line_count:  int,
}


init_lexer :: proc(input, path: string) -> ^Lexer {
	l: ^Lexer = new(Lexer)
	l.src = input
	l.ch = ' '
	l.offset = 0
	l.read_offest = 0
	l.line_offest = 0
	l.line_count = len(input) > 0 ? 1 : 0
	l.path = path
	read_next(l)
	return l
}

destroy_lexer :: proc(lexer: ^Lexer) {
	free(lexer)
}


read_next :: proc(l: ^Lexer) {
	if l.read_offest < len(l.src) {
		l.offset = l.read_offest
		if l.ch == '\n' {
			l.line_offest = l.offset
			l.line_count += 1
		}
		ch, w := rune(l.src[l.read_offest]), 1
		switch {
		case ch == 0:
			fmt.println("Error with character: ", l)
		case ch >= utf8.RUNE_SELF:
			ch, w = utf8.decode_rune_in_string(l.src[l.read_offest:])
			if ch == utf8.RUNE_ERROR && w == 1 {
				fmt.println("Error with character: ", l)
			} else if ch == utf8.RUNE_BOM && l.offset > 0 {
				fmt.println("Error with character: ", l)
			}
		}
		l.read_offest += w
		l.ch = ch
	} else {
		l.offset = len(l.src)
		if l.ch == '\n' {
			l.line_offest = l.offset
			l.line_offest += 1
		}
		l.ch = -1
	}
}

skip_ws :: proc(l: ^Lexer) {
	for {
		switch l.ch {
		case ' ', '\n', '\t', '\r':
			read_next(l)
		case:
			return
		}
	}
}

offset_to_position :: proc(l: ^Lexer, offset: int) -> Token_Position {
	line := l.line_count
	col := offset - l.line_offest + 1
	return(
		Token_Position {
			file = l.path,
			offset = offset,
			line = line,
			col = col,
		} \
	)
}


read :: proc(l: ^Lexer) -> Token {
	skip_ws(l)

	offset := l.offset
	token_kind: Token_Kind
	literal: string
	position := offset_to_position(l, offset)

	return Token{type = token_kind, literal = literal, pos = position}
}
