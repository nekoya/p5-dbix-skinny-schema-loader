package Mock::Additional;

use DBIx::Skinny connect_info => +{
    dsn => 'dbi:SQLite:test.db',
    username => '',
    password => '',
};

1;
