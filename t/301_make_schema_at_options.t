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

my $before = '# custom template';
my $tmpl = 'install_utf8_columns qw/jpname title content/;';

my $after = << '...';
my $created_at = sub {
    my ($class, $args) = @_;
    $args->{ created_at } ||= DateTime->now;
};
...

my $table_template = << '...';
install_table [% table %] => schema {
    pk '[% pk %]';
    columns qw/[% columns %]/;
    trigger pre_insert => $created_at;
};

...

ok my $schema = make_schema_at(
    'Mock::DB::Schema',
    {
        table_template  => $table_template,
        template        => $tmpl, # deplicated, use before_template
        before_template => $before,
        after_template  => $after,
    },
    [ 'dbi:SQLite:test.db', '', '' ]
), 'got schema class file content by make_schema_at';

is "$schema\n", << '...', 'assert content';
package Mock::DB::Schema;
use DBIx::Skinny::Schema;

# custom template

install_utf8_columns qw/jpname title content/;

install_table authors => schema {
    pk 'id';
    columns qw/id gender_name pref_name name/;
    trigger pre_insert => $created_at;
};

install_table books => schema {
    pk 'id';
    columns qw/id author_id name/;
    trigger pre_insert => $created_at;
};

install_table genders => schema {
    pk 'name';
    columns qw/name/;
    trigger pre_insert => $created_at;
};

install_table prefectures => schema {
    pk 'name';
    columns qw/id name/;
    trigger pre_insert => $created_at;
};

my $created_at = sub {
    my ($class, $args) = @_;
    $args->{ created_at } ||= DateTime->now;
};

1;
...
