// 15 april 2015
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
%token PACKAGE FUNC STRUCT INTERFACE FIELD
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
		/* empty */
	|	pgidl package		{
			$$ = append($$, $2)
		}
	;

package:
		PACKAGE IDENT '{' decls '}'	{
			$$.Name = $2
			$$.Funcs = $4.Funcs
			$$.Structs = $4.Structs
			$$.Interfaces = $4.Interfaces
			$$.Order = $4.Order
		}
	;

decls:
		/* empty */
	|	decls funcdecl				{
			$$.Funcs = append($$.Funcs, $2)
			$$.Order = append($$.Order, &Order{
				Which:	0,
				Index:	len($$.Funcs) - 1,
			})
		}
	|	decls structdecl			{
			$$.Structs = append($$.Structs, $2)
			$$.Order = append($$.Order, &Order{
				Which:	1,
				Index:	len($$.Structs) - 1,
			})
		}
	|	decls ifacedecl				{
			$$.Interfaces = append($$.Interfaces, $2)
			$$.Order = append($$.Order, &Order{
				Which:	2,
				Index:	len($$.Interfaces) - 1,
			})
		}
	;

funcdecl:
		FUNC IDENT '(' VOID ')' ';'			{
			$$.Name = $2
		}
	|	FUNC IDENT '(' VOID ')' type ';'		{
			$$.Name = $2
			$$.Ret = $6
		}
	|	FUNC IDENT '(' arglist ')' ';'			{
			$$.Name = $2
			$$.Args = $4
		}
	|	FUNC IDENT '(' arglist ')' type ';'		{
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
				}
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
			$$.Name = 1
			$$.NumPtrs = 1
		}
	|	'*' ptrtype	{
			$$.NumPtrs++
		}
	;

funcptrtype:
		'*' FUNC '(' VOID ')'			{
			$$.IsFuncPtr = true
			$$.FuncType = &Func{}
		}
	|	'*' FUNC '(' VOID ')' type		{
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Ret:		$6,
			}
		}
	|	'*' FUNC '(' arglist ')'			{
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
			}
		}
	|	'*' FUNC '(' arglist ')' type		{
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
				Ret:		$6,
			}
		}
	;

structdecl:
		STRUCT IDENT '{' fieldlist '}' ';'	{
			$$.Name = $2
			$$.Fields = $4
		}
	;

fieldlist:
		/* empty */
	|	fieldlist field		{
			$$ = append($$, $2)
		}
	;

field:
		FIELD IDENT type ';'		{
			$$.Name = $2
			$$.Type = $3
		}
	;

ifacedecl:
		INTERFACE IDENT '{' ifacememberlist '}' ';'		{
			$$.Name = $2
			$$.Fields = $4.Fields
			$$.Methods = $4.Methods
		}
	|	INTERFACE IDENT FROM IDENT '{' ifacememberlist '}' ';'	{
			$$.Name = $2
			$$.From = $4
			$$.Fields = $6.Fields
			$$.Methods = $6.Methods
		}
	;

ifacememberlist:
		/* empty */
	|	ifacememberlist field		{
			$$.Fields = append($$.Fields, $2)
		}
	|	ifacememberlist funcdecl		{
			$$.Methods = append($$.Methods, $2)
		}
	;
