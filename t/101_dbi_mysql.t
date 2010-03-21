use strict;
use warnings;
use lib './t';
use Test::More;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use DBIx::Skinny::Schema::Loader::DBI::mysql;
use Mock::MySQL;

my ($dsn, $username, $password) = @ENV{map { "SKINNY_MYSQL_${_}" } qw/DSN USER PASS/};
plan skip_all => 'Set $ENV{SKINNY_MYSQL_DSN}, _USER and _PASS to run this test' unless ($dsn && $username);

Mock::MySQL->connect({dsn => $dsn, username => $username, password => $password});
Mock::MySQL->setup_test_db;

throws_ok { DBIx::Skinny::Schema::Loader::DBI::mysql->new({ dsn => '', user => '', pass => '' }) }
qr/^Can't connect to data source/,
'failed to connect DB';

ok my $loader = DBIx::Skinny::Schema::Loader::DBI::mysql->new({
    dsn => $dsn, user => $username, pass => $password
}), 'created loader object';
is_deeply $loader->tables, [qw/authors books genders prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is $loader->table_pk('authors'), 'id', 'authors pk';
is $loader->table_pk('books'), 'id', 'books pk';
is $loader->table_pk('genders'), 'name', 'genders pk';
is $loader->table_pk('prefectures'), 'name', 'prefectures pk';

Mock::MySQL->do($_) for (
    q{
    CREATE TABLE composite (
        id   int,
        name varchar(255),
        primary key (id, name)
    ) },
    q{
    CREATE TABLE no_pk (
        code int,
        name varchar(255)
    ) },
);

is $loader->table_pk('composite'), '', 'skip composite pk';
throws_ok { $loader->table_pk('no_pk') }
qr/^Could not find primary key/,
'caught exception pk not found';

Mock::MySQL->do($_) for (
    q{ DROP TABLE composite },
    q{ DROP TABLE no_pk },
);

my $schema = DBIx::Skinny::Schema::Loader->new;
ok $schema->connect($dsn, $username, $password), 'connected loader';
isa_ok $schema->{ impl }, 'DBIx::Skinny::Schema::Loader::DBI::mysql';

Mock::MySQL->clean_test_db;

done_testing;
