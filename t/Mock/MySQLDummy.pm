package Mock::MySQLDummy;

use DBIx::Skinny setup => +{
    dsn => 'dbi:mysql:testdatabase',
    username => 'user',
    password => 'passwd',
};

package Mock::MySQLDummy::Schema;
use base qw/DBIx::Skinny::Schema::Loader/;

1;
