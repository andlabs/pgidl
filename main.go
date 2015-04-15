// 15 april 2015
package main

import (
	"os"
)

//go:generate go tool yacc pgidl.y

func main() {
	l := newLexer(os.Stdin)
	yyParse(l)
}