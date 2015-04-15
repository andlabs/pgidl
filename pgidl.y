// 15 april 2015
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
			$$.Decls = $4
		}
	;

decls:
		/* empty */
	|	decls funcdecl				{
			$$ = append($$, $2)
		}
	|	decls structdecl			{
			$$ = append($$, $2)
		}
	|	decls ifacedecl				{
			$$ = append($$, $2)
		}
	;

funcdecl:
		FUNC IDENT '(' VOID ')' type ';'		{
			$$.Name = $2
			$$.Ret = $6
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

structdecl:
		STRUCT ident '{' fieldlist '}' ';'	{
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
