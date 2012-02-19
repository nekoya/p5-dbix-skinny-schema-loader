use strict;
use warnings;
use lib './t';
use Test::More;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use DBIx::Skinny::Schema::Loader::DBI::Pg;
use Mock::Pg;

my ($dsn, $username, $password) = @ENV{map { "SKINNY_PG_${_}" } qw/DSN USER PASS/};
plan skip_all => 'Set $ENV{SKINNY_PG_DSN}, _USER and _PASS to run this test' unless ($dsn && $username);

Mock::Pg->connect({dsn => $dsn, username => $username, password => $password});
Mock::Pg->setup_test_db;

throws_ok { DBIx::Skinny::Schema::Loader::DBI::Pg->new({ dsn => '', user => '', pass => '' }) }
qr/^Can't connect to data source/,
'failed to connect DB';

ok my $loader = DBIx::Skinny::Schema::Loader::DBI::Pg->new({
    dsn => $dsn, user => $username, pass => $password
}), 'created loader object';
is_deeply $loader->tables, [qw/authors books composite genders no_pk prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is_deeply $loader->table_pk('authors'), [], 'authors pk';
is_deeply $loader->table_pk('books'), 'id', 'books pk';
is_deeply $loader->table_pk('genders'), [], 'genders pk';
is_deeply $loader->table_pk('prefectures'), 'name', 'prefectures pk';

is_deeply [sort @{$loader->table_pk('composite')}], [qw/id name/], 'composite pk';
is_deeply $loader->table_pk('no_pk'), [], 'no primary key';

my $schema = DBIx::Skinny::Schema::Loader->new;
ok $schema->connect($dsn, $username, $password), 'connected loader';
isa_ok $schema->{ impl }, 'DBIx::Skinny::Schema::Loader::DBI::Pg';

Mock::Pg->clean_test_db;

done_testing;
