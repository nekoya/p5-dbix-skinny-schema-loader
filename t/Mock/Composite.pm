package Mock::Composite;

use DBIx::Skinny connect_info => +{
    dsn => 'dbi:SQLite:test.db',
    username => '',
    password => '',
};

package Mock::Composite::Schema;
use base qw/DBIx::Skinny::Schema::Loader/;

__PACKAGE__->load_schema;

1;
