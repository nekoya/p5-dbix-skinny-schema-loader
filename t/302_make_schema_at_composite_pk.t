use strict;
use warnings;
use lib './t';
use Test::More tests => 4;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use DBIx::Skinny::Schema::Loader::DBI::SQLite;
use Mock::SQLite;

END { Mock::SQLite->clean_test_db }

my $testdsn  = 'dbi:SQLite:test.db';
my $testuser = '';
my $testpass = '';

ok my $dbh = DBI->connect($testdsn, $testuser, $testpass), 'connected to SQLite';
Mock::SQLite->dbh($dbh);
Mock::SQLite->setup_test_db;

throws_ok { DBIx::Skinny::Schema::Loader::DBI::SQLite->new({ dsn => '', user => '', pass => '' }) }
    qr/^Can't connect to data source/,
    'failed to connect DB';

$dbh->do($_) for (
    qq{
        CREATE TABLE composite (
            id   int,
            name text,
            primary key (id, name)
        )
    },
);

use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
ok my $schema = make_schema_at(
    'Mock::DB::Schema',
    {
    },
    [ 'dbi:SQLite:test.db', '', '' ]
), 'got schema class file content by make_schema_at';
is "$schema\n", << '...', 'assert content';
package Mock::DB::Schema;
use DBIx::Skinny::Schema;

install_table authors => schema {
    pk qw/id/;
    columns qw/id gender_name pref_name name/;
};

install_table books => schema {
    pk qw/id/;
    columns qw/id author_id name/;
};

install_table composite => schema {
    pk qw/id name/;
    columns qw/id name/;
};

install_table genders => schema {
    pk qw/name/;
    columns qw/name/;
};

install_table prefectures => schema {
    pk qw/name/;
    columns qw/id name/;
};

1;
...
