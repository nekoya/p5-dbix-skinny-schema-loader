use inc::Module::Install;
name 'DBIx-Skinny-Schema-Loader';
all_from 'lib/DBIx/Skinny/Schema/Loader.pm';

requires 'Exporter';
requires 'DBI';
requires 'DBIx::Skinny';
requires 'DBIx::Skinny::Schema';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
