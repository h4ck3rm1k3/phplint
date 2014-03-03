all: phplint

clean:
	rm -f Version.* *.c phplint phplint.exe

Version.def: ../VERSION
	echo "DEFINITION MODULE Version" > Version.def
	echo "CONST VERSION = \""$(shell cat ../VERSION)"\"" >> Version.def
	echo END >> Version.def

Version.imp:
	echo "IMPLEMENTATION MODULE Version   END" > Version.imp

Version.c: Version.def Version.imp
	m2 Version.imp

Accounting.c: Globals.c Scanner.c Search.c MagicConstants.c Accounting.def Accounting.imp
	m2 Accounting.imp

Types.c: Types.def Types.imp
	m2 Types.imp

Tokens.imp: Scanner.def ../utils/make-tokens-module
	../utils/make-tokens-module > Tokens.imp

Tokens.c: Tokens.imp
	m2 Tokens.imp

Globals.c: Types.c Globals.def Globals.imp
	m2 Globals.imp

FileName.c: FileName.def FileName.imp
	m2 FileName.imp

Scanner.c: Tokens.c FileName.c Globals.c Scanner.def Scanner.imp
	m2 Scanner.imp

Operators.c: Types.c Globals.c Accounting.c Operators.def Operators.imp
	m2 Operators.imp

Classes.c: Types.c Scanner.c Search.c Globals.c Classes.def Classes.imp
	m2 Classes.imp

Expressions.c: Types.c Errors.c Exceptions.c Accounting.c Globals.c Scanner.c Search.c Classes.c Operators.c Typecast.c Expressions.def Expressions.imp
	m2 Expressions.imp

Documentator.c: Classes.c Errors.c Scanner.c Types.c FileName.c Documentator.def Documentator.imp
	m2 Documentator.imp

ParseDocBlock.c: Types.c Globals.c Classes.c Search.c Scanner.c Expressions.c \
	ParseDocBlock.def ParseDocBlock.imp
	m2 ParseDocBlock.imp

Search.c: Namespace.c Types.c Scanner.c Globals.c Search.def Search.imp
	m2 Search.imp

Proto.c: Accounting.c Scanner.c Exceptions.c Expressions.c Globals.c Namespace.c Search.c Proto.def Proto.imp
	m2 Proto.imp

Statements.c: Accounting.c Classes.c Errors.c Exceptions.c FileName.c Types.c Scanner.c Globals.c Namespace.c Expressions.c Search.c ParseDocBlock.c Proto.c Documentator.c Template.c Statements.def Statements.imp
	m2 Statements.imp

Errors.c: Classes.c Globals.c Exceptions.c Scanner.c Search.c Errors.def Errors.imp
	m2 Errors.imp

Exceptions.c: Classes.c Scanner.c Search.c Globals.c Exceptions.def Exceptions.imp
	m2 Exceptions.imp

Namespace.c: Globals.c Scanner.c Namespace.def Namespace.imp
	m2 Namespace.imp

MagicConstants.c: Globals.c Scanner.c FileName.c MagicConstants.def MagicConstants.imp
	m2 MagicConstants.imp

Typecast.c: Types.c Scanner.c Search.c Globals.c Classes.c Typecast.def Typecast.imp
	m2 Typecast.imp

Template.c: Types.c Accounting.c Globals.c Namespace.c Scanner.c Search.c Classes.c Template.def Template.imp
	m2 Template.imp

phplint: Accounting.c Documentator.c Expressions.c FileName.c Globals.c \
	Scanner.c Statements.c Types.c Version.c phplint.mod
	m2 -s phplint.mod
	@# To keep GDB symbols, comment-out the following lines:
	test -f phplint && strip phplint || true
	test -f phplint.exe && strip phplint.exe || true
