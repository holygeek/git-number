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
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   one.txt
#
EOT
eq_or_diff($got, $expected, $testname); #:}
