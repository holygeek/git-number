package Scaffold;
use Exporter 'import';
@EXPORT_OK = qw($workdir $srcdir);

BEGIN {
	my $package = caller();
	no strict 'refs';
	if (! eval q{use Test::Differences; 1}) {
		*{"${package}::eq_or_diff"} = \&Test::More::is_deeply;
	} else {
		*{"${package}::eq_or_diff"} = \&Test::Differences::eq_or_diff;
	}
}

use FindBin;
use File::Path qw/mkpath rmtree/;

our $srcdir = "$FindBin::Bin/../";
our $workdir = "$FindBin::Bin/testoutput";

$ENV{PATH} = "$srcdir:" . $ENV{PATH};
$ENV{GIT_AUTHOR_EMAIL} = 'author@example.com';
$ENV{GIT_AUTHOR_NAME} = 'A. U. Thor';
$ENV{GIT_COMMITTER_EMAIL} = 'author@example.com';
$ENV{GIT_COMMITTER_NAME} = 'A. U. Thor';

sub init {
	rmtree($workdir);
	my $ndir_created = mkpath($workdir);
	return $ndir_created;
}
