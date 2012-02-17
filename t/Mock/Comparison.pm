package Mock::Comparison;
use DBIx::Skinny;

package Mock::Comparison::Schema;
use DBIx::Skinny::Schema;

install_table books => schema {
    pk qw/id/;
    columns qw/id author_id name/;
};

install_table authors => schema {
    pk qw//;
    columns qw/id gender_name pref_name name/;
};

install_table genders => schema {
    pk qw//;
    columns qw/name/;
};

install_table prefectures => schema {
    pk qw/name/;
    columns qw/id name/;
};

install_table composite => schema {
    pk qw/id name/;
    columns qw/id name/;
};

install_table no_pk => schema {
    pk qw//;
    columns qw/code name/;
};

1;
