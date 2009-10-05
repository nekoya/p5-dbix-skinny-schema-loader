use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Data::Dumper;
use Perl6::Say;
use Test::More tests => 8;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use Mock::SQLite;

END   { Mock::SQLite->clean_test_db }

ok my $dbh = DBI->connect('dbi:SQLite:test.db', '', ''), 'connected to SQLite';
Mock::SQLite->dbh($dbh);
Mock::SQLite->setup_test_db;

ok my $loader = DBIx::Skinny::Schema::Loader->new(dbh => $dbh), 'created loader object';
is_deeply $loader->tables, [qw/authors books genders prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is $loader->table_pk('authors'), 'id', 'authors pk';
is $loader->table_pk('books'), 'id', 'books pk';
is $loader->table_pk('genders'), 'name', 'genders pk';
is $loader->table_pk('prefectures'), 'name', 'prefectures pk';

$dbh->do($_) for (
    qq{
        CREATE TABLE composite (
            id   int,
            name text,
            primary key (id, name)
        )
    },
    qq{
        CREATE TABLE no_pk (
            code int,
            name text
        )
    }
);

throws_ok { $loader->table_pk('composite') }
    qr/^DBIx::Skinny is not support composite primary key/,
    'caught exception for sonposite pk';
throws_ok { $loader->table_pk('no_pk') }
    qr/^Could not find primary key/,
    'caught exception pk not found';

$dbh->do($_) for (
    q{ DROP TABLE composite },
    q{ DROP TABLE no_pk },
);

print $loader->make_schema_at('MyApp::Schema');
