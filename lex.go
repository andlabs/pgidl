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
	l.scanner.Init(r)
	l.scanner.Err = func(s *scanner.Scanner, msg string) {
		l.Error(msg)
	}
	l.scanner.Mode = scanner.ScanIdents | scanner.SkipComments
	return l
}

// TODO don't export these
var symtypes = map[string]int{
	"package":	PACKAGE,
	"func":		FUNC,
	"struct":		STRUCT,
	"interface":	INTERFACE,
	"void":		VOID,
	"field":		FIELD,
	"from":		FROM,
}

func (l *lexer) Lex(lval *yySymType) int {
	r := l.scanner.Scan()
	switch r {
	case scanner.EOF:
		return 0
	case scanner.Ident:
		yySymType.String = scanner.TokenText()
		t, ok := symtypes[yySymType.String]
		if !ok {
			return IDENT
		}
		return t
	}
	return int(r)
}

func (l *lexer) Error(s string) {
	fmt.Fprintf(os.Stderr, "syntax error: %s\n", s)
	os.Exit(1)
}
