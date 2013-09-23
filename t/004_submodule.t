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

$testname = "Modified a file in submodule"; #{:
`
cd $workdir &&
mkdir a b &&
cd a &&
  git init &&
  echo 'Super project' > a.txt &&
  git add . && git commit -m 'initial commit a' &&
cd ../b &&
  git init &&
  echo 'Sub project' > b.txt &&
  git add . && git commit -m 'initial commit b' &&
cd ../a &&
  git submodule add ../b b &&
  git commit -m 'Added ../b as submodule in b' &&
cd b &&
  echo 'Added new line' >> b.txt
`;

$expected = qr/#?1\tmodified:   b \(modified content\)\n.*no changes added to commit \(use "git add" and\/or "git commit -a"\)/ms;

$got = `cd $workdir/a; $srcdir/git-number --color=never`;
like($got, $expected, $testname);

$testname = "Get name of modified submodule using git-list";
$expected = 'b';
$got = `cd $workdir/a; $srcdir/git-list 1`;
chomp $got;
eq_or_diff($got, $expected, $testname);
#}
