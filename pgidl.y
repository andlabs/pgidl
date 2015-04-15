// 15 april 2015
%{
package main
%}
%start pgidl
%union {
	String	string
	IDL		IDL
	Package	*Package
	Func		*Func
	Args		[]*Arg
	Type		*Type
	Struct	*Struct
	Fields	[]*Field
	Field		*Field
	Iface		*Interface
}
%token <String> IDENT
%token PACKAGE FUNC STRUCT INTERFACE VOID FIELD FROM
%type <IDL> pgidl
%type <Package> package decls
%type <Func> funcdecl
%type <Args> arglist
%type <Type> type ptrtype funcptrtype
%type <Struct> structdecl
%type <Fields> fieldlist
%type <Field> field
%type <Iface> ifacedecl ifacememberlist
%%
pgidl:
		/* empty */		{
			$$ = nil
		}
	|	pgidl package		{
			$$ = append($1, $2)
		}
	;

package:
		PACKAGE IDENT '{' decls '}' ';'	{
			$$ = $4
			$$.Name = $2
		}
	;

decls:
		/* empty */				{
			$$ = new(Package)
		}
	|	decls funcdecl				{
			$$ = $1
			$$.Funcs = append($$.Funcs, $2)
			$$.Order = append($$.Order, &Order{
				Which:	0,
				Index:	len($$.Funcs) - 1,
			})
		}
	|	decls structdecl			{
			$$ = $1
			$$.Structs = append($$.Structs, $2)
			$$.Order = append($$.Order, &Order{
				Which:	1,
				Index:	len($$.Structs) - 1,
			})
		}
	|	decls ifacedecl				{
			$$ = $1
			$$.Interfaces = append($$.Interfaces, $2)
			$$.Order = append($$.Order, &Order{
				Which:	2,
				Index:	len($$.Interfaces) - 1,
			})
		}
	;

funcdecl:
		FUNC IDENT '(' VOID ')' ';'			{
			$$ = new(Func)
			$$.Name = $2
		}
	|	FUNC IDENT '(' VOID ')' type ';'		{
			$$ = new(Func)
			$$.Name = $2
			$$.Ret = $6
		}
	|	FUNC IDENT '(' arglist ')' ';'			{
			$$ = new(Func)
			$$.Name = $2
			$$.Args = $4
		}
	|	FUNC IDENT '(' arglist ')' type ';'		{
			$$ = new(Func)
			$$.Name = $2
			$$.Args = $4
			$$.Ret = $6
		}
	;

arglist:
		IDENT type	{
			$$ = []*Arg{
				&Arg{
					Name:	$1,
					Type:	$2,
				},
			}
		}
	|	arglist ',' IDENT type		{
			$$ = append($1, &Arg{
				Name:	$3,
				Type:	$4,
			})
		}
	;

type:
		IDENT		{
			$$ = new(Type)
			$$.Name = $1
		}
	|	ptrtype		{
			$$ = $1
		}
	|	funcptrtype	{
			$$ = $1
		}
	;

ptrtype:
		'*' IDENT		{
			$$ = new(Type)
			$$.Name = $2
			$$.NumPtrs = 1
		}
	|	'*' ptrtype	{
			$$ = $2
			$$.NumPtrs++
		}
	;

funcptrtype:
		'*' FUNC '(' VOID ')'			{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{}
		}
	|	'*' FUNC '(' VOID ')' type		{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Ret:		$6,
			}
		}
	|	'*' FUNC '(' arglist ')'			{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
			}
		}
	|	'*' FUNC '(' arglist ')' type		{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
				Ret:		$6,
			}
		}
	;

structdecl:
		STRUCT IDENT '{' fieldlist '}' ';'	{
			$$ = new(Struct)
			$$.Name = $2
			$$.Fields = $4
		}
	;

fieldlist:
		/* empty */		{
			$$ = nil
		}
	|	fieldlist field		{
			$$ = append($1, $2)
		}
	;

field:
		FIELD IDENT type ';'		{
			$$ = new(Field)
			$$.Name = $2
			$$.Type = $3
		}
	;

ifacedecl:
		INTERFACE IDENT '{' ifacememberlist '}' ';'		{
			$$ = $4
			$$.Name = $2
		}
	|	INTERFACE IDENT FROM IDENT '{' ifacememberlist '}' ';'	{
			$$ = $6
			$$.Name = $2
			$$.From = $4
		}
	;

ifacememberlist:
		/* empty */				{
			$$ = new(Interface)
		}
	|	ifacememberlist field		{
			$$.Fields = append($1.Fields, $2)
		}
	|	ifacememberlist funcdecl		{
			$$.Methods = append($1.Methods, $2)
		}
	;
