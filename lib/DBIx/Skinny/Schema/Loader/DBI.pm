package DBIx::Skinny::Schema::Loader::DBI;
use Any::Moose;

has dbh => (
    is       => 'ro',
    isa      => 'DBI::db',
    required => 1,
);

has quoter => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->dbh->get_info(29) },
);

has namesep => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->dbh->get_info(41) },
);

has tables => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    lazy_build => 1,
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

use Carp;

sub table_columns {
    my ($self, $table) = @_;
    my $sth = $self->dbh->prepare("select * from $table where 1 = 0");
    $sth->execute;
    my $retval = \@{$sth->{NAME_lc}};
    $sth->finish;
    return $retval;
}

sub table_pk {
    my ($self, $table) = @_;
    my @keys = $self->dbh->primary_key(undef, undef, $table);
    if ( @keys ) {
        confess "DBIx::Skinny is not support composite primary key" if $#keys;
        return $keys[0];
    }
    my $columns = $self->table_columns($table);
    return $columns->[0] if scalar @$columns == 1;
    return 'id' if ( grep { $_ eq 'id' } @$columns );
    confess "Could not find primary key of $table";
}

1;
