use strict;
use warnings;
use lib './t';
use FindBin::libs;
use Test::More tests => 4;
use Test::Exception;

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
    eval "use DBD::mysql";
    skip 'needs DBD::mysql for testing', 2 if $@;

    note "test MySQL";
    my $testdsn  = $ENV{ SKINNY_MYSQL_DSN  } || 'dbi:mysql:test';
    my $testuser = $ENV{ SKINNY_MYSQL_USER } || '';
    my $testpass = $ENV{ SKINNY_MYSQL_PASS } || '';

    my $dbh = DBI->connect($testdsn, $testuser, $testpass, { RaiseError => 0, PrintError => 0 })
        or skip 'Set $ENV{SKINNY_MYSQL_DSN}, _USER and _PASS to run this test', 2;

    Mock::MySQL->dbh($dbh);
    Mock::MySQL->setup_test_db;

    ok my $db = Mock::NoSetup->new, 'created Skinny object';
    my $connect_info = {
        dsn      => $testdsn,
        username => $testuser,
        password => $testpass,
    };
    $db->connect($connect_info);
    $db->schema->load_schema($connect_info);
    is $db->single('books', { id => 1 })->name, 'mysql', 'assert book name';

    Mock::MySQL->clean_test_db;
};
