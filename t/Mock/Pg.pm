package Mock::Pg;
use DBIx::Skinny connect_info => +{};

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
        q{ DROP TABLE no_pk },
        q{ DROP TABLE composite },
        q{ DROP TABLE prefectures },
        q{ DROP TABLE genders },
        q{ DROP TABLE authors },
        q{ DROP TABLE books },
    );
    $self->do($_) for @statements;
}

1;
