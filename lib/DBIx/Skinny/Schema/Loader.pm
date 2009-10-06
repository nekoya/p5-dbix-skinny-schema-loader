package DBIx::Skinny::Schema::Loader;

our $VERSION = '0.01';

use Any::Moose;
has impl => (
    is      => 'rw',
    isa     => 'DBIx::Skinny::Schema::Loader::DBI',
);
no Any::Moose;
__PACKAGE__->meta->make_immutable;

use Carp;
use DBI;
use Text::MicroTemplate qw(:all);

sub connect {
    my ($self, $dsn, $user, $pass) = @_;
    $dsn =~ /^dbi:([^:]+):/;
    my $driver = $1 or croak "Could not parse DSN";
    croak "$driver is not supported by DBIx::Skinny::Schema::Loader yet"
        unless $driver =~ /^(SQLite|mysql)$/;
    my $impl = __PACKAGE__ . "::DBI::$driver";
    eval "use $impl"; ## no critic
    die $@ if $@;
    $self->impl($impl->new({
        dsn  => $dsn  || '',
        user => $user || '',
        pass => $pass || '',
    }));
}

sub load_schema {
    my $class = shift;

    # import on concrete class namespace
    eval "use DBIx::Skinny::Schema"; ## no critic

    (my $skinny_class = caller) =~ s/::Schema//;
    my $self = $class->new;
    $self->connect(
        $skinny_class->attribute->{ dsn },
        $skinny_class->attribute->{ user },
        $skinny_class->attribute->{ password },
    );
    my $schema = caller->schema_info;
    for my $table ( @{ $self->impl->tables } ) {
        $schema->{ $table }->{ pk } = $self->impl->table_pk($table);
        $schema->{ $table }->{ columns } = $self->impl->table_columns($table);
    }
}

sub make_schema_at {
    my ($class, $schema_class, $options, $connect_info) = @_;

    my $self = $class->new;
    $self->connect(@{ $connect_info });

    my $schema = "package $schema_class;\nuse DBIx::Skinny::Schema;\n\n";
    my $renderer = build_mt(
        "install_table <?= \$_[0] ?> => schema {\n".
        "    pk '<?= \$_[1] ?>';\n".
        "    columns qw/<?= \$_[2] ?>/;\n".
        "};\n\n"
    );
    $schema .= $renderer->(
        $_,
        $self->impl->table_pk($_),
        join " ", @{ $self->impl->table_columns($_) }
    )->as_string for @{ $self->impl->tables };
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
