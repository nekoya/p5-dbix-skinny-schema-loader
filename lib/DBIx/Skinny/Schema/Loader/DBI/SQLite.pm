package DBIx::Skinny::Schema::Loader::DBI::SQLite;
use strict;
use warnings;

use base qw/DBIx::Skinny::Schema::Loader::DBI/;

sub tables {
    my $self = shift;
    my $sth = $self->{ dbh }->prepare("SELECT * FROM sqlite_master");
    $sth->execute;
    my @tables;
    while ( my $row = $sth->fetchrow_hashref ) {
        next unless lc( $row->{type} ) eq 'table';
        next if $row->{tbl_name} =~ /^sqlite_/;
        push @tables, $row->{tbl_name};
    }
    $sth->finish;
    my @sorted = sort @tables;
    return \@sorted;
}

1;
