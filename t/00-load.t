#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Business::ID::SIM' );
}

diag( "Testing Business::ID::SIM $Business::ID::SIM::VERSION, Perl $], $^X" );
