package Mock::Pg::Schema;
use DBIx::Skinny setup => +{};

sub setup_test_db {
    my $self = shift;
    my @statements = (
        q{
            CREATE SCHEMA foo
        },
        q{
            CREATE SCHEMA bar
        },
        q{
            CREATE TABLE foo.books (
                id         serial primary key,
                author_id  int,
                name       varchar(255)
            )
        },
        q{
            CREATE TABLE foo.authors (
                id           int,
                gender_name  varchar(255),
                pref_name    varchar(255),
                name         varchar(255)
            )
        },
        q{
            CREATE TABLE bar.genders (
                name  varchar(255)
            )
        },
        q{
            CREATE TABLE bar.prefectures (
                id    int,
                name  varchar(255) primary key
            )
        },
        q{
            CREATE TABLE foo.composite (
                id   int,
                name varchar(255),
                primary key (id, name)
            )
        },
        q{
            CREATE TABLE bar.no_pk (
                code int,
                name varchar(255)
            )
        },
    );
    $self->do($_) for @statements;
}

sub clean_test_db {
    my $self = shift;
    my @statements = (
        q{ DROP TABLE foo.authors },
        q{ DROP TABLE foo.books },
        q{ DROP TABLE foo.composite },
        q{ DROP TABLE bar.genders },
        q{ DROP TABLE bar.no_pk },
        q{ DROP TABLE bar.prefectures },
        q{ DROP SCHEMA foo },
        q{ DROP SCHEMA bar }
    );
    $self->do($_) for @statements;
}

1;
