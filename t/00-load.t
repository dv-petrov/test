#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'UrlTemplate::Checker' ) || print "Bail out!\n";
}

diag( "Testing UrlTemplate::Checker $UrlTemplate::Checker::VERSION, Perl $], $^X" );
