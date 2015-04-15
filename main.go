// 15 april 2015
package main

import (
	"fmt"
	"os"
	"io"
)

//go:generate go tool yacc pgidl.y

func Parse(r io.Reader) (idl IDL, errs []string) {
	yyErrorVerbose = true
	l := newLexer(r)
	yyParse(l)
	for _, e := range l.errs {
		errs = append(errs, fmt.Sprintf("%s %s\n", e.pos, e.msg))
	}
	if len(errs) == 0 {
		return l.idl, nil
	}
	return nil, errs
}

func main() {
	fmt.Println(Parse(os.Stdin))
}
