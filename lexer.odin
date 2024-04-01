package main

import "core:fmt"
import "core:log"
import "core:odin/tokenizer"
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

handle_error :: proc(l: ^Lexer, message: string) {
	log.errorf("Error lexing src: %s :: %#v", message, l)
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
	return Token_Position{file = l.path, offset = offset, line = line, col = col}
}


read_identifier :: proc(l: ^Lexer) -> string {
	offset := l.offset

	for tokenizer.is_letter(l.ch) || tokenizer.is_digit(l.ch) {
		read_next(l)
	}
	return string(l.src[offset:l.offset])
}


check_if_keyword :: proc(literal: string) -> (Token_Kind, bool) {
	if len(literal) > 1 {
		for k, i in Keywords_Types {
			if literal == k {
				return Token_Kind(i), true
			}
		}
	}
	return Token_Kind.NotFound, false
}

read_mantissa :: proc(l: ^Lexer, base := 10) {
	for tokenizer.digit_val(l.ch) < base || l.ch == '_' {
		read_next(l)
	}
}

read_exponent :: proc(l: ^Lexer, kind: ^Token_Kind) {
	if l.ch == 'e' || l.ch == 'E' {
		kind^ = .Float
		read_next(l)
		if l.ch == '-' || l.ch == '+' {
			read_next(l)
		}
		if tokenizer.digit_val(l.ch) < 10 {
			read_mantissa(l, 10)
		} else {
			handle_error(l, "reading read_exponent")
		}
	}
}

peek_byte :: proc(l: ^Lexer, offset := 0) -> byte {
	if l.read_offest + offset < len(l.src) {
		return l.src[l.read_offest + offset]
	}
	return 0
}


read_fraction :: proc(l: ^Lexer, kind: ^Token_Kind) -> bool {
	if l.ch == '.' && peek_byte(l) == '.' {
		return true
	}

	if l.ch == '.' {
		kind^ = .Float
		read_next(l)
		read_mantissa(l, 10)
	}
	return false
}

read_number :: proc(l: ^Lexer, seen_decimal_point: bool) -> (Token_Kind, string) {

	offset := l.offset
	kind := Token_Kind.Int
	seen_point := seen_decimal_point

	if seen_point {
		offset -= 1
		kind = .Float
		read_mantissa(l)
		read_exponent(l, &kind)
	} else {
		if l.ch == '0' {
			validate_base :: proc(l: ^Lexer, kind: ^Token_Kind, base: int, msg: string) {
				prev := l.offset
				read_next(l)
				read_mantissa(l, base)
				if l.offset - prev <= 1 {
					kind^ = .Illegal
					handle_error(l, msg)
				}
			}
			read_next(l)
			switch l.ch {
			case 'b':
				validate_base(l, &kind, 2, "illegal binary number")
			case 'o':
				validate_base(l, &kind, 8, "illegal octal number")
			case 'd':
				validate_base(l, &kind, 10, "illegal decimal number")
			case 'z':
				validate_base(l, &kind, 12, "illegal dozenal number")
			case 'x':
				validate_base(l, &kind, 16, "illegal hexadecimal number")
			case 'h':
				prev := l.offset
				read_next(l)
				read_mantissa(l, 16)
				if l.offset - prev <= 1 {
					kind = Token_Kind.Illegal
					handle_error(l, "illegal hexadecimal float")
				} else {
					sub := l.src[prev + 1:l.offset]
					count := 0
					for d in sub {
						if d != '_' {
							count += 1
						}
					}
					switch count {
					case 4, 8, 16:
						break
					case:
						handle_error(l, "illegal hexadecimal float")
					}
				}
			case:
				seen_point = false
				read_mantissa(l)
				if l.ch == '.' {
					seen_point = true
					if read_fraction(l, &kind) {
						return kind, string(l.src[offset:l.offset])
					}

				}
				read_exponent(l, &kind)
				return kind, string(l.src[offset:l.offset])
			}
		}
	}
	read_mantissa(l)
	if read_fraction(l, &kind) {
		return kind, string(l.src[offset:l.offset])
	}

	read_exponent(l, &kind)

	return kind, string(l.src[offset:l.offset])
}

read_string :: proc(l: ^Lexer) -> string {
	// TODO(Alex): Implement
	return ""
}

read_raw_string :: proc(l: ^Lexer) -> string {
	// TODO(Alex): Implement
	return ""
}

read :: proc(l: ^Lexer) -> Token {
	skip_ws(l)

	offset := l.offset
	token_kind: Token_Kind
	literal: string
	position := offset_to_position(l, offset)

	switch ch := l.ch; true {
	case tokenizer.is_letter(ch):
		literal = read_identifier(l)
		token_kind = .Ident
		if kind, found := check_if_keyword(literal); found {
			token_kind = kind
		}
	case '0' <= ch && ch <= '9':
		read_number(l, false)
	case:
		read_next(l)
		switch ch {
		case -1:
			token_kind = .EOF
		case '\n':
			token_kind = .SemiColon
			literal = "\n"
		case '\\':
			token := read(l)
			if token.pos.line == position.line {
				handle_error(l, "expected a new line")
			}
			return token
		case '\'':
		case '"':
			token_kind = .String
			literal = read_string(l)
		case '`':
			token_kind = .String
			literal = read_raw_string(l)
		case '.':
			token_kind = .Period
			switch l.ch {
			case '0' ..= '9':
				token_kind, literal = read_number(l, true)
			case '.':
				handle_error(l, "don't support ellipsis and ranges yet")
			}
		case '?':
			token_kind = .QuestionMark
		case '(':
			token_kind = .LeftParen
		case ')':
			token_kind = .RightParen
		case '[':
			token_kind = .LeftBrace
		case ']':
			token_kind = .RightBrace
		case '{':
			token_kind = .LeftBracket
		case '}':
			token_kind = .RightBracket
		case '@':
			token_kind = .At
		case '*':
			token_kind = .Multiply
		case '=':
			token_kind = .Assign
			if l.ch == '=' {
				read_next(l)
				token_kind = .Equal
			}
		case '+':
			token_kind = .Plus
		case '-':
			token_kind = .Minus
		case '/':
			token_kind = .Divide
		case '<':
			token_kind = .LessThan
			if l.ch == '=' {
				read_next(l)
				token_kind = .LessThanEq
			}
		case '>':
			token_kind = .GreaterThan
			if l.ch == '=' {
				read_next(l)
				token_kind = .GreaterThanEq
			}
		case ';':
			token_kind = .SemiColon
		case ':':
			token_kind = .Colon
		case '&':
			token_kind = .And
		case '|':
			token_kind = .Or
		case:
			if ch != utf8.RUNE_BOM {
				handle_error(l, "illegal character")
			}
			token_kind = .Illegal
		}
	}
	if literal == "" {
		literal = string(l.src[offset:l.offset])
	}
	return Token{type = token_kind, literal = literal, pos = position}
}
