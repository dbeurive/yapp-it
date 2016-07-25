package Constant;
use strict;
use warnings;
use base 'Exporter';

use constant TYPE_VARIABLE => 1;
use constant TYPE_STRING   => 2;
use constant TYPE_NUMERIC  => 3;
use constant TYPE_FUNCTION => 4;

our @EXPORT = qw(TYPE_VARIABLE TYPE_STRING TYPE_NUMERIC TYPE_FUNCTION);

1;