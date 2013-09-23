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
$expected = qr/(# )?On branch master\n#?\n(# )?Initial commit\n#?\nnothing to commit \(create\/copy files and use "git add" to track\)/;
like($got, $expected, $testname); #:}

$testname = 'git-id - untracked files'; #{:
`
cd $workdir &&
echo a > a &&
echo b > b
`;
$got = `cd $workdir; $srcdir/git-id --color=never 2>&1`;
$expected = qr/Untracked files:.*\n#?1\ta\n#?2\tb\n\n?nothing added to commit but untracked files present \(use "git add" to track\)/ms;
like($got, $expected, $testname); #:}

$testname = 'git-id - added and untracked files'; #{:
`
cd $workdir &&
git add a
`;
$got = `cd $workdir; $srcdir/git-id --color=never 2>&1`;
$expected = qr/Changes to be committed:.*#?1\tnew file:   a\n.*Untracked files:.*#?2\tb\n/ms;
like($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
