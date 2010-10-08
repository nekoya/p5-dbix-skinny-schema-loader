package Mock::Pg;
use DBIx::Skinny setup => +{};

sub setup_test_db {
    my $self = shift;
    my @statements = (
        q{
            CREATE TABLE books (
                id         serial primary key,
                author_id  int,
                name       varchar(255)
            )
        },
        q{
            CREATE TABLE authors (
                id           int,
                gender_name  varchar(255),
                pref_name    varchar(255),
                name         varchar(255)
            )
        },
        q{
            CREATE TABLE genders (
                name  varchar(255)
            )
        },
        q{
            CREATE TABLE prefectures (
                id    int,
                name  varchar(255) primary key
            )
        },
        q{
            CREATE TABLE composite (
                id   int,
                name varchar(255),
                primary key (id, name)
            )
        },
        q{
            CREATE TABLE no_pk (
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
        q{ DROP TABLE IF EXISTS no_pk },
        q{ DROP TABLE IF EXISTS composite },
        q{ DROP TABLE IF EXISTS prefectures },
        q{ DROP TABLE IF EXISTS genders },
        q{ DROP TABLE IF EXISTS authors },
        q{ DROP TABLE IF EXISTS books },
    );
    $self->do($_) for @statements;
}

1;
