#!/usr/bin/env perl

use Test::More tests => 1;

BEGIN { use_ok('CPAN::MetaMuncher') }

diag( "Testing CPAN::MetaMuncher $CPAN::MetaMuncher::VERSION, Perl $], $^X" );
