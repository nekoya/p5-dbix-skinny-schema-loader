use strict;
use warnings;
use lib './t';
use Test::More tests => 8;

use DBI;
use Mock::SQLite::UcPk;
use Mock::MySQL::UcPk;
use Mock::NoSetup;

BEGIN {
    my $dbh = DBI->connect( 'dbi:SQLite:test.db', '', '' );
    Mock::SQLite::UcPk->dbh($dbh);
    Mock::SQLite::UcPk->setup_test_db;
}
END { Mock::SQLite::UcPk->clean_test_db }

{
    note "test SQLite";
    ok my $db = Mock::NoSetup->new, 'created Skinny object';
    my $connect_info = { dsn => 'dbi:SQLite:test.db' };
    $db->connect($connect_info);
    $db->schema->load_schema($connect_info);
    my $book = $db->single( 'books', { id => 1 } );
    is $book->name, 'book1', 'assert book name';
    ok( $book->update( { name => 'sqlite is good' } ) );
    is $book->name, 'sqlite is good', 'assert book name updated';
}

SKIP: {
    note "test MySQL";

    my ( $dsn, $username, $password ) =
      @ENV{ map { "SKINNY_MYSQL_${_}" } qw/DSN USER PASS/ };
    skip 'Set $ENV{SKINNY_MYSQL_DSN}, _USER and _PASS to run this test', 4
      unless ( $dsn && $username );

    Mock::MySQL::UcPk->connect(
        { dsn => $dsn, username => $username, password => $password } );
    Mock::MySQL::UcPk->setup_test_db;

    ok my $db = Mock::NoSetup->new, 'created Skinny object';
    my $connect_info = {
        dsn      => $dsn,
        username => $username,
        password => $password,
    };
    $db->connect($connect_info);
    $db->schema->load_schema($connect_info);
    my $book = $db->single( 'books', { id => 1 } );
    is $book->name, 'mysql', 'assert book name';
    ok( $book->update( { name => 'mysql is good' } ) );
    is $book->name, 'mysql is good', 'assert book name updated';

    Mock::MySQL::UcPk->clean_test_db;
}
