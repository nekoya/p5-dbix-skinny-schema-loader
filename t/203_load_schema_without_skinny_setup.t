use strict;
use warnings;
use lib './t';
use Test::More tests => 4;

use DBI;
use Mock::SQLite;
use Mock::MySQL;
use Mock::NoSetup;

BEGIN {
    my $dbh = DBI->connect('dbi:SQLite:test.db', '', '');
    Mock::SQLite->dbh($dbh);
    Mock::SQLite->setup_test_db;
}
END { Mock::SQLite->clean_test_db }

{
    note "test SQLite";
    ok my $db = Mock::NoSetup->new, 'created Skinny object';
    my $connect_info = { dsn => 'dbi:SQLite:test.db' };
    $db->connect($connect_info);
    $db->schema->load_schema($connect_info);
    is $db->single('books', { id => 1 })->name, 'book1', 'assert book name';
}

SKIP : {
    note "test MySQL";

    my ($dsn, $username, $password) = @ENV{map { "SKINNY_MYSQL_${_}" } qw/DSN USER PASS/};
    skip 'Set $ENV{SKINNY_MYSQL_DSN}, _USER and _PASS to run this test', 2 unless ($dsn && $username);

    Mock::MySQL->connect({dsn => $dsn, username => $username, password => $password});
    Mock::MySQL->setup_test_db;

    ok my $db = Mock::NoSetup->new, 'created Skinny object';
    my $connect_info = {
        dsn      => $dsn,
        username => $username,
        password => $password,
    };
    $db->connect($connect_info);
    $db->schema->load_schema($connect_info);
    is $db->single('books', { id => 1 })->name, 'mysql', 'assert book name';

    Mock::MySQL->clean_test_db;
};
