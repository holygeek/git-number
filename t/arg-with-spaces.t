#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

my $got;
my $expected;
my $testname;

Scaffold::init();

{
  $testname = "argument with spaces"; #{:
  `
  cd $workdir &&
  mkdir tmp &&
  cd tmp &&
  git init &&
  echo a > test.txt &&
  git add test.txt &&
  $srcdir/git-number commit -m "Initial commit"
  `;
  $expected = "Initial commit";
  chomp($got = `cd $workdir/tmp && git log -1 --format=%s`);
  eq_or_diff($got, $expected, $testname); #:}
}

done_testing();
