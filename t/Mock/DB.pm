package Mock::DB;

use DBIx::Skinny setup => +{
    dsn => 'dbi:SQLite:test.db',
    username => '',
    password => '',
};

1;
