use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Data::Dumper;
use Perl6::Say;
use Test::More;
use Test::Exception;

use DBI;
use DBIx::Skinny::Schema::Loader;
use DBIx::Skinny::Schema::Loader::DBI::Pg;
use Mock::Pg;

BEGIN {
  eval "use DBD::Pg";
  plan skip_all => 'needs DBD::Pg for testing' if $@;
}

END { Mock::Pg->clean_test_db }

plan tests => 12;

SKIP: {
    my $testdsn  = $ENV{ SKINNY_PG_DSN  } || 'dbi:Pg:dbname=test';
    my $testuser = $ENV{ SKINNY_PG_USER } || '';
    my $testpass = $ENV{ SKINNY_PG_PASS } || '';

    my $dbh = DBI->connect($testdsn, $testuser, $testpass, { RaiseError => 0, PrintError => 0 })
        or skip 'Set $ENV{SKINNY_PG_DSN}, _USER and _PASS to run this test', 10;

    Mock::Pg->dbh($dbh);
    Mock::Pg->setup_test_db;

    throws_ok { DBIx::Skinny::Schema::Loader::DBI::Pg->new({ dsn => '', user => '', pass => '' }) }
        qr/^Can't connect to data source/,
        'failed to connect DB';

    ok my $loader = DBIx::Skinny::Schema::Loader::DBI::Pg->new({
            dsn => $testdsn, user => $testuser, pass => $testpass
        }), 'created loader object';
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
                name varchar(255),
                primary key (id, name)
            )
        },
        qq{
            CREATE TABLE no_pk (
                code int,
                name varchar(255)
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

    my $schema = DBIx::Skinny::Schema::Loader->new;
    ok $schema->connect($testdsn, $testuser, $testpass), 'connected loader';
    isa_ok $schema->{ impl }, 'DBIx::Skinny::Schema::Loader::DBI::Pg';
}

