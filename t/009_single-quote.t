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

$testname = "single quote"; #{:

my @filenames = grep /^[^#]/,  <DATA>;

my $nfiles = scalar @filenames;
my $need_quoting = join("", sort @filenames);
chomp $need_quoting;
my $cmd = "cd $workdir &&
  git init &&
  echo \"$need_quoting\"|while read filename; do
    # echo \"# \$filename\" >&2
    echo foo > \"\$filename\"
  done &&
  $srcdir/git-id &&
  $srcdir/git-number add 1-$nfiles";
`$cmd`;
$expected = $need_quoting;
$got = `cd $workdir; git ls-files`;
chomp $got;
eq_or_diff($got, $expected, "File with single-quote characters must be quoted");
#:}

done_testing();

__DATA__
single'quoted'.txt
