#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use Test::More qw/no_plan/;
use File::Path qw/make_path remove_tree/;
use File::Slurp qw/slurp/;

BEGIN {
	if (! eval q{use Test::Differences; 1 }) {
		*eq_or_diff = \&is_deeply;
	}
}

my $srcdir = "$FindBin::Bin/../";

my $workdir = "$FindBin::Bin/testoutput";

remove_tree($workdir);
make_path($workdir);

$ENV{PATH} = "$srcdir:" . $ENV{PATH};

my $got;
my $expected;
my $testname;

$testname = "Two untracked files"; #{:
`
cd $workdir &&
git init &&
echo a > one.txt &&
echo b > two.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#1	one.txt
#2	two.txt
nothing added to commit but untracked files present (use "git add" to track)
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Added first file"; #{:
`
cd $workdir &&
git add one.txt
`;
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
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#2	two.txt
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "Added second file"; #{:
`
cd $workdir &&
git add two.txt
`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   one.txt
#2	new file:   two.txt
#
EOT
$got = `cd $workdir; $srcdir/git-number --color=never`;
eq_or_diff($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
