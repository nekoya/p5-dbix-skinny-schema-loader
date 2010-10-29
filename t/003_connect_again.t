use strict;
use warnings;
use lib './t';
use Test::More;
use Test::Exception;

use DBI;
use Mock::SQLite;

BEGIN {
    my $dbh = DBI->connect('dbi:SQLite:test.db', '', '');
    Mock::SQLite->dbh($dbh);
    Mock::SQLite->setup_test_db;
}
END { Mock::SQLite->clean_test_db }

use DBIx::Skinny::Schema::Loader;
ok my $loader = DBIx::Skinny::Schema::Loader->new, 'created loader instance';

throws_ok { $loader->make_schema_at('MyApp::DB::Schema') } qr/^Could not parse DSN/;

ok $loader->connect('dbi:SQLite:test.db', '', ''), 'connect manually';
ok my $schema = $loader->make_schema_at('MyApp::DB::Schema'), 'created schema';
like $schema, qr/^install_table books => schema/m, 'install_table section exists';

done_testing;
