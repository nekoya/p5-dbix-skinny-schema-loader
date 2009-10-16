use strict;
use warnings;
use lib './t';
use FindBin::libs;
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

use Mock::DB;
ok my $db = Mock::DB->new, 'created Skinny object';
is $db->single('books', { id => 1 })->name, 'book1', 'assert book name';
