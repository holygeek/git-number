#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

my $got;
my $expected;
my $testname;

Scaffold::init();

$testname = 'git-id on virgin git init'; #{:
`
cd $workdir &&
git init
`;
$got = `cd $workdir; $srcdir/git-id 2>&1`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
nothing to commit (create/copy files and use "git add" to track)
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = 'git-id - untracked files'; #{:
`
cd $workdir &&
echo a > a &&
echo b > b
`;
$got = `cd $workdir; $srcdir/git-id --color=never 2>&1`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#1	a
#2	b
nothing added to commit but untracked files present (use "git add" to track)
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = 'git-id - added and untracked files'; #{:
`
cd $workdir &&
git add a
`;
$got = `cd $workdir; $srcdir/git-id --color=never 2>&1`;
$expected = <<EOT;
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#1	new file:   a
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#2	b
EOT
eq_or_diff($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
