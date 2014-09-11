package QuoteTest;

use strict;
use warnings;
use lib 't/lib';
use Scaffold qw/$workdir $srcdir/;

sub test_quoting {
  my ($quote, @filenames) = @_;

  my $nfiles = scalar @filenames;
  my $need_quoting = join("", sort @filenames);
  chomp $need_quoting;
  my $cmd = "cd $workdir &&
    git init &&
    echo $quote$need_quoting$quote|while read filename; do
      # echo \"# \$filename\" >&2
      echo foo > \"\$filename\"
    done &&
    $srcdir/git-id &&
    $srcdir/git-number add 1-$nfiles";
  `$cmd`;
  my $expected = $need_quoting;
  chomp(my $got = `cd $workdir; git ls-files`);
  return ($got, $expected);
}

1;
