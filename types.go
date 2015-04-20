// 15 april 2015
package pgidl

type IDL []*Package

type Package struct {
	Name		string
	Funcs		[]*Func
	Structs		[]*Struct
	Interfaces		[]*Interface
	Raws		[]string
	Enums		[]*Enum
	Order		[]*Order
}

type Order struct {
	Which		Which
	Index		int
}

type Which uint
const (
	Funcs Which = iota
	Structs
	Interfaces
	Raws
	Enums
)

type Func struct {
	Name	string
	Args		[]*Arg
	Ret		*Type
}

type Arg struct {
	Name	string
	Type		*Type
}

type Type struct {
	IsFuncPtr		bool
	Name		string
	NumPtrs		uint
	FuncType		*Func
}

type Struct struct {
	Name	string
	Fields	[]*Field
}

type Field struct {
	Name	string
	Type		*Type
}

type Interface struct {
	Name	string
	From	string
	Fields	[]*Field
	Methods	[]*Func
}

type Enum struct {
	Name		string
	Members		[]string
}
