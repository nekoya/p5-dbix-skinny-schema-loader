package Mock::MySQLDummy;

use DBIx::Skinny connect_info => +{
    dsn => 'dbi:mysql:testdatabase',
    username => 'user',
    password => 'passwd',
};

package Mock::MySQLDummy::Schema;
use base qw/DBIx::Skinny::Schema::Loader/;

1;
