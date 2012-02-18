use strict;
use warnings;
use lib './t';
use Test::More;

use Mock::Comparison;

use DBI;
use Mock::SQLite;

BEGIN {
    my $dbh = DBI->connect('dbi:SQLite:test.db', '', '');
    Mock::SQLite->dbh($dbh);
    Mock::SQLite->setup_test_db;
}
END { Mock::SQLite->clean_test_db }

use Mock::DB;
use Mock::Comparison;

my $skinny = Mock::Comparison->new->schema->schema_info;
my $loader = Mock::DB->new->schema->schema_info;

my $s_si;
for my $key ( keys %$skinny ) {
    $s_si->{$key} = {
        'pk' => $skinny->{$key}->{pk},
        'columns' => $skinny->{$key}->{columns},
    };
}

my $l_si;
for my $key ( keys %$loader ) {
    $l_si->{$key} = {
        'pk' => $loader->{$key}->{pk},
        'columns' => $loader->{$key}->{columns},
    };
}

is_deeply $s_si, $l_si, 'comparison';

done_testing;
