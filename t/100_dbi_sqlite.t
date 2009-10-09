use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Data::Dumper;
use Perl6::Say;
use Test::More tests => 11;
use Test::Exception;

use DBI;
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
    qq{
        CREATE TABLE no_pk (
            code int,
            name text
        )
    }
);

ok my $loader = DBIx::Skinny::Schema::Loader::DBI::SQLite->new({
        dsn => $testdsn, user => $testuser, pass => $testpass
    }), 'created loader impl object';

is_deeply $loader->tables, [qw/authors books composite genders no_pk prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is $loader->table_pk('authors'), 'id', 'authors pk';
is $loader->table_pk('books'), 'id', 'books pk';
is $loader->table_pk('genders'), 'name', 'genders pk';
is $loader->table_pk('prefectures'), 'name', 'prefectures pk';

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
