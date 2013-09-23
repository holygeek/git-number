use strict;
use warnings;
use Test::More;

plan tests => 2;

use lib 't/lib';
use Scaffold;

my $git_version = `git version`;
chomp $git_version;
my $ndir_created = Scaffold::init();
like ($git_version, qr/git version/, "git is installed");
diag "Using $git_version";
ok ($ndir_created == 1, 'Work dir created');
