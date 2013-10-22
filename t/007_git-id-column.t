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
  skip "git status does not support --column", 1
    unless system("echo a|git column") == 0;

  $testname = "git id --column"; #{:
  `
  cd $workdir &&
  git init &&
  echo a > one.txt &&
  echo b > two.txt
  `;
  $expected = qr/#?1\tone.txt *2\s+two.txt/;
  $got = `cd $workdir; $srcdir/git-id --color=never --column=always`;
  like($got, $expected, $testname); #:}
}

done_testing();

