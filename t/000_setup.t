use strict;
use warnings;
use Test::More;

plan tests => 1;

use lib 't/lib';
use Scaffold;

my $ndir_created = Scaffold::init();
ok ($ndir_created == 1, 'Work dir created');
