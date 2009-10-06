package DBIx::Skinny::Schema::Loader::DBI;
use Any::Moose;

has dsn => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has user => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has pass => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has dbh => (
    is  => 'rw',
    isa => 'DBI::db',
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

sub BUILD {
    my $self = shift;
    $self->dbh(DBI->connect($self->dsn, $self->user, $self->pass));
}

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
        croak "DBIx::Skinny is not support composite primary key (table: $table)" if $#keys;
        return $keys[0];
    }
    my $columns = $self->table_columns($table);
    return $columns->[0] if scalar @$columns == 1;
    return 'id' if ( grep { $_ eq 'id' } @$columns );
    croak "Could not find primary key of $table";
}

1;
