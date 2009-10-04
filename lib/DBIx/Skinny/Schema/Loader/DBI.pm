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

sub table_columns {
    my ($self, $table) = @_;
    my $sth = $self->dbh->prepare("select * from $table where 1 = 0");
    $sth->execute;
    my $retval = \@{$sth->{NAME_lc}};
    $sth->finish;
    return $retval;
}

1;
