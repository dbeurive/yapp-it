# Introduction

This repository contains an example that shows how to use [Yapp](http://search.cpan.org/~fdesar/Parse-Yapp-1.05/lib/Parse/Yapp.pm) to parse a simple programming language that only defines function calls.

This simple programming language is composed of:
* Functions' calls. Functions' names start with the letter "F" (ex: F12, F450...).
* Variables. Variables' names start with the letter "V" (ex: V478, V658...).
* Strings. 
* Numerical values (ex: 12, 01 or 12.32).

For example:
```
F1(V1,
   F2(V2,
      V3,
      F3(V4,V5,F5(V10, V11)),
      V12,
      F3(V7,V8,V9, F6(F7(F5(V10, V11)))),
      F100("100 \"\euros\"\n", "euros", 100)
   ),
   F4()
);
```

# Content of the directory

* The language's grammar is defined within the file `procedural.yp`.
* The parser, generated from the grammar (after running the Makefile), is stored within the file `parsers/procdural.pm`. Please note that you have to run the Makefile in order to get this file. Type `make all` (or `make test`).
* The test script, that uses the generated parser, is the file `test.pl`.
* The directory `tests` contains a list of simple inputs texts that are used to test the parser.
* The directory `lib` contains some utlities.

# Description of the test script

This test script takes as input a "program" and convert it into [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation).

## Building the parser

Make sure that you have installed the module [`Parse::Yapp`](http://search.cpan.org/~fdesar/Parse-Yapp-1.05/lib/Parse/Yapp.pm).

	sudo cpan -i Parse::Yapp

	make all

## Running the test script

	make test

## Example 1

The "proram": `F1(V1, "ABC", 12, F2(), F3(F4(V1)))`

Is converted into:

	V1
	F4:1
	F3:1
	F2:0
	12
	"ABC"
	V1
	F1:5

You should read the (RPN) ouput like this:

Push V1 into the stack:

	0: V1

Execute F4 with 1 argument (taken from the stack), and push the result into the stack:

	0: Result of F4(V1)

Execute F3 with 1 argument (taken from the stack), and push the result into the stack:

	0: Result of F3(F4(V1))

Execute F2 with 0 argument (taken from the stack), and push the result into the stack:

	1: Result of F3(F4(V1))
	0: Result of F2()

Push 12 into the stack:

	2: Result of F3(F4(V1))
	1: Result of F2()
	0: 12

Push "ABC" into the stack:

	3: Result of F3(F4(V1))
	2: Result of F2()
	1: 12
	0: "ABC"

Push V1 into the stack:

	4: Result of F3(F4(V1))
	3: Result of F2()
	2: 12
	1: "ABC"
	0: V1

Execute F1 with 5 arguments (taken from the stack), and push the result into the stack:

	0: Result of F1(V1, "ABC", 12, F2(), F3(F4(V1)))

## Example 2

This is a longuer example:

The "proram": 

	F1(V1,
		F2(	V2,
			V3,
			F3(V4,V5,F5(V10, V11)),
			V12,
			F3(V7,V8,V9, F6(F7(F5(V10, V11)))),
			F100("100 \"\euros\"\n", "euros", 100)
		),
		F4()
	);

The result is:

	F4:0
	100
	"euros"
	"100 \"\euros\"\n"
	F100:3
	V11
	V10
	F5:2
	F7:1
	F6:1
	V9
	V8
	V7
	F3:4
	V12
	V11
	V10
	F5:2
	V5
	V4
	F3:3
	V3
	V2
	F2:6
	V1
	F1:3


# The grammar

The tokens (returned by the lexer)

	%whites                 = /\s+/
	%token FUNCTION         = /(F\d+)/
	%token VARIABLE         = /(V\d+)/
	%token STRING           = /((?<!\\)"((?<=\\)"|[^"])*(?<!\\)")/
	%token NUMERIC          = /(\d+(\.\d+)?)/
	%token PARAM_SEPARATOR  = /(\,)/
	%token CALL_SEPARATOR   = /\;/
	%token OPEN_SIGN        = /(\()/
	%token CLOSE_SIGN       = /(\))/

The grammar

	%start code

	%%

	param: VARIABLE
	     | STRING
	     | NUMERIC
	     | call
	     ;

	param_list: param
	          | param PARAM_SEPARATOR param_list
	          ;

	call: FUNCTION OPEN_SIGN param_list CLOSE_SIGN
	    | FUNCTION OPEN_SIGN CLOSE_SIGN
	    ;

	code:
	    | call 
	    | call CALL_SEPARATOR code 
	    ;



