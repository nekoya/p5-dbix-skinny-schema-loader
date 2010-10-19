use strict;
use warnings;
use lib './t';
use Test::More tests => 2;

use DBI;
use Mock::SQLite;

BEGIN {
    my $dbh = DBI->connect('dbi:SQLite:test.db', '', '');
    Mock::SQLite->dbh($dbh);
    Mock::SQLite->setup_test_db;
}
END { Mock::SQLite->clean_test_db }

use DBIx::Skinny::Schema::Loader qw/make_schema_at/;

ok my $schema = make_schema_at(
    'Mock::DB::Schema',
    {
        ignore_rules => [ qr/rs$/, qr/^no/ ],
    },
    [ 'dbi:SQLite:test.db', '', '' ]
), 'got schema class file content by make_schema_at';

$schema =~ /^# generated (20\d\d\-\d\d\-\d\d .{3} \d\d:\d\d:\d\d)/m;
my $timestamp = $1;

is "$schema\n", << "...", 'assert content';
# THIS FILE IS AUTOGENERATED BY DBIx::Skinny::Schema::Loader ${DBIx::Skinny::Schema::Loader::VERSION}, DO NOT EDIT DIRECTLY.
# generated $timestamp

package Mock::DB::Schema;
use DBIx::Skinny::Schema;

install_table books => schema {
    pk qw/id/;
    columns qw/id author_id name/;
};

install_table composite => schema {
    pk qw/id name/;
    columns qw/id name/;
};

install_table prefectures => schema {
    pk qw/name/;
    columns qw/id name/;
};

1;
...
