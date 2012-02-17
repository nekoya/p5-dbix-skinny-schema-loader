use strict;
use warnings;
use lib './t';
use Test::More;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use DBIx::Skinny::Schema::Loader::DBI::Pg;
use Mock::Pg::Schema;

my ($dsn, $username, $password) = @ENV{map { "SKINNY_PG_${_}" } qw/DSN USER PASS/};
plan skip_all => 'Set $ENV{SKINNY_PG_DSN}, _USER and _PASS to run this test' unless ($dsn && $username);

Mock::Pg::Schema->connect({dsn => $dsn, username => $username, password => $password});
Mock::Pg::Schema->setup_test_db;

throws_ok { DBIx::Skinny::Schema::Loader::DBI::Pg->new({ dsn => '', user => '', pass => '' }) }
qr/^Can't connect to data source/,
'failed to connect DB';

ok my $loader = DBIx::Skinny::Schema::Loader::DBI::Pg->new( {
    dsn  => $dsn,
    user => $username,
    pass => $password,
} ), 'created loader object';


subtest using_foo_schema => sub {
    $loader->{schema} = 'foo';

    is_deeply $loader->tables, [qw/ authors books composite /], 'tables';
    is_deeply $loader->table_columns('books'), [qw/ id author_id name /], 'table_columns';

    is_deeply $loader->table_pk('authors'), [], 'authors pk';
    is_deeply $loader->table_pk('books'), 'id', 'books pk';

    is_deeply [sort @{$loader->table_pk('composite')}], [qw/id name/], 'composite pk';

    done_testing;
};

subtest using_bar_schema => sub {
    $loader->{schema} = 'bar';

    is_deeply $loader->tables, [qw/ genders no_pk prefectures /], 'tables';
    is_deeply $loader->table_pk('genders'), [], 'genders pk';
    is_deeply $loader->table_pk('prefectures'), 'name', 'prefectures pk';

    is_deeply $loader->table_pk('no_pk'), [], 'no primary key';

    done_testing;
};

Mock::Pg::Schema->clean_test_db;

done_testing;
