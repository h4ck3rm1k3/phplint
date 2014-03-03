<?php
# Accessing global classes, functions and constants from within a namespace
/*. require_module 'standard'; .*/
namespace Foo;

/*. string .*/ function strlen(/*. string .*/ $s) { return $s; }
const INI_ALL = "my new constant";
class Exception {}

$a = \strlen('hi'); // calls global function strlen
$b = \INI_ALL; // accesses global constant INI_ALL
$c = new \Exception('error'); // instantiates global class Exception

$d = strlen('xx');
$e = INI_ALL;
$f = new Exception();
?>
