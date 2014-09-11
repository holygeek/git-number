#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib 't/lib';
use Scaffold;
use QuoteTest;


Scaffold::init();

my @filenames = grep /^[^#]/,  <DATA>;

my ($got, $expected) = QuoteTest::test_quoting('"', @filenames);
eq_or_diff($got, $expected, "File with single-quote characters must be quoted");
#:}

done_testing();

__DATA__
single'quoted'.txt
