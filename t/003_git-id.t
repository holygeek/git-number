#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

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

# vim:fdm=marker foldmarker={\:,\:}: commentstring=\ #%s
