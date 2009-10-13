package DBIx::Skinny::Schema::Loader::DBI::Pg;
use strict;
use warnings;

use base qw/DBIx::Skinny::Schema::Loader::DBI/;

sub tables {
    my $self = shift;
    my $sth  = $self->{ dbh }->table_info('', 'public', undef, undef);
    my @tables;
    for my $rel (@{ $sth->fetchall_arrayref({}) }) {
        push @tables, $rel->{TABLE_NAME};
    }
    return \@tables;
}

1;
