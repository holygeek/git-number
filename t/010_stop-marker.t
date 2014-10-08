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
  $testname = "stop mark"; #{:
  `
  cd $workdir &&
  git init &&
  echo a > one.txt &&
  echo b > two.txt
  `;
  $expected = 'Nothing new to pack.';
  `cd $workdir; $srcdir/git-number --color=never`;
  $got = `cd $workdir; $srcdir/git-number -U++ ++ repack --depth 1`;
  chomp $got;
  is($got, $expected, $testname); #:}
}

done_testing();
