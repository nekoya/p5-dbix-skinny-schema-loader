package DBIx::Skinny::Schema::Loader::DBI::mysql;
use strict;
use warnings;

use base qw/DBIx::Skinny::Schema::Loader::DBI/;

sub tables {
    my $self = shift;
    my $quoter = $self->quoter;
    my $namesep = $self->namesep;
    my @tables = $self->{ dbh }->tables(undef, undef, '', '');
    s/\Q$quoter\E//g for @tables;
    s/^.*\Q$namesep\E// for @tables;
    return \@tables;
}

1;
