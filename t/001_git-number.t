#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 10;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

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
$expected = qr/#?1	one.txt\n#?2	two.txt/;
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected, $testname); #:}

$testname = "Added first file"; #{:
`
cd $workdir &&
git add one.txt
`;
$expected = qr/\n#?1\tnew file:   one.txt.*(# )?Untracked files:.*\n#?2\ttwo.txt/ms;


$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected, $testname); #:}

$testname = "Added second file"; #{:
`
cd $workdir &&
git add two.txt
`;
$expected = qr/Changes to be committed:.*\n#?1\tnew file:   one.txt\n#?2\tnew file:   two.txt/ms;
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected, $testname); #:}

$testname = "Status with deleted file"; #{:
`
cd $workdir &&
rm -f two.txt
`;
$expected = qr/Changes to be committed:.*\n#?1\tnew file:   one.txt\n#?2\tnew file:   two.txt\n.*Changes not staged for commit:.*\n#?3\tdeleted:    two.txt/ms;
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected, $testname); #:}

$testname = "Status after commit and reset --hard"; #{:
`
cd $workdir &&
git commit -m 'initial commit' &&
git reset --hard
`;

# This is the price you pay when scripting against porcelain:
my $expected_regex = qr/(# )?On branch master
nothing to commit,? \(?working directory clean\)?
/;
# In git 1.7, it was    "nothing to commit (working directory clean)"
# In git 1.8, it became "nothing to commit, working directory clean"
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected_regex, $testname); #:}

$testname = "git-number status foo.txt"; #{:
`
cd $workdir &&
echo foo > foo.txt
`;
$expected = qr/Untracked files:.*\n#?1\tfoo.txt\n.*nothing added to commit but untracked files present \(use "git add" to track\)/ms;
$got = `cd $workdir; $srcdir/git-number --color=never`;
like($got, $expected, $testname); #:}

$testname = "git-number status 1"; #{:
$expected = qr/Untracked files:.*\n#?\tfoo.txt\n.*nothing added to commit but untracked files present \(use "git add" to track\)/ms;
$got = `cd $workdir; $srcdir/git-number --color=never status 1`;
like($got, $expected, $testname); #:}

$testname = "git-number -c ls 1"; #{:
`cd $workdir; $srcdir/git-number`;
$expected = <<EOT;
foo.txt
EOT
$got = `cd $workdir; $srcdir/git-number -c ls 1`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-number -c ...' in different dir than 'git-number' was invoked in"; #{:
`cd $workdir; echo "Needle" > needle.txt; mkdir foo; cd foo; $srcdir/git-number`;
$expected = <<EOT;
Needle
EOT
$got = `cd $workdir; $srcdir/git-number -c cat 2`;
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-number -c echo' must run echo"; #{:
$expected = <<EOT;

EOT
$got=`git-number -c echo`;
eq_or_diff($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
