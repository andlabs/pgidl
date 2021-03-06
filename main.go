// 15 april 2015
package pgidl

import (
	"fmt"
	"io"
)

//go:generate go tool yacc pgidl.y

func Parse(r io.Reader, filename string) (idl IDL, errs []string) {
	yyErrorVerbose = true
	l := newLexer(r, filename)
	yyParse(l)
	for _, e := range l.errs {
		errs = append(errs, fmt.Sprintf("%s %s", e.pos, e.msg))
	}
	if len(errs) == 0 {
		return l.idl, nil
	}
	return nil, errs
}
