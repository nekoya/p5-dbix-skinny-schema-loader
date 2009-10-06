package Mock::Additional;

use DBIx::Skinny setup => +{
    dsn => 'dbi:SQLite:test.db',
    username => '',
    password => '',
};

1;
