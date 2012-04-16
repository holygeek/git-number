use strict;
use warnings;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

use Test::More tests => 10;

my $got;
my $expected;
my $testname;

Scaffold::init();

$testname = "git-list before git-number"; #{:
`
cd $workdir &&
git init &&
echo a > one.txt &&
echo b > two.txt
`;
$got = `cd $workdir; $srcdir/git-list 2>&1`;
$expected = <<EOT;
Please run git-number first
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-list 1"; #{:
`
cd $workdir &&
$srcdir/git-number
`;
$got = `cd $workdir; $srcdir/git-list 1`;
$expected = <<EOT;
one.txt
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-list foo' must output foo"; #{:
$got = `cd $workdir; $srcdir/git-list foo`;
$expected = <<EOT;
foo
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-list 1 foo' must output one.txt and foo"; #{:
$got = `cd $workdir; $srcdir/git-list 1 foo`;
$expected = <<EOT;
one.txt
foo
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "'git-list 1 foo 100' must output one.txt, foo and 100"; #{:
$got = `cd $workdir; $srcdir/git-list 1 foo 100`;
$expected = <<EOT;
one.txt
foo
100
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-list 2"; #{:
$got = `cd $workdir; $srcdir/git-list 2`;
$expected = <<EOT;
two.txt
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-list 1 2"; #{:
$got = `cd $workdir; $srcdir/git-list 1 2`;
$expected = <<EOT;
one.txt
two.txt
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-list 1 2 1 2"; #{:
$got = `cd $workdir; $srcdir/git-list 1 2 1 2`;
$expected = <<EOT;
one.txt
two.txt
one.txt
two.txt
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "pass args that look like options intact";
$got = `cd $workdir; $srcdir/git-list -a -b -c`;
$expected = <<EOT;
-a
-b
-c
EOT
eq_or_diff($got, $expected, $testname); #:}

$testname = "git-list"; #{:
$got = `cd $workdir; $srcdir/git-list`;
$expected = <<EOT;
one.txt
two.txt
EOT
eq_or_diff($got, $expected, $testname); #:}

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
