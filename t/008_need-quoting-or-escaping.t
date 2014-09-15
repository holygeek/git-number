#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib 't/lib';
use Scaffold;
use QuoteTest;


Scaffold::init();

my @filenames = grep /^[^#]/,  <DATA>;

my ($got, $expected) = QuoteTest::test_quoting("'", @filenames);
eq_or_diff($got, $expected, "File with shell-unsafe characters must be quoted");
#:}

done_testing();

__DATA__
#double"quoted".txt   # git status already quotes the quotes for us
file with spaces.txt
(parenthesis).txt
[square]brackets.txt
backtick`.txt
dollar$ign.txt
background&.txt
