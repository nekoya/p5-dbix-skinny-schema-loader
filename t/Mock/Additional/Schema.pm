package Mock::Additional::Schema;
use base qw/DBIx::Skinny::Schema::Loader/;

use DBIx::Skinny::Schema;
#BEGIN { DBIx::Skinny::Schema->import }

install_table books => schema {
    trigger pre_insert => sub {
        my ($class, $args) = @_;
        $args->{ name } = 'HOGE';
    }
};

__PACKAGE__->load_schema();

1;
