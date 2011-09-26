use strict;
use warnings;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

use Test::More tests => 3;

my $got;
my $expected;
my $testname;

Scaffold::init();

$testname = "git-list 1"; #{:
`
cd $workdir &&
git init &&
echo a > one.txt &&
echo b > two.txt &&
$srcdir/git-number
`;
$got = `cd $workdir; $srcdir/git-list 1`;
$expected = <<EOT;
one.txt
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

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
