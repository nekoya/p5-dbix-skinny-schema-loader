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

use DBIx::Skinny::Schema::Loader;
ok my $schema = DBIx::Skinny::Schema::Loader->make_schema_at(
    'Mock::DB::Schema',
    {
    },
    [ 'dbi:SQLite:test.db', '', '' ]
), 'got schema class file content by make_schema_at';
is "$schema\n", << '...', 'assert content';
package Mock::DB::Schema;
use DBIx::Skinny::Schema;

install_table authors => schema {
    pk 'id';
    columns qw/id gender_name pref_name name/;
};

install_table books => schema {
    pk 'id';
    columns qw/id author_id name/;
};

install_table genders => schema {
    pk 'name';
    columns qw/name/;
};

install_table prefectures => schema {
    pk 'name';
    columns qw/id name/;
};

1;
...
