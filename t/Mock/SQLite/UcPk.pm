package Mock::SQLite::UcPk;
use base qw/Mock::SQLite/;

__PACKAGE__->mk_classdata('dbh');

sub setup_test_db {
    my $self = shift;
    return unless $self->dbh;
    my @statements = (
        q{
            CREATE TABLE books (
                ID         INTEGER PRIMARY KEY AUTOINCREMENT,
                author_id  INT,
                name       TEXT
            )
        },
        q{
            CREATE TABLE authors (
                ID           INT,
                gender_name  TEXT,
                pref_name    TEXT,
                name         TEXT
            )
        },
        q{
            CREATE TABLE genders (
                name  TEXT
            )
        },
        q{
            CREATE TABLE prefectures (
                ID    INT,
                name  TEXT PRIMARY KEY
            )
        },
        q{
            CREATE TABLE composite (
                    ID   int,
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

        q{ INSERT INTO books VALUES (1, 1, 'book1') },
    );
    $self->dbh->do($_) for @statements;
}

1;
