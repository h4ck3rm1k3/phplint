<?php
/*. require_module 'spl'; .*/
namespace A\B\C;
class Exception extends \Exception {}

$a = new Exception('hi'); // $a is an object of class A\B\C\Exception
$b = new \Exception('hi'); // $b is an object of class Exception

$c = new ArrayObject; // fatal error, class A\B\C\ArrayObject not found
$c = new \ArrayObject; // fatal error, class A\B\C\ArrayObject not found


const E_ERROR = 45;

/*. int .*/ function strlen(/*. int .*/ $i)
{
    return \strlen("" . $i) - 1;
}

echo E_ERROR, "\n"; // prints "45"
echo INI_ALL, "\n"; // prints "7" - falls back to global INI_ALL

echo strlen(123), "\n"; // prints "2"
if (is_array('hi')) { // prints "is not array"
    echo "is array\n";
} else {
    echo "is not array\n";
}

?>
