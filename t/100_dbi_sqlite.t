use strict;
use warnings;
use lib './t';
use Test::More tests => 13;
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

ok my $loader = DBIx::Skinny::Schema::Loader::DBI::SQLite->new({
        dsn => $testdsn, user => $testuser, pass => $testpass
    }), 'created loader impl object';

is_deeply $loader->tables, [qw/authors books composite genders no_pk prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is_deeply $loader->table_pk('authors'), [], 'authors pk';
is_deeply $loader->table_pk('books'), 'id', 'books pk';
is_deeply $loader->table_pk('genders'), [], 'genders pk';
is_deeply $loader->table_pk('prefectures'), 'name', 'prefectures pk';

is_deeply [sort @{$loader->table_pk('composite')}], [qw/id name/], 'composite pk';
is_deeply $loader->table_pk('no_pk'), [], 'no primary key';

my $schema = DBIx::Skinny::Schema::Loader->new;
ok $schema->connect($testdsn, $testuser, $testpass), 'connected loader';
isa_ok $schema->{ impl }, 'DBIx::Skinny::Schema::Loader::DBI::SQLite';
