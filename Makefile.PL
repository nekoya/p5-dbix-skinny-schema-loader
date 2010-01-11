use inc::Module::Install;
name 'DBIx-Skinny-Schema-Loader';
all_from 'lib/DBIx/Skinny/Schema/Loader.pm';

requires 'Exporter';
requires 'DBIx::Skinny' => '0.05';
requires 'DBD::SQLite';

author_tests('xt');

test_requires 'Class::Data::Inheritable';
test_requires 'Test::More';
test_requires 'Test::Exception';
include 'Sub::Uplevel';

use_test_base;
auto_include;
WriteAll;
