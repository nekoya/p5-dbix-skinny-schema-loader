package DBIx::Skinny::Schema::Loader::DBI::Pg;
use strict;
use warnings;

use base qw/DBIx::Skinny::Schema::Loader::DBI/;

sub tables {
    my $self   = shift;
    my $schema = $self->{ schema } || 'public';
    my $sth    = $self->{ dbh }->table_info('', $schema, undef, undef);
    my @tables;
    for my $rel (@{ $sth->fetchall_arrayref({}) }) {
        push @tables, $rel->{TABLE_NAME};
    }
    return \@tables;
}

sub table_columns {
    my ($self, $table) = @_;
    my $schema = $self->{ schema } || 'public';
    my $sth    = $self->{ dbh }->prepare("select * from $schema.$table where 1 = 0");
    $sth->execute;
    my $retval = \@{$sth->{NAME_lc}};
    $sth->finish;
    return $retval;
}

1;
