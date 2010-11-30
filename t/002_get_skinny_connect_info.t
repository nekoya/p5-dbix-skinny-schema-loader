use strict;
use warnings;
use lib './t';
use Test::More tests => 1;

use Mock::MySQLDummy;

my $loader = Mock::MySQLDummy::Schema->new;
is_deeply $loader->_get_skinny_connect_info, {
    dsn => 'dbi:mysql:testdatabase',
    username => 'user',
    password => 'passwd',
    connect_options => undef,
}, 'fetch connect_info from Skinny class'
