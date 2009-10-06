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

    my $self = bless {%$fields}, $class;
    $self->{ dbh } = DBI->connect($self->{ dsn }, $self->{ user }, $self->{ pass });
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
        croak "DBIx::Skinny is not support composite primary key (table: $table)" if $#keys;
        return $keys[0];
    }
    my $columns = $self->table_columns($table);
    return $columns->[0] if scalar @$columns == 1;
    return 'id' if ( grep { $_ eq 'id' } @$columns );
    croak "Could not find primary key of $table";
}

1;
