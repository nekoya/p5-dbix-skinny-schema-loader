package Mock::MySQL;
use DBIx::Skinny connect_info => +{};

sub setup_test_db {
    my $self = shift;
    $self->clean_test_db;
    my @statements = (
        q{
            CREATE TABLE books (
                id         int not null auto_increment primary key,
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
                id      int,
                name    varchar(255),
                primary key (id, name)
            )
        },
        q{
            CREATE TABLE no_pk (
                code int,
                name varchar(255)
            )
        },
        q{ INSERT INTO books VALUES (1, 1, 'mysql') },
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
