MODULE phplint

(*
	PHPLint - Validator and documentator for PHP programs
	Copyright 2005 by icosaedro.it di Umberto Salsi <phplint@icosaedro.it>
	Info, download and updates: www.icosaedro.it/phplint/
*)

IMPORT m2, str, io
IMPORT Accounting
IMPORT Documentator
IMPORT Expressions
IMPORT FileName
IMPORT Globals
IMPORT ParseDocBlock
IMPORT Scanner
IMPORT Statements
IMPORT Types
IMPORT Version


VAR
	mark_consts, mark_vars, mark_funcs, mark_classes: INTEGER
	(* 
		Unused entities of the symbol tables will be checked between
		mark_xxx and count(xxx)-1.  For example, constants not used will be
		searched between consts[mark_consts] and consts[count(consts)-1]
		and so on for funcs[] and classes[]. Exception: vars[mark_vars]
		up to vars[vars_n-1].
	*)


FUNCTION MarkUsed()
BEGIN
	mark_consts = count(consts)
	mark_vars = vars_n
	mark_funcs = count(funcs)
	mark_classes = count(classes)
END


FUNCTION ReportUndeclaredAndUnused()
VAR
	i, j: INTEGER
	co: CONSTANT
	v: VARIABLE
	f: Function
	class: Class
	class_consts: ARRAY OF ClassConst
	properties: ARRAY OF Property
	methods: ARRAY OF Method
	c: ClassConst
	p: Property
	m: Method
	private_str: STRING
	pkg: Package
BEGIN
	IF NOT report_unused OR NOT print_notices THEN
		RETURN
	END

	FOR i=mark_consts TO count(consts)-1 DO
		co = consts[i]
		IF co[decl_in] = NIL THEN
			IF co[used] = 1 THEN
				Notice2(co[last_rhs], "undeclared constant `" + co[name]
				+ "' used only once: misspelled?")
			ELSE
				Notice2(co[last_rhs], "undeclared constant `" + co[name] + "'")
			END
		ELSIF co[used] = 0 THEN
			Notice2(co[decl_in], "unused constant `" + co[name] + "'")
		END
	END

	FOR i=mark_vars TO vars_n-1 DO
		v = vars[i]
		IF v[used] = 0 THEN
			Notice2(v[last_lhs], "unused global variable `$" + v[name] + "'")
		END
	END

	FOR i=mark_funcs TO count(funcs)-1 DO
		f = funcs[i]
		IF f[decl_in] = NIL THEN
			IF f[used] = 1 THEN
				Notice2(f[last_rhs], "undeclared function `" + f[name]
				+ "()' used only once: misspelled?")
			ELSE
				Notice2(f[last_rhs], "undeclared function `" + f[name] + "()'")
			END
		ELSIF f[used] = 0 THEN
			Notice2(f[decl_in], "unused function `" + f[name] + "()'")
		END
	END

	IF php_ver = php4 THEN
		private_str = "`/*. private .*/'"
	ELSE
		private_str = "`private'"
	END

	FOR i=mark_classes TO count(classes)-1 DO
		class = classes[i]
		IF class[used] = 0 THEN
			Notice2(class[decl_in], "unused class `" + class[name] + "'")
		ELSE
			class_consts = class[consts]
			FOR j=0 TO count(class_consts)-1 DO
				c = class_consts[j]
				IF c[used] = 0 THEN
					IF c[used_inside] THEN
						IF c[visibility] <> private THEN
							Notice2(c[decl_in], "the constant `" + c[name]
							+ "' used only inside its class, you should make it `/*. private .*/'")
						END
					ELSE
						Notice2(c[decl_in], "unused constant `"
						+ class[name] + "::" + c[name] + "'")
					END
				END
			END
			properties = class[properties]
			FOR j=0 TO count(properties)-1 DO
				p = properties[j]
				IF p[used] = 0 THEN
					IF p[used_inside] THEN
						IF p[visibility] <> private THEN
							Notice2(p[decl_in], "the property `$" + p[name]
							+ "' used only inside its class, you should make it " + private_str)
						END
					ELSE
						Notice2(p[decl_in], "unused property `"
						+ class[name] + "::$" + p[name] + "'")
					END
				END
			END
			methods = class[methods]
			FOR j=0 TO count(methods)-1 DO
				m = methods[j]
				IF m[used] = 0 THEN
					IF m[used_inside] THEN
						IF m[visibility] <> private THEN
							Notice2(m[decl_in], "the method " + mn(class, m)
							+ " is used only inside its class, you should make it as " + private_str)
						END
					ELSE
						Notice2(m[decl_in], "unused method " + mn(class, m))
					END
				END
			END
		END
	END

	FOR i=0 TO count(required_packages)-1 DO
		pkg = required_packages[i]
		IF (pkg <> curr_package) AND (pkg[used] = 0) THEN
			IF pkg[module] THEN
				Notice2(NIL, "unused module `" + Basename(pkg[fn]) + "'")
			ELSE
				Notice2(NIL, "unused package `" + fmt_fn(pkg[fn]) + "'")
			END
		END
	END
END


FUNCTION ReportRequiredPackages()
VAR i: INTEGER p: Package
BEGIN
	IF NOT print_notices THEN
		RETURN
	END
	FOR i=0 TO count(required_packages)-1 DO
		p = required_packages[i]
		IF p[used] > 0 THEN
			IF p[module] THEN
				Notice2(NIL, "required module `" + Basename(p[fn]) + "'")
			ELSE
				Notice2(NIL, "required package `" + fmt_fn(p[fn]) + "'")
			END
		END
	END
END


FUNCTION SplitPath(cwd: STRING, path: STRING): ARRAY OF STRING
VAR
	a: ARRAY OF STRING
	i: INTEGER
BEGIN
	a = split(path, ":")
	FOR i=0 TO count(a)-1 DO
		a[i] = Absolute(cwd, a[i])
	END
	RETURN a
END


FUNCTION Version()
BEGIN
	print(
	"PHPLint " + VERSION + "\n" +
	"Copyright 2013 by icosaedro.it di Umberto Salsi\n" +
	"This is free software; see the license for copying conditions.\n" +
	"More info: http://www.icosaedro.it/phplint/\n" +
	"\n")
END


FUNCTION Help()
BEGIN
	print(
"Usage:   phplint [OPTION] [FILE] ...\n" +
"A PHP language parser and validator with extended syntax.\n" +
"\nOPTIONS:\n\n" +
"Between round parentheses is the default value.\n" +
"  --version               print version\n" +
"  --help                  this help\n" +
"  --php-version V         set PHP version V to 4 or 5 (5)\n" +
"  --modules-path PATH     set the path[s] to modules dir[s] (\".\")\n" +
"  --[no-]is-module        parsed file is a module (FALSE)\n" +
"  --packages-path PATH    set the path[s] to packages dir[s] (\".\")\n" +
"  --[no-]recursive        follows require_once recursively (TRUE)\n" +
"  --[no-]print-file-name  print file name along error also for the file\n" +
"                          currently being parsed (TRUE)\n" +
"  --print-path absolute   print file names as absolute path (default)\n" +
"  --print-path relative   ...or relative to the current working directory\n" +
"  --print-path shortest   ...or the shortest of the two above\n" +
"  --[no-]ctrl-check       check control chars in strings (TRUE)\n" +
"  --[no-]ascii-ext-check  check extended ASCII chars in strings (TRUE)\n" +
"  --[no-]print-notices    print notices  (TRUE)\n" +
"  --[no-]print-warnings   print warnings (TRUE)\n" +
"  --[no-]print-errors     print errors   (TRUE)\n" +
"  --[no-]parse-phpdoc     parse phpDocumentor comments (TRUE)\n" +
"  --[no-]print-context    print error context (FALSE)\n" +
"  --[no-]print-source     print source (FALSE)\n" +
"  --[no-]print-line-numbers   print the line numbers along the source (TRUE)\n" +
"  --[no-]report-unused    report unused IDs (TRUE)\n" +
#"  --mark-used            mark all the IDs as used\n" +
"  --[no-]fails-on-warning exit status 1 also for warnings (FALSE)\n" +
"  --tab-size N            set tabulation to N spaces (8)\n" +
"  --[no-]overall          displays total no. of errors and warnings (TRUE)\n" +
"  --doc-help              help about the PHPLint Documentator\n" +
"  --debug                 print source with debugging info\n" +
"Exit status 0 if no errors, 1 on errors; if the --fails-on-warning option is\n" +
"set, exit status 1 also for warnings.\n" +
"\nReport bugs to phplint@icosaedro.it (but read README before submit).\n" +
"Info and updates: www.icosaedro.it/phplint/\n" +
"\n")
END


VAR
	args: ARRAY OF STRING
	arg: STRING
	i: INTEGER
	do_report: BOOLEAN
	is_module: BOOLEAN
	fails_on_warning: BOOLEAN
	overall: BOOLEAN

BEGIN
	(* Set defaults options: *)
	php_ver = php5
	recursive_parsing = TRUE
	print_errors = TRUE
	print_warnings = TRUE
	print_notices = TRUE
	print_context = FALSE
	print_source = FALSE
	print_line_numbers = TRUE
	print_file_name = TRUE
	print_path_fmt = absolute_path
	TRY cwd = io.GetCWD() END
	parse_phpdoc = TRUE
	tab_size = 8
	ctrl_check = TRUE
	ascii_ext_check = TRUE
	report_unused = TRUE
	modules_abs_path = NIL
	packages_abs_path = NIL
	is_module = FALSE
	fails_on_warning = FALSE
	overall = TRUE

	Documentator.Init()

	args = get_args()
	FOR i=1 TO count(args)-1 DO
		arg = args[i]
		IF    arg = "--help"             THEN Help()
		ELSIF arg = "--version"          THEN Version()
		ELSIF arg = "--debug"            THEN DEBUG = TRUE
		ELSIF arg = "--recursive"        THEN recursive_parsing = TRUE
		ELSIF arg = "--no-recursive"     THEN recursive_parsing = FALSE
		ELSIF arg = "--print-file-name"  THEN print_file_name = TRUE
		ELSIF arg = "--no-print-file-name" THEN print_file_name = FALSE
		ELSIF arg = "--ctrl-check"       THEN ctrl_check = TRUE
		ELSIF arg = "--no-ctrl-check"    THEN ctrl_check = FALSE
		ELSIF arg = "--ascii-ext-check"  THEN ascii_ext_check = TRUE
		ELSIF arg = "--no-ascii-ext-check" THEN ascii_ext_check = FALSE
		ELSIF arg = "--print-notices"    THEN print_notices = TRUE
		ELSIF arg = "--no-print-notices" THEN print_notices = FALSE
		ELSIF arg = "--print-warnings"   THEN print_warnings = TRUE
		ELSIF arg = "--no-print-warnings" THEN print_warnings = FALSE
		ELSIF arg = "--print-errors"     THEN print_errors = TRUE
		ELSIF arg = "--no-print-errors"  THEN print_errors = FALSE
		ELSIF arg = "--print-context"    THEN print_context = TRUE
		ELSIF arg = "--no-print-context" THEN print_context = FALSE
		ELSIF arg = "--print-source"     THEN print_source = TRUE
		ELSIF arg = "--no-print-source"  THEN print_source = FALSE
		ELSIF arg = "--print-line-numbers"  THEN print_line_numbers = TRUE
		ELSIF arg = "--no-print-line-numbers" THEN print_line_numbers = FALSE
		ELSIF arg = "--parse-phpdoc"     THEN parse_phpdoc = TRUE
		ELSIF arg = "--no-parse-phpdoc"  THEN parse_phpdoc = FALSE
		ELSIF arg = "--mark-used"        THEN MarkUsed()
		ELSIF arg = "--report-unused"    THEN report_unused = TRUE
		ELSIF arg = "--no-report-unused" THEN report_unused = FALSE
		ELSIF arg = "--is-module"        THEN is_module = TRUE
		ELSIF arg = "--no-is-module"     THEN is_module = FALSE
		ELSIF arg = "--fails-on-warning" THEN fails_on_warning = TRUE
		ELSIF arg = "--no-fails-on-warning" THEN fails_on_warning = FALSE
		ELSIF arg = "--overall"          THEN overall = TRUE
		ELSIF arg = "--no-overall"       THEN overall = FALSE
		ELSIF arg = "--print-path"       THEN
			inc(i, 1)
			IF i >= count(args) THEN
				error("phplint: missing argument for --print-path\n")
				exit(1)
			END
			IF args[i] = "absolute" THEN
				print_path_fmt = absolute_path
			ELSIF args[i] = "relative" THEN
				print_path_fmt = relative_path
			ELSIF args[i] = "shortest" THEN
				print_path_fmt = shortest_path
			ELSE
				error("phplint: invalid argument for --print-path\n")
				exit(1)
			END
		ELSIF arg = "--php-version" THEN
			inc(i, 1)
			IF i >= count(args) THEN
				error("phplint: missing argument for --php-version\n")
				exit(1)
			END
			IF args[i] = "4" THEN
				php_ver = php4
			ELSIF args[i] = "5" THEN
				php_ver = php5
			ELSE
				error("phplint: invalid PHP version - must be 4 or 5\n")
				exit(1)
			END
		ELSIF arg = "--modules-path" THEN
			inc(i, 1)
			IF i >= count(args) THEN
				error("phplint: missing argument for --modules-path\n")
				exit(1)
			END
			modules_abs_path = SplitPath(cwd, args[i])
		ELSIF arg = "--packages-path" THEN
			inc(i, 1)
			IF i >= count(args) THEN
				error("phplint: missing argument for --packages-path\n")
				exit(1)
			END
			packages_abs_path = SplitPath(cwd, args[i])
		ELSIF arg = "--tab-size" THEN
			inc(i, 1)
			IF i >= count(args) THEN
				error("phplint: missing argument for --tab-size\n")
				exit(1)
			END
			tab_size = stoi(args[i])
		ELSIF (length(arg) >= 5) AND (arg[0,5] = "--doc") THEN
			i = Documentator.ParseParameter(i, args)
		ELSIF (length(arg) > 0) AND (arg[0] = "-") THEN
			error("phplint: unknown option `" + arg + "'\n")
			exit(1)
		ELSE
			arg = Absolute(cwd, arg)

			curr_package = ParsePackage(arg, is_module)

			IF curr_package <> NIL THEN
				Documentator.Generate(
					php_ver,
					arg,
					curr_package[descr],
					required_packages,
					include_path,
					consts, vars, funcs, classes)
			END
			do_report = TRUE
		END
	END

	IF do_report THEN
		CleanCurrentScope()

		IF print_notices THEN
			ReportUndeclaredAndUnused()
			ReportRequiredPackages()
		END

		IF overall THEN
			print("Overall test results: " + itos(error_counter) + " errors, "
			+ itos(warning_counter) + " warnings.\n")
		END

		IF scope <> 0 THEN
			error("phplint: INTERNAL ERROR: scope=" + scope + "\n")
			exit(1)
		END

		IF (error_counter = 0) AND (NOT fails_on_warning OR (warning_counter = 0)) THEN
			exit(0)
		ELSE
			exit(1)
		END
	END

END

(* THE END *)
