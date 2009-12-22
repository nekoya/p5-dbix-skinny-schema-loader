use strict;
use warnings;
use lib './t';
use Test::More tests => 5;
use Test::Exception;

use DBIx::Skinny::Schema::Loader;
ok my $loader = DBIx::Skinny::Schema::Loader->new, 'created loader instance';

throws_ok { $loader->connect('', '', '') }
    qr/^Could not parse DSN/,
    'caught exception when dsn was invalid';

throws_ok { $loader->connect('dbi:Oracle:test', '', '') }
    qr/^Oracle is not supported by DBIx::Skinny::Schema::Loader yet/,
    'caught exception when driver was not supported';

ok $loader->connect('dbi:SQLite:test.db', '', ''), 'connect succeeded';
ok unlink('./test.db'), 'deleted test DB';
