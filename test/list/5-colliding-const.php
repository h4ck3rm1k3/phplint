<?php

# interface: colliding inherited constants

interface IF1
{
	const c = 1;
}

interface IF2
{
	const c = 1;
}

interface IF3 extends IF1, IF2
{ }


?>
