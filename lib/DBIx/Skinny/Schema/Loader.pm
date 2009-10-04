package DBIx::Skinny::Schema::Loader;

our $VERSION = '0.01';

use Any::Moose;
has dbh => (
    is       => 'ro',
    isa      => 'DBI::db',
    required => 1,
);

has impl => (
    is      => 'rw',
    isa     => 'DBIx::Skinny::Schema::Loader::DBI',
    handles => [qw/tables table_columns table_pk/],
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

use Text::MicroTemplate qw(:all);

sub BUILD {
    my $self = shift;
    my $driver = $self->_find_primary_driver;
    my $impl = __PACKAGE__ . "::DBI::$driver";
    eval "use $impl"; ## no critic
    $self->impl($impl->new(dbh => $self->dbh));
}

sub _find_primary_driver {
    my $self = shift;
    my %installed = DBI->installed_drivers;
    my @keys = keys %installed;
    return $keys[0];
}

sub make_schema_at {
    my ($self, $schema_class) = @_;
    my $schema = "package $schema_class;\nuse DBIx::Skinny::Schema\n\n";
    my $renderer = build_mt(
        "install_table <?= \$_[0] ?> => schema {\n".
        "    pk '<?= \$_[1] ?>';\n".
        "    columns qw/<?= \$_[2] ?>/;\n".
        "};\n\n"
    );
    $schema .= $renderer->(
        $_,
        $self->table_pk($_),
        join " ", @{ $self->table_columns($_) }
    )->as_string for @{ $self->tables };
    $schema .= "1;";
    return $schema;
}

1;
__END__

=head1 NAME

DBIx::Skinny::Schema::Loader - Schema loader for DBIx::Skinny

=head1 SYNOPSIS

  use DBIx::Skinny::Schema::Loader;

=head1 DESCRIPTION

DBIx::Skinny::Schema::Loader is

=head1 AUTHOR

Default Name E<lt>default {at} example.comE<gt>

=head1 SEE ALSO

DBIx::Skinny

=head1 AUTHOR

Ryo Miyake  C<< <ryo.studiom@gmail.com> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
