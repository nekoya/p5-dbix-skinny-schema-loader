package Mock::DB;

use DBIx::Skinny connect_info => +{
    dsn => 'dbi:SQLite:test.db',
    username => '',
    password => '',
};

1;
