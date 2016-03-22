#!/usr/bin/env perl
# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
use strict;
use warnings;
use Test::More tests => 2;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

my $got;
my $expected;
my $testname;

# Start from a clean slate
Scaffold::init();

$testname = "git number with custom status color"; #{:
`
cd $workdir &&
echo 'one' > one.txt &&
    git init &&
    git add . &&
    git config color.status.header 'normal dim'
`;
$got = `cd $workdir; $srcdir/git-number --color=always`;
$got =~ s/\e\[\d*m//gs;
$expected = qr/1\tnew file:   one.txt\n/ms;
like($got, $expected, $testname); #:}

$testname = "git number with untracked in bold red"; #{:
`
cd $workdir &&
echo 'untracked1' > untracked1.txt &&
    git config color.status.untracked 'red bold' &&
    $srcdir/git-number --color=always
`;
$got = `cd $workdir; $srcdir/git-list 2`;
$expected = "untracked1.txt\n";
eq_or_diff($got, $expected, $testname); #:}
