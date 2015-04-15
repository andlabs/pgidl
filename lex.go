// 15 april 2015
package main

import (
	"fmt"
	"os"
	"io"
	"text/scanner"
)

type lexer struct {
	scanner	*scanner.Scanner
}

func newLexer(r io.Reader) *lexer {
	l := new(lexer)
	l.scanner = new(scanner.Scanner)
	l.scanner.Init(r)
	l.scanner.Error = func(s *scanner.Scanner, msg string) {
		l.Error(msg)
	}
	l.scanner.Mode = scanner.ScanIdents | scanner.ScanComments | scanner.SkipComments
	return l
}

var symtypes = map[string]int{
	"package":	tokPACKAGE,
	"func":		tokFUNC,
	"struct":		tokSTRUCT,
	"interface":	tokINTERFACE,
	"void":		tokVOID,
	"field":		tokFIELD,
	"from":		tokFROM,
}

func (l *lexer) Lex(lval *yySymType) int {
	r := l.scanner.Scan()
	switch r {
	case scanner.EOF:
		return 0
	case scanner.Ident:
		lval.String = l.scanner.TokenText()
		t, ok := symtypes[lval.String]
		if !ok {
			return tokIDENT
		}
		return t
	}
	return int(r)
}

func (l *lexer) Error(s string) {
	fmt.Fprintf(os.Stderr, "syntax error: %s\n", s)
	os.Exit(1)
}
