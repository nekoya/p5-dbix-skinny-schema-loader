use strict;
use warnings;
use lib './t';
use Test::More;
use Test::Exception;

use DBIx::Skinny::Schema::Loader;

subtest 'invalid args' => sub {
    ok my $loader = DBIx::Skinny::Schema::Loader->new, 'created loader instance';
    throws_ok { $loader->connect('', '', '') }
        qr/^Could not parse DSN/,
        'caught exception when dsn was invalid';

    done_testing;
};

subtest 'Oracle' => sub {
    my $loader = DBIx::Skinny::Schema::Loader->new;
    throws_ok { $loader->connect('dbi:Oracle:test', '', '') }
        qr/^Oracle is not supported by DBIx::Skinny::Schema::Loader yet/,
        'caught exception when driver was not supported';

    done_testing;
};

subtest 'connect_info array style' => sub {
    my $loader = DBIx::Skinny::Schema::Loader->new;
    ok $loader->connect('dbi:SQLite:test.db', '', ''), 'connect succeeded';
    ok unlink('./test.db'), 'deleted test DB';
    done_testing;
};

subtest 'connect_info hashref style' => sub {
    my $loader = DBIx::Skinny::Schema::Loader->new;
    ok $loader->connect(+{ dsn => 'dbi:SQLite:test.db', user => '', pass =>'' }), 'connect succeeded(hashref style)';
    ok unlink('./test.db'), 'deleted test DB';
    done_testing;
};

done_testing;
