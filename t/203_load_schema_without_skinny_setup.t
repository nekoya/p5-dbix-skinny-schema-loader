use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Data::Dumper;
use Perl6::Say;
use Test::More tests => 2;
use Test::Exception;

use DBI;
use Mock::SQLite;

BEGIN {
    my $dbh = DBI->connect('dbi:SQLite:test.db', '', '');
    Mock::SQLite->dbh($dbh);
    Mock::SQLite->setup_test_db;
}
END { Mock::SQLite->clean_test_db }

use Mock::NoSetup;
ok my $db = Mock::NoSetup->new, 'created Skinny object';
my $dsn = { dsn => 'dbi:SQLite:test.db' };
$db->connect($dsn);
$db->schema->load_schema($dsn);

is $db->single('books', { id => 1 })->name, 'book1', 'assert book name';
