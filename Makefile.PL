use inc::Module::Install;
name 'KillerPass';
all_from 'lib/KillerPass.pm';

requires 'YAML::Tiny';
requires 'Config::Pit';
requires 'Plack';
requires 'Starlet';
requires 'Server::Starter';
requires 'IO::Interface::Simple';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
