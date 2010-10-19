use inc::Module::Install;
name 'DBIx-Skinny-Schema-Loader';
all_from 'lib/DBIx/Skinny/Schema/Loader.pm';

requires 'Exporter';
requires 'DBIx::Skinny' => '0.0714'; # required this version for "pk qw/composite key/;"
requires 'Time::Piece';

author_tests('xt');

test_requires 'Class::Data::Inheritable';
test_requires 'DBD::SQLite';
test_requires 'Test::More';
test_requires 'Test::Exception';
include 'Sub::Uplevel';

use_test_base;
auto_include;
WriteAll;
