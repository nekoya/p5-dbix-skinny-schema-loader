package Mock::NoSetup;
use DBIx::Skinny;

package Mock::NoSetup::Schema;
use base qw/DBIx::Skinny::Schema::Loader/;

1;
