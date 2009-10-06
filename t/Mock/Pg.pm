package Mock::Pg;
use base qw/Class::Data::Inheritable/;

__PACKAGE__->mk_classdata('dbh');

sub setup_test_db {
    my $self = shift;
    return unless $self->dbh;
    my @statements = (
        qq{
            CREATE TABLE books (
                id         serial primary key,
                author_id  int,
                name       varchar(255)
            )
        },
        qq{
            CREATE TABLE authors (
                id           int,
                gender_name  varchar(255),
                pref_name    varchar(255),
                name         varchar(255)
            )
        },
        qq{
            CREATE TABLE genders (
                name  varchar(255)
            )
        },
        qq{
            CREATE TABLE prefectures (
                id    int,
                name  varchar(255) primary key
            )
        }
    );
    $self->dbh->do($_) for @statements;
}

sub clean_test_db {
    my $self = shift;
    return unless $self->dbh;
    my @statements = (
        q{ DROP TABLE prefectures },
        q{ DROP TABLE genders },
        q{ DROP TABLE authors },
        q{ DROP TABLE books },
    );
    $self->dbh->do($_) for @statements;
}

1;
