use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(map { split /[\s\:\-]/ } <DATA>);
set_spell_cmd("aspell -l en list") if `which aspell`;
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');
__DATA__
DBIx::Skinny::Schema::Loader
Ryo
Miyake
PostgreSQL
SQLite
dsn
username
deplicated
