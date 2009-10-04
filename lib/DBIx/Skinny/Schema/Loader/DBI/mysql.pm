package DBIx::Skinny::Schema::Loader::DBI::mysql;
use Any::Moose;
extends 'DBIx::Skinny::Schema::Loader::DBI';

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub _build_tables {
    my $self = shift;
    my $quoter = $self->quoter;
    my $namesep = $self->namesep;
    my @tables = $self->dbh->tables(undef, undef, '', '');
    s/\Q$quoter\E//g for @tables;
    s/^.*\Q$namesep\E// for @tables;
    return \@tables;
}

1;
