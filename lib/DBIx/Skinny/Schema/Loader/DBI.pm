package DBIx::Skinny::Schema::Loader::DBI;
use strict;
use warnings;


use Carp;

sub new {
    my ($class, $fields) = @_;
    $fields = {} unless defined $fields;
    for ( qw/dsn user pass/ ) {
        croak "$_ is required" unless defined $fields->{ $_ }
    }

    my $self = bless {connect_options => {}, %$fields}, $class;
    $self->{ dbh } = DBI->connect($self->{ dsn }, $self->{ user }, $self->{ pass }, $self->{connect_options});
    return $self;
}

sub quoter {
    my $self = shift;
    $self->{ dbh }->get_info(29);
}

sub namesep {
    my $self = shift;
    $self->{ dbh }->get_info(41);
}

sub table_columns {
    my ($self, $table) = @_;
    my $sth = $self->{ dbh }->prepare("select * from $table where 1 = 0");
    $sth->execute;
    my $retval = \@{$sth->{NAME_lc}};
    $sth->finish;
    return $retval;
}

sub table_pk {
    my ($self, $table) = @_;
    my @keys = $self->{ dbh }->primary_key(undef, undef, $table);
    if ( @keys ) {
        @keys = map { lc($_) } @keys;
        return $#keys ? \@keys : $keys[0];
    }
    return [];
}

1;
