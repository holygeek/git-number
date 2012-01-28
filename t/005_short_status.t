#!/usr/bin/env perl
# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
use strict;
use warnings;
use Test::More tests => 1;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

my $got;
my $expected;
my $testname;

# Start from a clean slate
Scaffold::init();

$testname = "Show status in short format"; #{:
`
cd $workdir &&
echo 'one' > one.txt &&
    git init &&
    git add .
`;
$got = `cd $workdir; $srcdir/git-number --color=never -s`;
$expected = <<EOT;
1 A  one.txt
EOT
eq_or_diff($got, $expected, $testname); #:}
