package DBIx::Skinny::Schema::Loader;
use strict;
use warnings;

our $VERSION = '0.03';

use Carp;
use DBI;
use DBIx::Skinny::Schema;

sub import {
    my ($class, @args) = @_;
    my $caller = caller;

    my @functions = qw(
    make_schema_at
    );

    for my $func ( @args ) {
        if ( grep { $func } @functions ) {
            no strict 'refs';
            *{"$caller\::$func"} = \&$func;
        }
    }
}

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub connect {
    my ($self, $dsn, $user, $pass) = @_;
    $dsn =~ /^dbi:([^:]+):/;
    my $driver = $1 or croak "Could not parse DSN";
    croak "$driver is not supported by DBIx::Skinny::Schema::Loader yet"
        unless $driver =~ /^(SQLite|mysql)$/;
    my $impl = __PACKAGE__ . "::DBI::$driver";
    eval "use $impl"; ## no critic
    die $@ if $@;
    $self->{ impl } = $impl->new({
        dsn  => $dsn  || '',
        user => $user || '',
        pass => $pass || '',
    });
}

sub load_schema {
    my $class = shift;

    (my $skinny_class = caller) =~ s/::Schema//;
    my $self = $class->new;
    my $attr = $skinny_class->attribute;
    $self->connect($attr->{ dsn }, $attr->{ user }, $attr->{ password });

    my $schema = caller->schema_info;
    for my $table ( @{ $self->{ impl }->tables } ) {
        $schema->{ $table }->{ pk } = $self->{ impl }->table_pk($table);
        $schema->{ $table }->{ columns } = $self->{ impl }->table_columns($table);
    }
}

sub make_schema_at {
    my ($schema_class, $options, $connect_info) = @_;

    my $self = __PACKAGE__->new;
    $self->connect(@{ $connect_info });

    my $schema = "package $schema_class;\nuse DBIx::Skinny::Schema;\n\n";
    if ( my $template = $options->{ template } ) {
        chomp $template;
        $schema .= $template . "\n\n";
    }
    $schema .= $self->_make_install_table_text({
        table   => $_,
        pk      => $self->{ impl }->table_pk($_),
        columns => $self->{ impl }->table_columns($_),
    }) for @{ $self->{ impl }->tables };
    $schema .= "1;";
    return $schema;
}

sub _make_install_table_text {
    my ($self, $params) = @_;
    my $table   = $params->{ table };
    my $pk      = $params->{ pk    };
    my $columns = join " ", @{ $params->{ columns } };

    return "install_table $table => schema {\n".
           "    pk '$pk';\n".
           "    columns qw/$columns/;\n".
           "};\n\n"
}

1;
__END__

=head1 NAME

DBIx::Skinny::Schema::Loader - Schema loader for DBIx::Skinny

=head1 SYNOPSIS

dynamic schema loading.

  package Your::DB::Schema;
  use base qw/DBIx::Skinny::Schema::Loader/;

  __PACKAGE__->load_schema;

  1;

or you can get static content of schema class.
for example, following source save as "publish_schema.pl"

  use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
  print make_schema_at(
    'Your::DB::Schema',
    {
      # options here
    },
    [ 'dbi:SQLite:test.db', '', '' ]
  );

and execute
$ perl publish_schema.pl > Your/DB/Schema.pm

=head1 DESCRIPTION

DBIx::Skinny::Schema::Loader is schema loader for DBIx::Skinny.
Supported dynamic schema loading and static publish.

it supports MySQL and SQLite, PostgreSQL is not supported yet.

=head1 METHODS

=head2 connect( $dsn, $user, $pass )

perhaps you don't have to use it manually.

invoke concrete db driver class named "DBIx::Skinny::Schema::Loader::DBI::XXXX".

=head2 load_schema

loading schema dynamically.

  package Your::DB::Schema;
  use base qw/DBIx::Skinny::Schema::Loader/;

  __PACKAGE__->load_schema;

  1;

load_schema refer to connect info in your Skinny class.
when your schema class named "Your::DB::Schema",
Loader considers "Your::DB" as Skinny class.

load_schema execute install_table for all tables.
set pk and columns automatically.

see also C<how loader find primary keys>, C<additional settings for load_schema> section.

=head2 make_schema_at( $schema_class, $options, $connect_info )

return schema file content.
you can use make_schema_as an imported function.

  use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
  print make_schema_at(
      'Your::DB::Schema',
      {
        # options here
      },
      [ 'dbi:SQLite:test.db', '', '' ]
  );

$schema_class is schema class name that you want publish.

$options detail in C<options of make_schema_st> section.

$connect_info is arrayref of dsn, username, password to connect DB.

=head1 how loader find primary keys

surely primary key defined at DB, use it as PK.

in case of primary key is not defined at DB, Loader find PK following logic.
1. if table has only one column, use it
2. if table has column 'id', use it

unless found PK yet, Loader throws exception.

Loader throws exception when PK is composite key.
DBIx::Skinny is not support composite primary key.

=head1 additional settings for load_schema

if you want to use additional settings, write like it

  package Your::DB::Schema;
  use base qw/DBIx::Skinny::Schema::Loader/;

  use DBIx::Skinny::Schema;  # import schema functions

  install_utf8_columns qw/title content/;

  install_table books => schema {
    trigger pre_insert => sub {
      my ($class, $args) = @_;
      $args->{ created_at } ||= DateTime->now;
    };
  };

  __PACKAGE__->load_schema;

  1;

'use DBIx::Skinny::Schema' works to import schema functions.
you can write instead of it, 'BEGIN { DBIx::Skinny::Schema->import }'
because 'require DBIx::Skinny::Schema' was done by Schema::Loader.

You may worry call install_table without pk and columns doesn't work.
Don't worry, DBIx::Skinny allows call install_table twice or more.

=head1 options of make_schema_st

=head2 template

insert your custom template.

  my $tmpl = << '...';
  install_utf8_columns qw/title content/;

  install_table books => schema {
    trigger pre_insert => sub {
      my ($class, $args) = @_;
      $args->{ created_at } ||= DateTime->now;
    }
  }
  ...

  print make_schema_at(
      'Your::DB::Schema',
      {
          template => $tmpl,
      },
      [ 'dbi:SQLite:test.db', '', '' ]
  );

=head1 AUTHOR

Ryo Miyake E<lt>ryo.studiom {at} gmail.comE<gt>

=head1 SEE ALSO

DBIx::Skinny, DBIx::Class::Schema::Loader

=head1 AUTHOR

Ryo Miyake  C<< <ryo.studiom@gmail.com> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
