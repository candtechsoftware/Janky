package main

import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) <= 1 {
		fmt.println("Need to provide file to read")
		return
	}

	file_name := os.args[1]

	b, err := os.read_entire_file_from_filename(file_name)
	p := init_parser()
	ast_file := Ast_File {
		name     = file_name,
		fullpath = file_name,
	}

	ok := parse_file(&p, &ast_file)
    fmt.println("Lexer: %#v", p.lexer)
    fmt.println("Stmts: %#v", p.file.decls)
}
