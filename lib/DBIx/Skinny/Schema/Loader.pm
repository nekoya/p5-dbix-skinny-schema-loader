package DBIx::Skinny::Schema::Loader;

our $VERSION = '0.01';

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
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $quoter = $self->quoter;
        my $namesep = $self->namesep;
        my @tables = $self->dbh->tables(undef, undef, '', '');
        s/\Q$quoter\E//g for @tables;
        s/^.*\Q$namesep\E// for @tables;
        return \@tables;
    },
);
no Any::Moose;

sub _table_columns {
    my ($self, $table) = @_;
    my $sth = $self->dbh->prepare("select * from airlines where 1 = 0");
    $sth->execute;
    my $retval = \@{$sth->{NAME_lc}};
    $sth->finish;
    return $retval;
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
