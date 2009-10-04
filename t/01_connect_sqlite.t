use strict;
use warnings;
use FindBin::libs;
use Test::More tests => 1;

use DBI;
use DBIx::Skinny::Schema::Loader;
use Mock::SQLite;

END   { Mock::SQLite->clean_test_db }

ok my $dbh = DBI->connect('dbi:SQLite:test.db', '', ''), 'connected to SQLite';
Mock::SQLite->dbh($dbh);
Mock::SQLite->setup_test_db;

ok my $loader = DBIx::Skinny::Schema::Loader->new(dbh => $dbh), 'created loader object';

print join "\n", @{ $loader->tables };
