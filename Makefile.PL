use inc::Module::Install;
name 'DBIx-Skinny-Schema-Loader';
all_from 'lib/DBIx/Skinny/Schema/Loader.pm';

requires 'Any::Moose';
requires 'Exporter';
requires 'DBI';
requires 'DBI::Skinny';
requires 'DBI::Skinny::Schema';
requires 'Text::MicroTemplate';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
