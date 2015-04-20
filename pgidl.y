// 15 april 2015
%{
package pgidl
%}
%start pgidl
%union {
	String	string
	Package	*Package
	Func		*Func
	Args		[]*Arg
	Type		*Type
	Struct	*Struct
	Fields	[]*Field
	Field		*Field
	Iface		*Interface
	Enum	*Enum
}
%token <String> tokIDENT tokSTRING
%token tokPACKAGE tokFUNC tokSTRUCT tokINTERFACE tokVOID tokFIELD tokFROM tokRAW tokCONST tokENUM
%type <Package> package decls
%type <Func> funcdecl
%type <Args> arglist
%type <Type> type ptrtype funcptrtype
%type <Struct> structdecl
%type <Fields> fieldlist
%type <Field> field
%type <Iface> ifacedecl ifacememberlist
%type <String> raw
%type <Enum> enum enumlist
%%
pgidl:
		/* empty */		{
			yylex.(*lexer).idl = nil
		}
	|	pgidl package		{
			yylex.(*lexer).idl = append(yylex.(*lexer).idl, $2)
		}
	;

package:
		tokPACKAGE tokIDENT '{' decls '}' ';'	{
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
				Which:	Funcs,
				Index:	len($$.Funcs) - 1,
			})
		}
	|	decls structdecl			{
			$$ = $1
			$$.Structs = append($$.Structs, $2)
			$$.Order = append($$.Order, &Order{
				Which:	Structs,
				Index:	len($$.Structs) - 1,
			})
		}
	|	decls ifacedecl				{
			$$ = $1
			$$.Interfaces = append($$.Interfaces, $2)
			$$.Order = append($$.Order, &Order{
				Which:	Interfaces,
				Index:	len($$.Interfaces) - 1,
			})
		}
	|	decls raw					{
			$$ = $1
			$$.Raws = append($$.Raws, $2)
			$$.Order = append($$.Order, &Order{
				Which:	Raws,
				Index:	len($$.Raws) - 1,
			})
		}
	|	decls enum				{
			$$ = $1
			$$.Enums = append($$.Enums, $2)
			$$.Order = append($$.Order, &Order{
				Which:	Enums,
				Index:	len($$.Enums) - 1,
			})
		}
	;

funcdecl:
		tokFUNC tokIDENT '(' tokVOID ')' ';'			{
			$$ = new(Func)
			$$.Name = $2
		}
	|	tokFUNC tokIDENT '(' tokVOID ')' type ';'		{
			$$ = new(Func)
			$$.Name = $2
			$$.Ret = $6
		}
	|	tokFUNC tokIDENT '(' arglist ')' ';'			{
			$$ = new(Func)
			$$.Name = $2
			$$.Args = $4
		}
	|	tokFUNC tokIDENT '(' arglist ')' type ';'		{
			$$ = new(Func)
			$$.Name = $2
			$$.Args = $4
			$$.Ret = $6
		}
	;

arglist:
		tokIDENT type	{
			$$ = []*Arg{
				&Arg{
					Name:	$1,
					Type:	$2,
				},
			}
		}
	|	arglist ',' tokIDENT type		{
			$$ = append($1, &Arg{
				Name:	$3,
				Type:	$4,
			})
		}
	;

type:
		tokIDENT		{
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
		'*' tokIDENT			{
			$$ = new(Type)
			$$.Name = $2
			$$.NumPtrs = 1
		}
	|	'*' tokVOID			{
			$$ = new(Type)
			$$.Name = "void"
			$$.NumPtrs = 1
		}
	|	'*' tokCONST tokIDENT	{
			$$ = new(Type)
			$$.Name = "const " + $3
			$$.NumPtrs = 1
		}
	|	'*' ptrtype				{
			$$ = $2
			$$.NumPtrs++
		}
	;

funcptrtype:
		'*' tokFUNC '(' tokVOID ')'			{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{}
		}
	|	'*' tokFUNC '(' tokVOID ')' type		{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Ret:		$6,
			}
		}
	|	'*' tokFUNC '(' arglist ')'			{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
			}
		}
	|	'*' tokFUNC '(' arglist ')' type		{
			$$ = new(Type)
			$$.IsFuncPtr = true
			$$.FuncType = &Func{
				Args:	$4,
				Ret:		$6,
			}
		}
	;

structdecl:
		tokSTRUCT tokIDENT '{' fieldlist '}' ';'	{
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
		tokFIELD tokIDENT type ';'		{
			$$ = new(Field)
			$$.Name = $2
			$$.Type = $3
		}
	;

ifacedecl:
		tokINTERFACE tokIDENT '{' ifacememberlist '}' ';'		{
			$$ = $4
			$$.Name = $2
		}
	|	tokINTERFACE tokIDENT tokFROM tokIDENT '{' ifacememberlist '}' ';'	{
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

raw:
		tokRAW tokSTRING ';'	{
			$$ = $2
		}
	;

enum:
		tokENUM tokIDENT '{' enumlist optionalComma '}' ';'		{
			$$ = $4
			$$.Name = $2
		}
	;

enumlist:
		tokIDENT				{
			$$ = &Enum{}
			$$.Members = append($$.Members, $1)
		}
	|	enumlist ',' tokIDENT	{
			$$ = $1
			$$.Members = append($$.Members, $3)
		}
	;

optionalComma:
		/* empty */
	|	','
	;
