use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Data::Dumper;
use Perl6::Say;
use Test::More tests => 8;

use DBI;
use DBIx::Skinny::Schema::Loader;
use Mock::MySQL;

END { Mock::MySQL->clean_test_db }

my $testdsn  = $ENV{ SKINNY_MYSQL_DSN  } || 'dbi:mysql:test';
my $testuser = $ENV{ SKINNY_MYSQL_USER } || '';
my $testpass = $ENV{ SKINNY_MYSQL_PASS } || '';

ok my $dbh = DBI->connect($testdsn, $testuser, $testpass), 'connected to MySQL';
Mock::MySQL->dbh($dbh);
Mock::MySQL->setup_test_db;

ok my $loader = DBIx::Skinny::Schema::Loader->new(dbh => $dbh), 'created loader object';
is_deeply $loader->tables, [qw/authors books genders prefectures/], 'tables';
is_deeply $loader->table_columns('books'), [qw/id author_id name/], 'table_columns';

is $loader->table_pk('authors'), 'id', 'authors pk';
is $loader->table_pk('books'), 'id', 'books pk';
is $loader->table_pk('genders'), 'name', 'genders pk';
is $loader->table_pk('prefectures'), 'name', 'prefectures pk';

print $loader->make_schema_at('MyApp::Schema');
